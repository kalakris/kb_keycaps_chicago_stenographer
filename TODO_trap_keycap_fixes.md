# Trapezoidal Keycap Rendering Fixes - Work In Progress

## Goal

Fix rendering artifacts (holes, spikes, notches) on the three trapezoidal sector-shaped
keycaps (T1, T2, T3) defined in `Choc_Chicago_Steno_Thumb_Trap.scad`. The keycaps must
render cleanly with CGAL backend and produce artifact-free STL files suitable for 3D printing.

## The Three Keys

| Key | keyID | Dish Type | Shape | Notes |
|-----|-------|-----------|-------|-------|
| T1  | 2     | convex    | Asymmetric sector, left edge aligned to C1 column | Uses `left_line` + `depth_ratio` |
| T2  | 0     | convex    | Symmetric 1.25u sector | Simplest case |
| T3  | 1     | thumb     | Symmetric 1.25u sector with scoop dish | XSkew=-3, YSkew=-3 |

## Issues Found and Fixed (committed)

### 1. DishShape function was wrong (FIXED)
The `DishShape()` function used `rot1=90, rot2=270` (left half of ellipse, no extensions).
The convex file's version uses `rot1=270, rot2=450` with extension points `[c+a,-b]` and
`[c+a,b]`. Without the extensions, the dish sweep volume didn't intersect the keycap body.

### 2. Convex back trajectory direction was wrong (FIXED)
`_cx_dish_cut()` used `trajectory(backward=..., pitch=-...)` for the back path. But the
convex dish uses two separate sweeps with different Z rotations (90° and 270°), so both
need `trajectory(forward=..., pitch=...)`. The 270° rotation already reverses direction.
Using `backward` made both sweeps go the same way — only cutting one half of the dome.

Note: the thumb dish `_thumb_dish_cut()` correctly uses `backward` because it combines
both paths into a single DishCurve with the back path iterated in reverse.

### 3. Convex dish forward distances were too short (FIXED)
Original values (FFwd1=4.5, FFwd2=3.3) were from R3x 1.25u (BotLen=15.6mm). The trap
keys have BotLen=20mm. Increased to FFwd1=6.0, FFwd2=4.5 so the sweep covers the full
keycap length. Without this, the dome left uncovered corners (Volumes=4).

### 4. Cross-section point density was too low (FIXED)
`sector_rectangle()` used `n = max(4, fn/4)` = 15 points per edge (60 total).
`elliptical_rectangle()` uses `fn` = 60 points per edge (240 total).
The 4x lower density created coarse geometry that caused twisted quads in `skin()`,
leading to CGAL "nonplanar faces" warnings and dish boolean artifacts.
Changed to `n = fn` to match elliptical_rectangle density.

## Remaining Issue: Dish-Corner Artifacts

### Problem
When the dish sweep (convex dome or thumb scoop) is boolean-differenced from the sector
keycap body, artifacts appear at corners where the dish surface exits the keycap walls:
- **T1**: Small spike/protrusion at the C1-aligned (left_line) edge corner
- **T3**: Small notch where the scoop exits the wall at corners

The regular keycaps (using `elliptical_rectangle` cross-sections) don't have this problem
because their smooth curved edges create clean dish-wall intersections.

### Root Cause
The `sector_rectangle` cross-section has **straight side edges** (radial lines connecting
inner and outer arcs). Where these straight edges meet the arc edges, there are sharp
corners. The dish sweep surface intersects these sharp corners tangentially, creating
degenerate boolean geometry that CGAL resolves as spikes or notches.

`elliptical_rectangle` has **smooth parametric curves** for all 4 edges, so the dish
surface always intersects smooth curvature — no degenerate tangent intersections.

### Approaches Tried

1. **Reduced dish arc sizes** (FArcIn/FArcFn): Making dish arcs small enough to stay
   within the keycap top width (5.5-6.0mm) made the dome/scoop too narrow — bad aesthetics.
   The regular convex keys use arcs that extend well past the keycap walls (8.5mm arcs vs
   5.8mm half-width) and work fine.

2. **Clip dish with hull()**: Intersected the dish with a hull of bottom+top cross-sections.
   Created flat cuts on the top surface because hull() makes straight sides that don't
   follow the keycap's power-curve taper.

3. **Clip dish with skin() of sector cross-sections**: Intersected dish with the keycap's
   own sector skin. Created rendering artifacts because the clip volume itself has nonplanar
   faces from skin().

4. **Curved side edges (bulge)**: Added `sin(t*180) * b[0]` outward bulge to side edges.
   Helped slightly but didn't fix corners (bulge is zero at endpoints where corners are).
   User didn't like the aesthetic change from straight edges.

5. **Elliptical body + sector intersection** (current state on branch):
   - Build smooth `elliptical_rectangle` keycap body
   - Apply dish cut to smooth body (no artifacts)
   - Intersect result with `sector_rectangle` skin to trim footprint

   **Results**: Top surfaces are clean (dome/scoop have no artifacts). BUT the side edges
   are not clean straight lines — the elliptical body's curved edges show through at the
   trim boundaries, creating wavy/doubled edges. T1's left_line alignment is also lost
   because the elliptical body doesn't know about the C1-aligned edge.

### Recommended Next Steps

The intersection approach (option 5) is the most promising but needs refinement:

- **Edge quality**: The elliptical body needs to be slightly LARGER than the sector shape
  at all points so the sector trim is the sole determinant of the edge shape. Currently
  the elliptical body is the same size, so at some heights it's smaller than the sector,
  creating mixed edges.

- **T1 left_line**: The elliptical body doesn't implement the C1-aligned left edge. The
  sector trim handles the footprint, but the inner shell and stem transition may not
  align correctly. May need to extend the elliptical body width for T1 to ensure the
  sector trim always wins.

- Alternative: instead of `elliptical_rectangle` for the smooth body, use a simple
  `circle()` or `square()` that's guaranteed larger than the sector at all heights.
  Then the sector intersection exclusively determines the shape. The dish still operates
  on the smooth oversized body (no corner artifacts), and the sector trim gives clean
  straight edges.

## Key Files

- `Choc_Chicago_Steno_Thumb_Trap.scad` — Main file, all changes here
- `Choc_Chicago_Steno_Convex.scad` — Reference for convex dish and elliptical_rectangle
- `Choc_Chicago_Steno_Thumb.scad` — Reference for thumb dish
- `gen_sprued_keycaps.scad` — Routes keycap IDs to trap module (variation 4)
- `go60_visualization.scad` — Uses trap keys for T1/T2/T3 positions

## Test Commands

Render individual keys (use CGAL backend):
```bash
cat > test_trap.scad << 'EOF'
use <Choc_Chicago_Steno_Thumb_Trap.scad>
test_keyID = 0;
test_dish = "convex";
keycap_cs_thumb_trap(keyID=test_keyID, dishType=test_dish, Stem=true, StemRot=0, Dish=true);
EOF

# T2 (symmetric convex) — simplest, test this first
/opt/homebrew/bin/openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=0' -D 'test_dish="convex"' -o stl/debug/trap_t2.stl test_trap.scad

# T1 (asymmetric convex with left_line)
/opt/homebrew/bin/openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=2' -D 'test_dish="convex"' -o stl/debug/trap_t1.stl test_trap.scad

# T3 (thumb scoop)
/opt/homebrew/bin/openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=1' -D 'test_dish="thumb"' -o stl/debug/trap_t3.stl test_trap.scad
```

Check for: `Simple: yes`, `Volumes: 2`, no visible holes/spikes/notches in STL viewer.

Reference keys for comparison:
```bash
# Regular convex R3x (clean reference)
/opt/homebrew/bin/openscad --backend=CGAL --render --export-format binstl \
  -o stl/debug/ref_convex.stl Choc_Chicago_Steno_Convex.scad

# Regular thumb T1 (clean reference)
/opt/homebrew/bin/openscad --backend=CGAL --render --export-format binstl \
  -o stl/debug/ref_thumb.stl Choc_Chicago_Steno_Thumb.scad
```
