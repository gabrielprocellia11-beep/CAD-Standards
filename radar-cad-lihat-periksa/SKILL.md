---
name: radar-cad-lihat-periksa
description: Wajib dipakai setiap kali menggambar atau mengedit denah/tampak/potongan di AutoCAD untuk RAD+ar, terutama bila sumbernya model SketchUp. Mengatur siklus gambar -> lihat -> bandingkan -> perbaiki, dan cara membaca garis potongan SketchUp supaya tidak salah tangkap.
---

# RAD+ar - Lihat & Periksa Gambar

Skill ini melengkapi `radar-cad-standar` (layer, dinding, pintu, frame) - baca keduanya.
Butuh server AutoCAD `alat/autocad-mcp-mata.ps1` (tool `acad_lihat_area`, `acad_screenshot`, `acad_cek_denah`).
Untuk dinding/pintu/tangga/kolom gunakan generator `alat/python/radar_cad_dsl.py` bila tersedia, lalu tetap LIHAT hasilnya.

## Aturan utama: jangan pernah menggambar buta

Koordinat garis BUKAN gambar. Daftar angka seperti `39399,1091975,43509,1091975`
tidak memberi tahu apakah itu dinding, kolom, meja, railing, atau garis taman.
Karena itu setiap tahap menggambar WAJIB diikuti dengan MELIHAT hasilnya.

Siklus untuk setiap tahap (bukan hanya di akhir):

1. **Gambar** satu tahap saja (lihat urutan di bawah).
2. **Lihat** - panggil `acad_lihat_area` (zoom ke frame/lantai + screenshot).
   Bila tool itu tidak ada, panggil `acad_zoom_window` lalu `acad_screenshot`.
3. **Ukur** - panggil `acad_cek_denah` untuk area yang sama (hitungan per layer,
   garis dobel, layer kosong).
4. **Bandingkan** dengan acuan: gambar acuan RAD+ar (PRACTICE 2.dwg / plot
   "HABCO GROUND FLOOR PLAN.pdf") dan screenshot model SketchUp lantai yang sama.
5. **Perbaiki** yang salah, lalu ulangi langkah 2-4 sampai lolos.
6. Baru lanjut ke tahap berikutnya.

Tulis di laporan apa yang terlihat di screenshot (1-3 kalimat) sebelum lanjut.
Jika tidak bisa mengambil screenshot, BERHENTI dan laporkan ke user - jangan
lanjut menggambar tanpa melihat.

## Urutan menggambar denah (satu lantai)

| Tahap | Isi | Layer | Lolos jika (dilihat di screenshot) |
|---|---|---|---|
| 0 | Underlay potongan SketchUp | `X-UNDERLAY` (warna 8, tidak di-plot) | Garis abu-abu tipis, posisi pas di tengah frame |
| 1 | Grid struktur + bubble | `AGRI` | Garis putus-putus menerus, jarak sama dengan model, bubble berlabel A,B,C / 1,2,3 |
| 2 | Kolom (blok, mis. COL-D800) di persilangan grid | `ASTR` | Setiap persilangan grid yang memang ada kolomnya terisi; tidak ada kolom melayang di luar grid |
| 3 | Dinding & dinding core: persegi tertutup per segmen -> REGION -> UNION -> hatch SOLID (lihat `radar-cad-standar`) | `ACUT` + `AHAT` | Dinding tebal hitam menerus, tidak putus-putus, tidak ada garis dobel |
| 4 | Isi core: tangga, lift, shaft | `AELE` | Bentuk tangga & lift jelas, berlabel STAIR / LIFT |
| 5 | Bukaan: daun pintu (`ACUT`), ayunan pintu (`ABOV`), kaca/jendela (`AELE`) | `ACUT` / `ABOV` / `AELE` | Pintu ada ayunannya, kaca garis tipis, dinding terbuka di posisi pintu |
| 6 | Label ruang + FFL | `ATEX` | Setiap ruang utama punya nama + FFL (mis. "MAIN LOBBY FFL +0.700") |
| 7 | Dimensi grid & total | `ADIM` / `ATEX` | Dimensi antar-grid dan total di 2 sisi |
| 8 | Judul, skala, frame A3 (pakai `RADARFRAME`, lihat `radar-cad-dwg-baru`) | `ATEX` / `ATEXTIT` | Denah memenuhi +/-60-75% frame, judul & skala bar terbaca |

Jangan loncat tahap. Jangan menggambar tahap 3 sebelum tahap 1-2 lolos.

## Cara membaca potongan SketchUp (sumber salah tangkap terbesar)

Garis hasil potongan adalah DATA MENTAH, bukan denah. Perlakukan sebagai underlay
yang harus DITAFSIRKAN, bukan disalin.

- **Tinggi potong**: potong di FFL lantai itu + 1200 mm. Jangan pakai nilai di
  bawah lantai (contoh salah: -450) - kolom dan dinding tidak terpotong benar.
- **Filter dulu di SketchUp**: potong hanya tag/layer struktur & dinding
  (Wall, Column, Core, Glass). Sembunyikan furnitur, landscape, entourage,
  railing dekoratif sebelum memotong.
- **Hapus garis dobel**: segmen yang koordinatnya sama (toleransi 5 mm) cukup
  satu. Jika `acad_cek_denah` melaporkan `garis_dobel > 0`, bersihkan dulu.
- **Kenali jenis garis dari bentuknya, lalu konfirmasi dengan screenshot**:
  - dua garis sejajar berjarak 100-300 mm, panjang -> dinding
  - kotak kecil persegi 400-1000 mm di pola berulang -> kolom (cocokkan ke grid)
  - kumpulan garis pendek sejajar berjarak 250-300 mm -> tangga
  - kotak +/-2000 x 2000 mm di dalam core -> lift
  - garis tunggal panjang di luar bangunan -> batas tapak / jalan (layer site, bukan dinding)
  - banyak garis kecil tak beraturan di tengah ruang -> furnitur (abaikan di denah arsitektur)
- **Kolom tidak boleh ditebak dari potongan saja**: tentukan grid dulu dari
  model, lalu taruh blok kolom di persilangan. Titik kolom yang tidak jatuh di
  grid = tanda salah tafsir, periksa ulang di SketchUp.
- **Skala & posisi**: unit model mm. Bila denah terlihat sangat kecil di dalam
  frame (< 30% lebar frame), kemungkinan unit/skala salah - cek sebelum lanjut.

## Kriteria selesai satu lantai

Semua harus benar, dilihat dari screenshot terakhir + hasil `acad_cek_denah`:

- [ ] Layer `AGRI`, `ASTR`, `ACUT`, `AHAT`, `ATEX` semuanya > 0 di area lantai itu
- [ ] `garis_dobel` = 0
- [ ] Dinding tampil sebagai hatch solid menerus, bukan garis putus-putus
- [ ] Tidak ada kolom di luar grid, tidak ada garis furnitur/landscape di layer `ACUT`
- [ ] Core (tangga + lift) terbaca jelas dan berlabel
- [ ] Label ruang + FFL ada; judul "LEVEL n PLAN - FFL +x.xxx" ada
- [ ] Denah mengisi +/-60-75% frame dan terpusat
- [ ] Underlay `X-UNDERLAY` dimatikan / tidak di-plot

Jika satu saja belum, lantai itu BELUM selesai - jangan pindah lantai berikutnya.

## Contoh kesalahan nyata (HABCO, 17 Nov 2026)

- Semua garis potongan disalin ke `ACUT` -> 0 kolom, 0 teks, garis dobel,
  furnitur & garis tapak tercampur dengan dinding.
- Potongan di level -450 -> kolom hilang / jadi titik melayang.
- Denah sangat kecil di dalam frame -> tidak diperiksa karena tidak pernah dilihat.
- Semua kesalahan ini akan tertangkap di langkah 2-3 siklus di atas.

## Cara menilai screenshot denah

Saat melihat screenshot hasil `acad_lihat_area`, jawab pertanyaan ini satu per satu
dan tulis jawabannya singkat di laporan. Jangan menjawab "terlihat baik" tanpa
menyebut apa yang dilihat.

1. **Komposisi** - Apakah denah terpusat di frame dan mengisi +/-60-75%?
   Bila terlalu kecil/besar: periksa unit (mm) dan skala frame (1:400 A3 = frame
   +/- 168.000 x 118.800 mm di model).
2. **Grid** - Apakah garis grid menerus dan berlabel? Jumlah grid sama dengan model?
3. **Kolom** - Apakah semua kolom tepat di persilangan grid? Ada kolom melayang?
4. **Dinding** - Apakah dinding hitam solid dan menerus? Ada celah aneh, garis
   dobel (terlihat lebih tebal/kabur), atau dinding yang hanya satu garis?
5. **Core** - Tangga dan lift terbaca? Posisinya sama dengan model SketchUp?
6. **Sampah** - Ada furnitur, pohon, mobil, garis tapak yang ikut di layer dinding?
7. **Teks** - Nama ruang, FFL, judul terbaca dan tidak saling tumpuk?
8. **Dibanding acuan** - Sebutkan 1-3 perbedaan terbesar dengan gambar acuan
   (PRACTICE 2 / plot HABCO GROUND FLOOR PLAN). Perbaiki yang terbesar dulu.

Bila ragu apakah suatu garis itu dinding atau bukan: ambil screenshot model
SketchUp di posisi yang sama, atau tanya user. Jangan menebak.

### Tanda bahaya - berhenti dan perbaiki dulu

- `acad_cek_denah` melaporkan layer wajib = 0
- `garis_dobel` > 0
- Ratusan LINE pendek di `ACUT` tanpa satu pun HATCH
- Denah < 30% lebar frame
- Screenshot gagal / hitam -> jangan lanjut menggambar, laporkan ke user
