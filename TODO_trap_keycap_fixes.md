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

## Remaining Minor Issue

T1 has a tiny notch at the bottom right corner (visible when viewing from below).
Likely from the dome sweep edge barely intersecting the sector at the extreme corner.
Considered acceptable — not visible from the top/typing perspective.

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

Manifold backend is ~300x faster for PNG previews:
```bash
openscad --backend=Manifold --render --imgsize=1200,400 \
  --camera=0,0,2,85,0,0,30 -D 'test_keyID=0' -D 'test_dish="convex"' \
  -o stl/debug/trap_t2_front.png test_trap.scad
```
