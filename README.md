<!-- omit from toc -->
# Chicago Stenographer Keycaps - Optimized for JLCPCB 3D printing

This fork combines multiple chicago stenographer keycaps with sprues into one file to get around the $1 minimum charge of JLCPCB.

If you like these keycaps after trying the 3D printed version, [consider buying original versions from the creator at asymplex.xyz](https://www.asymplex.xyz).

<!-- omit from toc -->
## Table Of Contents

- [1. Photos](#1-photos)
- [2. About this fork](#2-about-this-fork)
- [3. Documentation](#3-documentation)
  - [3.1. Keycap Types](#31-keycap-types)
    - [3.1.1. R2 Keycaps - Top](#311-r2-keycaps---top)
    - [3.1.2. R3 Keycaps - Middle rows and home row](#312-r3-keycaps---middle-rows-and-home-row)
    - [3.1.3. R4 Keycaps - Bottom](#313-r4-keycaps---bottom)
    - [3.1.4. Thumb Keycaps](#314-thumb-keycaps)
    - [3.1.5. 1.5u Thumb Key](#315-15u-thumb-key)
    - [3.1.6. Convex Keycaps](#316-convex-keycaps)
    - [3.1.7. Lateral Keycaps](#317-lateral-keycaps)
  - [3.2. What to print...](#32-what-to-print)
    - [3.2.1. If you have a 5x3 row board (Such as the corne without the outer coulmn)](#321-if-you-have-a-5x3-row-board-such-as-the-corne-without-the-outer-coulmn)
    - [3.2.2. If you have a 6x3 row board (Such as the corne WITH the outer coulmn)](#322-if-you-have-a-6x3-row-board-such-as-the-corne-with-the-outer-coulmn)
    - [3.2.3. If you have a 6x4 board with a num row...](#323-if-you-have-a-6x4-board-with-a-num-row)
  - [3.3. How to order on JLCPCB](#33-how-to-order-on-jlcpcb)
  - [3.4. How to create custom sets of keycaps](#34-how-to-create-custom-sets-of-keycaps)

## 1. Photos

Here are some photos of my prints using JLC 3DP's MJF PA12-HP Nylon process:

![Chicago Stenographer 3D Print - MJF](Photo/CS_jlc3dp_mjf_01.jpg)

![Chicago Stenographer 3D Print - MJF](Photo/CS_jlc3dp_mjf_02.jpg)

## 2. About this fork

This is a fork of [sporkus/PseudoMakeMeKeyCapProfiles](https://github.com/sporkus/PseudoMakeMeKeyCapProfiles/), which is a fork of [pseudoku's original chicago stenographer keycaps](https://github.com/pseudoku/PseudoMakeMeKeyCapProfiles).

Sporkus is the one who came up with the idea and the code to add spuers to the keycaps.

I expanded on those efforts in the following ways...

* Added support to generate rows of varying keycaps
* Fixed the 1.5u inner thumb key that is used in many corne-like boards
* Added the homing bar option to the lateral keys
* Added documentation on how to print the keycaps
* Fixed openscad warnings

![Screenshot of thumbs stl](Photo/thumb_keys_stl.png)

![Screenshot of thumbs back stl](Photo/thumb_keys_stl_back.png)

## 3. Documentation

### 3.1. Keycap Types

When I first started looking into these keycaps, I was incredibly confused by all the available keycap variations and files.

This repo is my attempt to simplify and document what I learned.

In the MX keycap world Rx is used to refer to rows and keycap heights. As someone who was only using Choc keycaps in the ergo keyboard world that was not intuitive for me at all.

But this graphic [from melgeek](https://www.melgeek.com/blogs/guide/the-type-of-keycaps-profiles) explains it well:
![Keycap Rows](Photo/keycap_rows.jpg)

#### 3.1.1. R2 Keycaps - Top

You use these keycaps for the top row, but for the CS keycap set, both R2 and R4 are the same. You simply flip them around.

I also included pre-rotated keycaps as R4, but you can also just print R2 twice.

If your keyboard has a num row, you would use them for the num row and the bottom alpha row.

If you have a corne-style keyboard with just three rows, you would use it for the top and bottom alpha rows.

#### 3.1.2. R3 Keycaps - Middle rows and home row

You use these keycaps for the columns between the top and bottom rows.

If you have a num row, you would use it for the top alpha row and the homerow.

If you have a corne-style keyboard with just three rows, you would use it just for the home row.

#### 3.1.3. R4 Keycaps - Bottom

As explained in the R2 section, these are exactly the same as the R2 files, but pre-rotated.

You can order 2x R2 or 1x R2 + 1x R4.

#### 3.1.4. Thumb Keycaps

The thumb keycaps are designed to create a "dish" with ridges on the outer thumb keys.

The same model is used for the left and right keys, but it is mirrored. In this repo you will find a model that already has all the versions you will need.

If you have a corne-style thumb cluster with 3 keys, you can use a convex key for the middle one. It will act like a homing key.

And there is an alternative convex key included, which is slightly lower so that you can see which one you like better.

#### 3.1.5. 1.5u Thumb Key

Additionally, there are also 1.5u variations of the outer thumb keys.

You have to be very careful if you get the files from other repos, because by default the stem is rotated by 90 degrees unlike regular 1.5u keys.

The files here have the stem in the correct orientation for keyboards like the corne where the switch is already rotated by 90 degrees.

#### 3.1.6. Convex Keycaps

The convex keys are used on the middle thumb keys, but can also optionally be used on the inner and outer columns.

You can [see an example of how that looks here](https://www.printables.com/model/158865-chicago-steno-low-profile-ergo-keycaps).

#### 3.1.7. Lateral Keycaps

Steno keycaps have vertical ridges that keep your finger aligned in the row. This is great, but some people prefer to not have these ridges for the inner and outer columns so that they don't have to lift the finger to reach the side-key or to perform horizontal combos with one finger.

Keep in mind, that the lateral keycaps are used as a pair on two columns next to each other.

The file contains only one set of the two. If you want it on both sides of the keyboard, you have to print it twice.

I suggest printing one version with the homing dots and another with the homing bars to get all possible variations.

### 3.2. What to print...

Look at the `export_*.scad` files to see what key models were used and further comments on how to use the sets. Render them with OpenSCAD to generate STL files (STLs are not checked into git due to size).

#### 3.2.1. If you have a 5x3 row board (Such as the corne without the outer coulmn)

* 1x `cs_row_r2_top.stl`
* 1x `cs_row_r3_homerow_bar.stl` or `cs_row_r3_homerow_dots.stl` (different homing keys)
  * Or the `cs_row_r3_regular.stl` and `cs_row_r3_homing_only.stl` to get both homing key variations
* 1x `cs_row_r4_bottom.stl`
* 1x `cs_row_thumbs.stl`

#### 3.2.2. If you have a 6x3 row board (Such as the corne WITH the outer coulmn)

All of the above, PLUS...

* 1x `cs_column_regular.stl` or `cs_column_convex.stl` for the outer pinky column

You can also print the `cs_column_regular_with_homing_bars.stl` variation which contains two more homing key.

Combine it with the `cs_row_r3_homerow_dots.scad` to get both homing key variations without needing to print them separately.

Alternatively, you can also consider the lateral variation, but this one needs to be printed twice as it should be used on both the outer and pinky keys.

The leeve rows can also be used for the index and inner column as the stl includes homing key variations.

To be able to use lateral keys on both sides and get both types of homing keys you should print...

* 1x `cs_column_lateral_homing_bar.stl`
* 1x `cs_column_lateral_homing_dot.stl`

#### 3.2.3. If you have a 6x4 board with a num row...

All of the above, PLUS...

* 1x `cs_row_r3_regular.stl` for the top alpha row (the r2 keycaps will be used for the num row)

#### 3.2.4. If you have a MoErgo Go60 (6x4 split columnar)

The Go60 has 6 columns x 4 rows per half plus a 6-key thumb cluster. Print the following:

| File | Keys | Qty | Subtotal | Notes |
|------|------|-----|----------|-------|
| `export_go60_regular_columns.scad` | 10 | 2 | 20 | C3+C4 (ring/middle) R1-R4 + 2 spare convex thumbs. Render with CGAL. |
| `export_go60_lateral_columns.scad` | 8 | 2 | 16 | C6+C5 (outer pinky pair) lateral R1-R4 |
| `export_go60_inner_columns_left.scad` | 10 | 1 | 10 | Left C2+C1 lateral R1-R4 + homing bar + homing dot |
| `export_go60_inner_columns_right.scad` | 10 | 1 | 10 | Right C2+C1 lateral R1-R4 + homing bar + homing dot |
| `export_go60_thumbs.scad` | 10 | 1 | 10 | Main thumb cluster: ridged + convex + spare convex. Render with CGAL. |
| `export_go60_thumbs_alt.scad` | 10 | 1 | 10 | Alt thumb cluster: 8 convex R2 + 2 thumb 1.25u. Render with CGAL. |
| **Total** | | | **76** | |

Plates marked "Render with CGAL" contain convex keys that require the CGAL backend (`openscad --backend=CGAL`). Other plates can use the faster Manifold backend.

Open `go60_visualization.scad` in OpenSCAD to preview the full keyboard layout with all keys at their approximate positions.

### 3.3. How to order on JLCPCB

* Upload the stl model
* Select 3D Technology: `MJF (Nylon)`
* Select Material: `PA12-HP Nylon`
* Optionally select Surface Finish: `Add - Dyeing - Dyed Black` to get black keycaps.
  * Without this they will be a "textured gray"
* Make sure to select the correct Quantity

The total for a 6x4 board with all the optional stuff will cost appoximately $23.88. In addition to that JLC now charges $1 per sprued file [as per their connected parts policy](https://jlc3dp.com/help/article/213-Connected-Parts-Printing-Guide).

So, it will be approximately $32.88 + shipping in total.

> [!NOTE]
> You will likely get warnings that some areas on the 1.5u thumb keys are too thin.
>
> You can just tell them that you accept the risk and it will print just fine. Me and several other people successfully printed these keycaps despite the warnings.
>
> The original code for the 1.5u thumb keys produced keycaps with the wrong stem orientation. I have attempted to fix this problem, but JLCPCB still complains about areas that are too thin and will ask you if you want to take the risk of them not getting printed correctly when you order.
>
> All other keycaps should not have problems though.

#### 3.3.1. JLCPCB Shopping Cart Example  <!-- omit from toc -->

![JLCPCB Shopping Cart Example](Photo/jlcpcb_shopping_cart.png)

### 3.4. How to create custom sets of keycaps

* Install OpenSCAD
  * The [snaphot version](https://openscad.org/downloads.html#snapshots) is recommended for performance reasons
  * If it crashes, [try an older version of the snapshot](https://files.openscad.org/snapshots/)
* Set up the dev environment
  * Adjust the Makefile with the path to your OpenSCAD installation
  * Unzip the `libraries.zip` into your [OpenSCAD library path](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries)
* Create your keycap set
  * Copy one of the files starting with `export_`
  * Adjust the keycaps you want to use. Available options are in `gen_sprued_keycaps.scad`
  * Keep in mind that jlcpcb only allows a maximum of 10 keycaps per file
* Generate STLs
  * Run `make` and it will generate all missing STLs
  * Alternatively you can also select which file to generate by running something like `make stl/cs_row_thumbs.stl`, but keep in mind that you have to use the file name of the final stl file and not of the source `.scad` file

Alternatively you can also run the GUI version, but it's a bit slow.

You can speed it up by enabling the `manifold` options in `Preferences -> Features` (Snapshot version only).
