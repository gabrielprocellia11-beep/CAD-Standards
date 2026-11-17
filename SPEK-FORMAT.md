# Format Spek (YAML)

Spek adalah **satu sumber kebenaran** gambar. Owner cukup memeriksa angka di spek; gambar dibuat otomatis dari spek. Semua ukuran dalam **mm**, koordinat proyek dipertahankan.

```yaml
proyek: HABCO                 # wajib
lantai: L1                    # wajib
ffl: "+0.700"                 # wajib, 3 desimal, ±0.000 = jalan utama
skala: 400                    # wajib: 100/150/200/250/300/400/500/750/1000

grid:                         # wajib, dimensi selalu ke grid
  x: {A: 30812.5, B: 36812.5}
  y: {"1": 1056587.5, "2": 1061087.5}

kolom:                        # block COL-..., di ASTR
  tipe: COL-D800
  di: semua_titik_grid        # atau: titik: [[x,y], ...]

dinding:                      # garis AS + tebal (50/100/150/200/250/300)
  - {id: W1, dari: [x,y], ke: [x,y], tebal: 250}
  # opsional ext0/ext1: perpanjangan ujung manual (default otomatis menembus dinding yang ditemui)

bukaan:                       # posisi = jarak dari 'dari' dinding ke TENGAH bukaan
  - {tipe: pintu,       dinding: W1, posisi: 4200, lebar: 900, sisi: kiri, engsel: awal}
  - {tipe: pintu-ganda, dinding: W1, posisi: 8000, lebar: 1600, sisi: kanan}
  - {tipe: sliding,     dinding: W1, posisi: 12000, lebar: 1800}
  - {tipe: jendela,     dinding: W1, posisi: 15000, lebar: 2400}
  # sisi  = ke sisi mana daun membuka, dilihat dari arah 'dari' -> 'ke'
  # engsel = awal / akhir (ujung celah yang dekat 'dari' atau 'ke')

tangga:
  - {x0: 0, y0: 0, x1: 1200, y1: 3300, anak_tangga: 12, arah: y}

ramp:                         # selalu dicek; isi [] jika memang tidak ada
  - {batas: [[x,y], ...], kemiringan: "1:12"}

ruang:
  - {nama: LOBBY, titik: [x,y], level: "+0.700", batas: [[x,y], ...]}
  # 'batas' dipakai linter untuk memastikan teks ada di dalam ruang

asumsi: []                    # setiap tebakan ditulis di sini, dilaporkan ke owner
TANYA: []                     # pertanyaan terbuka -> spek2lisp menolak jalan sampai kosong
```

## Cara mengisi
- **Dari SketchUp:** section plane ±750 mm di atas pelat, kamera atas ortografis, ukur (Ruby atau gambar ber-skala). Hanya **mengukur**: linework tidak pernah diekspor. Snap ke 25 mm.
- **Dari sketsa:** baca tata letak, lalu tanyakan grid, tebal dinding, lebar bukaan, nama ruang dan skala. Jangan menebak diam-diam.
