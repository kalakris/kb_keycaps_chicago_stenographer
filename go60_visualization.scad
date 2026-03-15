// Go60 Full Keyboard Visualization
//
// NOT for printing - this places all keycaps at their approximate
// positions to visualize the final sculpt contours of both halves.
//
// Assumes choc spacing (18x17mm). Column stagger and thumb positions
// are estimated for a typical columnar ergo layout.
//
// Open in OpenSCAD and hit F5 (preview) or F6 (render + export STL).

use <gen_sprued_keycaps.scad>

/* ── Spacing ─────────────────────────────────────────────────── */

col_spacing = 18;    // horizontal distance between columns
row_spacing = 17;    // vertical distance between rows
half_gap    = 50;    // gap between left and right halves

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
    // C4 - ring (regular)
    ["cs_r1_1",         "cs_r2_1",         "cs_r3_1_dot",         "cs_r4_1"        ],
    // C3 - middle (regular)
    ["cs_r1_1",         "cs_r2_1",         "cs_r3_1_bar",         "cs_r4_1"        ],
    // C2 - index (lateral_l of C2+C1 pair)
    ["cs_r1_lateral_l", "cs_r2_lateral_l", "cs_r3_lateral_l_bar", "cs_r4_lateral_l"],
    // C1 - inner index (lateral_r of C2+C1 pair)
    ["cs_r1_lateral_r", "cs_r2_lateral_r", "cs_r3_lateral_r",     "cs_r4_lateral_r"],
];

// Thumb row: spare, spare, outer, convex, convex, inner
left_thumb_keys = [
    "cs_r3x_1",    // spare (under C6)
    "cs_r3x_1",    // spare (under C5)
    "cs_t_1_l",    // outer thumb
    "cs_r3x_1",    // convex
    "cs_r3x_1",    // convex
    "cs_t_1_r",    // inner thumb
];

/* ── Layout module ───────────────────────────────────────────── */

module go60_left_half() {
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

    // Thumb row (estimated arc below finger keys)
    thumb_base_y = -1.5 * row_spacing - 22;
    thumb_arc     = [0, 2, 4, 5, 3, 0];  // slight upward arc in the middle

    for (i = [0:5]) {
        translate([
            i * col_spacing,
            thumb_base_y + thumb_arc[i],
            0
        ])
        rotate([0, 0, -8])
        cs_keycap(left_thumb_keys[i]);
    }
}

/* ── Place both halves ───────────────────────────────────────── */

// Left half
translate([-(half_gap / 2) - 5 * col_spacing, 0, 0])
    go60_left_half();

// Right half (physical mirror of left - contours are symmetric)
translate([half_gap / 2 + 5 * col_spacing, 0, 0])
    mirror([1, 0, 0])
        go60_left_half();
