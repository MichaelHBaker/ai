#!/usr/bin/env python3
"""
layer_regime.py - find where a part crosses its slicer's cooling thresholds.

WHY THIS EXISTS
---------------
Aug 2026: every clip sheared off top_deck_r at a touch, with no residue. Four hours of
print wasted, and several days of diagnosis, because of a property that was visible
before printing and that nobody thought to look at.

A deck half is 132x210mm and 8mm thick, with four small clips standing on top of it.
Its body layers take MINUTES. Its clip layers take SECONDS. Every cooling threshold in a
print profile is a single number sitting somewhere between those two, which means:

    the body and the clips print under completely different cooling regimes,
    and the profile's name tells you nothing about it.

PrusaSlicer's logic, per layer:
    layer_time < slowdown_below_layer_time  ->  slow down toward min_print_speed
    layer_time < fan_below_layer_time       ->  fan ramps from min_fan_speed to max_fan_speed

So on a part like this the big flat body always prints at MIN fan and looks perfect,
while the small features on top may be the only geometry in the whole job that ever
reaches MAX fan. A print can be flawless everywhere you would normally inspect it and
still have almost no bond where the small features meet the body.

That is a property of geometry meeting profile. It is computable. This computes it.

WHAT IT DOES
------------
Slices the STL mathematically (no slicer needed), estimates per-layer extrusion time,
and reports which cooling regime each band of layers falls into - BEFORE you print.

    python layer_regime.py <model.stl> [--bundle b.ini] [--print P] [--filament F]

HOW TO READ THE OUTPUT
----------------------
The absolute times are estimates, +/-50%. Do not tune anything on them. What matters is:

  1. THE RATIO between bands. A 100x step between adjacent bands is the danger signal,
     and no estimation error hides that.
  2. WHICH SIDE OF EACH THRESHOLD each band lands on, and how close. A band sitting just
     above a threshold at 1.2x is a band that may cross it on the real slicer.

The tool tells you which regime each part of the geometry is in. It does NOT tell you
what cooling that material needs - that is materials knowledge, or your own record of
what has worked. See the CLIP ROOT ADHESION FAILURE section in chassis_v3.scad.

WHAT IT DELIBERATELY DOES NOT MODEL
-----------------------------------
Acceleration, travel moves, retraction, minimum-layer-time slowdown feeding back into
its own estimate, per-region solid/sparse classification (it uses a global top/bottom
rule), variable extrusion width, gap fill, ironing, and supports. Every one of those
pushes small-island layers SLOWER, i.e. further into the danger regime - so this tool
is optimistic about small features, never the reverse. If it flags a band, believe it.
"""

import argparse, io, math, os, struct, sys


# ---------------------------------------------------------------- mesh loading
def load_stl(path):
    raw = open(path, "rb").read()
    tris = []
    if raw[:5].lower() == b"solid" and b"facet" in raw[:2000]:
        vs, ns, n = [], [], None
        for line in raw.decode("utf-8", "replace").splitlines():
            t = line.strip()
            if t.startswith("facet normal"):
                n = tuple(float(x) for x in t.split()[2:5])
            elif t.startswith("vertex"):
                vs.append(tuple(float(x) for x in t.split()[1:4]))
                if len(vs) % 3 == 0:
                    ns.append(n)
        tris = [(ns[i // 3], tuple(vs[i:i+3])) for i in range(0, len(vs), 3)]
    else:
        cnt = struct.unpack("<I", raw[80:84])[0]
        off = 84
        for _ in range(cnt):
            d = struct.unpack("<12fH", raw[off:off+50])
            tris.append(((d[0], d[1], d[2]),
                         ((d[3], d[4], d[5]), (d[6], d[7], d[8]), (d[9], d[10], d[11]))))
            off += 50
    return tris


# ------------------------------------------------------- cross-section at z
def section(tris, z):
    """Return (area, boundary_length) of the solid's cross-section at height z.

    Uses oriented segments so the area falls out of the shoelace sum directly - no
    polygon assembly needed. Each triangle contributes one segment, oriented so the
    solid is on the left, which is derived from the facet normal.
    """
    area = 0.0
    length = 0.0
    for n, (a, b, c) in tris:
        pts = []
        for p, q in ((a, b), (b, c), (c, a)):
            if (p[2] - z) * (q[2] - z) < 0:            # strict crossing only
                t = (z - p[2]) / (q[2] - p[2])
                pts.append((p[0] + t * (q[0] - p[0]), p[1] + t * (q[1] - p[1])))
        if len(pts) != 2:
            continue
        (x1, y1), (x2, y2) = pts
        # orient: outward in-plane normal must lie to the right of travel
        dx, dy = n[1], -n[0]
        if (x2 - x1) * dx + (y2 - y1) * dy < 0:
            (x1, y1), (x2, y2) = (x2, y2), (x1, y1)
        area += 0.5 * (x1 * y2 - x2 * y1)
        length += math.hypot(x2 - x1, y2 - y1)
    return abs(area), length


# ---------------------------------------------------------------- config
def read_bundle(path):
    secs, cur = {}, None
    for line in io.open(path, encoding="utf-8"):
        line = line.strip()
        if line.startswith("["):
            cur = line.strip("[]"); secs[cur] = {}
        elif cur and "=" in line and not line.startswith("#"):
            k, v = line.split("=", 1); secs[cur][k.strip()] = v.strip()
    return secs


def num(d, key, default=0.0):
    v = str(d.get(key, default)).strip().strip('"').rstrip("%")
    try: return float(v)
    except ValueError: return float(default)


# ---------------------------------------------------------------- analysis
def analyse(stl, cfg, cool):
    lh   = num(cfg, "layer_height", 0.2)
    flh  = num(cfg, "first_layer_height", lh)
    per  = int(num(cfg, "perimeters", 2))
    w    = num(cfg, "extrusion_width", 0.45) or 0.45
    dens = num(cfg, "fill_density", 15) / 100.0
    tsl  = int(num(cfg, "top_solid_layers", 5))
    bsl  = int(num(cfg, "bottom_solid_layers", 5))
    v_per   = num(cfg, "perimeter_speed", 45)
    v_ext   = num(cfg, "external_perimeter_speed", 25)
    v_inf   = num(cfg, "infill_speed", 80)
    v_solid = num(cfg, "solid_infill_speed", 80)
    v_top   = num(cfg, "top_solid_infill_speed", v_solid)

    tris = load_stl(stl)
    zs = [v[2] for _, t in tris for v in t]
    zmin, zmax = min(zs), max(zs)

    layers, z = [], zmin
    i = 0
    while z < zmax - 1e-9:
        h = flh if i == 0 else lh
        layers.append((i + 1, z, min(z + h, zmax), h))
        z += h; i += 1

    # first pass: cross-sections
    raw = []
    for idx, z0, z1, h in layers:
        area, blen = section(tris, (z0 + z1) / 2.0)
        raw.append((idx, z1, area, blen))
    amap = {r[0]: r[2] for r in raw}

    rows = []
    for idx, z1, area, blen in raw:
        if area <= 0 and blen <= 0:
            continue
        # A layer is TOP SOLID if the section shrinks sharply within tsl layers above it.
        # A global "last N layers" rule is wrong for parts whose real top surface is far
        # below the tallest feature - e.g. a deck whose top face is at layer 40 of 90.
        nxt = [amap.get(idx + k, 0.0) for k in range(1, tsl + 1)]
        solid = idx <= bsl or (nxt and min(nxt) < 0.9 * area)
        # perimeter loops: outer one at external speed, the rest at perimeter speed
        p_out, p_in = blen, blen * max(0, per - 1)
        t = p_out / max(v_ext, 1) + p_in / max(v_per, 1)
        # whatever area the perimeters do not consume gets infilled
        rest = max(0.0, area - per * w * blen)
        f = 1.0 if solid else dens
        path = rest / w * f
        # the final solid layer of a top surface runs at top_solid_infill_speed
        toplayer = solid and amap.get(idx + 1, 0.0) < 0.9 * area
        v = v_top if toplayer else (v_solid if solid else v_inf)
        t += path / max(v, 1)
        rows.append((idx, z1, area, blen, t, solid))
    return rows, cool


def bands(rows, tol=0.35):
    """Group consecutive layers whose estimated time is within tol (log-ish) of each other."""
    out = []
    for r in rows:
        if out and abs(math.log((r[4] + 1e-6) / (out[-1][-1] + 1e-6))) < tol:
            out[-1][1] = r[0]; out[-1][2] = r[1]
            out[-1][3] = min(out[-1][3], r[4]); out[-1][4] = max(out[-1][4], r[4])
            out[-1][5] += 1; out[-1].append(r[4])
        else:
            out.append([r[0], r[0], r[1], r[4], r[4], 1, r[4]])
    return out


def fan_for(t, cool):
    """PrusaSlicer cooling: below fan_below_layer_time the fan ramps min->max."""
    fb  = cool["fan_below_layer_time"]
    sd  = cool["slowdown_below_layer_time"]
    lo, hi = cool["min_fan_speed"], cool["max_fan_speed"]
    if t >= fb:
        return lo, False
    if t <= sd:
        return hi, True
    frac = (fb - t) / max(fb - sd, 1e-9)
    return lo + (hi - lo) * frac, False


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("stl")
    ap.add_argument("--bundle", default="PrusaSlicer_config_bundle.ini")
    ap.add_argument("--print", dest="pp", help="print preset name (substring ok)")
    ap.add_argument("--filament", dest="fp", help="filament preset name (substring ok)")
    a = ap.parse_args()

    secs = read_bundle(a.bundle)
    def find(prefix, want):
        cands = [k for k in secs if k.startswith(prefix)]
        if want:
            m = [k for k in cands if want.lower() in k.lower()]
            if m: return m[0]
        sel = secs.get("presets", {})
        key = sel.get(prefix.rstrip(":"))
        for k in cands:
            if key and k.split(":", 1)[1] == key: return k
        return cands[0] if cands else None

    pk, fk = find("print:", a.pp), find("filament:", a.fp)
    cfg, fil = secs[pk], secs[fk]
    cool = {"fan_below_layer_time":      num(fil, "fan_below_layer_time", 25),
            "slowdown_below_layer_time": num(fil, "slowdown_below_layer_time", 9),
            "min_fan_speed":             num(fil, "min_fan_speed", 30),
            "max_fan_speed":             num(fil, "max_fan_speed", 60)}

    print("part     : %s" % os.path.basename(a.stl))
    print("print    : %s" % pk.split(":", 1)[1])
    print("filament : %s" % fk.split(":", 1)[1])
    print("cooling  : fan ramps below %.0fs, slowdown below %.0fs, fan %.0f%%..%.0f%%\n"
          % (cool["fan_below_layer_time"], cool["slowdown_below_layer_time"],
             cool["min_fan_speed"], cool["max_fan_speed"]))

    rows, cool = analyse(a.stl, cfg, cool)
    if not rows:
        print("no cross-sections found"); return 1

    print("%-14s %9s %11s %9s %8s  %s" %
          ("layers", "Z top", "area mm2", "est time", "fan", "regime"))
    print("-" * 74)
    warn = []
    for b in bands(rows):
        lo, hi, ztop, tmin, tmax, n = b[0], b[1], b[2], b[3], b[4], b[5]
        tmid = (tmin + tmax) / 2
        # representative area for the band
        ar = [r[2] for r in rows if lo <= r[0] <= hi]
        fan, floored = fan_for(tmid, cool)
        tag = "MAX fan" if fan >= cool["max_fan_speed"] - 0.01 else (
              "min fan" if fan <= cool["min_fan_speed"] + 0.01 else "ramping")
        if floored: tag += " + slowed"
        print("%-14s %9.2f %11.0f %7.0fs %7.0f%%  %s" %
              ("%d-%d" % (lo, hi) if hi > lo else str(lo),
               ztop, sum(ar) / len(ar), tmid, fan, tag))
        if fan > cool["min_fan_speed"] + 0.01:
            warn.append((lo, hi, tmid, fan))

    print()
    if warn:
        print("!! %d band(s) print with elevated cooling while the rest of the part does not."
              % len(warn))
        for lo, hi, t, f in warn:
            print("   layers %d-%d at ~%.0fs/layer -> %.0f%% fan (part baseline %.0f%%)"
                  % (lo, hi, t, f, cool["min_fan_speed"]))
        print("   On PETG this is where small features fail to weld to the body beneath them.")
        print("   Compare against a profile whose max_fan_speed you have already proven.")
    else:
        print("OK - every layer sits on the same side of the cooling thresholds.")
        print("   No regime split. Whatever the profile does, it does uniformly.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
