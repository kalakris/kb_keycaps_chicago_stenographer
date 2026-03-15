// Go60 - Regular columns (C3, C4) with homing bar on home row
//
// Same as export_go60_regular_columns.scad but with a homing bar on
// the R3 home row key for tactile home position reference.
//
// Order quantity: 1 (for the column where you want bar-style homing)

use <gen_sprued_keycaps.scad>

keycap_ids = [
    // Left Keyboard Side
    "cs_r1_1",      // Row 1 (top)
    "cs_r2_1",      // Row 2
    "cs_r3_1_bar",  // Row 3 (home) - with homing bar
    "cs_r4_1",      // Row 4 (bottom)

    // Right Keyboard Side
    "cs_r1_1",      // Row 1 (top)
    "cs_r2_1",      // Row 2
    "cs_r3_1_bar",  // Row 3 (home) - with homing bar
    "cs_r4_1",      // Row 4 (bottom)
];

gen_sprued_keycaps(keycap_ids, vertical=true);
