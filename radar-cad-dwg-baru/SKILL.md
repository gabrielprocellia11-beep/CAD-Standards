---
name: radar-cad-dwg-baru
description: Cara Bambang membuka gambar AutoCAD BARU dalam satuan millimetre lengkap dengan standar RAD+ar (semua layer resmi, linetype, text style ROMANS/GILLSANS, dimstyle WMS, blok kantor dari Cad standards.dwg) dan membuat frame A3 + title block. Pakai setiap kali diminta "buka/buat dwg baru", "gambar baru", "new drawing", atau sebelum mulai menggambar denah dari nol.
---

# Membuka DWG baru standar RAD+ar (mm)

Hasilnya sama dengan gambar yang dibuat Claude: 1 unit = 1 mm, model space 1:1, semua layer kantor
dengan warna/linetype/lineweight resmi, ROMANS + GILLSANS, dimstyle `WMS<skala>`, blok kantor
(`level-reduced`, `room data`, label pintu/jendela, section/elevation marker, material key, `ARROW1` …).
Detail standarnya ada di skill **radar-cad-standar** — baca juga sebelum menggambar.

## Langkah (pakai `run_powershell`)

### 1. Ambil alat dari repo (sekali per komputer, ulangi kalau repo di-update)
```powershell
$d = "$env:APPDATA\Bambang\radar-cad"
New-Item -ItemType Directory -Force $d | Out-Null
foreach ($f in 'RADAR-SETUP.lsp','radar-dwg-baru.ps1') {
  Invoke-WebRequest "https://raw.githubusercontent.com/gabrielprocellia11-beep/CAD-Standards/main/alat/$f" -OutFile "$d\$f" -UseBasicParsing
  Unblock-File "$d\$f"
}
```

### 2. Buka gambar baru
Tanyakan dulu kalau belum jelas: **skala** (1:100 / 1:200 / 1:250 / 1:400 / 1:500), **nama proyek**,
**judul gambar**, dan **nama + folder file**.
```powershell
$d = "$env:APPDATA\Bambang\radar-cad"
powershell -NoProfile -ExecutionPolicy Bypass -File "$d\radar-dwg-baru.ps1" `
  -Skala 500 -Frame -Proyek "DAAN MOGOT WEST LAKE GARDEN" -Judul "GROUND FLOOR PLAN" `
  -Simpan "D:\000 RAD+AR\009 DAAN MOGOT\CAD\002 denah.dwg"
```
| Parameter | Arti |
|---|---|
| `-Skala` | skala gambar (default 100). Menentukan dimstyle aktif `WMS<skala>`, tinggi teks, LTSCALE, ukuran frame |
| `-Frame` | sekalian gambar frame A3 + title block di 0,0 |
| `-Proyek`, `-Judul` | teks title block (otomatis jadi huruf kapital berjarak `G R O U N D   F L O O R   P L A N`) |
| `-Simpan` | path .dwg. **Tidak menimpa** file yang sudah ada kecuali `-Timpa` |
| `-Template` | default `acadiso.dwt` (metrik). Jangan pakai `acad.dwt` (inch) |

Skrip ini selalu membuat dokumen **baru** — gambar lain yang sedang dibuka user tidak disentuh.
Jika AutoCAD belum jalan, skrip menjalankannya.

### 3. Cek hasil
Skrip mencetak `OK - ... INSUNITS=4 (4 = mm) | 35+ layer | dimstyle WMS500`. Kalau `INSUNITS` bukan 4
atau muncul dialog **"Security - Unsigned Executable File"**: pilih **Load Once**, lalu di command line
ketik `RADARSETUP` (isi skala). Ambil screenshot untuk memastikan frame ada di layar.

## Kalau mau manual di AutoCAD
1. `NEW` → pilih **acadiso.dwt**.
2. `APPLOAD` → `%APPDATA%\Bambang\radar-cad\RADAR-SETUP.lsp` → Load.
3. `RADARSETUP` → skala. `RADARFRAME` → skala, nama proyek, judul, titik kiri-bawah.
Juga bisa dari LISP: `(radar:setup 400)` dan `(radar:frame 400 "HABCO" "FIRST FLOOR PLAN" '(175000 0))`.

## Yang dipasang RADARSETUP
- `INSUNITS 4`, `MEASUREMENT 1`, `LUNITS 2`, `LUPREC 0`, `INSUNITSDEFSOURCE/TARGET 4`, UCS World.
- Linetype `HIDDEN`, `PHANTOM`, `HIDDEN2` dari acadiso.lin; `LTSCALE = skala × 0.25` (default kerja —
  sesuaikan kalau Cad standards.dwg memakai nilai lain), `PSLTSCALE 1`.
- 35 layer: 0 · ACUT · ASTR · AELE · AWIN · ABOV(HIDDEN) · AHAT · APAT · AFUR · ASAN(PHANTOM) · ALAND · AELELT ·
  AGRI(PHANTOM) · ADIM · ATEX · ATEXNRL · ATEXRM · ATEXTIT · ATEXDTL · ATEXERL · ATIT · ASIT(PHANTOM) ·
  ASET(PHANTOM) · AEXTG(HIDDEN2) · ADRAIN · ALIG · AWIR · ARCP · AREA · AELEC · AOUTL · AREV · URACAD · ATHRES ·
  Defpoints (181, tidak di-plot). Warna = tebal pena di CTB, jangan diubah.
- Text style **ROMANS** (romans.shx) dan **GILLSANS** (Gill Sans MT bold). `TEXTSIZE = 2 × skala`.
- Dimstyle **WMS100 … WMS1000** (100,150,200,250,300,400,500,750,1000): text 2, tick oblique 2, warna teks 8,
  gap 1, ext offset 2, ext extend 2, presisi 0, ROMANS, DIMSCALE = skala. WMS yang sudah ada tidak ditimpa.
- Blok kantor + dimstyle WMS asli disalin dari `D:\000 RAD+AR\Cad standards.dwg` (atau
  `D:\000 CAD Content\Cad Standard\Cad standards.dwg`) lewat ObjectDBX, kalau file itu ada.
- `D:\000 CAD Content\Hatch` ditambahkan ke Support File Search Path kalau foldernya ada.

## Frame RADARFRAME (A3 landscape, model space)
Sheet 420S × 297S (Defpoints, merah) · border offset 5S · guide box offset 9S (kuning) · title block di tengah bawah:
nama proyek y 31.5 h 2.25 · judul y 27 h 1.875 · angka scale bar y 22.375 · scale bar 18.125–20.125 ·
`1:S - A3` y 16.125 · `R A D + a r` y 12.225 · bulan-tahun y 9.475 · `© RAD+ar <tahun>.  All rights reserved.` y 6.725
(semua × S dari bawah sheet). North arrow sederhana di kanan judul — ganti dengan blok north arrow kantor kalau ada.
Lantai berikutnya: frame berdampingan (mis. origin x 175000 @1:400, 210000 @1:500).

## Larangan (sama seperti Claude)
- **Jangan PURGE.** Jangan trace/export dari SketchUp atau DWG lain — gambar sendiri.
- Isi gambar harus di dalam guide box kuning; kalau tidak muat, naikkan skala.
- Simpan dengan QSAVE di akhir, pastikan tidak ada `*` di judul jendela.
