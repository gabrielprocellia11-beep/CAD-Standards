---
name: radar-cad-standar
description: Standar gambar CAD kantor RAD+ar: aturan wajib, satuan & skala, frame plot A3 dan title block, tabel layer resmi (warna/linetype/lineweight), dinding, pintu, jendela, kolom, grid, dimensi WMS, teks, FFL, cara membaca denah, plot style CTB. Baca sebelum menggambar denah/potongan/tampak di AutoCAD.
---

# Standar CAD RAD+ar

Berlaku untuk semua gambar AutoCAD kantor RAD+ar. Ikuti persis; penyimpangan harus didiskusikan dengan pemilik.

## 0. The owner's golden rules (non-negotiable)
1. **Never export or trace.** Never export a SketchUp cut/section to DWG, never copy/trace linework from another DWG.
   Draw every wall, door, window, stair, column, planter and road yourself. A 3D section cut (image) is only a
   *measuring reference* for sizes and positions.
2. **Allowed to copy:** blocks and loose furniture only (sofas, tables, beds, toilets, trees, cars, people, north arrow).
3. **Delete the old content first** when told to draw into an existing file — but delete only model-space objects.
   **Never PURGE** (it deletes the office layers, text styles and dimension styles).
4. **Accuracy over speed, but work fast.** Measure, then draw. Time boxes are usually 10–15 min: get the most done,
   correctly, and say honestly what is unfinished.
5. **Ask when information is missing** (room names, which floor is which, scale, which file).
6. **Walls always have a gap at doors and windows.** Never draw a door or glazing on top of a continuous wall.
7. **Do not hatch floors.** Grass hatch only on real lawns/planters. Floors of rooms stay unhatched.
8. **Lines must be clean and straight** — no squiggly auto-traced outlines. If a cut is unclear, re-measure and
   simplify to straight segments / true arcs.
9. **Loose furniture is not the focus.** Draw architecture: walls, columns, stairs, ramps, openings, doors, windows,
   platforms, level changes, landscape edges. Counters/bars/tables = simple rectangles or circles.
10. Structural columns are **blocks** (one block definition, inserted many times).

---

## 1. Units, coordinates, scale
- Units: **millimetres** (INSUNITS = 4). 1 drawing unit = 1 mm.
- Draw everything at **1:1 in model space**; the scale only affects paper frame, text and dimension sizes.
- Keep project/survey coordinates when a base drawing exists (DAAN MOGOT frames sit at x 1,345,000 / 1,555,000).
- Office UCS in standards file: origin at the top-left of the first sheet (UCS ORIGIN 1345000,353650). Return to WCS
  before scripting (`UCS W`).
- Common plot scales: **1:100, 1:200, 1:250, 1:400, 1:500**. Choose the scale so that the WHOLE plan incl. the
  surrounding roads fits inside the A3 guide box *above* the title block. If objects fall outside the paper, the
  scale is wrong — go up a scale (e.g. 1:250 → 1:400).

## 2. Plot frame (A3 landscape, model-space frames)
For scale S (e.g. 500):
- **Sheet**: 420·S × 297·S rectangle, layer DEFPOINTS, colour red (1).
- **Border box**: offset 5·S inside the sheet, DEFPOINTS.
- **Guide box**: offset 9·S inside the sheet, DEFPOINTS, colour yellow (2). All drawing content stays inside it.
- Frames for several floors are placed side by side with a gap (e.g. 210,000 at 1:500 — frame width + spacing).
- **Title block** — centred at the bottom of the frame, heights in paper-mm × S, measured from the sheet bottom:
  | Item | y (mm×S) | text height (mm×S) | style |
  |---|---|---|---|
  | Project name, spaced capitals, yellow, Gill Sans bold | 31.5 | 2.25 | GILLSANS |
  | Drawing title e.g. `G R O U N D   F L O O R   P L A N`, yellow | 27.0 | 1.875 | GILLSANS |
  | Scale-bar numbers (0 / 5 / 10 / 25 M at 1:500) | 22.375 | 1.4625 | GILLSANS |
  | Scale bar (2 mm tall, alternate solid fill) | 18.125–20.125 | – | – |
  | `1:500 - A3` | 16.125 | 1.6875 | GILLSANS |
  | `R A D + a r` | 12.225 | 1.5 | GILLSANS |
  | Date e.g. `N O V E M B E R    2 0 2 6` | 9.475 | 1.2 | GILLSANS |
  | `© RAD+ar 2026.  All rights reserved.` | 6.725 | 1.125 | copyright |
- North arrow to the right of the title, label `N`.

## 3. Layers (office standard — use exactly these)
| Layer | Colour | Use |
|---|---|---|
| **ACUT** | 7 white | Cut walls (lines in plan), door leaves, sliding door leaves |
| **AHAT** | 3 green | Hatches: SOLID wall fill, GRASS lawns, AR-CONC concrete, tile patterns |
| **ASTR** | 1 red | Structure: columns (as blocks), structural outline of existing buildings |
| **AELE** | 5 blue | Elements below cut: glazing lines, stairs, lifts, steps, ramps, kerbs, landscape edges, pavilion/roof seen from above |
| **AELELT** | 3 | Landscape lines: jogging track, lake/pond edge (smooth curves) |
| **ABOV** | 6 magenta | Overhead / above cut: door swing arcs, canopies, roof edges over, eaves, dashed overhead slabs |
| **APAT** | 64 | Pattern/floor-finish outlines (zones, decking) — not floors |
| **AFUR** | 9 grey | Furniture (blocks) |
| **ASAN** | 5 | Sanitary fittings (blocks) |
| **ALAND** | 3 | Trees/plants (blocks) |
| **ASIT** | 1 red | Site boundary (polyline, heavy) |
| **AGRI** | 4 cyan, PHANTOM linetype | Structural grid lines |
| **ADIM** | 3 green | Dimensions |
| **ATEX** | 8 | All annotation text, level text, title block |
| **ATEXRM** | 1 | (room-name text in some sheets) |
| **ATEXTIT / ATEXDTL** | 2 / 8 | Titles, detail callouts |
| **DEFPOINTS** | – | Plot frame, guide box, construction boundaries (never plots) |
| ARCP, AWIN, AELEC, ALIG… | | Exist in the template — use only when the sheet type needs them |

Key mappings the owner corrected:
- **Doors**: leaf = thin rectangle (50 mm) on **ACUT**; swing arc on **ABOV**. Double doors = two leaves meeting in the middle.
- **Windows / glazing**: two parallel lines at the wall faces on **AELE**, sitting inside a wall gap.
- **Water (pond/lake)** edge on AELELT with ANSI31 hatch at large scale.
- **Grass / planters**: AELE outline + GRASS hatch on AHAT.
- **Neighbouring buildings** (context): AELE outline + light ANSI31 hatch (large scale, not dense).
- Existing/ to-remain structure: ASTR outline + EARTH / AR-CONC hatch.

## 4. Walls
- Draw walls as closed rectangles per segment (centre-line ± thickness/2), then **REGION → UNION → SOLID hatch (AHAT)
  → EXPLODE back to lines on ACUT** so corners and T-junctions are clean with no overlapping lines.
- Typical thicknesses: 150 interior, 250–300 exterior, 100 toilet partitions, 50 cubicle partitions.
- Leave a **gap** in the wall for every door and window opening.

## 5. Columns & grid
- Column = **block** (e.g. `COL-D800`: circle r400 + solid donut fill, drawn on layer 0, inserted on ASTR).
  Steel H-columns: 300×150, flange 9, web 7, root fillet 13 (one ASTR polyline + web line).
- Grid lines on AGRI (PHANTOM linetype) through every column line, extending past the building.
- Dimension the grid: tier 1 = each bay, tier 2 = overall, using office dimstyle.
- Give grids and bay dimensions to **every** detailed building, not only the main one.

## 6. Dimensions
- Office dimstyles: **WMS100** (and WMS300). For other scales set DIMSCALE = scale (e.g. 400) or create
  `WMS<scale>` from WMS100 with DIMSCALE changed. Dimension grid-to-grid; place dimension lines outside the building.

## 7. Text & labels
- Text style **ROMANS** for plan text; **GILLSANS** for titles.
- **Room names**: red, Gill Sans bold: `{\fGill Sans|b1|i0|c0|p34;\C1;ROOM NAME}` (centered MTEXT).
- **Main space + level**: yellow, two lines: `{\C2;OPEN OFFICE\PFFL +11.200}`.
- **Area text**: small, e.g. `45.23 m²` under the room name.
- Height at 1:500: big zones ≈ 2.0×S·0.5 … small rooms ≈ 0.8–1.2 mm paper height; never let text spill out of a room.
- Level marker block in standards file: `level-reduced` (attribute = level text).
- Road names in yellow (`JALAN PANJANG`, `JALAN H. TAHA`).

## 8. FFL (finished floor level)
- **FFL +0.000 is the main road level** (for HABCO: *jalan panjang*). All other levels are measured relative to it.
- Write levels with sign and 3 decimals in metres: `+0.700`, `+11.200`, `-0.450`.
- From a SketchUp model: find each slab's top z, subtract the road z, divide by 1000.
  HABCO example (road z = −1150): tower L1 +0.700, L1 mezz +3.700, L2 +6.700, L3 +11.200, L4 +15.700, L5 +20.200,
  L6 +24.700, L7 +29.200, roof +33.700; low building L1 +1.150, L2 +6.650, L3 +11.450.

## 9. Reading a plan / identifying elements
- **Cut walls** = thick black in a section cut → ACUT + solid fill.
- **Columns** = black circles/squares on a regular grid → block on ASTR.
- **Stairs** = parallel tread lines + arrow (UP) + break line → AELE.
- **Lifts** = box with an X → AELE.
- **Ramps** = long narrow strip with handrail line and cross lines, label `RAMP 1:12` → AELE.
- **Doors** = gap in wall + leaf + 90° arc. **Sliding doors** = two offset leaves. **Windows** = two thin lines in a gap.
- **Roof / canopy over** = dashed or magenta outline → ABOV. **Roof seen from above** on upper-floor plans → AELE with ridge lines.
- **Grass/planter** = green → GRASS hatch. **Water** = blue → water hatch. **Paving** = grey → outline (tile hatch only if needed, light).
- **Parking** = stall lines 2500 wide × 5000 deep on AELE.
- Show the ground-floor landscape only on the ground-floor plan; upper floors show roofs below and context outlines.

### 13.1 Official layer table (from `Cad standards.dwg`, identical in `Cad standards 2.dwg`)
Lineweight column = layer lineweight (mm). Plotted weight is set by the CTB per colour (13.3).
| Layer | Col | Linetype | LW | Use |
|---|---|---|---|---|
| 0 | 200 | Continuous | 0.15 | block geometry only |
| ACUT | 7 | Continuous | 0.15 | cut walls / door leaves |
| ASTR | 1 | Continuous | 0.18 | structure |
| AELE | 5 | Continuous | 0.13 | elements below cut |
| AWIN | 5 | Continuous | 0.13 | windows (alternative to AELE) |
| ABOV | 6 | **HIDDEN** | 0.05 | overhead |
| AHAT | 3 | Continuous | 0.05 | hatches |
| APAT | 64 | Continuous | 0.05 | patterns |
| AFUR | 9 | Continuous | 0.05 | furniture |
| ASAN | 5 | PHANTOM | 0.13 | sanitary |
| ALAND | 3 | Continuous | 0.05 | landscape/plants |
| AELELT | 3 | Continuous | 0.05 | landscape lines |
| AGRI | 4 | **PHANTOM** | 0.05 | grid |
| ADIM | 3 | Continuous | 0.05 | dimensions |
| ATEX / ATEXNRL | 8 | Continuous | 0.09 | text |
| ATEXRM | 1 | Continuous | 0.30 | room names |
| ATEXTIT | 2 | Continuous | 0.40 | drawing titles |
| ATEXDTL / ATEXERL | 8 | Continuous | 0.15 | detail/material tags, symbols |
| ATIT | 7 | Continuous | 0.15 | title items |
| ASIT | 1 | PHANTOM | 0.18 | site boundary |
| ASET | 6 | PHANTOM | 0.18 | setback line (GSB) |
| AEXTG | 50 | HIDDEN2 | 0.15 | existing to remain/demolish |
| ADRAIN | 5 | PHANTOM | 0.13 | drains |
| ALIG / AWIR | 1 | Cont./PHANTOM | 0.18 | lighting / wiring |
| ARCP | 5 | Continuous | 0.13 | reflected ceiling |
| AREA | 2 | Continuous | 0.13 | area polylines |
| AELEC | 1 | Continuous | 0.20 | electrical |
| AOUTL | 1 | Continuous | 0.20 | outline |
| AREV | 3 | Continuous | 0.13 | revisions/clouds |
| URACAD | 3 | Continuous | 0.05 | (misc) |
| DEFPOINTS | 181 | Continuous | – | non-plotting frames/boxes |
Office cleanup routine also uses ATHRES (thresholds, green) and moves ATEXFIN → ATEXDTL.

### 13.2 Dimension style (WMS100 / WMS300)
Overall scale = drawing scale (100, 300 …) · text height 2 · arrow = **oblique tick** size 2 · text colour 8 · text gap 1 ·
extension offset 2 · extension extend 2 · precision 0 (whole mm) · text style ROMANS. Make `WMS400`, `WMS500` the same with overall scale changed.
Office macro buttons: **Dim Equal** (`dim override` text `EQ`), **Dim Override Gap 3**.

### 13.3 Plotting style (CTB) — `D:\000 CAD Content\Plotstyle`
Office tables: **`196 plotstyle A1 & A3.ctb`** and **`214 plotstyle.ctb`** (also installed on this PC with GIRR_A3.ctb).
Most colours plot **black**; lineweight by colour index:
| Colour | Plots | 196 | 214 |
|---|---|---|---|
| 1 red | black | 0.30 | 0.30 |
| 2 yellow | black | 0.40 | 0.40 |
| 3 green | black | 0.05 | 0.05 |
| 4 cyan | black | 0.08 | 0.08 |
| 5 blue | black | 0.12 | 0.12 |
| 6 magenta | black | 0.045 | 0.045 |
| 7 white | black | 0.25 | 0.25 |
| 8 grey | black | 0.12 | 0.12 |
| 9 | black | 0.045 | 0.045 |
| 10 | black | 0.35 | 0.15 |
| 20 | object colour | 0.15 | 0.15 |
| 30 / 32 | black (214: object colour) | 0.12 / 0.25 | same |
| 80, 100, 252 | black/obj | 0.12 | 0.12 |
| 94 | black | 1.06 (very heavy) | 1.06 |
| 141 | black, 60 % screen | 0.03 | 0.03 |
| 253 | object colour | 0.05 | 0.12 |
| 255 | object colour | 0.20 | 0.20 |
| all others | black | 0.03 | 0.03 |
214 plots many more indices (11, 21, 22, 31, 41, 42, 50, 51, 61, 70, 71, 81, 91 … 241, 252–255) in object colour (for coloured landscape/hatches).
**Consequence for drafting:** colour = pen weight. ACUT 7 → 0.25 (cut walls bold), ASTR/ATEXRM 1 → 0.30, titles 2 → 0.40,
AELE 5 → 0.12, ATEX/ADIM… 8/3 → 0.12/0.05, AGRI 4 → 0.08, ABOV 6 → 0.045, AFUR 9 → 0.045, APAT 64 → 0.03. Never set entity colours that break this.

### 13.4 Plotting practice (from plot.log)
- Plot from **Model space** using the A3 frame window; paper **A3 297×420 landscape**, "fit" to the frame at the written scale.
- Printers: EPSON L1300 / **EPSON L15150** (current PC), **DWG To PDF.pc3** for PDFs. Older: Ricoh/Oce (A1). 
- Scales used: 1:100, 1:150, 1:250, 1:300, 1:400 (HABCO 007 design was plotted 1:400 in 2022), 1:500, 1:750, 1:1000.
- Template page setups in standards file: A1 Oce TDS300 (C_A1 printer OCE.ctb), A3 RICOH (C_A3 printer RICOH.ctb) — legacy names; on this PC use 196/214 ctb.

### 13.5 Written drafting rules inside `Cad standards.dwg` (verbatim intent)
- **Body text**: ROMANS, left aligned, height = **2 × scale** (200 @1:100); text box widths in **multiples of 150**; copy text together with its leader arrow, don't re-adjust.
- **Room name text**: centred in room, height = **2.5 × scale** (250 @1:100), box 3000 wide (@1:100).
- **Drawing title**: ATEXTIT, ROMANS height 4 × scale, with "LOCATION" and `{\H0.5x;\C8;SCALE 1:XXX}` line.
- **Grid bubble text**: ROMANS 3 × scale, colour 8 (AGRI). Level tags (B1, L1 … ROOF): 8 × scale.
- **Dimensioning**: never change the dim settings – copy & shift existing dims; always dimension to grids; text 2 × scale; all arrow/leader sizes 2.
- **Dimension height** = 10 × scale from the insertion node to the dimension line.
- **First dimension tier** starts at the edge of the grid line (set inward if needed); next tier offset **¾ of dim height**; dims may overlap, never change dim height.
- **Drawing reference box**: set it up FIRST, before drawing, to plan size/scale; grid and symbols are set out relative to the guide/reference box; distance border↔reference box in multiples of 150 and constant.
- **Constant 1 cm border** on all drawings left empty; lines & text stay **300 (×scale/100) away from border box**.
- Object reference box: offset 150 / R150 for scales 1:20–1:100, 50/R50 for 1:5–1:10, 25/R25 for 1:1–1:2.
- Sectional floor levels: text 2 × scale, fixed datum-line length, box 3000W.
- Any deviation from the standard must be discussed; adjustments must be measurable, never arbitrary.
- Guide length note: "35550 for A3, 71100 for A1" (reference width at 1:100).
- Scale bar values per scale: 1:100/150/200 → 0-1-2-5 M; 1:250 → 0-2-4-10 M; 1:300 → 0-3-6-15 M; 1:400 → 0-2-4-10-20 M;
  1:500 → 0-5-10-25 M; 1:600 → 0-6-12-30 M; 1:1000 → 0-5-10-25-50 M.

### 13.6 Standard blocks in the template (insert at scale = drawing scale, layer ATEXDTL)
`level-reduced`, `level-landscape`, `level-water`, `room data`, `label-door 1/2`, `label-window 1/2`, `label-detail`,
`section-topleft/topright/bottomleft/bottomright/leftup/leftdown/rightup/rightdown`, `elevation-up/down/left/right/all`,
material keys (`aluminium, carpet, ceiling type, concrete, fabric, glass, interior, linoleum, metal, mirror, paver, premix,
resin based, roof type, stainless steel, steel, stone, tile, timber, veneer, vinyl, wall`), `proto A3` (frame), `Tender Vertical-A1-Att-1`, `ARROW1`, `_OBLIQUE`.
