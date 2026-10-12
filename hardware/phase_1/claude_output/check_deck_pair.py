#!/usr/bin/env python3
"""
check_deck_pair.py - verify two deck halves are a MIRROR PAIR, not two copies.

WHY THIS EXISTS
---------------
Aug 14 2026. deck_top_L applied mirror([1,0,0]) to centre the left half on the origin.
It centred it, and it also flipped the part's handedness: the exported STL was the mirror
image of the left half and could not be assembled with the right one. Cost an 8-hour print.

It survived undetected for months because IT IS INVISIBLE ON A Y-SYMMETRIC PART. Every
hole in both decks mirrors about Y=-85 - leg cutouts at 0/-170, battery bolts, side-box
bolts, sonar inserts - so a mirrored half rotated 180 degrees still bolts up perfectly.
The bottom decks genuinely were fine. The top deck only became able to show the fault when
the Jul 2026 clip layout broke Y-symmetry.

It also survived my own STL checker, which un-mirrored the export before comparing it to
the model. That validated the MODEL and was structurally blind to the PART. Same mistake as
everywhere else in that investigation: a control that shares the property being tested.

WHAT IT CHECKS
--------------
The alignment stubs. The right half carries 5mm pins projecting from its split face; the
left half carries the matching blind holes. In a correct pair those features sit on
OPPOSITE sides of each part. In a mirrored pair they sit on the same side - which is the
whole fault, reduced to one comparison.

    python check_deck_pair.py top_deck_r.stl top_deck_l.stl

Works for the bottom decks too, and would have caught this in under a second.
"""

import struct, sys, os, datetime


def load(path):
    raw = open(path, "rb").read()
    if raw[:5].lower() == b"solid" and b"facet" in raw[:2000]:
        v = []
        for line in raw.decode("utf-8", "replace").splitlines():
            if line.strip().startswith("vertex"):
                v.append(tuple(float(x) for x in line.split()[1:4]))
        return v
    n = struct.unpack("<I", raw[80:84])[0]
    off, v = 84, []
    for _ in range(n):
        d = struct.unpack("<12fH", raw[off:off+50])
        for k in (3, 6, 9):
            v.append((d[k], d[k+1], d[k+2]))
        off += 50
    return v


def stub_side(verts, plate_mid_z, ylevels, tol=6.0):
    """Mean X of the alignment-stub features, which live at mid-plate height on the split
    face at two Y stations. Sign of that X says which edge of the part the split is on."""
    xs = []
    for v in verts:
        if abs(v[2] - plate_mid_z) > tol:
            continue
        if min(abs(v[1] - y) for y in ylevels) > tol:
            continue
        xs.append(v[0])
    return (sum(xs) / len(xs), len(xs)) if xs else (None, 0)


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    a, b = sys.argv[1], sys.argv[2]
    va, vb = load(a), load(b)

    # STALENESS FIRST. A stale export answers a question about the file you last wrote,
    # not the file you have. This project has lost prints to it more than once, and the
    # handedness fix in particular is invisible until the STL is regenerated.
    scad = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(a))),
                        "chassis_v3.scad")
    if not os.path.exists(scad):
        scad = "chassis_v3.scad"
    stale = []
    if os.path.exists(scad):
        for f in (a, b):
            if os.path.getmtime(f) < os.path.getmtime(scad):
                stale.append(f)
    fmt = lambda t: datetime.datetime.fromtimestamp(t).strftime("%m-%d %H:%M:%S")
    if stale:
        print("STALE EXPORT - these are older than chassis_v3.scad (%s):"
              % fmt(os.path.getmtime(scad)))
        for f in stale:
            print("   %-20s %s" % (os.path.basename(f), fmt(os.path.getmtime(f))))
        print("Re-export before trusting anything below.")
        print()

    for name, v in ((a, va), (b, vb)):
        zs = [p[2] for p in v]
        print("%-18s  X %8.2f..%8.2f   Z %6.2f..%6.2f"
              % (os.path.basename(name), min(p[0] for p in v), max(p[0] for p in v),
                 min(zs), max(zs)))

    # plate mid-height: decks sit with their underside at z=0 and are PLATE_THICKNESS thick
    midz = 4.0
    ylev = (85.0, -85.0)          # ALIGN_STUB_YF / YR carried into the export frame
    xa, na = stub_side(va, midz, ylev)
    xb, nb = stub_side(vb, midz, ylev)

    print()
    if xa is None or xb is None:
        print("could not locate alignment stub features (%d / %d verts matched)" % (na, nb))
        return 2
    print("%-18s  stub features at mean X %+8.2f  (%d verts)" % ("half A", xa, na))
    print("%-18s  stub features at mean X %+8.2f  (%d verts)" % ("half B", xb, nb))

    print()
    if xa * xb < 0:
        if stale:
            print("split faces are on opposite sides, but AT LEAST ONE EXPORT IS STALE -")
            print("re-export and re-run before believing this.")
            return 1
        print("PASS - split faces are on OPPOSITE sides. These are a mirror pair.")
        return 0
    print("FAIL - both split faces are on the SAME side. These are two copies of the same")
    print("       handedness, not a mirror pair. One half is mirrored and will not assemble")
    print("       with the other. Check for mirror([1,0,0]) in the export view.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
