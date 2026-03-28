// Go60 - Inner lateral columns (C2+C1) for LEFT keyboard half
//
// C2 (index) and C1 (inner index) lateral pair for the left half.
// Includes both bar and dot homing options for C2 R3 — pick one,
// the other becomes a spare along with the plain R3 it replaces.
//
// On the left half, C2 = lateral_l, C1 = lateral_r.
//
// 10 keys: 8 regular (C2+C1 R1-R4) + 1 homing bar + 1 homing dot
// Order quantity: 1

use <gen_sprued_keycaps.scad>

keycap_ids = [
    // C2 (index) - lateral_l
    "cs_r1_lateral_l",      // Row 1 (top)
    "cs_r2_lateral_l",      // Row 2
    "cs_r3_lateral_l",      // Row 3 (home) - spare, replaced by bar or dot
    "cs_r4_lateral_l",      // Row 4 (bottom)

    // C1 (inner index) - lateral_r
    "cs_r1_lateral_r",      // Row 1 (top)
    "cs_r2_lateral_r",      // Row 2
    "cs_r3_lateral_r",      // Row 3 (home)
    "cs_r4_lateral_r",      // Row 4 (bottom)

    // Homing options for C2 R3 (pick one)
    "cs_r3_lateral_l_bar",  // C2 homing bar
    "cs_r3_lateral_l_dot",  // C2 homing dot
];

gen_sprued_keycaps(keycap_ids, vertical=true);
