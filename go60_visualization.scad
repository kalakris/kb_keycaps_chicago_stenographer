// Go60 Full Keyboard Visualization
//
// NOT for printing - this places all keycaps at their approximate
// positions to visualize the final sculpt contours of both halves.
//
// Assumes choc spacing (18x17mm). Column stagger and thumb positions
// are estimated for a typical columnar ergo layout.
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

col_spacing = 18;    // horizontal distance between columns
row_spacing = 17;    // vertical distance between rows
half_gap    = 50;    // gap between left and right halves

/* ── Alternate key stacking ──────────────────────────────────── */

alt_z = -20;         // Z offset per alternate layer below the board

/* ── Column stagger ──────────────────────────────────────────── */

// Y offset per column index (0=C6 outermost .. 5=C1 innermost)
// Typical columnar ergo stagger
stagger = [-8, -3, 3, 6, 0, -3];

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

// Thumb row: spare, spare, outer, convex, convex, inner
left_thumb_keys = [
    "cs_r3x_1",    // spare (under C6)
    "cs_r3x_1",    // spare (under C5)
    "cs_t_1_l",    // outer thumb
    "cs_r3x_1",    // convex
    "cs_r3x_1",    // convex
    "cs_t_1_r",    // inner thumb (outermost in splay)
];

// Alt thumb row: all convex R2 except outermost = 1.25u thumb
left_thumb_keys_alt = [
    "cs_r2x_1",    // spare (under C6)
    "cs_r2x_1",    // spare (under C5)
    "cs_r2x_1",    // convex
    "cs_r2x_1",    // convex
    "cs_r2x_1",    // convex
    "cs_t_125_l",  // outermost thumb 1.25u
];

/* ── Thumb placement helper ───────────────────────────────────── */

// Thumb row parameters
thumb_base_y    = -1.5 * row_spacing - 18;  // gap below R4
thumb_col_start = 2;           // first thumb key aligns with C4
thumb_splay     = -10;         // degrees per splayed key

module place_thumb_row(keys, z_off=0) {
    // First 3 keys align straight with finger columns C4, C3, C2.
    // Remaining 3 fan inward with ~10° progressive splay per key,
    // pivoting at the boundary of the straight and splayed sections.
    for (i = [0:5]) {
        splay_steps = i < 3 ? 0 : i - 2;   // 0,0,0,1,2,3
        rot = splay_steps * thumb_splay;

        pivot_x = (thumb_col_start + 3) * col_spacing - col_spacing/2;
        pivot_y = thumb_base_y;

        translate([pivot_x, pivot_y, 0])
        rotate([0, 0, rot])
        translate([-pivot_x, -pivot_y, 0])
        translate([
            (thumb_col_start + i) * col_spacing,
            thumb_base_y,
            z_off
        ])
        cs_keycap(keys[i]);
    }
}

/* ── Layout module (finger + thumb + alt thumb) ──────────────── */

module go60_half_board() {
    // Finger keys: 6 columns x 4 rows
    for (col = [0:5]) {
        for (row = [0:3]) {
            translate([
                col * col_spacing,
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
c2_r3_pos = [4 * col_spacing, (1.5 - 2) * row_spacing + stagger[4], 0];

/* ── Place both halves ───────────────────────────────────────── */

left_offset = [-(half_gap / 2) - 5 * col_spacing, 0, 0];
right_offset = [half_gap / 2 + 5 * col_spacing, 0, 0];

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
translate(right_offset + [-1, 1, 1] * c2_r3_pos + [0, 0, alt_z])
    cs_keycap("cs_r3_lateral_r_dot");    // dot alternate

translate(right_offset + [-1, 1, 1] * c2_r3_pos + [0, 0, 2 * alt_z])
    cs_keycap("cs_r3_lateral_r");        // spare plain R3
