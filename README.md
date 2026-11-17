# RAD+ar CAD skills (untuk Bambang / Claude)

Kumpulan skill format Claude (`SKILL.md`) berisi standar CAD kantor RAD+ar, plus alat supaya Bambang
bisa membuka gambar AutoCAD baru dalam **millimetre** dengan semua standar yang sama seperti Claude.

| Skill | Isi |
|---|---|
| `radar-cad-standar` | Aturan wajib, layer, frame plot, dinding/pintu/jendela, grid, dimensi, teks, FFL, plot style CTB |
| `radar-cad-dwg-baru` | **Buka DWG baru (mm)** dengan semua layer, linetype, text style, dimstyle WMS, blok kantor + frame A3 |
| `radar-cad-shortcut-alat` | Shortcut acad.pgp, extra LISP, CUIX, setup PC, pustaka LISP & hatch, otomatisasi AutoLISP |
| `radar-cad-pelajaran` | Riwayat latihan, DO & DON'T, kesalahan & perbaikan, tips kerja cepat |
| `radar-cad-proyek` | Data proyek DAAN MOGOT & HABCO |

## Alat (`alat/`)
| File | Fungsi |
|---|---|
| `RADAR-SETUP.lsp` | Perintah `RADARSETUP` (pasang standar mm ke gambar aktif) dan `RADARFRAME` (frame A3 + title block). Juga `(radar:setup 100)` / `(radar:frame 100 "PROYEK" "JUDUL" '(0 0))` |
| `radar-dwg-baru.ps1` | Membuka dokumen AutoCAD **baru** dari `acadiso.dwt`, memuat LISP, setup, opsional frame & simpan |
| `python/radar_cad_dsl.py`, `python/radar_cad_lisp.py` | Generator AutoLISP (dinding union+solid, pintu, jendela, tangga, kolom, hatch) yang dipakai Claude |

Cepat:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File alat\radar-dwg-baru.ps1 -Skala 500 -Frame `
  -Proyek "NAMA PROYEK" -Judul "GROUND FLOOR PLAN" -Simpan "D:\...\denah.dwg"
```

## Referensi
`referensi/RADAR-CAD-STANDARDS.md` – dokumen standar lengkap (bahasa Inggris) sumber semua skill.

**Pasang di Bambang:** Settings → Repo → Tambah repo → isi `gabrielprocellia11-beep/CAD-Standards` → Tambah, lalu aktifkan kelima skill di tab Skill.
Repo harus **public** (Bambang tidak bisa membaca repo private).
