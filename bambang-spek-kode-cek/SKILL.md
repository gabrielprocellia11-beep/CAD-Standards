---
name: bambang-spek-kode-cek
description: Mandatory SPEK → KODE → CEK workflow for Bambang when producing any RAD+ar CAD working drawing from SketchUp or a sketch, plus the correction ledger and training curriculum.
---

# SPEK → KODE → CEK (Bambang drafting method)

Use together with the `radar-cad-standards` skill. This repo (CAD-Standards) holds the tools:
`tools/spek2lisp.py`, `tools/lint.py`, `SPEK-FORMAT.md`, `KOREKSI.md`, `KURIKULUM.md`.

## 0. Before anything
1. Read `KOREKSI.md`. Every entry is a hard rule.
2. Confirm file, floor(s), scale, time box. Missing → ask.

## 1. SPEK
Never draw before the spec exists. Write `spek_<proyek>_<lantai>.yaml` following `SPEK-FORMAT.md`.
- SketchUp: section ~750 mm above slab, ortho top view, measure only (never export linework), snap 25 mm.
- Sketch: read layout, ASK for grid, wall thickness, opening widths, room names, scale.
- Guesses → `asumsi`. Unresolved → `TANYA` → stop and ask.

## 2. KODE
`python tools/spek2lisp.py spek.yaml` → `.lsp` + `.png`. LOOK at the PNG.

## 3. CEK
`python tools/lint.py spek.yaml --lsp <file>.lsp`. Any GAGAL → fix yourself and rerun. Never report with GAGAL.
Then in AutoCAD: `(load "...")` → Load Once → ZOOM E → QSAVE → confirm no `*` in title bar.

## 4. Report
Done / not done, assumptions, lint result, open questions.

## 5. Corrections
Every owner correction → append to `KOREKSI.md` (Kesalahan / Aturan baru / Cek linter) AND add a `cek_...` function to `tools/lint.py`. Not done until both exist.

## 6. Curriculum
See `KURIKULUM.md`. Advance after 2 consecutive tasks ≥ 20/25 without major correction.
