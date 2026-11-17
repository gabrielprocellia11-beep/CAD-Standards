#!/usr/bin/env python3
"""lint.py - RAD+ar: cek aturan pada spek YAML (dan .lsp hasilnya) SEBELUM masuk AutoCAD.

Pemakaian:
    python lint.py contoh/spek_contoh_kantor.yaml [--lsp hasil.lsp]

Keluar dengan kode 1 jika ada GAGAL. Bambang wajib memperbaiki semua GAGAL
sebelum melapor. PERINGATAN boleh lolos tapi harus disebut di laporan.

Menambah cek baru (dari KOREKSI.md): tulis fungsi `cek_xxx(spek, r)` lalu
daftarkan di CEK di bawah. Satu koreksi = satu cek.
"""
import argparse, math, re, sys
import yaml

TEBAL_OK = {50, 100, 150, 200, 250, 300}
LAYER_OK = {"0", "ACUT", "AHAT", "ASTR", "AELE", "AWIN", "ABOV", "APAT", "AFUR", "ASAN", "ALAND",
            "AELELT", "AGRI", "ADIM", "ATEX", "ATEXNRL", "ATEXRM", "ATEXTIT", "ATEXDTL", "ATEXERL",
            "ASIT", "ASET", "AEXTG", "ADRAIN", "DEFPOINTS"}
SKALA_OK = {100, 150, 200, 250, 300, 400, 500, 750, 1000}


class R:
    def __init__(self):
        self.gagal, self.warn = [], []

    def g(self, kode, msg): self.gagal.append(f"[{kode}] {msg}")
    def w(self, kode, msg): self.warn.append(f"[{kode}] {msg}")


def panjang(w):
    return math.hypot(w["ke"][0] - w["dari"][0], w["ke"][1] - w["dari"][1])


def inside(p, poly):
    x, y, ins = p[0], p[1], False
    for i in range(len(poly)):
        x1, y1 = poly[i]; x2, y2 = poly[(i + 1) % len(poly)]
        if (y1 > y) != (y2 > y) and x < (x2 - x1) * (y - y1) / (y2 - y1) + x1:
            ins = not ins
    return ins


# ---------- cek ----------
def cek_tanya(s, r):
    if s.get("TANYA"):
        r.g("C00", f"Masih ada {len(s['TANYA'])} TANYA. Berhenti dan tanyakan ke owner.")


def cek_dasar(s, r):
    for k in ("proyek", "lantai", "skala", "ffl"):
        if k not in s: r.g("C01", f"Field '{k}' wajib ada.")
    if s.get("skala") not in SKALA_OK: r.g("C01", f"Skala 1:{s.get('skala')} bukan skala kantor.")
    if "ffl" in s and not re.fullmatch(r"[+\-±]\d+\.\d{3}", str(s["ffl"])):
        r.g("C02", f"FFL '{s['ffl']}' harus format +0.700 / -0.450 / ±0.000.")


def cek_dinding(s, r):
    ids = set()
    for w in s.get("dinding", []):
        if w.get("id") in ids: r.g("C03", f"ID dinding dobel: {w.get('id')}")
        ids.add(w.get("id"))
        if w.get("tebal") not in TEBAL_OK:
            r.g("C03", f"{w['id']}: tebal {w.get('tebal')} tidak standar (50/100/150/250/300).")
        if panjang(w) < 1: r.g("C03", f"{w['id']}: panjang nol.")


def cek_bukaan(s, r):
    walls = {w["id"]: w for w in s.get("dinding", [])}
    per = {}
    for i, op in enumerate(s.get("bukaan", [])):
        nm = f"bukaan#{i + 1} ({op.get('tipe')})"
        w = walls.get(op.get("dinding"))
        if not w: r.g("C04", f"{nm}: dinding '{op.get('dinding')}' tidak ada."); continue
        c0, c1 = op["posisi"] - op["lebar"] / 2, op["posisi"] + op["lebar"] / 2
        if c0 < 0 or c1 > panjang(w):
            r.g("C04", f"{nm}: keluar dari dinding {w['id']} (celah {c0:.0f}-{c1:.0f}, panjang {panjang(w):.0f}).")
        if op["tipe"] in ("pintu", "pintu-ganda", "sliding") and not 600 <= op["lebar"] <= 3000:
            r.w("C05", f"{nm}: lebar {op['lebar']} tidak biasa untuk pintu.")
        if op["tipe"] not in ("pintu", "pintu-ganda", "sliding", "jendela"):
            r.g("C04", f"{nm}: tipe tidak dikenal.")
        per.setdefault(w["id"], []).append((c0, c1, nm))
    for wid, lst in per.items():
        lst.sort()
        for (a0, a1, n1), (b0, b1, n2) in zip(lst, lst[1:]):
            if b0 < a1: r.g("C06", f"{n1} dan {n2} bertumpuk di dinding {wid}.")


def cek_snap(s, r):
    bad = []
    for w in s.get("dinding", []):
        for v in (*w["dari"], *w["ke"]):
            if abs(v * 2 % 25) > 1e-6 and abs(v * 2 % 25 - 25) > 1e-6: bad.append(f"{w['id']}:{v}")
    for op in s.get("bukaan", []):
        for v in (op["posisi"], op["lebar"]):
            if v % 25: bad.append(f"bukaan {op['dinding']}:{v}")
    if bad: r.g("C07", "Ukuran tidak di-snap 25 mm: " + ", ".join(bad[:8]))


def cek_grid_kolom(s, r):
    g = s.get("grid", {})
    if not g.get("x") or not g.get("y"):
        r.g("C08", "Grid X dan Y wajib ada (dimensi selalu ke grid).")
    elif len(g["x"]) < 2 or len(g["y"]) < 2:
        r.w("C08", "Grid kurang dari 2 garis per arah: dimensi 2 tingkat tidak bisa dibuat.")
    k = s.get("kolom")
    if k and not str(k.get("tipe", "")).startswith("COL-"):
        r.g("C09", "Kolom harus block (nama COL-...).")


def cek_ruang(s, r):
    for rm in s.get("ruang", []):
        if rm.get("nama", "") != rm.get("nama", "").upper(): r.w("C10", f"Nama ruang '{rm['nama']}' sebaiknya kapital.")
        if "batas" in rm and not inside(rm["titik"], rm["batas"]):
            r.g("C10", f"Teks ruang {rm['nama']} di luar batas ruangnya.")
        if "batas" not in rm:
            r.w("C10", f"Ruang {rm['nama']}: tambahkan 'batas' supaya posisi teks bisa dicek.")


def cek_ramp(s, r):
    if "ramp" not in s: r.w("C11", "Field 'ramp' tidak ada. Sudah dicek ada ramp atau tidak? (isi [] jika tidak ada)")


def cek_muat_a3(s, r):
    xs, ys = [], []
    for w in s.get("dinding", []): xs += [w["dari"][0], w["ke"][0]]; ys += [w["dari"][1], w["ke"][1]]
    g = s.get("grid", {}); xs += list(g.get("x", {}).values()); ys += list(g.get("y", {}).values())
    if not xs: return
    S = s.get("skala", 100)
    lebar, tinggi = (max(xs) - min(xs)) + 2 * (2000 + 20 * S), (max(ys) - min(ys)) + 2 * (2000 + 20 * S)
    maxw, maxh = 402 * S, 279 * S - 35 * S  # guide box minus area title block
    if lebar > maxw or tinggi > maxh:
        r.g("C12", f"Tidak muat di A3 1:{S} ({lebar/1000:.1f}x{tinggi/1000:.1f} m > {maxw/1000:.1f}x{maxh/1000:.1f} m). Naikkan skala.")


def cek_asumsi(s, r):
    if s.get("asumsi"): r.w("C13", f"{len(s['asumsi'])} asumsi - WAJIB disebut di laporan.")


CEK = [cek_tanya, cek_dasar, cek_dinding, cek_bukaan, cek_snap, cek_grid_kolom, cek_ruang, cek_ramp,
       cek_muat_a3, cek_asumsi]
# ^ tambahkan cek baru dari KOREKSI.md di sini


def cek_lsp(path, r):
    t = open(path, encoding="utf-8").read()
    if re.search(r"PURGE", t, re.I): r.g("L01", "File .lsp mengandung PURGE - DILARANG.")
    for lay in set(re.findall(r'\(cons 8 "([^"]+)"\)', t)) - LAYER_OK:
        r.g("L02", f"Layer non-standar dipakai: {lay}")
    if re.search(r'"(_\.)?-?HATCH"[^)]*"(AR-CONC|ANSI31|GRASS)"', t) and "lantai" in t.lower():
        r.w("L03", "Ada hatch - pastikan bukan hatch lantai.")


def main():
    ap = argparse.ArgumentParser(); ap.add_argument("spek"); ap.add_argument("--lsp")
    a = ap.parse_args()
    s = yaml.safe_load(open(a.spek, encoding="utf-8")); r = R()
    for c in CEK: c(s, r)
    if a.lsp: cek_lsp(a.lsp, r)
    print(f"LINT {s.get('proyek')} {s.get('lantai')}: {len(r.gagal)} GAGAL, {len(r.warn)} PERINGATAN")
    for m in r.gagal: print("  GAGAL      ", m)
    for m in r.warn: print("  PERINGATAN ", m)
    print("HASIL:", "LULUS" if not r.gagal else "TIDAK LULUS - perbaiki dulu, jangan lapor.")
    sys.exit(1 if r.gagal else 0)


if __name__ == "__main__":
    main()
