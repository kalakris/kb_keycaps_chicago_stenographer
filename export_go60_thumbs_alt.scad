// Go60 - Alternative thumb cluster
//
// Lower-profile alternative using convex R2 keys for the main thumb
// positions and 1.25u vertically-oriented thumb keys for outer/inner.
//
// 10 keys: 8 convex R2 + 1 thumb 1.25u left + 1 thumb 1.25u right
// Order quantity: 1

use <gen_sprued_keycaps.scad>

keycap_ids = [
    // Left Keyboard Side
    "cs_t_125_l",  // Outer thumb (left)
    "cs_r2x_1",    // Convex
    "cs_r2x_1",    // Convex
    "cs_r2x_1",    // Convex
    "cs_r2x_1",    // Convex

    // Right Keyboard Side
    "cs_r2x_1",    // Convex
    "cs_r2x_1",    // Convex
    "cs_r2x_1",    // Convex
    "cs_r2x_1",    // Convex
    "cs_t_125_r",  // Outer thumb (right)
];

gen_sprued_keycaps(keycap_ids, spacing=20);
