// Go60 - Regular columns (C3, C4) without homing keys
//
// These are the ridged steno keycaps for the middle and ring finger columns.
// Uses R1 (steep top) -> R2 -> R3 -> R4 sculpt across 4 finger rows.
//
// Order quantity: 2 (one for each regular column pair C3+C4)
// If you want homing keys on some columns, replace one order with
// export_go60_regular_columns_homing_bar or _homing_dot instead.

use <gen_sprued_keycaps.scad>

keycap_ids = [
    // Left Keyboard Side
    "cs_r1_1",  // Row 1 (top)
    "cs_r2_1",  // Row 2
    "cs_r3_1",  // Row 3 (home)
    "cs_r4_1",  // Row 4 (bottom)

    // Right Keyboard Side
    "cs_r1_1",  // Row 1 (top)
    "cs_r2_1",  // Row 2
    "cs_r3_1",  // Row 3 (home)
    "cs_r4_1",  // Row 4 (bottom)
];

gen_sprued_keycaps(keycap_ids, vertical=true);
