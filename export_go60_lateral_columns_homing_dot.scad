// Go60 - Lateral column pair with homing dots on home row
//
// Same as export_go60_lateral_columns.scad but includes extra homing dot
// keys for the R3 home row position.
//
// Order quantity: use this instead of the non-homing version for pairs
// where you want dot-style homing markers.

use <gen_sprued_keycaps.scad>

keycap_ids = [
    // Left column of pair
    "cs_r1_lateral_l",      // Row 1 (top)
    "cs_r2_lateral_l",      // Row 2
    "cs_r3_lateral_l",      // Row 3 (home)
    "cs_r4_lateral_l",      // Row 4 (bottom)

    // Right column of pair
    "cs_r1_lateral_r",      // Row 1 (top)
    "cs_r2_lateral_r",      // Row 2
    "cs_r3_lateral_r",      // Row 3 (home)
    "cs_r4_lateral_r",      // Row 4 (bottom)

    // Homing keys (replace one R3 key from above with these)
    "cs_r3_lateral_l_dot",  // Left column homing dot
    "cs_r3_lateral_r_dot",  // Right column homing dot
];

gen_sprued_keycaps(keycap_ids, vertical=true);
