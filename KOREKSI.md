# Buku Koreksi Owner

Dibaca Bambang **sebelum setiap tugas**. Setiap entri adalah aturan wajib.
Satu koreksi baru dianggap selesai jika sudah ada di sini **dan** sudah menjadi cek di `tools/lint.py`.

Format:
```
## YYYY-MM-DD: <proyek>
Kesalahan: ...
Aturan baru: ... (harus terukur)
Cek linter: C.. / L.. (nama fungsi)
```

---

## Koreksi awal (dari standar & koreksi sebelumnya)

| # | Aturan | Cek |
|---|---|---|
| K01 | Jangan pernah export/trace dari SketchUp atau DWG lain; gambar ulang sendiri | proses (lapor sumber ukuran) |
| K02 | Dinding selalu bercelah di pintu & jendela | C04/C06 + spek2lisp |
| K03 | Jangan hatch lantai; GRASS hanya di taman/planter | L03 |
| K04 | Kolom struktur = block | C09 |
| K05 | Setiap bangunan detail punya grid + dimensi 2 tingkat | C08 |
| K06 | Cari dan gambar ramp | C11 |
| K07 | Jangan PURGE | L01 |
| K08 | Teks tidak keluar dari ruang | C10 |
| K09 | Isi harus muat di guide box A3, jika tidak naikkan skala | C12 |
| K10 | Tanyakan informasi yang kurang, jangan menebak | C00 / C13 |

---

## Log koreksi baru

<!-- tambahkan di bawah ini -->

---

## Skor latihan

| Tanggal | Level | Tugas | Akurasi | Standar | Lengkap | Jujur | Waktu | Total /25 | Catatan |
|---|---|---|---|---|---|---|---|---|---|
