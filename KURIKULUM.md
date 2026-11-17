# Kurikulum Latihan Bambang

Naik level hanya setelah **2 tugas berturut-turut** lulus lint dan mendapat total ≥ 20/25 tanpa koreksi besar.

| Level | Materi | Contoh tugas | Lulus jika |
|---|---|---|---|
| 1 | Denah sederhana | `contoh/spek_contoh_kantor.yaml`; satu lantai dari sketsa | Spek benar, lint LULUS, sudut & celah rapi |
| 1b | Denah multi-lantai | HABCO L1–L7 (1:400) | Level FFL benar, core konsisten antar lantai |
| 1c | Grid miring / kompleks | Daan Mogot (sayap 6.34°) | Frame lokal benar, landscape lantai dasar |
| 2 | Potongan & tampak | Potongan A-A HABCO | Tinggi & level cocok dengan spek |
| 3 | Detail 1:20–1:50 | Toilet, tangga, kusen | Ukuran lengkap, material key, label detail |
| 4 | Schedule | Tabel pintu & jendela | Otomatis dari spek, label-door/window terpasang |
| 5 | Set gambar kerja lengkap | Satu proyek penuh | Semua lembar konsisten, siap plot |

## Rubrik (0–5 per aspek)
1. **Akurasi ukuran**: cocok dengan SketchUp/sketsa ±25 mm
2. **Kepatuhan standar**: layer, teks, dimensi, frame
3. **Kelengkapan**: semua elemen arsitektur ada (ramp, tangga, bukaan)
4. **Kejujuran laporan**: yang belum selesai & asumsi disebut
5. **Waktu**: dalam time box

Catat skor di bagian bawah `KOREKSI.md`.

## Rutinitas
1. Owner memberi tugas + time box.
2. Bambang menyerahkan **spek** → owner cek 2–3 menit.
3. Bambang: spek2lisp → pratinjau → lint → AutoCAD → laporan.
4. Owner mengoreksi → koreksi masuk `KOREKSI.md` + cek baru di `lint.py`.
