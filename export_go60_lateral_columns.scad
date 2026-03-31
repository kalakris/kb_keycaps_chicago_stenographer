// Go60 - Lateral column pair without homing keys
//
// Lateral keycaps have a smooth side for easier finger sliding between
// columns. Used on C1 (inner index), C2 (index), C5 (pinky), C6 (outer
// pinky) in pairs.
//
// Uses R1 (steep top) -> R2 -> R3 -> R4 sculpt across 4 finger rows.
//
// The left and right variations sit next to each other in a column pair.
//
// 10 keys: 8 lateral (R1-R4 × 2 columns) + 2 spare ridged thumbs
// Order quantity: 2 (for C6+C5 on each half)

use <gen_sprued_keycaps.scad>

keycap_ids = [
    // Left column of pair
    "cs_r1_lateral_l",  // Row 1 (top)
    "cs_r2_lateral_l",  // Row 2
    "cs_r3_lateral_l",  // Row 3 (home)
    "cs_r4_lateral_l",  // Row 4 (bottom)

    // Right column of pair
    "cs_r1_lateral_r",  // Row 1 (top)
    "cs_r2_lateral_r",  // Row 2
    "cs_r3_lateral_r",  // Row 3 (home)
    "cs_r4_lateral_r",  // Row 4 (bottom)

    // Spare ridged thumb keys (no spares on other plates)
    "cs_t_1_l",         // Spare outer thumb (left)
    "cs_t_1_r",         // Spare outer thumb (right)
];

gen_sprued_keycaps(keycap_ids, vertical=true);
