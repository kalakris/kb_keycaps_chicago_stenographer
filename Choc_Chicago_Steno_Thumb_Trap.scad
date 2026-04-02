use <scad-utils/morphology.scad>
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <scad-utils/trajectory.scad>
use <scad-utils/trajectory_path.scad>
use <sweep.scad>
use <skin.scad>

// Trapezoidal / sector-shaped keycaps for arc-splayed thumb positions
//
// On the Go60 (and similar boards), splayed thumb keys sit on a
// circular arc. Standard rectangular keycaps leave wedge-shaped gaps.
// This module generates sector-shaped keycaps that fill those gaps:
//   - Wider on the outer edge (away from arc center)
//   - Narrower on the inner edge (toward arc center)
//   - Arced outer/inner edges following the arc curvature
//   - Radial side edges (or column-aligned for T1 inner edge)
//
// Two dish types are supported:
//   dishType="convex" — dome top (two-sided DishShape cut, like R3x)
//   dishType="thumb"  — concave scoop (single DishShape2 sweep, like T1)
//
// keyID 0: Convex symmetric sector (T2)
// keyID 1: Thumb symmetric sector (T3)
// keyID 2: Convex with inner edge aligned to C1 column (T1)

// Preview: render T1 keycap (convex, inner edge aligned to C1)
keycap_cs_thumb_trap(
    keyID     = 2,
    dishType  = "convex",
    Stem      = true,
    StemRot   = 0,
    Dish      = true,
    visualizeDish = false,
    crossSection  = false
);

/* ── Arc geometry (Go60 defaults, must match go60_visualization.scad) ── */

trap_arc_r     = 79.1;   // arc radius at key center
trap_arc_step  = 14.0;   // angular spacing between adjacent splayed keys (deg)
trap_gap       = 1.0;    // gap between adjacent keycap edges (mm)
trap_arc_cx    = 73.2;   // arc center x (half-board coords)
trap_arc_start = 14.9;   // angle of T1 (first splayed key) from vertical

/* ── Derived geometry ── */

trap_half_angle = trap_arc_step / 2;

// Half-angle reduced by gap (gap measured at arc_r)
trap_gap_ha     = atan2(trap_gap / 2, trap_arc_r);
trap_eff_ha     = trap_half_angle - trap_gap_ha;

// Center width (at arc_r) with gap subtracted
trap_center_width = 2 * trap_arc_r * sin(trap_eff_ha);

/* ── T1 inner edge alignment with C1 ── */
// T1's inner edge (left side on left half) should align vertically
// with C1's left edge above it. The stem stays at the switch center.

// T1 position and rotation in half-board coordinates
trap_t1_x   = trap_arc_cx + trap_arc_r * sin(trap_arc_start);
trap_t1_rot = -trap_arc_start;

// C1 left edge position (half-board coords)
// C1 at col_x[5] = 92.5, keycap BotWid = 17.2
trap_c1_left_x = 92.5 - 17.2/2;  // = 83.9

// Convert vertical line at world x = trap_c1_left_x to key-local frame.
// In local coords: x = x0 + slope * y
//   x0    = dx / cos(rot)
//   slope = tan(rot)
// where dx = target_world_x - key_world_x, rot = key_rotation
trap_t1_dx = trap_c1_left_x - trap_t1_x;
trap_t1_left_line = [trap_t1_dx / cos(trap_t1_rot), tan(trap_t1_rot)];

// T1 depth taper: 16mm (1u) on left, 20mm (1.25u) on right.
// BotLen for T1 = 18mm (average). Depth ratios scale the half-depth
// at each side relative to the center hd.
trap_t1_depth_ratio = [8/9, 10/9];  // [left, right]

/* ── Resolution ── */

wallthickness = 1.2;
topthickness  = 2.5;
stepsize      = 50;
step          = 1;
fn            = 60;
layers        = 50;

/* ── Stem ── */

slop            = 0.3;
stemWid         = 8;
stemLen         = 6;
stemCrossHeight = 1.8;
extra_vertical  = 0.6;
stemLayers      = 50;

/* ── Key shape parameters ── */
// BotWid is the center width of the trapezoidal footprint.
// The actual outer/inner widths are computed from arc geometry.
//
// keyID 0: Convex R3x, 1.25u depth (for T2) — flat dome top
// keyID 1: Thumb, 1.25u depth (for T3) — concave scoop
// keyID 2: Convex R3x, tapered depth 16→20mm (for T1) — inner edge aligned to C1

keyParameters = [
//  BotWid              BotLen  TWDif  TLDif  keyh  WSft  LSft  XSkew  YSkew ZSkew WEx LEx  CapR0i CapR0f CapR1i CapR1f CapREx StemEx
    [trap_center_width, 20.00,  5.6,   5,     4.4,  0,    0.0,  0.01,  0,     0,   2,  2,   .10,    3,    .10,    3,     2,     2], // 0: Convex 1.25u (T2)
    [trap_center_width, 20.00,  4.25,  3.25,  4.95, -.5,  0.0,  -3,   -3,     0,   2,  2,   .10,    2,    .10,    2,     2,     2], // 1: Thumb 1.25u (T3)
    [trap_center_width, 18.00,  5.6,   5,     4.4,  0,    0.0,  0.01,  0,     0,   2,  2,   .10,    3,    .10,    3,     2,     2], // 2: Convex tapered (T1)
];

/* ── Dish parameters ── */

convexDishParameters = [
//  FFwd1  FFwd2  FPit1  FPit2  DshDep DshHDif FArcIn FArcFn FArcEx  BFwd1  BFwd2  BPit1  BPit2  BArcIn BArcFn BArcEx
    [ 8.0,  6.0,   -3,   -45,    1.5,   3.75,  14.0,  14.5,    2,    8.0,   6.0,    -3,   -45,   14.0,  14.5,    2], // Convex dome, extended to cover all sector corners
];

thumbDishParameters = [
//  FFwd1 FFwd2 FPit1 FPit2  DshDep DshHDif FArcIn FArcFn FArcEx  BFwd1  BFwd2  BPit1  BPit2  BArcIn BArcFn BArcEx FTani FTanf BTani BTanf TanEX PhiInit PhiFin
    [  9,  7,      0,  -40,      7,    1.7,   20,    24,     2,      9,   5.5,     5,   -50,    20,    24,     2,    5,   3.75,   2,  3.75,   2,   199,   210], // Thumb scoop, extended to cover all sector corners
];

/* ── Parameter accessor functions ── */

function BottomWidth(keyID)  = keyParameters[keyID][0];
function BottomLength(keyID) = keyParameters[keyID][1];
function TopWidthDiff(keyID) = keyParameters[keyID][2];
function TopLenDiff(keyID)   = keyParameters[keyID][3];
function KeyHeight(keyID)    = keyParameters[keyID][4];
function TopWidShift(keyID)  = keyParameters[keyID][5];
function TopLenShift(keyID)  = keyParameters[keyID][6];
function XAngleSkew(keyID)   = keyParameters[keyID][7];
function YAngleSkew(keyID)   = keyParameters[keyID][8];
function ZAngleSkew(keyID)   = keyParameters[keyID][9];
function WidExponent(keyID)  = keyParameters[keyID][10];
function LenExponent(keyID)  = keyParameters[keyID][11];
function CapRound0i(keyID)   = keyParameters[keyID][12];
function CapRound0f(keyID)   = keyParameters[keyID][13];
function CapRound1i(keyID)   = keyParameters[keyID][14];
function CapRound1f(keyID)   = keyParameters[keyID][15];
function ChamExponent(keyID) = keyParameters[keyID][16];
function StemExponent(keyID) = keyParameters[keyID][17];

// Convex dish accessors
function CxFrontForward1(i) = convexDishParameters[i][0];
function CxFrontForward2(i) = convexDishParameters[i][1];
function CxFrontPitch1(i)   = convexDishParameters[i][2];
function CxFrontPitch2(i)   = convexDishParameters[i][3];
function CxDishDepth(i)     = convexDishParameters[i][4];
function CxDishHeightDif(i) = convexDishParameters[i][5];
function CxFrontInitArc(i)  = convexDishParameters[i][6];
function CxFrontFinArc(i)   = convexDishParameters[i][7];
function CxFrontArcExpo(i)  = convexDishParameters[i][8];
function CxBackForward1(i)  = convexDishParameters[i][9];
function CxBackForward2(i)  = convexDishParameters[i][10];
function CxBackPitch1(i)    = convexDishParameters[i][11];
function CxBackPitch2(i)    = convexDishParameters[i][12];
function CxBackInitArc(i)   = convexDishParameters[i][13];
function CxBackFinArc(i)    = convexDishParameters[i][14];
function CxBackArcExpo(i)   = convexDishParameters[i][15];

// Thumb dish accessors
function ThFrontForward1(i) = thumbDishParameters[i][0];
function ThFrontForward2(i) = thumbDishParameters[i][1];
function ThFrontPitch1(i)   = thumbDishParameters[i][2];
function ThFrontPitch2(i)   = thumbDishParameters[i][3];
function ThDishDepth(i)     = thumbDishParameters[i][4];
function ThDishHeightDif(i) = thumbDishParameters[i][5];
function ThFrontInitArc(i)  = thumbDishParameters[i][6];
function ThFrontFinArc(i)   = thumbDishParameters[i][7];
function ThFrontArcExpo(i)  = thumbDishParameters[i][8];
function ThBackForward1(i)  = thumbDishParameters[i][9];
function ThBackForward2(i)  = thumbDishParameters[i][10];
function ThBackPitch1(i)    = thumbDishParameters[i][11];
function ThBackPitch2(i)    = thumbDishParameters[i][12];
function ThBackInitArc(i)   = thumbDishParameters[i][13];
function ThBackFinArc(i)    = thumbDishParameters[i][14];
function ThBackArcExpo(i)   = thumbDishParameters[i][15];
function ThForwardTanInit(i)= thumbDishParameters[i][16];
function ThForwardTanFin(i) = thumbDishParameters[i][17];
function ThBackTanInit(i)   = thumbDishParameters[i][18];
function ThBackTanFin(i)    = thumbDishParameters[i][19];
function ThTanArcExpo(i)    = thumbDishParameters[i][20];
function ThTransAngleInit(i)= thumbDishParameters[i][21];
function ThTransAngleFin(i) = thumbDishParameters[i][22];

/* ── Transformation functions ── */

function CapTranslation(t, keyID) = [
    ((1-t)/layers * TopWidShift(keyID)),
    ((1-t)/layers * TopLenShift(keyID)),
    (t/layers * KeyHeight(keyID))
];

function InnerTranslation(t, keyID) = [
    ((1-t)/layers * TopWidShift(keyID)),
    ((1-t)/layers * TopLenShift(keyID)),
    (t/layers * (KeyHeight(keyID) - topthickness))
];

function CapRotation(t, keyID) = [
    ((1-t)/layers * XAngleSkew(keyID)),
    ((1-t)/layers * YAngleSkew(keyID)),
    ((1-t)/layers * ZAngleSkew(keyID))
];

function CapTransform(t, keyID) = [
    pow(t/layers, WidExponent(keyID)) * (BottomWidth(keyID) - TopWidthDiff(keyID))
        + (1 - pow(t/layers, WidExponent(keyID))) * BottomWidth(keyID),
    pow(t/layers, LenExponent(keyID)) * (BottomLength(keyID) - TopLenDiff(keyID))
        + (1 - pow(t/layers, LenExponent(keyID))) * BottomLength(keyID)
];

function CapRoundness(t, keyID) = [
    pow(t/layers, ChamExponent(keyID)) * CapRound0f(keyID)
        + (1 - pow(t/layers, ChamExponent(keyID))) * CapRound0i(keyID),
    pow(t/layers, ChamExponent(keyID)) * CapRound1f(keyID)
        + (1 - pow(t/layers, ChamExponent(keyID))) * CapRound1i(keyID)
];

function InnerTransform(t, keyID) = [
    pow(t/layers, WidExponent(keyID)) * (BottomWidth(keyID) - TopLenDiff(keyID) - wallthickness*2)
        + (1 - pow(t/layers, WidExponent(keyID))) * (BottomWidth(keyID) - wallthickness*2),
    pow(t/layers, LenExponent(keyID)) * (BottomLength(keyID) - TopLenDiff(keyID) - wallthickness*2)
        + (1 - pow(t/layers, LenExponent(keyID))) * (BottomLength(keyID) - wallthickness*2)
];

function StemTranslation(t, keyID) = [
    0, 0,
    stemCrossHeight + .1 + (t/stemLayers * (KeyHeight(keyID) - topthickness - stemCrossHeight - .1))
];

function StemTransform(t, keyID, StemRot) =
    let(s = min(t/stemLayers, 1))
    StemRot == 0
    ? [
        pow(s, StemExponent(keyID)) * (BottomWidth(keyID) - TopLenDiff(keyID) - wallthickness*2)
            + (1 - pow(s, StemExponent(keyID))) * (stemWid - 2*slop),
        pow(s, StemExponent(keyID)) * (BottomLength(keyID) - TopLenDiff(keyID) - wallthickness*2)
            + (1 - pow(s, StemExponent(keyID))) * (stemLen - 2*slop)
      ]
    : [
        pow(s, StemExponent(keyID)) * (BottomWidth(keyID) - TopLenDiff(keyID) - wallthickness*2)
            + (1 - pow(s, StemExponent(keyID))) * (stemLen - 2*slop),
        pow(s, StemExponent(keyID)) * (BottomLength(keyID) - TopLenDiff(keyID) - wallthickness*2)
            + (1 - pow(s, StemExponent(keyID))) * (stemWid - 2*slop)
      ];

/* ── Sector cross-section function ── */

// Generates a 2D point list for a sector-shaped cross-section.
//   X axis = tangential (along the arc)
//   Y axis = radial (positive = away from arc center)
//
// When left_line is provided as [x0, slope], the left edge follows the
// line x = x0 + slope*y instead of a radial line. This allows aligning
// the inner edge with a column above (e.g. T1 aligned to C1).
// The left_line values scale proportionally with center_hw so the
// alignment tapers naturally toward the top of the keycap.

// depth_ratio = [left_ratio, right_ratio] scales the half-depth on each
// side. Default [1,1] = symmetric. For T1: [8/9, 10/9] tapers from
// 1u on the left (C1 side) to 1.25u on the right (T2 side).
// When depth varies, outer/inner edges interpolate smoothly between
// the different radii rather than following a single arc.

function sector_rectangle(a, b=[0.1, 0.1], arc_r=79.1, fn=32, left_line=undef, depth_ratio=[1,1], fillet=0) =
    let(
        center_hw = a[0],
        hd = a[1],
        hd_left  = hd * depth_ratio[0],
        hd_right = hd * depth_ratio[1],
        eff_ha = asin(min(center_hw / arc_r, 0.99)),
        n = fn,

        // ── Right edge corners (radial, using hd_right) ──
        r_out_r = arc_r + hd_right,
        r_in_r  = arc_r - hd_right,
        out_r_x =  r_out_r * sin(eff_ha),
        out_r_y =  r_out_r * cos(eff_ha) - arc_r,
        in_r_x  =  r_in_r * sin(eff_ha),
        in_r_y  =  r_in_r * cos(eff_ha) - arc_r,

        // ── Left edge corners (using hd_left) ──
        r_out_l = arc_r + hd_left,
        r_in_l  = arc_r - hd_left,

        // Default: radial line at -eff_ha
        rad_out_l_x = -r_out_l * sin(eff_ha),
        rad_out_l_y =  r_out_l * cos(eff_ha) - arc_r,
        rad_in_l_x  = -r_in_l * sin(eff_ha),
        rad_in_l_y  =  r_in_l * cos(eff_ha) - arc_r,

        // Override: line x = ll_x0 + ll_slope * y
        ll_scale = center_hw / (trap_center_width / 2),
        ll_x0    = left_line != undef ? left_line[0] * ll_scale : 0,
        ll_slope = left_line != undef ? left_line[1] : 0,

        // Intersect line with outer arc (radius r_out_l for left side)
        ll_A = 1 + ll_slope*ll_slope,
        ll_B = 2*(ll_x0*ll_slope + arc_r),
        ll_C_out = ll_x0*ll_x0 + arc_r*arc_r - r_out_l*r_out_l,
        ll_disc_out = ll_B*ll_B - 4*ll_A*ll_C_out,
        ll_y_out = (-ll_B + sqrt(max(0, ll_disc_out))) / (2*ll_A),
        ll_x_out_v = ll_x0 + ll_slope*ll_y_out,

        // Intersect line with inner arc (radius r_in_l for left side)
        ll_C_in = ll_x0*ll_x0 + arc_r*arc_r - r_in_l*r_in_l,
        ll_disc_in = ll_B*ll_B - 4*ll_A*ll_C_in,
        ll_y_in = (-ll_B + sqrt(max(0, ll_disc_in))) / (2*ll_A),
        ll_x_in_v = ll_x0 + ll_slope*ll_y_in,

        // Select left corners
        out_l_x = left_line != undef ? ll_x_out_v : rad_out_l_x,
        out_l_y = left_line != undef ? ll_y_out   : rad_out_l_y,
        in_l_x  = left_line != undef ? ll_x_in_v  : rad_in_l_x,
        in_l_y  = left_line != undef ? ll_y_in    : rad_in_l_y,

        // Arc angles at left corners
        a_out_l = asin(max(-0.99, min(0.99, out_l_x / r_out_l))),
        a_in_l  = asin(max(-0.99, min(0.99, in_l_x / r_in_l))),

        // Fillet: chamfer sharp corners to prevent tangential dish intersections.
        // Each edge is shortened by fillet/edge_length at each end; the polygon
        // connection between shortened edges forms the chamfer.
        _right_len = norm([out_r_x - in_r_x, out_r_y - in_r_y]),
        _left_len  = norm([out_l_x - in_l_x, out_l_y - in_l_y]),
        _outer_len = ((r_out_r + r_out_l) / 2) * abs(eff_ha - a_out_l) * 3.14159265 / 180,
        _inner_len = ((r_in_r + r_in_l) / 2) * abs(eff_ha - a_in_l) * 3.14159265 / 180,
        _fr = fillet > 0 ? min(fillet / max(_right_len, 0.001), 0.12) : 0,
        _fo = fillet > 0 ? min(fillet / max(_outer_len, 0.001), 0.12) : 0,
        _fl = fillet > 0 ? min(fillet / max(_left_len, 0.001), 0.12) : 0,
        _fi = fillet > 0 ? min(fillet / max(_inner_len, 0.001), 0.12) : 0
    )
    concat(
        // Right edge: inner-right to outer-right (shortened by fillet at each end)
        [for (i = [0:n-1]) let(t = _fr + i/n * (1 - 2*_fr))
            [(1-t)*in_r_x + t*out_r_x, (1-t)*in_r_y + t*out_r_y]],

        // Outer edge: from right (+eff_ha, r_out_r) to left (a_out_l, r_out_l)
        [for (i = [0:n-1]) let(t = _fo + i/n * (1 - 2*_fo),
            r_out_t = r_out_r + t*(r_out_l - r_out_r),
            a_angle = eff_ha + t*(a_out_l - eff_ha))
            [r_out_t*sin(a_angle), r_out_t*cos(a_angle) - arc_r]],

        // Left edge: outer-left to inner-left (straight line)
        [for (i = [0:n-1]) let(t = _fl + i/n * (1 - 2*_fl))
            [(1-t)*out_l_x + t*in_l_x, (1-t)*out_l_y + t*in_l_y]],

        // Inner edge: from left (a_in_l, r_in_l) to right (+eff_ha, r_in_r)
        [for (i = [0:n-1]) let(t = _fi + i/n * (1 - 2*_fi),
            r_in_t = r_in_l + t*(r_in_r - r_in_l),
            a_angle = a_in_l + t*(eff_ha - a_in_l))
            [r_in_t*sin(a_angle), r_in_t*cos(a_angle) - arc_r]]
    );

/* ── Dish shape functions ── */

function ellipse(a, b, d = 0, rot1 = 0, rot2 = 360) =
    [for (t = [rot1:step:rot2]) [a*cos(t)+a, b*sin(t)*(1+d*cos(t))]];

function DishShape(a, b, c, d) =
    concat(
        [[c+a,-b]],
        ellipse(a, b, d = 0, rot1 = 270, rot2 = 450),
        [[c+a,b]]
    );

function DishShape2(a, b, phi = 200, theta, r) =
    concat(
        ellipse(a, b, d = 0, rot1 = 90, rot2 = phi),
        [for (t = [step:step*2:theta])
            let(sig = atan(a*cos(phi) / -b*sin(phi)))
            [r*cos(-atan(-a*cos(phi)/b*sin(phi)) - t)
                + a*cos(phi) - r*cos(sig) + a,
             r*sin(-atan(-a*cos(phi)/b*sin(phi)) - t)
                + b*sin(phi) + r*sin(sig)]
        ],
        [[a, b*sin(phi) - r*sin(theta)*2]]
    );

/* ── Stem modules ── */

module choc_stem(draftAng = 5) {
    stemHeight = 3.1;
    dia = .15;
    wids = 1.2/2;
    lens = 2.9/2;
    module Stem() {
        difference() {
            translate([0, 0, -stemHeight/2])
            linear_extrude(height = stemHeight) hull() {
                translate([wids-dia, -3/2]) circle(d=dia);
                translate([-wids+dia, -3/2]) circle(d=dia);
                translate([wids-dia, 3/2]) circle(d=dia);
                translate([-wids+dia, 3/2]) circle(d=dia);
            }
            translate([3.9, 0]) cylinder(d1=7+sin(draftAng)*stemHeight, d2=7, 3.5, center=true, $fn=64);
            translate([-3.9, 0]) cylinder(d1=7+sin(draftAng)*stemHeight, d2=7, 3.5, center=true, $fn=64);
        }
    }
    translate([5.7/2, 0, -stemHeight/2+2]) Stem();
    translate([-5.7/2, 0, -stemHeight/2+2]) Stem();
}

/* ── Helper functions ── */

function sign_x(i, n) =
    i < n/4 || i > n - n/4 ? 1 :
    i > n/4 && i < n - n/4 ? -1 :
    0;

function sign_y(i, n) =
    i > 0 && i < n/2 ? 1 :
    i > n/2 ? -1 :
    0;

function rounded_rectangle_profile(size=[1,1], r=1, fn=32) = [
    for (index = [0:fn-1])
        let(a = index/fn*360)
            r * [cos(a), sin(a)]
            + sign_x(index, fn) * [size[0]/2-r, 0]
            + sign_y(index, fn) * [0, size[1]/2-r]
];

// Smooth cross-section from Choc_Chicago_Steno_Convex.scad.
// Used to build a smooth body for dish boolean (avoids dish
// artifacts at sector corners), then intersected with sector shape.
function elliptical_rectangle(a = [1,1], b =[1,1], fn=32) = [
    for (index = [0:fn-1])
     let(theta1 = -atan(a[1]/b[1])+ 2*atan(a[1]/b[1])*index/fn)
      [b[1]*cos(theta1), a[1]*sin(theta1)]
    + [a[0]*cos(atan(b[0]/a[0])) , 0]
    - [b[1]*cos(atan(a[1]/b[1])) , 0],
    for(index = [0:fn-1])
     let(theta2 = atan(b[0]/a[0]) + (180 -2*atan(b[0]/a[0]))*index/fn)
      [a[0]*cos(theta2), b[0]*sin(theta2)]
    - [0, b[0]*sin(atan(b[0]/a[0]))]
    + [0, a[1]*sin(atan(a[1]/b[1]))],
    for(index = [0:fn-1])
     let(theta2 = -atan(a[1]/b[1])+180+ 2*atan(a[1]/b[1])*index/fn)
      [b[1]*cos(theta2), a[1]*sin(theta2)]
    - [a[0]*cos(atan(b[0]/a[0])) , 0]
    + [b[1]*cos(atan(a[1]/b[1])) , 0],
    for(index = [0:fn-1])
     let(theta2 = atan(b[0]/a[0]) + 180 + (180 -2*atan(b[0]/a[0]))*index/fn)
      [a[0]*cos(theta2), b[0]*sin(theta2)]
    + [0, b[0]*sin(atan(b[0]/a[0]))]
    - [0, a[1]*sin(atan(a[1]/b[1]))]
]/2;

/* ── Main keycap module ── */

module keycap_cs_thumb_trap(
    keyID = 0,
    dishType = "convex",
    visualizeDish = false,
    crossSection = false,
    Dish = true,
    Stem = false,
    StemRot = 0,
    homeDot = false,
    homeBar = false
) {
    // T1 overrides (keyID 2): inner edge aligned to C1 + depth taper
    ll = (keyID == 2) ? trap_t1_left_line : undef;
    dr = (keyID == 2) ? trap_t1_depth_ratio : [1, 1];

    // ── Build body ──
    // Strategy: build a smooth elliptical_rectangle keycap, apply dish
    // (clean boolean on smooth surfaces), then intersect with sector
    // shape to trim the footprint. This avoids dish-corner artifacts
    // that occur when the dish boolean operates on sector geometry.

    intersection() {
        // ── Smooth keycap with dish ──
        difference() {
            union() {
                difference() {
                    // Outer shell: oversized smooth body so sector trim exclusively
                    // determines edges (dish operates on smooth surface, no corner artifacts)
                    skin([for (i = [0:layers-1])
                        transform(
                            translation(CapTranslation(i, keyID)) * rotation(CapRotation(i, keyID)),
                            elliptical_rectangle(CapTransform(i, keyID) + [8, 8], b = CapRoundness(i, keyID), fn=fn)
                        )
                    ]);

                    // Cut inner shell
                    if (Stem == true) {
                        translate([0, 0, -.001])
                        skin([for (i = [0:layers-1])
                            transform(
                                translation(InnerTranslation(i, keyID)) * rotation(CapRotation(i, keyID)),
                                elliptical_rectangle(InnerTransform(i, keyID), b = CapRoundness(i, keyID), fn=fn)
                            )
                        ]);
                    }
                }

                // Stem
                if (Stem == true) {
                    rotate([0, 0, StemRot])
                        choc_stem(draftAng = 0);

                    stemLayerAddition = 20;
                    translate([0, 0, -.001])
                    skin([for (i = [0:stemLayers-1 + stemLayerAddition])
                        transform(
                            translation(StemTranslation(i, keyID)),
                            rounded_rectangle_profile(StemTransform(i, keyID, StemRot), fn=fn, r=1)
                        )
                    ]);
                }
            }

            // Dish cut on smooth body — no corner artifacts
            if (Dish == true) {
                if (dishType == "convex") {
                    _cx_dish_cut(keyID);
                } else {
                    _thumb_dish_cut(keyID);
                }
            }

            // Cross-section cut for debugging
            if (crossSection == true) {
                translate([0, -25, -.1]) cube([25, 50, 15]);
            }
        }

        // ── Trim to sector footprint ──
        skin([for (i = [0:layers-1])
            transform(
                translation(CapTranslation(i, keyID)) * rotation(CapRotation(i, keyID)),
                sector_rectangle(
                    a = CapTransform(i, keyID) / 2,
                    b = CapRoundness(i, keyID),
                    arc_r = trap_arc_r,
                    fn = fn,
                    left_line = ll,
                    depth_ratio = dr,
                    fillet = 0.5
                )
            )
        ]);
    }
}

/* ── Convex dish cut (two-sided, from Choc_Chicago_Steno_Convex) ── */

module _cx_dish_cut(keyID) {
    i = 0;

    FrontPath = quantize_trajectories([
        trajectory(forward = CxFrontForward1(i), pitch = CxFrontPitch1(i)),
        trajectory(forward = CxFrontForward2(i), pitch = CxFrontPitch2(i))
    ], steps=stepsize, loop=false, start_position=$t*4);

    BackPath = quantize_trajectories([
        trajectory(forward = CxBackForward1(i), pitch = CxBackPitch1(i)),
        trajectory(forward = CxBackForward2(i), pitch = CxBackPitch2(i))
    ], steps=stepsize, loop=false, start_position=$t*4);

    function FDishArc(t) =
        pow(t/len(FrontPath), CxFrontArcExpo(i)) * CxFrontFinArc(i)
            + (1 - pow(t/len(FrontPath), CxFrontArcExpo(i))) * CxFrontInitArc(i);
    function BDishArc(t) =
        pow(t/len(FrontPath), CxBackArcExpo(i)) * CxBackFinArc(i)
            + (1 - pow(t/len(FrontPath), CxBackArcExpo(i))) * CxBackInitArc(i);

    FrontCurve = [for(j=[0:len(FrontPath)-1])
        transform(FrontPath[j], DishShape(CxDishDepth(i), FDishArc(j), CxDishDepth(i)+1.5, d=0))];
    BackCurve = [for(j=[0:len(BackPath)-1])
        transform(BackPath[j], DishShape(CxDishDepth(i), BDishArc(j), CxDishDepth(i)+1.5, d=0))];

    translate([-TopWidShift(keyID), .00001 - TopLenShift(keyID), KeyHeight(keyID) - CxDishHeightDif(i)])
        rotate([0, -YAngleSkew(keyID), 0])
        rotate([0, -90 + XAngleSkew(keyID), 90 - ZAngleSkew(keyID)])
        skin(FrontCurve);

    translate([-TopWidShift(keyID), -TopLenShift(keyID), KeyHeight(keyID) - CxDishHeightDif(i)])
        rotate([0, -YAngleSkew(keyID), 0])
        rotate([0, -90 - XAngleSkew(keyID), 270 - ZAngleSkew(keyID)])
        skin(BackCurve);
}

/* ── Thumb dish cut (single sweep, from Choc_Chicago_Steno_Thumb) ── */

module _thumb_dish_cut(keyID) {
    i = 0;

    FrontPath = quantize_trajectories([
        trajectory(forward = ThFrontForward1(i), pitch = ThFrontPitch1(i)),
        trajectory(forward = ThFrontForward2(i), pitch = ThFrontPitch2(i))
    ], steps=stepsize, loop=false, start_position=$t*4);

    BackPath = quantize_trajectories([
        trajectory(backward = ThBackForward1(i), pitch = -ThBackPitch1(i)),
        trajectory(backward = ThBackForward2(i), pitch = -ThBackPitch2(i))
    ], steps=stepsize, loop=false, start_position=$t*4);

    function FDishArc(t) =
        pow(t/len(FrontPath), ThFrontArcExpo(i)) * ThFrontFinArc(i)
            + (1 - pow(t/len(FrontPath), ThFrontArcExpo(i))) * ThFrontInitArc(i);
    function BDishArc(t) =
        pow(t/len(FrontPath), ThBackArcExpo(i)) * ThBackFinArc(i)
            + (1 - pow(t/len(FrontPath), ThBackArcExpo(i))) * ThBackInitArc(i);

    function FTanR(t) =
        pow(t/stepsize, ThTanArcExpo(i)) * ThForwardTanInit(i)
            + (1 - pow(t/stepsize, ThTanArcExpo(i))) * ThForwardTanFin(i);
    function BTanR(t) =
        pow(t/stepsize, ThTanArcExpo(i)) * ThBackTanInit(i)
            + (1 - pow(t/stepsize, ThTanArcExpo(i))) * ThBackTanFin(i);

    DishCurve = concat(
        [for(j=[len(BackPath)-1:-1:1]) transform(BackPath[j],
            DishShape2(ThDishDepth(i), BDishArc(j),
                phi=ThTransAngleInit(i), theta=60, r=BTanR(j)))],
        [for(j=[0:len(FrontPath)-1]) transform(FrontPath[j],
            DishShape2(a=ThDishDepth(i), b=FDishArc(j),
                phi=ThTransAngleInit(i), theta=60, r=FTanR(j)))]
    );

    translate([-TopWidShift(keyID), -TopLenShift(keyID), KeyHeight(keyID) - ThDishHeightDif(i)])
        rotate([0, -YAngleSkew(keyID), 0])
        rotate([0, -90 + XAngleSkew(keyID), 90 - ZAngleSkew(keyID)])
        skin(DishCurve);
}
