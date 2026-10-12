"""
check_stl.py — verify an exported STL against the current chassis_v3.scad parameters.

Written after two coupons in a row were printed from stale exports: the SCAD said one
thing, the STL on disk said another, and the only way it surfaced was measuring the
printed part with calipers. This reads the parameters straight out of the SCAD, measures
the same features out of the binary STL, and reports any disagreement.

Usage:
    python check_stl.py                       # defaults to camera_bar_fit.stl
    python check_stl.py path\\to\\other.stl

Run it after every export, before slicing.
"""

import os
import re
import struct
import sys

SCAD = r"C:\dev\ai\hardware\phase_1\chassis_v3.scad"
DEFAULT_STL = r"C:\dev\ai\hardware\phase_1\camera_bar_fit.stl"
# mm. Must stay WELL BELOW the smallest parameter step we work in (0.05), or a
# one-step-stale export reads as a pass — which is exactly what happened on
# 2026-08-06 with TOL=0.05: a 0.05 hole change had already been made in the SCAD
# and the old STL still reported "ok". The STL is exact geometry; the only honest
# error is tessellation on curved features, measured at ~0.006. 0.02 clears that
# with room to spare and still fails a single step.
TOL = 0.02


# ---------------------------------------------------------------- SCAD params
def scad_params(path):
    """Pull top-level numeric assignments. Handles plain numbers and NAME + n."""
    txt = open(path, encoding="utf-8", errors="replace").read()
    vals = {}
    for name, expr in re.findall(r"^([A-Z][A-Z0-9_]*)\s*=\s*([^;]+);", txt, re.M):
        expr = expr.split("//")[0].strip()
        if re.fullmatch(r"-?\d+(\.\d+)?", expr):
            vals[name] = float(expr)
        else:
            m = re.fullmatch(r"([A-Z][A-Z0-9_]*)\s*([+-])\s*(\d+(?:\.\d+)?)", expr)
            if m and m.group(1) in vals:
                base = vals[m.group(1)]
                vals[name] = base + float(m.group(3)) * (1 if m.group(2) == "+" else -1)
    return vals


# ----------------------------------------------------------------- STL loader
def load_verts(path):
    with open(path, "rb") as f:
        head = f.read(84)
        ntri = struct.unpack("<I", head[80:84])[0]
        body = f.read(ntri * 50)
    if len(body) < ntri * 50:
        raise SystemExit("truncated STL, or it is ASCII rather than binary")
    out = []
    for i in range(ntri):
        o = i * 50 + 12
        for v in range(3):
            out.append(struct.unpack("<3f", body[o + v * 12: o + v * 12 + 12]))
    return ntri, out


def print_rotation(path):
    """The print_camera_bar view rotates the bar to fit the bed diagonally. Read the
    angle out of the SCAD so this stays in sync if it is ever retuned."""
    txt = open(path, encoding="utf-8", errors="replace").read()
    i = txt.find('VIEW == "print_camera_bar"')
    if i < 0:
        return 0.0
    m = re.search(r"rotate\(\[\s*0\s*,\s*0\s*,\s*(-?\d+(?:\.\d+)?)\s*\]\)", txt[i:i + 400])
    return float(m.group(1)) if m else 0.0


def unrotate(verts, deg):
    """Undo a Z rotation so the feature windows line up with model coordinates."""
    import math
    a = math.radians(-deg)
    ca, sa = math.cos(a), math.sin(a)
    return [(v[0] * ca - v[1] * sa, v[0] * sa + v[1] * ca, v[2]) for v in verts]


def span_at_z(verts, z, xlo, xhi, band=0.02):
    """Full X span of vertices sitting in a thin Z band and an X window."""
    xs = [v[0] for v in verts if abs(v[2] - z) <= band and xlo <= v[0] <= xhi]
    return (min(xs), max(xs)) if xs else None


def widest_gap(verts, z, xlo, xhi, band=0.20):
    """Largest run between consecutive X values — the open centre between two walls."""
    xs = sorted(v[0] for v in verts if abs(v[2] - z) <= band and xlo <= v[0] <= xhi)
    if len(xs) < 2:
        return None
    best, at = 0.0, None
    for a, b in zip(xs, xs[1:]):
        if b - a > best:
            best, at = b - a, (a, b)
    return at


# --------------------------------------------------------------------- report
def check(label, measured, expected):
    if measured is None:
        print("  {0:<34} NOT FOUND (expected {1:.3f})".format(label, expected))
        return False
    d = measured - expected
    ok = abs(d) <= TOL
    print("  {0:<34} {1:8.3f}   expected {2:8.3f}   {3:+.3f}  {4}".format(
        label, measured, expected, d, "ok" if ok else "<-- MISMATCH"))
    return ok


def main():
    stl = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_STL
    p = scad_params(SCAD)

    ntri, verts = load_verts(stl)

    # print_camera_bar exports the full bar rotated to fit the bed. Detect that by
    # comparing the X extent against the model's own, and un-rotate before measuring
    # — otherwise every feature window looks in the wrong place and reports NOT FOUND.
    bar_half_expect = (p["STRUT_X"] + p["CAM_BAR_HOLE_D"] + 2 * p["BAR_HOLE_WALL"]) / 2
    rot = print_rotation(SCAD)
    rotated = rot and abs(max(v[0] for v in verts) - bar_half_expect) > TOL
    if rotated:
        verts = unrotate(verts, rot)
        print("       (un-rotated {0:g} deg to match model coordinates - this is a "
              "print_camera_bar export)".format(rot))

    xs = [v[0] for v in verts]

    print("STL  : {0}".format(stl))
    print("       {0} triangles, modified {1}".format(
        ntri, __import__("time").strftime("%Y-%m-%d %H:%M", __import__("time").localtime(os.path.getmtime(stl)))))
    print("SCAD : modified {0}".format(
        __import__("time").strftime("%Y-%m-%d %H:%M", __import__("time").localtime(os.path.getmtime(SCAD)))))
    stale = os.path.getmtime(stl) < os.path.getmtime(SCAD)
    if stale:
        print("       ** STL IS OLDER THAN THE SCAD - re-export before trusting anything below **")
    print()

    bar_t = p["BAR_THICKNESS"]
    usb_cx = p["CAM_BASELINE"] / 4          # CAM_USB_MIC_CX
    cam_cx = p["CAM_BASELINE"] / 2
    hole_cx = p["STRUT_X"] / 2
    hole_d = p["CAM_BAR_HOLE_D"]

    results = []
    print("USB shell clip (centre X {0:.1f}):".format(usb_cx))
    # cavity is widest CAM_USB_L/2 above the bar; the outer wall is flat so its
    # only vertices are at the very top of the wall
    g = widest_gap(verts, bar_t + p["CAM_USB_L"] / 2, usb_cx - 15, usb_cx + 15)
    cav = (g[1] - g[0]) if g else None
    results.append(check("cavity max width", cav, p["CAM_USB_W"] + 2 * p["CAM_USB_CLR"]))

    s = span_at_z(verts, bar_t + p["CAM_USB_WALL_H"], usb_cx - 15, usb_cx + 15)
    outer = (s[1] - s[0]) if s else None
    results.append(check("outer span at rim", outer,
                         p["CAM_USB_W"] + 2 * p["CAM_USB_CLR"] + 2 * p["CAM_USB_CLIP_T"]))

    print("\nCamera housing (centre X {0:.1f}):".format(cam_cx))
    s = span_at_z(verts, p["CAM_LENS_Z"] - p["CAM_LENS_D"] / 2, cam_cx - 15, cam_cx + 15)
    lens = (s[1] - s[0]) if s else None
    results.append(check("lens opening width", lens, p["CAM_LENS_W"]))

    # Board slot: a cube cut, so its only vertices are at the top and bottom faces.
    # Sample the floor (z=2) and read the Y gap between the slot's two walls.
    ys = sorted(v[1] for v in verts
                if abs(v[2] - 2.0) <= 0.02 and abs(v[0] - cam_cx) <= p["CAM_PCB_W"] / 2 + 1)
    slot = None
    if len(ys) >= 2:
        slot = max(ys) - min(ys)
    results.append(check("board slot thickness", slot, p["CAM_SLOT_W"]))

    # Slot WIDTH is a separate parameter (CAM_PCB_W) and is the one that actually
    # binds the board. Measure it at the slot floor, same z=2 band.
    sxs = sorted(v[0] for v in verts
                 if abs(v[2] - 2.0) <= 0.02 and abs(v[0] - cam_cx) <= p["CAM_HOUSING_W"] / 2)
    results.append(check("board slot width", (max(sxs) - min(sxs)) if sxs else None,
                         p["CAM_PCB_W"]))

    print("\nLeg post hole (centre X {0:.1f}):".format(hole_cx))
    w = hole_d / 2 + 2
    s = span_at_z(verts, 0.0, hole_cx - w, hole_cx + w)
    dia = (s[1] - s[0]) if s else None
    results.append(check("hole diameter", dia, hole_d))

    print("\nOverall:")
    bar_half = (p["STRUT_X"] + hole_d + 2 * p["BAR_HOLE_WALL"]) / 2
    results.append(check("bar end (max X)", max(xs), bar_half))

    print()
    if stale:
        # A stale file can still measure "ok" on every feature that did not change.
        # The timestamp alone is grounds for failure - do not let the dimensions
        # that happen to match vouch for the ones that do not.
        print("FAIL - STL predates the SCAD. Re-export from OpenSCAD and run this again.")
        sys.exit(1)
    elif all(results):
        print("PASS - the STL matches every parameter currently in chassis_v3.scad")
    else:
        print("FAIL - see MISMATCH above. Re-export from OpenSCAD and run this again.")
        sys.exit(1)


if __name__ == "__main__":
    main()
