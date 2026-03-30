// Go60 - Thumb cluster and spare keys
//
// Go60 thumb row per half: [spare, spare, outer, convex, convex, inner]
//
// The 4 main thumb keys are: outer (ridged), 2x convex (domed), inner (ridged)
// The 2 spare keys use convex profile since they can be pressed from various
// angles (by thumb or by moving the whole hand).
//
// Order quantity: 1

use <gen_sprued_keycaps.scad>

keycap_ids = [
    // Left Keyboard Side
    "cs_t_1_l",   // Outer thumb (left)
    "cs_r3x_1",   // Convex thumb
    "cs_r3x_1",   // Convex thumb
    "cs_t_1_r",   // Inner thumb (left)

    // Right Keyboard Side
    "cs_t_1_l",   // Inner thumb (right)
    "cs_r3x_1",   // Convex thumb
    "cs_r3x_1",   // Convex thumb
    "cs_t_1_r",   // Outer thumb (right)

    // Spare keys (2 per side, convex for versatility)
    "cs_r3x_1",   // Spare (left)
    "cs_r3x_1",   // Spare (right)
];

gen_sprued_keycaps(keycap_ids, spacing=20);
