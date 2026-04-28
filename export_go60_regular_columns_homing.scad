// Go60 - Regular columns with homing keys (non-lateral C1+C2)
//
// Same finger-key layout as export_go60_regular_columns.scad (ridged
// R1-R4 for two columns) but the 2 trailing slots are swapped from
// spare convex thumbs to homing-bar and homing-dot variants of cs_r3_1.
//
// Use for the non-lateral version of C1+C2 (inner index pair). Each
// half needs one homing key on C2 R3 (the F / J position); print 2 of
// these plates so each half can pick bar or dot.
//
// 10 keys: 8 finger (R1-R4 x 2 columns) + 1 homing bar + 1 homing dot
// Order quantity: 2 (one per keyboard half)

use <gen_sprued_keycaps.scad>

keycap_ids = [
    // Left column of pair
    "cs_r1_1",      // Row 1 (top)
    "cs_r2_1",      // Row 2
    "cs_r3_1",      // Row 3 (home) - spare, replaced by bar or dot
    "cs_r4_1",      // Row 4 (bottom)

    // Right column of pair
    "cs_r1_1",      // Row 1 (top)
    "cs_r2_1",      // Row 2
    "cs_r3_1",      // Row 3 (home) - spare, replaced by bar or dot
    "cs_r4_1",      // Row 4 (bottom)

    // Homing options for C2 R3 (pick one per half)
    "cs_r3_1_bar",  // C2 homing bar
    "cs_r3_1_dot",  // C2 homing dot
];

gen_sprued_keycaps(keycap_ids, vertical=true);
