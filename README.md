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
| `radar-cad-lihat-periksa` | **Wajib saat menggambar**: siklus gambar -> lihat (screenshot) -> cek -> perbaiki per tahap, urutan menggambar denah, cara membaca potongan SketchUp tanpa salah tangkap |

## Alat (`alat/`)
| File | Fungsi |
|---|---|
| `RADAR-SETUP.lsp` | Perintah `RADARSETUP` (pasang standar mm ke gambar aktif) dan `RADARFRAME` (frame A3 + title block). Juga `(radar:setup 100)` / `(radar:frame 100 "PROYEK" "JUDUL" '(0 0))` |
| `radar-dwg-baru.ps1` | Membuka dokumen AutoCAD **baru** dari `acadiso.dwt`, memuat LISP, setup, opsional frame & simpan |
| `autocad-mcp-mata.ps1` | Server AutoCAD MCP untuk Bambang: semua tool lama + `acad_lihat_area` / `acad_screenshot` (kirim screenshot AutoCAD sebagai **gambar**), `acad_zoom_window`, `acad_cek_denah` (hitung layer, garis dobel, layer wajib kosong) |
| `uji-cepat-mata.ps1` | Tes server di atas tanpa Bambang (AutoCAD harus terbuka) |
| `contoh-config-mcp-mata.json` | Contoh pendaftaran server `autocad-mata` |
| `python/radar_cad_dsl.py`, `python/radar_cad_lisp.py` | Generator AutoLISP (dinding union+solid, pintu, jendela, tangga, kolom, hatch) yang dipakai Claude |

Cepat:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File alat\radar-dwg-baru.ps1 -Skala 500 -Frame `
  -Proyek "NAMA PROYEK" -Judul "GROUND FLOOR PLAN" -Simpan "D:\...\denah.dwg"
```

## Referensi
`referensi/RADAR-CAD-STANDARDS.md` – dokumen standar lengkap (bahasa Inggris) sumber semua skill.

**Pasang di Bambang:** Settings → Repo → Tambah repo → isi `gabrielprocellia11-beep/CAD-Standards` → Tambah, lalu aktifkan keenam skill di tab Skill.
Repo harus **public** (Bambang tidak bisa membaca repo private).

## Mata untuk Bambang (`radar-cad-lihat-periksa`)
Bambang dulu menggambar **tanpa melihat**: ia hanya menerima koordinat garis, jadi tidak bisa membedakan dinding, kolom, furnitur atau garis tapak, dan tidak pernah mengecek hasilnya.
Skill `radar-cad-lihat-periksa` + server `alat/autocad-mcp-mata.ps1` memperbaikinya:

1. Tes server: buka AutoCAD dengan sebuah drawing, lalu
   `powershell -NoProfile -ExecutionPolicy Bypass -File alat\uji-cepat-mata.ps1`
   -> harus muncul "OK - gambar ... KB terkirim sebagai image", dan PNG di `%TEMP%\autocad-mcp-mata\` berisi tampilan AutoCAD (bukan hitam).
2. Di Bambang, ganti server `autocad` lama dengan perintah di `alat/contoh-config-mcp-mata.json` (sesuaikan path).
3. Aktifkan skill `radar-cad-lihat-periksa`.
4. Aplikasi Bambang harus meneruskan hasil tool bertipe `image` ke model AI. Jika Bambang tetap bilang tidak bisa melihat gambar, berarti aplikasinya yang membuang gambar.

Setiap screenshot memakai +/- 1.500-2.000 token; pastikan saldo kredit API cukup.
