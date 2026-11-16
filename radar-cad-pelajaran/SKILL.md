---
name: radar-cad-pelajaran
description: Riwayat latihan, DO dan DON'T, daftar kesalahan nyata yang pernah dikoreksi pemilik (trace, purge, skala salah, rumput di lantai, garis berlekuk, layer pintu salah) beserta perbaikannya, dan tips kerja cepat 10-15 menit. Baca sebelum mulai tugas gambar supaya tidak mengulang kesalahan.
---

# Pelajaran & kesalahan CAD (RAD+ar)

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
