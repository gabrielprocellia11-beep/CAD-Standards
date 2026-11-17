# RAD+ar — CAD Standards & Floor-Plan Drafting Rules
Knowledge base for Bambang. Learned from: `D:\000 RAD+AR\Cad standards.dwg`, `009 DAAN MOGOT\CAD\001 design.dwg`,
the HABCO model (`007 MAKET 3D CHINA\002 HABCO\007 habco working model (1).skp`) and the owner's corrections.
Read this file completely before doing ANY AutoCAD / floor-plan work.

---

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

## 10. Measuring from a 3D model (SketchUp) without exporting
1. Ruby Console: add a horizontal **section plane** ~750 mm above each floor slab, set an orthographic **top camera**
   over a known window (x0,y0,x1,y1 in mm), and `view.write_image` at a known pixel size → known mm per pixel
   (e.g. 100 m over 4000 px = 25 mm/px).
2. Measure walls, columns and openings from those images (pixel → mm), snap to 25/50 mm.
3. Re-draw every element yourself in AutoCAD on the correct layers. The image is never placed in the DWG.
4. Also cut one site image for roads, planters, neighbours (lower resolution is fine).

## 11. Working in AutoCAD efficiently (what worked)
- Generate an AutoLISP file with `entmake` for lines/polylines/arcs/circles/MTEXT/INSERT, then `(load "...lsp")`.
- Hatches: create a temporary boundary polyline, `-HATCH` with Select objects, then erase the boundary.
- `SECURELOAD` prompts on unsigned files — answer "Load Once".
- Keep the user's drawing safe: never close or overwrite a file the user has open without being told which file to use.
- Save with QSAVE at the end and confirm the title bar no longer shows `*`.

## 12. Project facts learned
**DAAN MOGOT West Lake Garden (009)** — 001 design.dwg: two 1:500 A3 frames (Lt 1 at x 1,345,000; Lt 2 at x 1,555,000).
Grid bays 6000 (21 bays south building), rows A/B/C (west half A'/B' 400 mm offset), north wing on a 6.34° grid.
Lake + jogging loop in the courtyard, two hipped pavilions, central deck, amphitheatre seating, wellness wing west,
service/office/musholla wing east, gym + F&B tenants + drop-off south.

**HABCO (002, MAKET 3D CHINA)** — 7 main floors + mezzanine + roof. Tower shell 27,750–53,925 × 1,054,425–1,092,025
(model mm), 250 walls, grid X 30812.5 / 36812.5 / 45812.5 / 51812.5 (bays 6000/9000/6000), Y 1056587.5 /
1061087.5 / 1070087.5 / 1079087.5 / 1088087.5 (4500/9000/9000/9000), round columns Ø800.
North core: stair 31375–37400, lifts 40750–42800 & 43150–45200, west toilets. South core: stair 32275–40075, lift 41575–44675.
Low (bar) building north: 52,900–91,000 × 1,093,100–1,106,300, L1 = two glass boxes + central entrance lobby,
L2 executive lounge, L3 office + meeting rooms, green roof. Ramps along the tower's south edge and east side.
Roads: jalan panjang (east, FFL +0.000, with median), jalan H. Taha (south), jalan H. Alimun (west).
Plans drawn at **1:400** so the full site incl. roads fits A3.


---

## 13. Office CAD Standard folder (`D:\000 CAD Content\Cad Standard`) — learned 16 Nov 2026

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

### 13.7 Keyboard shortcuts (office `acad.pgp`)
Draw: L line · PL pline · A arc · CC circle · REC rectang · SP spline · EEE ellipse · DO donut · XX xline · ML mline · PO point · POL polygon · REG region
Modify: M move · C/CP copy · R rotate · SC scale · S stretch · MI mirror · O offset · T **trim** · EX extend · F fillet · CA chamfer · BR break · J join · X explode · E erase · AR array · AL align · LEN lengthen · P **pedit** · SPE splinedit
Props/inquiry: PP / WW / MO / CH properties · MM matchprop · EE / LI list · D dist · AA area · ME measure · DV divide · QC quickcalc
Text/dim: TE / MT mtext · DT text · ED ddedit · DD dimlinear · DAL dimaligned · DCO dimcontinue · DBA dimbaseline · DDA dimangular · DDR dimradius · DDI dimdiameter · DAR dimarc · DED dimedit · DDD / DST dimstyle · LE qleader · MLD mleader · ST style
Hatch/blocks: H / BH hatch · HE hatchedit · HB hatchtoback · B block · W wblock · I insert · BE bedit · ATT attdef · AT attedit · XR xref · XA xattach · XC xclip · XB xbind
Layers: LL layer dialog · LLL -layer · **11/44 layon · 2 layiso · 22 layuniso · 3 layfrz · 33 laythw · 4 layoff · 5 laylock · 55 layulk · 555 unlock all · 6 laywalk · 7 laydel**
View: Z zoom · RE regen · REA regenall · DR draworder · VI view · PU purge (office warning: never purge standard layers) · PPP plot · OP options · OS osnap · UN units · SET setvar · TP tool palettes · ER external references
Extra LISP (`extra lisp.lsp`, auto-loaded): **1** = all layers off except current · **0** = layers on + thaw + unlock all · **v / vv / vvv** = 2 vertical / 2 horizontal / single viewport · **9** = UCS Z 45° · laylock / laylockall / layulkall.
Custom CUIX buttons: Layer Properties toggle, Make Object's Layer Current, **UCS 90** (`ucs z 90` + plan), UCS Object, Dim Equal, Dim Override Gap 3, Layer On/Thaw/Unlock.

### 13.8 Setting up a new PC (from `arr notes.jpg`)
1. Tools ▸ Customize ▸ Edit Program Parameters (acad.pgp) → replace with office `acad.pgp` → save → type **REINIT** (tick PGP).
2. **APPLOAD** → load `extra lisp.lsp` → Startup Suite ▸ Contents ▸ Add (auto-load every start).
3. **CUI** → Customize All → right-click Partial Customization Files ▸ Load → `Customized CUIX.cuix` → buttons appear.
4. Copy `196 plotstyle A1 & A3.ctb` / `214 plotstyle.ctb` into the Plot Styles folder.

### 13.9 Office LISP library (`Cad Standard\LISP`) — most useful
- `fixhat` – moves hatches drawn on AELE to **AHAT** (green). `121 v3` (C:1) – end-of-job cleanup: layer colours (AELELT 3, AFUR 9, APAT 64, ATEX* 8, Defpoints 181, 0 = 200), ATHRESHOLD→ATHRES, dim text colour 8, AGRI texts colour 8, ATEXFIN→ATEXDTL, zoom E, purge, qsave, close. `zc` = zoom extents + save + close.
- `PLA` (room name + "Area: xx.xx m2" from a polyline), `at` (perimeter + area text), `art`, `tadd`/`tlen` (sum text numbers / total lengths), `num` (running numbers, default height 300).
- `cds` (all dimstyles text colour 8), `layercase`, `renamelay` (strip `$0$` from bound xref layers), `LR`/BINDFIX, `mel` merge layers, `LEXCEPT`, `TARGOFF/TARGFREZ/TARGLAY`, `layer isolate`.
- Geometry helpers: `bb` break at point, `mstr` multi-stretch, `mtrim`, `FM` multi-fillet, `ploffst` offset both sides, `Offset layer_ol`, `pljoin` (pedit fuzz), `Crv2pln`/`2pl` spline→polyline, `Dupdel`/`DELDUP` delete duplicates, `eraseout`, `Flatten` (Z=0), `XClipClean`, `xrefrel`, `ScaleListDel`, `DeMask`, `t2mt`/`dtom` text→mtext, `allcaps`, `count`/`blockreport`, `chblkly` change block entity layers, `dobylayer` draw order by layer, `StairSec` stair section, `RevThis` clean for Revit, `BBYHATCH`/`HatchMaker` create hatch patterns.

### 13.10 Office hatch library (`D:\000 CAD Content\Hatch`, 255 files)
Paving: `paving 300 450 / 300 600 / 450 450 / 600 600 / 900 450 / 900 600 stretcher`, `paving-1200-300`, `173paver1-3`, `random300`, `random2`, `RANDOM1`, `CRAZY1`, `mixedrandom`, `gransetstr`, `PEBBLES1`, `roundstone`, `stone1`, `pulaistone(2)`, `pecatu` variants, `kudalaut52/88`.
Tiles: `178TILE300X1200`, `178tile150x600`, `178tile300x1500`, `300x1350`, `pulaitile`, `conservationtile`, `SQ90`, `groove600`, `groove60300`, `tshgroove`.
Timber: `wood`, `wood0deg`, `wood1/2`, `woodhor`, `woodgrain45deg`, `timberstrip600x50`, `PARQUET`.
Landscape: `GRASS2`, `longgrass1`, `borderplant1/2`, `creepers1`, `167green`, `water`, `waterhor`, `wave`, `Earth45`.
Roof: `celtoise tiles 30/32 deg (side/top)`, `pietra ceramica side`.
Facade/metal: `corten`, `alumslot(s)`, `mesh2d/3d`, `bushhammer`, `FERROLITE`, `revised concrete (AR-CONC)`, project facades 130/159/165/167.

---

## 14. Practice log, mistakes and lessons (Claude's experience, Nov 2026)
Read this before starting — these are real mistakes the owner had to correct. Do not repeat them.

### 14.1 Practice history
| # | Task | File | Result / owner feedback |
|---|---|---|---|
| 1 | DAAN MOGOT West Lake Garden ground + 1st floor plans, 1:500, from `001 design.dwg` + SketchUp `004 design` | `D:\000 RAD+AR\Cad standards.dwg` | First attempt **traced** 001 → rejected ("do not trace, draw by yourself"). Redrawn from scratch. |
| 2 | Same, second pass | Cad standards.dwg | "Some layers incorrect, still not neat – compare with 001 and LEARN". Fixed: door arcs to ABOV, glazing to AELE, walls ACUT+SOLID, text styles. |
| 3 | HABCO (7 floors + mezz + roof) from SketchUp `007 habco working model (1).skp` | `D:\000 RAD+AR\PRACTICE 2.dwg` | Paper too small (objects outside frame at 1:250) → changed to **1:400**. Structure & layout inaccurate → re-measured from section cuts. |
| 4 | HABCO rework | PRACTICE 2 | Grass hatch on all floors + squiggly auto-traced outlines → owner: "before was better". Went back to hand-authored clean geometry. |
| 5 | HABCO fixes | PRACTICE 2 | Requests: clean lines, identify rooms, grids + dims on the other building, columns as blocks, draw ramps, **gaps in walls at doors/windows**. Partly done (see 14.5). |
| 6 | Learn office standard folder | `D:\000 CAD Content\Cad Standard`, `Plotstyle`, `Hatch` | Layers, CTB, shortcuts, rules recorded in section 13. |

### 14.2 DO
- Read this whole file and the office standard (section 13) **before** touching AutoCAD.
- Ask first when anything is missing: scale, which file to draw in, floor names, room uses, FFL datum, which buildings are "detail" vs "context".
- Draw everything yourself: measure from the 3D section cut (image), then type exact coordinates. The cut is a ruler, not a source of linework.
- Copy only blocks/furniture/trees/cars/people from other drawings.
- Pick the scale from the full extent **including roads and context**, then build the A3 frame (sheet 420×297×S, border 5×S, guide 9×S) and check every floor fits inside the guide box.
- Put each element on its correct layer (section 3 + 13.1); keep entity colour **ByLayer** — colour is pen weight (13.3).
- Walls: closed rectangles → REGION → UNION → SOLID fill on AHAT → explode back to clean ACUT lines. Leave a **gap** at every door and window.
- Doors: leaf on ACUT + swing arc on ABOV. Windows: two AELE lines in the wall gap. Columns: one block, many inserts on ASTR.
- Grids (AGRI, PHANTOM) through every column line on **every detailed building**, with bay + overall dimensions (WMS<scale>).
- Room names red Gill Sans bold centred; main spaces yellow with `FFL ±x.xxx`. FFL ±0.000 = main road.
- Landscape: grass/planters only where real lawns exist; paving light; water with its own hatch; roads with kerbs, medians, names.
- Identify and draw ramps (handrail line, slope arrow, `RAMP 1:12`), stairs (treads + UP arrow), lifts (box + X).
- Upper floors: show roofs/canopies of lower floors and context outlines, not the ground landscape.
- Preview the geometry (image) and check it before loading into AutoCAD; after loading, ZOOM E, screenshot, compare with the 3D.
- Work inside the time box; at the end say clearly what is done and what is not.
- QSAVE at the end and confirm the title bar has no `*`.

### 14.3 DON'T
- **Never export** SketchUp sections/models to DWG, never trace or copy linework from another DWG or an image.
- **Never PURGE** in the user's drawing (it once deleted the office layers, text styles and dimstyles — had to close without saving and reopen).
- Never hatch room floors with grass or patterns. Never auto-trace contours from images (gives squiggly, unclear lines).
- Never draw a door or window on top of a continuous wall.
- Never change dimension style settings; never leave text spilling out of rooms or outside the guide box.
- Never put objects outside the plot frame — if they don't fit, the scale is wrong.
- Never close, overwrite or "save as" a file the user has open without being told; never open a second copy of AutoCAD.
- Never recolour entities away from ByLayer (breaks the CTB pen weights).
- Never guess room names or ramp positions silently — ask, or mark as assumption.

### 14.4 Mistakes made and the fix
| Mistake | Why it was wrong | Fix / rule |
|---|---|---|
| Traced 001 design | Owner wants drawing skill, not copying | Draw from scratch; reference only for sizes |
| Door arcs on AELE, used AWIN etc. | Office puts swing arcs on ABOV, leaf on ACUT, glazing on AELE | Follow section 3 mappings; compare with 001 design |
| `-PURGE` in clear script | Deleted standard layers/dimstyles | Clear = erase model-space objects only |
| 1:250 frame too small | Context/roads fell outside paper | Measure total extent first → 1:400 for HABCO |
| Grass hatch on every floor | Floors are not lawns; looked messy | Grass only on real planters, ground floor only |
| Auto contours from images | Squiggly lines | Hand-authored straight segments / true arcs |
| Image crop offsets (bar building 200 px off, columns +1300/+320 px) | Wrong positions | Always verify measured points against a second view; check one known dimension |
| Tile hatch AR-B816 too dense (scale 3) | Black blob when plotted | Pattern scale ≈30 at 1:400; prefer office paving patterns (13.10) |
| Bar-building columns on glass lines; L2/L3 bar walls not re-checked | Inaccurate layout | Re-check each level against its own cut, not a copy of the level below |
| Grid linetype CENTER, AELELT colour 4 | Office standard says PHANTOM / colour 3 | Use the layer table in 13.1 |
| Overwriting device files kept old content | Bridge cached stale files | Write new file names for each iteration |
| `-LAYER` command hung in scripts | Prompts waited for input | Set layer props via VLA (vla-put-color …) |
| Opened a second AutoCAD window by accident | Risk of confusing files | Bring the existing window forward from the taskbar instead |

### 14.5 Still open on HABCO (PRACTICE 2.dwg)
- Unanswered owner questions: exact ramp extent (blue band around podium?) and the room uses of the low building.
- Bar building: columns sitting on glass lines, L2/L3 walls to re-verify, west side partial, ring planter simplified, tile hatch density.

### 14.6 Speed tips (10–15 min time boxes)
1. 2 min: read standards, decide scale, frame, levels list.  2. 5 min: measure key coordinates (grid, core, perimeter) once and reuse for all floors.
3. 5 min: generate all floors with one script (shared core/grid, per-floor differences only).  4. 2 min: load, ZOOM E, screenshot check, fix obvious errors, QSAVE, report.
