# baca-model-3d.rb  -  RAD+ar
# Membaca model SketchUp yang sedang terbuka SECARA OTOMATIS, tanpa perlu
# nama grup / tag / Outliner:
#   1. cari bangunan (tumpukan pelat lantai yang bertingkat)
#   2. hitung lantai tiap bangunan + FFL tiap lantai (relatif jalan/tapak)
#   3. buat GAMBAR potongan denah tiap lantai (FFL + 1200 mm, tampak atas,
#      orthographic) + skala ukur mm/pixel, untuk MENGUKUR (bukan export garis)
#   4. tulis ringkasan.txt + ringkasan.json
#
# Cara pakai (Ruby di SketchUp):
#   $radar_out = 'D:/000 RAD+AR/AI/PRACTICE/_baca3d'   # opsional
#   load 'D:/000 RAD+AR/AI/CAD-Standards/alat/baca-model-3d.rb'
# atau tempel seluruh isi file ini ke Ruby console / tool SketchUp.
#
# Model TIDAK diubah: semua perubahan sementara dibatalkan di akhir.
# Koordinat yang dilaporkan = koordinat model SketchUp dalam mm.
# Pakai koordinat yang sama di AutoCAD (1:1, mm) supaya ukuran bisa dicocokkan.

require 'json'

module RadarBaca3D
  MIN_SLAB_M2   = 10.0    # pelat/lantai minimal (m2)
  ELEV_MIN_MM   = 2500.0  # pelat di atas tapak + ini = lantai atas
  LEVEL_TOL_MM  = 900.0   # muka lantai dalam toleransi ini = satu level
  MIN_STOREY_MM = 2000.0  # tinggi lantai minimum
  LEVEL_AREA_FR = 0.25    # level dianggap lantai jika luasnya >= 25% level terbesar
  CUT_MM        = 1200.0  # tinggi potong di atas FFL
  IMG_W         = 2400

  # ---------- logika murni (bisa dites tanpa SketchUp) ----------

  # faces: [{z:, area:, minx:, miny:, maxx:, maxy:}] dalam mm / m2
  def self.ground_z(faces)
    big = faces.max_by { |f| f[:area] }
    big ? big[:z] : 0.0
  end

  def self.overlap?(a, b, tol)
    a[:minx] - tol <= b[:maxx] && b[:minx] - tol <= a[:maxx] &&
      a[:miny] - tol <= b[:maxy] && b[:miny] - tol <= a[:maxy]
  end

  def self.merge_box(a, b)
    { minx: [a[:minx], b[:minx]].min, miny: [a[:miny], b[:miny]].min,
      maxx: [a[:maxx], b[:maxx]].max, maxy: [a[:maxy], b[:maxy]].max,
      area: a[:area].to_f + b[:area].to_f }
  end

  # kelompokkan pelat yang terangkat (lantai atas) menjadi bangunan
  def self.find_buildings(faces, zg)
    elev = faces.select { |f| f[:z] > zg + ELEV_MIN_MM && f[:area] >= MIN_SLAB_M2 }
    boxes = elev.map { |f| f.slice(:minx, :miny, :maxx, :maxy, :area) }
    loop do
      merged = false
      out = []
      boxes.each do |b|
        hit = out.find { |o| overlap?(o, b, 500.0) }
        if hit then out[out.index(hit)] = merge_box(hit, b); merged = true
        else out << b end
      end
      boxes = out
      break unless merged
    end
    # buang kelompok kecil (kanopi, pergola) : < 15% bangunan terbesar
    maxa = boxes.map { |b| b[:area] }.max || 0
    boxes.select { |b| b[:area] >= 0.15 * maxa }
  end

  def self.inside?(f, box, tol = 1000.0)
    cx = (f[:minx] + f[:maxx]) / 2.0
    cy = (f[:miny] + f[:maxy]) / 2.0
    cx >= box[:minx] - tol && cx <= box[:maxx] + tol && cy >= box[:miny] - tol && cy <= box[:maxy] + tol
  end

  # level lantai satu bangunan dari muka horizontal yang menghadap ke atas
  def self.levels_for(faces, box, zg)
    foot = (box[:maxx] - box[:minx]) * (box[:maxy] - box[:miny]) / 1.0e6
    # buang bidang tapak/jalan yang jauh lebih besar dari tapak bangunan
    fs = faces.select { |f| f[:area] >= MIN_SLAB_M2 && f[:area] <= 1.5 * foot && f[:z] >= zg - 1500.0 && inside?(f, box) }
    fs = fs.sort_by { |f| f[:z] }
    groups = []
    fs.each do |f|
      g = groups.last
      if g && f[:z] - g[:zmin] <= LEVEL_TOL_MM
        g[:faces] << f
      else
        groups << { zmin: f[:z], faces: [f] }
      end
    end
    lv = groups.map do |g|
      byz = Hash.new(0.0)
      g[:faces].each { |f| byz[(f[:z] / 10.0).round * 10.0] += f[:area] }
      { z: byz.max_by { |_, a| a }[0], area: g[:faces].sum { |f| f[:area] } }
    end
    maxa = lv.map { |l| l[:area] }.max || 0
    lv = lv.select { |l| l[:area] >= LEVEL_AREA_FR * maxa }
    clean = []
    lv.each do |l|
      if clean.last && l[:z] - clean.last[:z] < MIN_STOREY_MM
        clean[-1] = l if l[:area] > clean.last[:area]
      else
        clean << l
      end
    end
    clean
  end

  def self.analyse(faces)
    zg = ground_z(faces)
    blds = find_buildings(faces, zg).map { |b| b.merge(levels: levels_for(faces, b, zg)) }
    blds = blds.sort_by { |b| -b[:levels].size }
    blds.each_with_index do |b, i|
      b[:nama] = "GEDUNG #{(65 + i).chr}"
      n = b[:levels].size
      b[:levels].each_with_index do |l, k|
        l[:nama]  = (k == n - 1 && n > 1) ? 'ROOF' : "LEVEL #{k + 1}"
        l[:ffl_m] = ((l[:z] - zg) / 1000.0).round(3)
      end
      b[:jumlah_lantai] = n > 1 ? n - 1 : n
    end
    { ground_z_mm: zg.round, bangunan: blds }
  end

  # ---------- bagian SketchUp ----------

  def self.mm(v) v.to_f * 25.4 end   # inch (internal) -> mm

  def self.collect_faces(model)
    out = []
    walk = lambda do |ents, tr, depth|
      ents.each do |e|
        next if e.respond_to?(:hidden?) && e.hidden?
        next if e.respond_to?(:layer) && e.layer && !e.layer.visible?
        if e.is_a?(Sketchup::Face)
          n = e.normal.transform(tr)
          next if n.length == 0
          n.normalize!
          next unless n.z > 0.985   # hanya muka horizontal menghadap ke atas
          pts = e.outer_loop.vertices.map { |v| v.position.transform(tr) }
          xs = pts.map { |p| mm(p.x) }; ys = pts.map { |p| mm(p.y) }
          a = 0.0
          pts.each_index { |i| j = (i + 1) % pts.size; a += xs[i] * ys[j] - xs[j] * ys[i] }
          area = a.abs / 2.0 / 1.0e6
          next if area < 2.0
          out << { z: pts.map { |p| mm(p.z) }.sum / pts.size, area: area,
                   minx: xs.min, miny: ys.min, maxx: xs.max, maxy: ys.max }
        elsif (e.is_a?(Sketchup::Group) || e.is_a?(Sketchup::ComponentInstance)) && depth < 12
          walk.call(e.definition.entities, tr * e.transformation, depth + 1)
        end
      end
    end
    walk.call(model.entities, Geom::Transformation.new, 0)
    out
  end

  # potongan denah: tampak atas ortho, section plane di z_cut, fit ke box
  def self.shoot(model, box, z_ffl_mm, path)
    v = model.active_view
    zc = (z_ffl_mm + CUT_MM) / 25.4
    # normal menunjuk ke sisi yang DIBUANG (di atas potongan). $radar_flip = true jika hasilnya terbalik.
    nz = $radar_flip ? -1 : 1
    sp = model.entities.add_section_plane([Geom::Point3d.new(0, 0, zc), Geom::Vector3d.new(0, 0, nz)])
    sp.activate
    mx = 5000.0
    cx = (box[:minx] + box[:maxx]) / 2.0 / 25.4
    cy = (box[:miny] + box[:maxy]) / 2.0 / 25.4
    aspect = v.vpwidth.to_f / v.vpheight
    w_mm = box[:maxx] - box[:minx] + 2 * mx
    h_mm = box[:maxy] - box[:miny] + 2 * mx
    hgt = [h_mm, w_mm / aspect].max / 25.4
    cam = v.camera
    cam.set(Geom::Point3d.new(cx, cy, zc + 400.0 / 0.0254), Geom::Point3d.new(cx, cy, zc), Y_AXIS)
    cam.perspective = false
    cam.height = hgt
    ih = (IMG_W / aspect).round
    v.write_image(path, IMG_W, ih, true)
    # skala ukur dari dua titik nyata
    sx = IMG_W.to_f / v.vpwidth; sy = ih.to_f / v.vpheight
    p1 = v.screen_coords(Geom::Point3d.new(cx - 10000.0 / 25.4, cy + 10000.0 / 25.4, zc))
    p2 = v.screen_coords(Geom::Point3d.new(cx + 10000.0 / 25.4, cy - 10000.0 / 25.4, zc))
    px_per_20m = ((p2.x - p1.x) * sx)
    mmpp = 20000.0 / px_per_20m
    x0 = (cx * 25.4) - (p1.x * sx + (p2.x - p1.x) * sx / 2.0) * mmpp
    y0 = (cy * 25.4) + (p1.y * sy + (p2.y - p1.y) * sy / 2.0) * mmpp
    sp.erase! if sp.valid?
    { file: File.basename(path), lebar_px: IMG_W, tinggi_px: ih, mm_per_px: mmpp.round(3),
      x_kiri_atas_mm: x0.round, y_kiri_atas_mm: y0.round, potong_z_mm: (z_ffl_mm + CUT_MM).round,
      rumus: 'X_mm = x_kiri_atas_mm + px * mm_per_px ;  Y_mm = y_kiri_atas_mm - py * mm_per_px' }
  end

  def self.run(out_dir = nil)
    model = Sketchup.active_model
    out_dir ||= $radar_out
    out_dir ||= (model.path.to_s.empty? ? File.join(Dir.home, 'baca3d') : File.join(File.dirname(model.path), '_baca3d'))
    Dir.mkdir(out_dir) unless File.directory?(out_dir)
    model.close_active while model.active_path

    faces = collect_faces(model)
    res = analyse(faces)
    zg = res[:ground_z_mm]

    v = model.active_view
    c = v.camera
    keep = [c.eye.clone, c.target.clone, c.up.clone, c.perspective?, (c.perspective? ? c.fov : c.height)]
    ro = model.rendering_options
    keep_ro = { 'DisplaySectionPlanes' => ro['DisplaySectionPlanes'], 'DisplaySectionCuts' => ro['DisplaySectionCuts'] }
    model.start_operation('RADAR baca 3D', true)
    begin
      ro['DisplaySectionPlanes'] = false
      ro['DisplaySectionCuts'] = true
      res[:bangunan].each do |b|
        b[:levels].each do |l|
          next if l[:nama] == 'ROOF'
          f = format('%s_%s.png', b[:nama].tr(' ', '_'), l[:nama].tr(' ', '_'))
          l[:gambar] = shoot(model, b, l[:z], File.join(out_dir, f))
        end
      end
      # gambar gabungan semua bangunan per level gedung tertinggi (untuk 1 frame = 1 lantai)
      all = res[:bangunan].map { |b| b }.reduce { |a, b| merge_box(a, b) }
      if all && res[:bangunan][0]
        res[:gabungan] = res[:bangunan][0][:levels].reject { |l| l[:nama] == 'ROOF' }.map do |l|
          f = format('SEMUA_%s.png', l[:nama].tr(' ', '_'))
          { level: l[:nama], ffl_m: l[:ffl_m], gambar: shoot(model, all, l[:z], File.join(out_dir, f)) }
        end
      end
    ensure
      model.abort_operation
      keep_ro.each { |k, val| ro[k] = val }
      v.camera.set(keep[0], keep[1], keep[2])
      v.camera.perspective = keep[3]
      keep[3] ? (v.camera.fov = keep[4]) : (v.camera.height = keep[4])
    end

    res[:catatan] = [
      'Gambar PNG hanya untuk MENGUKUR. Jangan export / trace garisnya ke AutoCAD.',
      'Koordinat = koordinat model SketchUp (mm). Gambar di AutoCAD pada koordinat yang sama, 1:1.',
      'Jumlah lantai & FFL dihitung otomatis dari pelat lantai. Periksa dengan melihat gambar; jika ragu, sebutkan apa yang ragu.',
      'Jika gambar LEVEL menunjukkan ATAP / tampak atas (bukan denah terpotong), jalankan ulang dengan $radar_flip = true.'
    ]
    File.write(File.join(out_dir, 'ringkasan.json'), JSON.pretty_generate(res))
    txt = ["RINGKASAN MODEL 3D  (#{File.basename(model.path.to_s)})", "Tapak/jalan z = #{zg} mm  (FFL +0.000)", '']
    res[:bangunan].each do |b|
      txt << "#{b[:nama]}: #{b[:jumlah_lantai]} lantai + atap  |  kotak X #{b[:minx].round}..#{b[:maxx].round}  Y #{b[:miny].round}..#{b[:maxy].round} mm  (#{((b[:maxx] - b[:minx]) / 1000).round(1)} x #{((b[:maxy] - b[:miny]) / 1000).round(1)} m)"
      b[:levels].each { |l| txt << format('   %-9s FFL %+.3f   luas pelat ~%d m2   %s', l[:nama], l[:ffl_m], l[:area].round, l[:gambar] ? l[:gambar][:file] : '') }
      txt << ''
    end
    txt << "Folder: #{out_dir}"
    txt += res[:catatan]
    File.write(File.join(out_dir, 'ringkasan.txt'), txt.join("\n"))
    puts txt.join("\n")
    res
  end
end

RadarBaca3D.run if defined?(Sketchup)
