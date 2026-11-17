# RAD+ar CAD Standards: Metode Bambang (SPEK → KODE → CEK)

Repo ini melatih dan mengatur **Bambang** (agen AI drafter RAD+ar) supaya bisa membuat gambar kerja CAD yang detail dan akurat dari model SketchUp maupun sketsa tangan.

## Alur wajib untuk setiap tugas gambar

```
1. Baca KOREKSI.md
2. SPEK   ukur SketchUp / baca sketsa  ->  spek_<proyek>_<lantai>.yaml
          (ada TANYA?  -> berhenti, tanyakan ke owner)
3. KODE   python tools/spek2lisp.py spek.yaml   ->  .lsp + .png
          lihat .png
4. CEK    python tools/lint.py spek.yaml --lsp hasil.lsp
          GAGAL? -> perbaiki sendiri, ulangi
5. AutoCAD: (load "hasil.lsp") -> Load Once -> ZOOM E -> QSAVE
6. Lapor: selesai / belum / asumsi / hasil lint / pertanyaan
7. Koreksi owner -> KOREKSI.md + satu cek baru di tools/lint.py
```

## Isi repo

| File | Fungsi |
|---|---|
| `SKILL.md` | Skill `bambang-spek-kode-cek` (instruksi kerja untuk Bambang) |
| `SPEK-FORMAT.md` | Format spek YAML, field demi field |
| `KOREKSI.md` | Buku koreksi owner: setiap koreksi menjadi aturan + cek linter |
| `KURIKULUM.md` | Level latihan 1–5 + rubrik penilaian |
| `tools/spek2lisp.py` | Spek → AutoLISP + pratinjau PNG |
| `tools/lint.py` | Pemeriksa aturan (keluar kode 1 jika GAGAL) |
| `contoh/` | Contoh spek latihan Level 1 + hasilnya |

Standar layer, frame A3, teks, dimensi dan aturan emas ada di skill `radar-cad-standards` dan `D:\000 RAD+AR\AI\bambang-desktop\knowledge\RADAR-CAD-STANDARDS.md`.

## Kebutuhan
Python 3.9+, `pyyaml`, `matplotlib`. AutoCAD (full, bukan LT) untuk memuat `.lsp`.
Block kolom (mis. `COL-D400`, `COL-D800`) harus sudah ada di DWG. Jika belum ada, kolom dilewati dan muncul pesan.

## Batasan v1 `spek2lisp.py`
Sudah: grid, kolom, dinding + celah bukaan + hatch solid, pintu tunggal/ganda, sliding, jendela, tangga lurus, ramp, nama ruang + FFL, dimensi grid 2 tingkat.
Belum: frame A3/title block (pakai template kantor), dinding lengkung, potongan/tampak, detail, schedule. Ditambah bertahap sesuai `KURIKULUM.md`.
