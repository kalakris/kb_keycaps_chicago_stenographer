// Go60 - Regular columns (C3, C4) with spare thumb convex keys
//
// These are the ridged steno keycaps for the middle and ring finger columns.
// Uses R1 (steep top) -> R2 -> R3 -> R4 sculpt across 4 finger rows.
// Each plate also includes 2 convex thumb keys for the spare thumb
// positions, giving 4 total across both plates.
//
// 10 keys: 8 finger (R1-R4 × 2 halves) + 2 convex thumb
// Order quantity: 2 (one for C3, one for C4)

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

    // Spare thumb keys (convex, for spare positions in thumb cluster)
    "cs_r3x_1", // Convex thumb
    "cs_r3x_1", // Convex thumb
];

gen_sprued_keycaps(keycap_ids, vertical=true);
