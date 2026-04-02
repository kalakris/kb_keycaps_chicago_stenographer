// Go60 Full Keyboard Visualization
//
// NOT for printing - this places all keycaps at their approximate
// positions to visualize the final sculpt contours of both halves.
//
// Column and row spacing derived from measured Go60 photography.
// The Go60 uses "hybrid spacing" with slightly narrower gaps between
// the pinky column pair (C6-C5) and the index column pair (C2-C1).
// Column stagger and thumb splay measured from reference images.
//
// The splayed thumb keys (T1, T2, T3) use trapezoidal sector-shaped
// keycaps (from Choc_Chicago_Steno_Thumb_Trap.scad) that fill the
// wedge gaps between arc-positioned keys:
//   T1: convex dome, inner edge aligned to C1, depth tapers 1u→1.25u
//   T2: convex dome, symmetric 1.25u sector
//   T3: thumb scoop, symmetric 1.25u sector
//
// The main board shows homing bars on C2 R3. Alternate and spare keys
// are stacked below their corresponding positions in Z.
//
// ── Key count tally (must match export plates exactly) ────────
//
//   Export plate                        Keys  Qty  Subtotal
//   export_go60_regular_columns          10  × 2  =  20
//   export_go60_lateral_columns           8  × 2  =  16
//   export_go60_inner_columns_left       10  × 1  =  10
//   export_go60_inner_columns_right      10  × 1  =  10
//   export_go60_thumbs                   10  × 1  =  10
//   export_go60_thumbs_alt               10  × 1  =  10
//                                              Total: 76
//
//   Board (main layer):
//     48 finger + 12 thumb                                = 60
//   Finger alternates (below C2 R3 per half):
//     (1 dot + 1 spare R3) × 2 halves                    =  4
//   Alt thumb row (below main thumbs per half):
//     (5 R2 convex + 1 T125) × 2 halves                  = 12
//   Total shown: 60 + 4 + 12 = 76  ✓
//
// Open in OpenSCAD and hit F5 (preview) or F6 (render + export STL).

use <gen_sprued_keycaps.scad>

/* ── Spacing ─────────────────────────────────────────────────── */

row_spacing = 17;    // vertical distance between rows
half_gap    = 100;   // gap between left and right halves

// Per-column X positions (0=C6 outermost .. 5=C1 innermost).
// The Go60 uses "hybrid spacing": the pinky pair (C6-C5) and
// index pair (C2-C1) have slightly narrower gaps (~17.9mm)
// than the middle columns (~18.9mm).
col_x = [0, 17.9, 36.8, 55.7, 74.6, 92.5];

// Mean column spacing (for thumb arc and board outline sizing)
col_spacing = 18.5;

/* ── Alternate key stacking ──────────────────────────────────── */

alt_z = -20;         // Z offset per alternate layer below the board

/* ── Column stagger ──────────────────────────────────────────── */

// Y offset per column index (0=C6 outermost .. 5=C1 innermost)
// Measured from Go60 reference photography:
//   C3 (middle finger) is highest (reference).
//   C6/C5 (pinky pair) drop ~0.79 rows.
//   C4/C2 (ring/index) drop ~0.17 rows.
//   C1 (inner index) drops ~0.26 rows.
stagger = [-13.4, -13.4, -2.9, 0, -2.9, -4.4];

/* ── Left half key grid ──────────────────────────────────────── */

// Columns left to right: C6, C5, C4, C3, C2, C1
// Rows top to bottom:    R1,  R2,  R3 (home), R4

left_finger_grid = [
    // C6 - outer pinky (lateral_l of C6+C5 pair)
    ["cs_r1_lateral_l", "cs_r2_lateral_l", "cs_r3_lateral_l",     "cs_r4_lateral_l"],
    // C5 - pinky (lateral_r of C6+C5 pair)
    ["cs_r1_lateral_r", "cs_r2_lateral_r", "cs_r3_lateral_r",     "cs_r4_lateral_r"],
    // C4 - ring (regular, no homing)
    ["cs_r1_1",         "cs_r2_1",         "cs_r3_1",             "cs_r4_1"        ],
    // C3 - middle (regular, no homing)
    ["cs_r1_1",         "cs_r2_1",         "cs_r3_1",             "cs_r4_1"        ],
    // C2 - index (lateral_l of C2+C1 pair, homing bar on R3)
    ["cs_r1_lateral_l", "cs_r2_lateral_l", "cs_r3_lateral_l_bar", "cs_r4_lateral_l"],
    // C1 - inner index (lateral_r of C2+C1 pair, no homing)
    ["cs_r1_lateral_r", "cs_r2_lateral_r", "cs_r3_lateral_r",     "cs_r4_lateral_r"],
];

// Thumb row: 6 keys starting at C4 (col_start=2)
// Keys 0-2 align straight below C4, C3, C2 (one row below R4).
// Keys 3-5 splay outward on a circular arc.
// Go60 naming: T1=innermost (C1 R5), T2=middle, T3=outermost.
left_thumb_keys = [
    "cs_r3x_1",          // C4 R5 - convex
    "cs_r3x_1",          // C3 R5 - convex
    "cs_t_1_l",          // C2 R5 - thumb
    "cs_t_trap_convex_t1", // T1 (innermost splayed) - trap convex, inner edge aligned to C1
    "cs_t_trap_convex",   // T2 (middle splayed) - trap convex
    "cs_t_trap_thumb_r",  // T3 (outermost splayed) - trap thumb
];

// Alt thumb row: all convex R2 except T3 = 1.25u thumb
// The board boundary at T3 comfortably fits a vertically-aligned 1.25u key.
left_thumb_keys_alt = [
    "cs_r2x_1",    // C4 R5 alt - convex
    "cs_r2x_1",    // C3 R5 alt - convex
    "cs_r2x_1",    // C2 R5 alt - convex
    "cs_r2x_1",    // T1 alt - convex
    "cs_r2x_1",    // T2 alt - convex
    "cs_t_125_l",  // T3 alt - outermost thumb 1.25u
];

/* ── Thumb placement helper ───────────────────────────────────── */

// Thumb row parameters
// R5 sits one row below R4.  R4 base y = (1.5-3)*row_spacing = -1.5*row_spacing.
thumb_base_y    = -2.5 * row_spacing;  // R5 position (one row below R4)
thumb_col_start = 2;           // first thumb key aligns with C4

// Thumb arc parameters (fitted from Go60 reference photography).
// The 3 splayed keys (T1, T2, T3) lie on a circular arc.
// Go60 naming: T1=innermost, T3=outermost.
// Adjacent bottom corners nearly touch and are aligned along the arc.
// The board boundary at T3 fits a vertically-aligned 1.25u key.
arc_cx    = 73.2;    // arc center x (near C2 column position)
arc_cy    = -125.3;  // arc center y (well below the board)
arc_r     = 79.1;    // arc radius
arc_start = 14.9;    // angle of T1 (degrees from vertical)
arc_step  = 14.0;    // angle between splayed keys

// Helper: compute the center position and rotation of splayed key n (0-based)
// n=0 → T1 (innermost), n=1 → T2, n=2 → T3 (outermost)
function splay_x(n) = arc_cx + arc_r * sin(arc_start + n * arc_step);
function splay_y(n) = arc_cy + arc_r * cos(arc_start + n * arc_step);
function splay_rot(n) = -(arc_start + n * arc_step);

module place_thumb_row(keys, z_off=0) {
    // First 3 keys (C4R5, C3R5, C2R5) align straight below their columns.
    // Remaining 3 (T1, T2, T3) are placed on a circular arc with
    // each key oriented tangent to the arc.
    for (i = [0:5]) {
        col_idx = thumb_col_start + i;
        splay_steps = i < 3 ? 0 : i - 2;   // 0,0,0,1,2,3

        if (splay_steps == 0) {
            // Straight keys: one row below R4, with column stagger
            col_stag = stagger[col_idx];
            translate([col_x[col_idx], thumb_base_y + col_stag, z_off])
                cs_keycap(keys[i]);
        } else {
            // Splayed keys: placed on the thumb arc
            n = splay_steps - 1;  // 0, 1, 2
            translate([splay_x(n), splay_y(n), z_off])
                rotate([0, 0, splay_rot(n)])
                    cs_keycap(keys[i]);
        }
    }
}

/* ── Board outline ───────────────────────────────────────────── */

// Approximate Go60 PCB/plate outline (key-switch area only,
// excluding the touchpad platform).  Derived from reference photo.
// The board has a stepped top edge: the pinky columns (C6, C5) sit
// lower than the main columns (C4-C1) due to aggressive stagger.
module go60_board_outline() {
    m = col_spacing / 2;  // margin around keys

    // Key position helpers
    function r1y(col) = 1.5 * row_spacing + stagger[col];
    function r4y(col) = -1.5 * row_spacing + stagger[col];

    // Generate smooth arcs around the splayed thumb keys.
    // The board boundary is at a constant radius that fits a
    // vertically-aligned 1.25u key at T2 or T3 (but not both
    // simultaneously — the lower corners would touch).
    // 1.25u key half-length ≈ 10mm radially from key center.
    key_half_125u = 10;  // half of 1.25u key length in radial direction
    r_out = arc_r + key_half_125u + 1;   // board edge away from arc center
    r_in  = arc_r - key_half_125u - 1;   // board edge toward arc center

    // Angle range: from before T1 to past T3
    a_min = arc_start - arc_step * 0.5;
    a_max = arc_start + 2 * arc_step + arc_step * 0.5;

    // Sample outer arc (T1 side → T3 side)
    arc_out = [for (a = [a_min : 2 : a_max])
        [arc_cx + r_out * sin(a), arc_cy + r_out * cos(a)]];
    // Sample inner arc (T3 side → T1 side)
    arc_in  = [for (a = [a_max : -2 : a_min])
        [arc_cx + r_in * sin(a), arc_cy + r_in * cos(a)]];

    color("DimGray", 0.4)
    translate([0, 0, -1.5])
    linear_extrude(0.5) {
        offset(r=2)
        offset(r=-2)
        polygon(concat(
            [
                // ── Top edge (finger area) ──
                // Top-left: above C6 R1
                [col_x[0] - m, r1y(0) + m],
                // Top of pinky section
                [col_x[1] + m/2, r1y(1) + m],
                // Step up to main section
                [col_x[1] + m/2, r1y(2) + m],
                [col_x[2] - m/2, r1y(2) + m],
                // Top of main section: C3 highest
                [col_x[3], r1y(3) + m],
                [col_x[5] + m, r1y(5) + m],

                // ── Right edge: down to thumb area ──
                [col_x[5] + m, r4y(5)],
                [col_x[5] + m, thumb_base_y + stagger[5]],
            ],
            // ── Outer arc of thumb fan ──
            arc_out,
            // ── Inner arc of thumb fan (back toward finger area) ──
            arc_in,
            [
                // ── Bottom edge (straight thumb keys) ──
                [col_x[4], thumb_base_y + stagger[4] - m],
                [col_x[2], thumb_base_y + stagger[2] - m],

                // ── Left/bottom edge ──
                [col_x[0] - m, r4y(0) - m],
            ]
        ));
    }
}

/* ── Layout module (finger + thumb + alt thumb + outline) ───── */

module go60_half_board() {
    // Board outline
    go60_board_outline();

    // Finger keys: 6 columns x 4 rows
    for (col = [0:5]) {
        for (row = [0:3]) {
            translate([
                col_x[col],
                (1.5 - row) * row_spacing + stagger[col],
                0
            ])
            cs_keycap(left_finger_grid[col][row]);
        }
    }

    // Main thumb row
    place_thumb_row(left_thumb_keys);

    // Alt thumb row (stacked below)
    place_thumb_row(left_thumb_keys_alt, alt_z);
}

/* ── C2 R3 position helper ───────────────────────────────────── */

// X/Y of C2 R3 in the half-board coordinate system
c2_r3_pos = [col_x[4], (1.5 - 2) * row_spacing + stagger[4], 0];

// Mirrored position for right half (negate X)
c2_r3_pos_mirror = [-c2_r3_pos[0], c2_r3_pos[1], c2_r3_pos[2]];

/* ── Place both halves ───────────────────────────────────────── */

left_offset  = [-(half_gap / 2) - col_x[5], 0, 0];
right_offset = [ (half_gap / 2) + col_x[5], 0, 0];

// Left half board
translate(left_offset)
    go60_half_board();

// Right half board (physical mirror of left)
translate(right_offset)
    mirror([1, 0, 0])
        go60_half_board();

/* ── Alternate/spare keys (stacked below in Z) ──────────────── */
// Placed outside the mirror so left and right use correct keycap IDs.

// Left half: C2 = lateral_l (from export_go60_inner_columns_left)
translate(left_offset + c2_r3_pos + [0, 0, alt_z])
    cs_keycap("cs_r3_lateral_l_dot");    // dot alternate

translate(left_offset + c2_r3_pos + [0, 0, 2 * alt_z])
    cs_keycap("cs_r3_lateral_l");        // spare plain R3

// Right half: C2 = lateral_r (from export_go60_inner_columns_right)
// Position mirrors left C2 R3 across the center
translate(right_offset + c2_r3_pos_mirror + [0, 0, alt_z])
    cs_keycap("cs_r3_lateral_r_dot");    // dot alternate

translate(right_offset + c2_r3_pos_mirror + [0, 0, 2 * alt_z])
    cs_keycap("cs_r3_lateral_r");        // spare plain R3
