# Trapezoidal Keycap Rendering Fixes - Work In Progress

## Background

The Go60 keyboard (and similar boards) has splayed thumb keys arranged on a circular arc.
Standard rectangular keycaps leave wedge-shaped gaps between these arc-positioned keys.
The trapezoidal sector-shaped keycaps fill these gaps with footprints that follow the arc
geometry — wider on the outer edge, narrower on the inner edge, with arced outer/inner
edges. See README.md section 3.1.8 and `go60_visualization.scad` for full context.

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

### Current State (option 5 refined — committed as checkpoint)

Three changes were combined to eliminate artifacts:

#### A. Oversized smooth body (+8mm per full dimension = 4mm per side)
The elliptical_rectangle outer shell is enlarged by `+[8,8]` so it fully contains the
sector at every layer. The sector trim exclusively determines the final edge shape.
The dish operates on the smooth oversized surface (no sector corners involved).

**Result**: Clean straight side edges on all three keys. No wavy/doubled edges.
T2 (symmetric convex) rendered perfectly with this change alone.

#### B. Extended dish sweep coverage
T1 and T3 still had spikes at corners where the dish sweep didn't reach far enough:
- T1 spike at right outer corner: depth_ratio 10/9 extends the right side to 10.51mm,
  but the original dish forward distance was only 10.5mm — the dish barely missed.
- T3 spike on left side: XSkew=-3, YSkew=-3 tilts the scoop, and the high side of
  the tilt didn't get enough dish coverage at the corner.

Fix: increased dish parameters so the sweep covers all corners with margin:
- Convex: arcs 10.75/10.95 → 14.0/14.5, forward 6.0+4.5=10.5 → 8.0+6.0=14.0 per dir
- Thumb: arcs 16/20 → 20/24, forward 7+5=12 → 9+7=16 (front), 7+3.5=10.5 → 9+5.5=14.5 (back)

#### C. Corner chamfers (fillet=0.5mm) on sector trim
Added `fillet` parameter to `sector_rectangle()`. When fillet > 0, each edge is
shortened by fillet/edge_length at each end. The polygon connections between
shortened edges form chamfer diagonals at the corners. This prevents any remaining
tangential dish-sector intersections that CGAL resolves as spikes.

### Known Trade-offs (to address in next session)

1. **Chamfered corners visible**: The 0.5mm chamfers create small flat cuts at the
   four corners of the sector, visible as "chopped-off" corners. The original keys
   have sharp corners. Need to either reduce the chamfer size (if the extended dish
   alone is sufficient) or replace chamfers with smooth rounded fillets.

2. **Reduced convex dome curvature**: The wider arcs (14mm vs 10.85mm) make the
   dome flatter within the visible sector footprint. The dome depth at center is
   still 1.5mm, but the curvature variation from center to edge dropped from
   0.28mm to 0.16mm. The original convex keys have more pronounced dome curvature.
   May need to increase DishDepth to compensate, or find a smaller arc increase
   that still covers corners.

3. **T3 scoop profile changed**: The original T3 had an asymmetric scoop profile
   (one smooth side, one sharper ridge) due to the XSkew/YSkew interaction with
   the original dish sweep extent. The extended sweep smooths this out. Need to
   compare with the original T3 reference and possibly use the original thumb dish
   parameters with a different artifact-prevention strategy.

### Recommended Next Steps (for next session)

1. **Test without chamfers**: Try fillet=0 with just the extended dish to see if the
   extended coverage alone is sufficient. If so, remove the chamfer to get sharp corners.

2. **Tune dish parameters separately**: Instead of one set of dish parameters for all
   keys, consider per-key dish tuning. The original convex/thumb dish parameters were
   tuned for aesthetics; the extensions were purely for coverage. A middle ground
   might preserve the original look while avoiding spikes.

3. **Consider the "sector body + dish mask" architecture**: Instead of
   `intersection(dished_smooth_body, sector_trim)`, restructure as:
   - Build full sector keycap (outer-inner+stem) using sector_rectangle
   - Build oversized smooth body with dish applied
   - `intersection(sector_keycap, dished_smooth_body)` — the sector determines
     ALL edges/walls, the smooth body only contributes the dish surface
   This might allow using the original dish parameters because the sector body
   (not the smooth body) determines the wall shape.

4. **Compare with reference keys**: Render the regular convex and thumb keys side
   by side with the trap keys to match dome curvature and scoop profile.

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
