# Trapezoidal Keycap Rendering Fixes

## Background

The Go60 keyboard (and similar boards) has splayed thumb keys arranged on a circular arc.
Standard rectangular keycaps leave wedge-shaped gaps between these arc-positioned keys.
The trapezoidal sector-shaped keycaps fill these gaps with footprints that follow the arc
geometry — wider on the outer edge, narrower on the inner edge, with arced outer/inner
edges. See README.md section 3.1.8 and `go60_visualization.scad` for full context.

## The Three Keys

| Key | keyID | Dish Type | Shape | Notes |
|-----|-------|-----------|-------|-------|
| T1  | 2     | convex    | Asymmetric sector, left edge aligned to C1 column | Uses `left_line` + `depth_ratio` |
| T2  | 0     | convex    | Symmetric 1.25u sector | Simplest case |
| T3  | 1     | thumb     | Symmetric 1.25u sector with scoop dish | XSkew=-3, YSkew=-3 |

## Current State: ALL KEYS WORKING

All three keys render cleanly: `Simple: yes`, `Volumes: 2` (CGAL validated).
Sharp sector corners, visible dome curvature, no artifacts.

### Architecture: Oversized smooth body + sector trim

```
intersection() {
    (oversized_elliptical_rectangle_body - inner + stem) - dish_cut,
    sector_rectangle_skin  // trim to sector footprint
}
```

- Oversized smooth body (+8mm per dimension) ensures the dish boolean operates on
  smooth surfaces only — no dish-corner artifacts.
- Sector trim (skin of sector_rectangle cross-sections) clips to the exact sector
  footprint with sharp corners (fillet=0).
- The dish only touches smooth geometry; the sector only clips smooth results.

### Convex dish parameters (T1, T2)

```
FFwd=8+6, arcs=10.5→13, BFwd=7+5, arcs=10.5→13
```

Key insight: the dish arc **widens along the sweep** (FArcIn=10.5, FArcFn=13.0).
- At the center (arc=10.5): tight enough for visible dome curvature on the narrow
  sector footprint (~0.15mm height variation from center to edge at top).
- At the far ends (arc=13.0): wide enough to cover all sector corners, including
  T1's extended right side (depth_ratio 10/9 pushes corner to ~10mm).

The front sweep is longer (8+6=14mm) than the back (7+5=12mm) because T1's
depth_ratio extends the front/outer side further.

### Thumb dish parameters (T3)

```
FFwd=9+7, arcs=20/24, BFwd=9+5.5, arcs=20/24
```

Fully extended to cover the skew-raised corners (XSkew=-3, YSkew=-3). With
reference-like front params, a bump appeared at the rear-left corner where the
raised sector surface exceeded the scoop depth. The extended params eliminate this.

### Corner chamfers: NOT NEEDED

Chamfers (fillet parameter in sector_rectangle) are not needed. Setting fillet=0
produces clean renders for all three keys with the current dish parameters. The
oversized body + extended dish approach handles corners without chamfers.

## Issues Found and Fixed (all committed)

### 1. DishShape function was wrong
The `DishShape()` function used `rot1=90, rot2=270` (left half of ellipse, no extensions).
Fixed to match convex file: `rot1=270, rot2=450` with extension points.

### 2. Convex back trajectory direction was wrong
`_cx_dish_cut()` used `trajectory(backward=...)` for the back path. Fixed to use
`trajectory(forward=...)` — the 270° Z rotation already reverses direction.

### 3. Convex dish forward distances were too short
Original values from R3x 1.25u (BotLen=15.6mm). Increased for trap keys (BotLen=18-20mm).

### 4. Cross-section point density was too low
`sector_rectangle()` used `n = max(4, fn/4)` = 15 points per edge. Changed to `n = fn`
to match elliptical_rectangle density and avoid nonplanar face issues.

### 5. Dish-corner artifacts (the main challenge)
The dish sweep exiting through sector corners created spikes/notches. Solved with the
oversized smooth body approach (dish operates on smooth body, sector trim clips result).

### 6. Chamfered corners
Initial fix used fillet=0.5 chamfers. Removed (fillet=0) once dish params were tuned.

### 7. Flat dome curvature
Extended arcs (14/14.5) made the dome invisible on the narrow sector. Fixed with
arc gradient (10.5→13) that provides curvature at center and coverage at edges.

### 8. T1 right corner spike
T1's depth_ratio 10/9 extends the right side to ~10mm. Required generous front sweep
(8+6=14mm) and widening arcs (→13) to cover the extended corner.

## Approaches Tried and Rejected

1. **Reduced dish arc sizes**: Made dome too narrow.
2. **Clip dish with hull()**: Created flat cuts on top surface.
3. **Clip dish with skin() of sectors**: Nonplanar face artifacts.
4. **Curved side edges (bulge)**: Didn't fix corners, changed aesthetics.
5. **Sector body + dish mask architecture**: Boolean subtraction of inner shell from
   sector body created non-manifold geometry (Simple: no). The inner shell's smooth
   surface tangentially meets the sector body's faceted surface.
6. **Tight arcs (6.5/7.5)**: Created large pyramid artifacts — dome didn't cover sector
   at intermediate heights where sector is wider than the dome arc.
7. **Reference-like thumb front params**: Created bump at rear-left corner where
   skew-raised sector surface exceeded scoop depth.

## Remaining Minor Issues

T1 (v1, keyID 2) and T1 v2 (keyID 3) both have a tiny notch at the outer-right
corner (visible from the side, at the base). Root cause: the `left_line` parameter
creates an asymmetric sector polygon whose skin() between layers produces a small
artifact at the right corner. Confirmed by disabling left_line → notch disappears.
NOT a dish coverage issue (persists even with arc=20, sweep=14, pitch=0, oversize=+14).
Considered acceptable — not visible from the top/typing perspective.

## V2 Thumb Row (WIP)

### Goal
Remove T1's curvature change (arc gradient 10.5→13) by making T1 symmetric
(BotLen=20, depth_ratio=[1,1], uniform arc). Extend straight R5 keys (C4R5,
C3R5, C2R5) downward so their bottoms form a horizontal line at y=-57, meeting
T1 v2's inner-left corner.

### T1 v2 (keyID 3) — WORKING
- Symmetric: BotLen=20, depth_ratio=[1,1], left_line from C1 (same as v1)
- Uniform dish arc=14 (no gradient), pitch=0 first segment, sweep=12+6/12+5
- Oversized body +14mm (needed for left_line corner margin)
- Sector trim uses fn=120 for keyID 3 (didn't fix notch but smoother)
- `Simple: yes`, `Volumes: 2` — clean except for the left_line notch

### Extended R5 keys (keyIDs 7, 8) — ext_a WORKING, ext_b HAS SPIKE

Uses `BodyOffsetY` in Choc_Chicago_Steno_Convex.scad to shift the body
asymmetrically (tapered: full offset at bottom, 0 at top).

**Architecture**: The body cross-sections taper from offset at the bottom to
centered-on-stem at the top. The dish stays at the stem center (y=0). Extended
dish sweeps (pitch=0 first segment for horizontal reach) cover the offset body.

**ext_a (keyID 7)**: BotLen=19.6, TLDif=5, offset=-1.80 → **clean, no spikes**
**ext_b (keyID 8)**: BotLen=22.5, TLDif=5, offset=-3.25 → **has spike on extended side**

The ext_b spike is from the dish not reaching the offset body at intermediate
heights. The body at mid-height extends to -12.3mm from center, but the dish
back sweep (12mm at pitch=0) only reaches -12mm. The 0.3mm shortfall creates
a thin spike where the body protrudes past the dish cut.

### Key Learnings

1. **Always use CGAL for convex key renders** — Manifold hides artifacts that
   appear in CGAL STLs. Manifold PNGs looked clean while CGAL STLs had spikes.

2. **Constant BodyOffsetY breaks CGAL booleans** — Shifting body+dish+inner
   shell by a constant offset produced `Volumes: 4` and visible seams in CGAL
   renders (inner shell protruding through body). Only the tapered approach
   (full at bottom → 0 at top) produces correct `Volumes: 2`.

3. **Dish sweep pitch=0 is critical** — The default -3° pitch causes the sweep
   to descend below z=0 before reaching the body extent, creating spikes. Setting
   pitch=0 on the first segment keeps the sweep horizontal, covering the body
   at the switch plate level.

4. **TLDif controls top surface size** — With TLDif=5 (standard), BotLen=22.5
   gives top half-length=8.75mm which exceeds the dish sweep reach (6.8mm),
   causing a spike on the non-extended side. This is why ext_b has a spike
   even with pitch=0: the TOP surface is too large for the standard dish.

5. **Left_line causes sector skin artifact** — The asymmetric polygon from
   left_line creates a persistent notch at the outer-right corner of the
   sector trim skin. No dish parameter change fixes it; only removing
   left_line eliminates it.

6. **InnerTransform/StemTransform had a bug** — Both used TopLenDiff for the
   width dimension instead of TopWidthDiff. Fixed (minor impact on existing
   keys: 0.6mm thicker wall at top).

### Next Steps

The extended keys need to look like symmetric (1+x)u convex keys from above,
with the stem simply offset below. This means:
- The body and dome should be fully symmetric around the body center
- The stem connects at the switch position (off-center relative to the body)
- Need to solve the CGAL boolean issue with constant BodyOffsetY, OR
- Use a different approach: build the keycap as a standard larger convex key
  centered on the body, then separately add/connect the stem at the switch pos

This should also fix ext_b's spike, since a symmetric dome centered on the body
would have standard R3x dish coverage without needing extended sweeps.

## Key Files

- `Choc_Chicago_Steno_Thumb_Trap.scad` — Main file, all changes here
- `Choc_Chicago_Steno_Convex.scad` — Reference for convex dish and elliptical_rectangle
- `Choc_Chicago_Steno_Thumb.scad` — Reference for thumb dish
- `gen_sprued_keycaps.scad` — Routes keycap IDs to trap module (variation 4)
- `go60_visualization.scad` — Uses trap keys for T1/T2/T3 positions

## Test Commands

Render individual keys (use CGAL backend):
```bash
# T2 (symmetric convex) — simplest, test this first
openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=0' -D 'test_dish="convex"' -o stl/debug/trap_t2.stl test_trap.scad

# T1 (asymmetric convex with left_line)
openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=2' -D 'test_dish="convex"' -o stl/debug/trap_t1.stl test_trap.scad

# T3 (thumb scoop)
openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=1' -D 'test_dish="thumb"' -o stl/debug/trap_t3.stl test_trap.scad
```

Check for: `Simple: yes`, `Volumes: 2`, no visible holes/spikes/notches in STL viewer.

```bash
# T1 v2 (symmetric convex, uniform arc, left_line)
openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=3' -D 'test_dish="convex"' -o stl/debug/trap_t1_v2.stl test_trap.scad

# Extended R5 keys (use test_ext.scad)
openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=7' -o stl/debug/r3x_ext_a.stl test_ext.scad
openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=8' -o stl/debug/r3x_ext_b.stl test_ext.scad
```

**IMPORTANT**: Always use CGAL for convex key test renders. Manifold hides
artifacts that appear in the CGAL-exported STL. Use CGAL for PNG profiles too:
```bash
openscad --backend=CGAL --render --imgsize=1600,600 \
  --camera=0,0,2,85,0,90,50 -D 'test_keyID=7' \
  -o stl/debug/r3x_ext_a_cgal_side.png test_ext.scad
```
