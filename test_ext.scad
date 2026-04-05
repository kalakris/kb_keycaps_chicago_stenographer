use <Choc_Chicago_Steno_Convex.scad>

test_keyID = 7;  // 7=ext-A, 8=ext-B

keycap_cs_convex(
    keyID  = test_keyID,
    Stem   = true,
    StemRot = 0,
    Dish   = true,
    visualizeDish = false,
    homeDot = false
);
