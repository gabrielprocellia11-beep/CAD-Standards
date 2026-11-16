---
name: radar-cad-shortcut-alat
description: Shortcut keyboard kantor RAD+ar (acad.pgp), extra LISP (1, 0, v, vv, 9), tombol CUIX, cara setup PC baru, pustaka LISP kantor (fixhat, 121, PLA, at, num), pustaka hatch kantor, dan alur kerja otomatisasi AutoCAD (ukur dari SketchUp tanpa export, generate AutoLISP). Pakai saat butuh perintah/shortcut/LISP/hatch.
---

# Shortcut, LISP & alat CAD RAD+ar

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


### Rutin AutoLISP yang terbukti jalan
`lisp.py` – emitter class `L` with `line, pline(pts, lay, closed, bulges, width), arc, circle, mtext, text, insert, hatch(loops, pat, scale, ang, lay), dim` and `HEADER` defining:
```lisp
(vl-load-com)
(defun cl:hatch (ss pat sc ang lay / ol)
  (setq ol (getvar "CLAYER")) (setvar "HPISLANDDETECTION" 1)
  (setvar "CLAYER" lay)
  (if (= pat "SOLID")
    (vl-cmdf "_.-HATCH" "_P" "_S" "_S" ss "" "")
    (vl-cmdf "_.-HATCH" "_P" pat sc ang "_S" ss "" ""))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (command "_.ERASE" ss "")
  (setvar "CLAYER" ol))
```
Wall union routine:
```lisp
(defun cl:regions-after (e / s) (setq s (ssadd) e (if e (entnext e) (entnext)))
  (while e (if (= (cdr (assoc 0 (entget e))) "REGION") (ssadd e s)) (setq e (entnext e))) s)
(defun cl:explode-r (obj / parts)
  (setq parts (vlax-invoke obj 'Explode))
  (foreach p parts (if (= (vla-get-ObjectName p) "AcDbRegion") (cl:explode-r p) (vla-put-Layer p "ACUT")))
  (vla-delete obj))
(defun cl:walls (ws / last rg i)
  (setq last (entlast)) (setvar "CLAYER" "ACUT") (setvar "DELOBJ" 1)
  (command "_.REGION" ws "")
  (setq rg (cl:regions-after last))
  (if (> (sslength rg) 1) (command "_.UNION" rg ""))
  (setq rg (cl:regions-after last))
  (setvar "CLAYER" "AHAT")
  (vl-cmdf "_.-HATCH" "_P" "_S" "_S" rg "" "")
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (setq rg (cl:regions-after last) i 0)
  (repeat (sslength rg) (cl:explode-r (vlax-ename->vla-object (ssname rg i))) (setq i (1+ i)))
  (setvar "CLAYER" "0"))
```
`dsl.py` – class `Plan` with: `line, pl, rect, arc(deg), circle, hatch(pts, pat, sc, ang, lay, islands)`, `wall(a, b, t, group, off, ext0, ext1)`, `wallrect`, `wallpath(pts, t, closed)`, `col_I(c)` (H-column), `col_rect`, `door(hinge, w, closed_ang, swing)` (arc ABOV + leaf ACUT), `ddoor(h1, h2, side)`, `sliding(a, b)` (ACUT), `window(a, b, t)` (2 AELE lines), `stair(x0, y0, x1, y1, n, axis)` (treads + arrow), `curve(pts, lay)` (PEDIT spline), `preview_segments()` for a matplotlib check, `emit(path)` (entities → hatches → walls via cl:walls; sets OSMODE 0, HPASSOC 0, CMDECHO 0, restores OSMODE). `Frame(P, origin, ang)` gives rotated local coordinates for skewed wings. Full source: `D:\000 RAD+AR\AI\bambang-desktop\knowledge\radar_cad_dsl.py` / `radar_cad_lisp.py` – stage and reuse rather than rewriting.
