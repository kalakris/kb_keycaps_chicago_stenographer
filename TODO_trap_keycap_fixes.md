# Trapezoidal & Extended Keycap Notes

Notes on the trapezoidal sector keycaps (T1/T2/T3) and the extended R5 keys
(ext_a/ext_b) used in the Go60 V2 thumb row.

## Background

The Go60 keyboard has splayed thumb keys arranged on a circular arc. Standard
rectangular keycaps leave wedge-shaped gaps. Two solutions are implemented:

1. **Trapezoidal sector keycaps** (T1/T2/T3) fill the splayed positions with
   sector-shaped footprints. See README.md section 3.1.8.
2. **Extended R5 keys** (ext_a/ext_b) extend the straight thumb row keys
   downward so their bottoms align with T1's inner edge at y=-57.

## Status: ALL KEYS WORKING

| Key       | keyID | File                                  | Status               |
|-----------|-------|---------------------------------------|----------------------|
| T1        | 2     | Choc_Chicago_Steno_Thumb_Trap.scad    | clean (CGAL Vol=2)   |
| T2        | 0     | Choc_Chicago_Steno_Thumb_Trap.scad    | clean (CGAL Vol=2)   |
| T3        | 1     | Choc_Chicago_Steno_Thumb_Trap.scad    | clean (CGAL Vol=2)   |
| ext_a     | 7     | Choc_Chicago_Steno_Convex.scad        | clean (CGAL Vol=2)   |
| ext_b     | 8     | Choc_Chicago_Steno_Convex.scad        | clean (CGAL Vol=2)   |

## Trap Key Architecture

```
intersection() {
    (oversized_elliptical_rectangle_body - inner + stem) - dish_cut,
    sector_rectangle_skin  // trim to sector footprint
}
```

- Oversized smooth body (+14mm per dimension) ensures the dish boolean operates
  on smooth surfaces only — no dish-corner artifacts.
- Sector trim (skin of sector_rectangle cross-sections) clips to the exact
  sector footprint.
- The dish only touches smooth geometry; the sector only clips smooth results.

### Trap dish parameters

**T2 (keyID 0, dish row 0)**: arc gradient 10.5→13, pitch=-3/-45, FFwd=8+6, BFwd=7+5
- Tight arc at center (visible dome), wide at edges (corner coverage)

**T1 (keyID 2, dish row 1)**: uniform arc 13.0/13.2, pitch=-3/-45, FFwd=8+6, BFwd=7+5
- Wide uniform arc needed because left_line extends sector to x≈-12.4mm
- pitch=-3 (not 0) provides smooth dome curvature along the sweep
- Symmetric depth (depth_ratio=[1,1], BotLen=20)

**T3 (keyID 1)**: thumb scoop, FFwd=9+7 pitch=0/-40, BFwd=9+5.5 pitch=5/-50, arcs=20/24
- Fully extended to cover skew-raised corners (XSkew=-3, YSkew=-3)

### T1 known minor issue

Tiny notch at the bottom corner from the left_line creating an asymmetric
sector polygon whose skin() between layers produces a small artifact.
Confirmed by disabling left_line → notch disappears. NOT a dish coverage issue.
Considered acceptable — not visible from the top/typing perspective.

## Extended R5 Architecture (ext_a / ext_b)

Symmetric body centered at BodyOffsetY, stem at switch (y=0). Body+dome look
symmetric from above, stem simply offset below.

**Implementation in Choc_Chicago_Steno_Convex.scad:**
- `CapTranslation` / `InnerTranslation`: constant `BodyOffsetY` at all heights
- `StemTranslation`: tapers from y=0 (stem) to y=BodyOffsetY (inner shell top),
  bridging the gap inside the body
- Dish positioning: shifted by `BodyOffsetY` to center on body
- Dish params: symmetric front/back sweeps, pitch=-3, arcs=8.5/8.7 (matching R3x 1u)

**Parameters:**
- ext_a (keyID 7): BotLen=19.6, BodyOffsetY=-1.80
- ext_b (keyID 8): BotLen=22.5, BodyOffsetY=-3.25

## Key Learnings

1. **Always use CGAL for convex key renders** — Manifold hides artifacts that
   appear in CGAL STLs.

2. **Symmetric body + offset stem beats tapered offset** — Initial approach
   used tapered BodyOffsetY (full at bottom → 0 at top). This made body
   asymmetric at intermediate heights. Constant offset on body+inner+dish with
   tapered stem transition works correctly and looks symmetric from above.

3. **pitch=0 on dish first segment makes the dome flat** — Use pitch=-3 (matching
   R3x 1u) for smooth dome curvature. pitch=0 was only needed for the failed
   tapered-body approach.

4. **Dish arc must cover the widest body cross-section** — For T1's left_line
   that extends to x≈-12.4mm, arc must be ≥13. For symmetric ext keys with
   BotWid=17.20, R3x 1u arcs (8.5/8.7) suffice.

5. **Left_line causes a small sector skin artifact** — The asymmetric polygon
   from left_line creates a persistent notch at the outer corner of the sector
   trim skin. No dish parameter change fixes it. Considered acceptable.

## Key Files

- `Choc_Chicago_Steno_Thumb_Trap.scad` — Trap keys T1/T2/T3
- `Choc_Chicago_Steno_Convex.scad` — Convex keys including ext_a/ext_b
- `gen_sprued_keycaps.scad` — Routes keycap names to modules
- `go60_visualization.scad` — V2 thumb row layout (`left_thumb_keys_v2`)

## Test Commands

Render individual keys (use CGAL backend):

```bash
# Trap keys
openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=0' -D 'test_dish="convex"' -o stl/debug/trap_t2.stl test_trap.scad
openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=1' -D 'test_dish="thumb"' -o stl/debug/trap_t3.stl test_trap.scad
openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=2' -D 'test_dish="convex"' -o stl/debug/trap_t1.stl test_trap.scad

# Extended R5 keys
openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=7' -o stl/debug/r3x_ext_a.stl test_ext.scad
openscad --backend=CGAL --render --export-format binstl \
  -D 'test_keyID=8' -o stl/debug/r3x_ext_b.stl test_ext.scad
```

Check for: `Simple: yes`, `Volumes: 2`, no visible holes/spikes/notches.

**IMPORTANT**: Always use CGAL for convex key test renders. Manifold hides
artifacts that appear in the CGAL-exported STL.
