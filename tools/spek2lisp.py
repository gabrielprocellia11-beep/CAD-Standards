#!/usr/bin/env python3
"""spek2lisp.py - RAD+ar: spek YAML -> AutoLISP (.lsp) + pratinjau PNG.

Pemakaian:
    python spek2lisp.py contoh/spek_contoh_kantor.yaml  [--out folder]

Menghasilkan:
    <nama>.lsp  -> di AutoCAD: (load "path/<nama>.lsp")  (pilih "Load Once")
    <nama>.png  -> pratinjau, WAJIB dilihat sebelum load.

Yang digambar (v1): grid (AGRI), kolom block (ASTR), dinding dengan celah
bukaan + hatch SOLID (ACUT/AHAT), pintu (daun ACUT + busur ABOV), sliding
(ACUT), jendela (2 garis AELE), tangga & ramp (AELE), nama ruang (MTEXT),
dimensi grid 2 tingkat (ADIM). Frame A3 + title block memakai template kantor.
Tidak pernah PURGE.
"""
import argparse, math, os, sys
import yaml

HEADER = r'''(vl-load-com)
(defun cl:regions-after (e / s) (setq s (ssadd) e (if e (entnext e) (entnext)))
  (while e (if (= (cdr (assoc 0 (entget e))) "REGION") (ssadd e s)) (setq e (entnext e))) s)
(defun cl:explode-r (obj / parts)
  (setq parts (vlax-invoke obj 'Explode))
  (foreach p parts (if (= (vla-get-ObjectName p) "AcDbRegion") (cl:explode-r p) (vla-put-Layer p "ACUT")))
  (vla-delete obj))
(defun cl:walls (ws / last rg i)
  (setq last (entlast)) (setvar "CLAYER" "ACUT") (setvar "DELOBJ" 1)
  (command "_.REGION" ws "")
  (setq rg (cl:regions-after last))
  (if (> (sslength rg) 1) (command "_.UNION" rg ""))
  (setq rg (cl:regions-after last))
  (setvar "CLAYER" "AHAT")
  (vl-cmdf "_.-HATCH" "_P" "_S" "_S" rg "" "")
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (setq rg (cl:regions-after last) i 0)
  (repeat (sslength rg) (cl:explode-r (vlax-ename->vla-object (ssname rg i))) (setq i (1+ i)))
  (setvar "CLAYER" "0"))
'''

LAYERS = {  # nama: (warna, linetype)
    "ACUT": (7, "Continuous"), "AHAT": (3, "Continuous"), "ASTR": (1, "Continuous"),
    "AELE": (5, "Continuous"), "ABOV": (6, "HIDDEN"), "AGRI": (4, "PHANTOM"),
    "ADIM": (3, "Continuous"), "ATEX": (8, "Continuous"), "ATEXRM": (1, "Continuous"),
}

def f(v):
    return f"{v:.4f}".rstrip("0").rstrip(".")

def pt(p):
    return f"({f(p[0])} {f(p[1])} 0.0)"


class Out:
    def __init__(self):
        self.ents, self.walls, self.post, self.seg = [], [], [], []

    def line(self, a, b, lay):
        self.ents.append(f'(entmake (list (cons 0 "LINE") (cons 8 "{lay}") (cons 10 \'{pt(a)}) (cons 11 \'{pt(b)})))')
        self.seg.append((a, b, lay))

    def pline(self, pts, lay, closed=True, store=None):
        vs = " ".join(f"(cons 10 '({f(p[0])} {f(p[1])}))" for p in pts)
        s = (f'(entmake (list (cons 0 "LWPOLYLINE") (cons 100 "AcDbEntity") (cons 8 "{lay}") '
             f'(cons 100 "AcDbPolyline") (cons 90 {len(pts)}) (cons 70 {1 if closed else 0}) {vs}))')
        (store if store is not None else self.ents).append(s)
        n = len(pts)
        for i in range(n if closed else n - 1):
            self.seg.append((pts[i], pts[(i + 1) % n], lay))

    def arc(self, c, r, a0, a1, lay):  # derajat, CCW dari a0 ke a1
        self.ents.append(f'(entmake (list (cons 0 "ARC") (cons 8 "{lay}") (cons 10 \'{pt(c)}) (cons 40 {f(r)}) '
                         f'(cons 50 {math.radians(a0):.6f}) (cons 51 {math.radians(a1):.6f})))')
        steps = 16
        pts = [(c[0] + r * math.cos(math.radians(a0 + (a1 - a0) * i / steps)),
                c[1] + r * math.sin(math.radians(a0 + (a1 - a0) * i / steps))) for i in range(steps + 1)]
        for i in range(steps):
            self.seg.append((pts[i], pts[i + 1], lay))

    def insert(self, name, p, lay, sc=1.0):
        self.ents.append(f'(if (tblsearch "BLOCK" "{name}") (entmake (list (cons 0 "INSERT") (cons 8 "{lay}") '
                         f'(cons 2 "{name}") (cons 10 \'{pt(p)}) (cons 41 {f(sc)}) (cons 42 {f(sc)}) (cons 43 {f(sc)}))) '
                         f'(princ "\\nBLOCK {name} tidak ada - kolom dilewati."))')

    def mtext(self, p, txt, h, lay):
        self.ents.append(f'(entmake (list (cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 8 "{lay}") '
                         f'(cons 100 "AcDbMText") (cons 10 \'{pt(p)}) (cons 40 {f(h)}) (cons 71 5) (cons 1 "{txt}")))')

    def dim(self, a, b, loc, horiz):
        rot = "_H" if horiz else "_V"
        self.post.append(f'(command "_.DIMLINEAR" \'{pt(a)} \'{pt(b)} {rot} \'{pt(loc)})')


def unit(a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]
    L = math.hypot(dx, dy)
    return (dx / L, dy / L), L


def build(spek):
    o = Out()
    S = spek["skala"]
    gx = spek.get("grid", {}).get("x", {})
    gy = spek.get("grid", {}).get("y", {})
    xs, ys = sorted(gx.values()), sorted(gy.values())
    ext = 2000

    # grid
    if xs and ys:
        for x in xs:
            o.line((x, ys[0] - ext), (x, ys[-1] + ext), "AGRI")
        for y in ys:
            o.line((xs[0] - ext, y), (xs[-1] + ext, y), "AGRI")
        # dimensi 2 tingkat (tier1 = bentang, tier2 = total), di bawah & kiri
        d1, d2 = ys[0] - ext - 10 * S, ys[0] - ext - 10 * S - 7.5 * S
        for a, b in zip(xs, xs[1:]):
            o.dim((a, ys[0]), (b, ys[0]), (a, d1), True)
        o.dim((xs[0], ys[0]), (xs[-1], ys[0]), (xs[0], d2), True)
        e1, e2 = xs[0] - ext - 10 * S, xs[0] - ext - 10 * S - 7.5 * S
        for a, b in zip(ys, ys[1:]):
            o.dim((xs[0], a), (xs[0], b), (e1, a), False)
        o.dim((xs[0], ys[0]), (xs[0], ys[-1]), (e2, ys[0]), False)

    # kolom
    k = spek.get("kolom")
    if k:
        titik = [(x, y) for x in xs for y in ys] if k.get("di") == "semua_titik_grid" else k.get("titik", [])
        for p in titik:
            o.insert(k["tipe"], p, "ASTR")

    # dinding + bukaan
    bukaan = spek.get("bukaan", [])
    walls = spek.get("dinding", [])

    def on_axis(p, w):
        (vx, vy), L = unit(w["dari"], w["ke"])
        dx, dy = p[0] - w["dari"][0], p[1] - w["dari"][1]
        along = dx * vx + dy * vy
        return abs(dx * vy - dy * vx) < 1 and -1 <= along <= L + 1

    def ext_at(p, me):  # perpanjang ujung sejauh setengah tebal dinding yang ditemui
        return max([o2["tebal"] / 2 for o2 in walls if o2 is not me and on_axis(p, o2)], default=0)

    for w in walls:
        a0, b0, t = w["dari"], w["ke"], w["tebal"]
        (ux, uy), L = unit(a0, b0)
        e0, e1 = w.get("ext0", ext_at(a0, w)), w.get("ext1", ext_at(b0, w))
        a = (a0[0] - ux * e0, a0[1] - uy * e0)
        b = (b0[0] + ux * e1, b0[1] + uy * e1)
        L += e0 + e1
        bukaan_w = [dict(op, posisi=op["posisi"] + e0) for op in bukaan if op["dinding"] == w["id"]]
        nx, ny = -uy, ux  # normal kiri
        ops = sorted(bukaan_w, key=lambda op: op["posisi"])
        cuts, s = [], 0.0
        for op in ops:
            c0, c1 = op["posisi"] - op["lebar"] / 2, op["posisi"] + op["lebar"] / 2
            cuts.append((s, c0)); s = c1
        cuts.append((s, L))
        P = lambda d, off: (a[0] + ux * d + nx * off, a[1] + uy * d + ny * off)
        for s0, s1 in cuts:
            if s1 - s0 > 1:
                o.pline([P(s0, -t / 2), P(s1, -t / 2), P(s1, t / 2), P(s0, t / 2)], "ACUT", store=o.walls)
        for op in ops:
            c0, c1 = op["posisi"] - op["lebar"] / 2, op["posisi"] + op["lebar"] / 2
            tp = op["tipe"]
            if tp == "jendela":
                o.line(P(c0, -t / 2), P(c1, -t / 2), "AELE")
                o.line(P(c0, t / 2), P(c1, t / 2), "AELE")
            elif tp == "sliding":
                h = op["lebar"] / 2 + 50
                o.pline([P(c0, -25), P(c0 + h, -25), P(c0 + h, 25), P(c0, 25)], "ACUT")
                o.pline([P(c1 - h, 25), P(c1, 25), P(c1, 75), P(c1 - h, 75)], "ACUT")
            elif tp in ("pintu", "pintu-ganda"):
                sgn = 1 if op.get("sisi", "kiri") == "kiri" else -1
                leaves = ([(c0, op["lebar"] / 2, 1), (c1, op["lebar"] / 2, -1)] if tp == "pintu-ganda"
                          else [(c0, op["lebar"], 1) if op.get("engsel", "awal") == "awal" else (c1, op["lebar"], -1)])
                for hd, wl, dirn in leaves:
                    hinge = P(hd, sgn * t / 2)
                    # daun tegak lurus dinding, tebal 50
                    q0 = hinge
                    q1 = (hinge[0] + nx * sgn * wl, hinge[1] + ny * sgn * wl)
                    ex, ey = ux * dirn * 50, uy * dirn * 50
                    o.pline([q0, q1, (q1[0] + ex, q1[1] + ey), (q0[0] + ex, q0[1] + ey)], "ACUT")
                    a_open = math.degrees(math.atan2(ny * sgn, nx * sgn))
                    a_closed = math.degrees(math.atan2(uy * dirn, ux * dirn))
                    lo, hi = sorted([a_open, a_closed])
                    if hi - lo > 180:
                        lo, hi = hi, lo + 360
                    o.arc(hinge, wl, lo, hi, "ABOV")

    # tangga
    for st in spek.get("tangga", []):
        x0, y0, x1, y1, n = st["x0"], st["y0"], st["x1"], st["y1"], st["anak_tangga"]
        o.pline([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], "AELE")
        for i in range(1, n):
            if st.get("arah", "y") == "y":
                y = y0 + (y1 - y0) * i / n; o.line((x0, y), (x1, y), "AELE")
            else:
                x = x0 + (x1 - x0) * i / n; o.line((x, y0), (x, y1), "AELE")
    for r in spek.get("ramp", []):
        o.pline([tuple(p) for p in r["batas"]], "AELE")
        c = r["batas"]; cx = sum(p[0] for p in c) / len(c); cy = sum(p[1] for p in c) / len(c)
        o.mtext((cx, cy), f"RAMP {r.get('kemiringan', '1:12')}", 2 * S, "ATEX")

    # ruang
    for rm in spek.get("ruang", []):
        txt = "{\\\\fGill Sans|b1|i0|c0|p34;\\\\C1;" + rm["nama"] + "}"
        if rm.get("level"):
            txt += "\\\\P{\\\\C2;FFL " + rm["level"] + "}"
        o.mtext(rm["titik"], txt, 2.5 * S, "ATEXRM")
    return o


def emit(o, path):
    L = [HEADER, '(setq cl:osm (getvar "OSMODE"))', '(setvar "OSMODE" 0) (setvar "CMDECHO" 0) (setvar "HPASSOC" 0)']
    for n, (c, lt) in LAYERS.items():
        L.append(f'(if (not (tblsearch "LAYER" "{n}")) (entmake (list (cons 0 "LAYER") (cons 100 "AcDbSymbolTableRecord") '
                 f'(cons 100 "AcDbLayerTableRecord") (cons 2 "{n}") (cons 70 0) (cons 62 {c}) (cons 6 "{lt}"))))')
    L += o.ents
    if o.walls:
        L.append("(setq cl:ws (ssadd))")
        for w in o.walls:
            L.append(w)
            L.append("(ssadd (entlast) cl:ws)")
        L.append("(cl:walls cl:ws)")
    if o.post:
        L.append('(setvar "CLAYER" "ADIM")')
        L += o.post
    L += ['(setvar "CLAYER" "0")', '(setvar "OSMODE" cl:osm)', '(command "_.ZOOM" "_E")', '(princ "\\nSelesai. Cek lalu QSAVE.")', '(princ)']
    with open(path, "w", encoding="utf-8") as fh:
        fh.write("\n".join(L) + "\n")


def preview(o, spek, path):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    col = {"ACUT": "black", "AELE": "blue", "ABOV": "magenta", "AGRI": "cyan", "ATEX": "grey"}
    fig, ax = plt.subplots(figsize=(12, 9))
    for a, b, lay in o.seg:
        ax.plot([a[0], b[0]], [a[1], b[1]], color=col.get(lay, "grey"), lw=1.4 if lay == "ACUT" else 0.7,
                ls="--" if lay in ("ABOV", "AGRI") else "-")
    k = spek.get("kolom")
    gx, gy = spek.get("grid", {}).get("x", {}), spek.get("grid", {}).get("y", {})
    if k and k.get("di") == "semua_titik_grid":
        for x in gx.values():
            for y in gy.values():
                ax.plot(x, y, "o", color="red", ms=6)
    for n, x in gx.items():
        ax.text(x, max(gy.values()) + 2600, n, ha="center", color="teal")
    for n, y in gy.items():
        ax.text(min(gx.values()) - 2600, y, n, va="center", color="teal")
    for rm in spek.get("ruang", []):
        ax.text(*rm["titik"], rm["nama"] + ("\nFFL " + rm["level"] if rm.get("level") else ""),
                ha="center", va="center", color="red", fontsize=8)
    ax.set_aspect("equal"); ax.set_title(f'{spek["proyek"]} - {spek["lantai"]} (pratinjau)')
    fig.savefig(path, dpi=130, bbox_inches="tight")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("spek"); ap.add_argument("--out", default=None)
    a = ap.parse_args()
    spek = yaml.safe_load(open(a.spek, encoding="utf-8"))
    if spek.get("TANYA"):
        sys.exit("STOP: masih ada TANYA di spek. Tanyakan ke owner dulu:\n- " + "\n- ".join(spek["TANYA"]))
    out = a.out or os.path.dirname(os.path.abspath(a.spek))
    base = os.path.join(out, f'{spek["proyek"]}_{spek["lantai"]}'.replace(" ", "_"))
    o = build(spek)
    emit(o, base + ".lsp"); preview(o, spek, base + ".png")
    print(f"OK -> {base}.lsp\n      {base}.png  (lihat pratinjau sebelum load)")


if __name__ == "__main__":
    main()
