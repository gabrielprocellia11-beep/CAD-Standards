"""Small drafting DSL: author architectural elements, emit AutoLISP + preview segments."""
import math, sys
sys.path.insert(0, '/home/claude/work')
try:
    from radar_cad_lisp import L, HEADER, f, s
except ImportError:
    from lisp import L, HEADER, f, s

def rot(p, c, a):
    ca, sa = math.cos(a), math.sin(a)
    return (c[0] + (p[0]-c[0])*ca - (p[1]-c[1])*sa, c[1] + (p[0]-c[0])*sa + (p[1]-c[1])*ca)

WALLFN = r'''
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

class Plan:
    def __init__(self, name):
        self.name = name
        self.ents = []          # (kind, data, layer)
        self.walls = {}         # group -> list of closed polygons
        self.hatches = []       # (loops, pat, sc, ang, layer)
    # ---------- primitives
    def line(self, a, b, lay): self.ents.append(('line', (a, b), lay))
    def pl(self, pts, lay, closed=False, bulges=None): self.ents.append(('pl', (list(pts), closed, bulges), lay))
    def rect(self, x0, y0, x1, y1, lay): self.pl([(x0, y0), (x1, y0), (x1, y1), (x0, y1)], lay, True)
    def arc(self, c, r, a0, a1, lay): self.ents.append(('arc', (c, r, a0, a1), lay))   # degrees, ccw
    def circle(self, c, r, lay): self.ents.append(('circle', (c, r), lay))
    def hatch(self, pts, pat, sc=1, ang=0, lay='AHAT', bulges=None, islands=()):
        loops = [(list(pts), bulges)] + [(list(i), None) for i in islands]
        self.hatches.append((loops, pat, sc, ang, lay))
    # ---------- architectural elements
    def wall(self, a, b, t=150, group='W', off=0.0, ext0=0.0, ext1=0.0):
        """wall on centreline a->b (off shifts the centreline sideways, + = left); ext extends ends."""
        dx, dy = b[0]-a[0], b[1]-a[1]; Lg = math.hypot(dx, dy); ux, uy = dx/Lg, dy/Lg; nx, ny = -uy, ux
        a2 = (a[0]-ux*ext0 + nx*off, a[1]-uy*ext0 + ny*off); b2 = (b[0]+ux*ext1 + nx*off, b[1]+uy*ext1 + ny*off)
        h = t/2
        poly = [(a2[0]+nx*h, a2[1]+ny*h), (b2[0]+nx*h, b2[1]+ny*h), (b2[0]-nx*h, b2[1]-ny*h), (a2[0]-nx*h, a2[1]-ny*h)]
        self.walls.setdefault(group, []).append(poly)
    def wallrect(self, x0, y0, x1, y1, group='W'):
        self.walls.setdefault(group, []).append([(x0, y0), (x1, y0), (x1, y1), (x0, y1)])
    def wallpath(self, pts, t=150, group='W', closed=False):
        n = len(pts)
        segs = list(zip(pts, pts[1:])) + ([(pts[-1], pts[0])] if closed else [])
        for a, b in segs: self.wall(a, b, t, group, ext0=t/2, ext1=t/2)
    def col_I(self, c, depth=300, width=150, ang=0.0, lay='ASTR'):
        """steel H-column 300x150 (flange 9, web 7, root fillet 13) as one ASTR polyline + web centre line."""
        w, d, tf, tw, r = width/2, depth/2, 9, 3.5, 13
        k = math.tan(math.radians(90)/4)
        loc = [(-w, d), (w, d), (w, d-tf), (tw+r, d-tf), (tw, d-tf-r), (tw, -d+tf+r), (tw+r, -d+tf), (w, -d+tf), (w, -d), (-w, -d),
               (-w, -d+tf), (-tw-r, -d+tf), (-tw, -d+tf+r), (-tw, d-tf-r), (-tw-r, d-tf), (-w, d-tf)]
        bl = [0, 0, 0, k, 0, k, 0, 0, 0, 0, 0, k, 0, k, 0, 0]
        pts = [rot((c[0]+x, c[1]+y), c, math.radians(ang)) for x, y in loc]
        self.pl(pts, lay, True, bl)
        self.line(rot((c[0], c[1]+d-tf), c, math.radians(ang)), rot((c[0], c[1]-d+tf), c, math.radians(ang)), lay)
    def col_rect(self, x0, y0, x1, y1, lay='ASTR'):
        pts = [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]
        self.pl(pts, lay, True); self.hatch(pts, 'SOLID', lay='AHAT')
    def door(self, hinge, w, closed_ang, swing=1, lay='ABOV', leaf=50):
        """single swing door. hinge point, leaf width, direction (deg) of the CLOSED leaf, swing +1 ccw / -1 cw."""
        a0 = closed_ang; a1 = closed_ang + 90*swing
        op = (hinge[0] + w*math.cos(math.radians(a1)), hinge[1] + w*math.sin(math.radians(a1)))
        cl = (hinge[0] + w*math.cos(math.radians(a0)), hinge[1] + w*math.sin(math.radians(a0)))
        lo, hi = (a0, a1) if swing > 0 else (a1, a0)
        self.arc(hinge, w, lo, hi, lay)
        # leaf panel in open position, on the side away from the arc
        ang = math.radians(a1); nx, ny = -math.sin(ang)*leaf*swing, math.cos(ang)*leaf*swing
        self.pl([hinge, op, (op[0]-nx, op[1]-ny), (hinge[0]-nx, hinge[1]-ny)], 'ACUT', True)
    def ddoor(self, h1, h2, swing_side=1, lay='ABOV'):
        """double door between hinge points h1,h2 (leaves meet in middle); swing_side +1 = left of h1->h2."""
        dx, dy = h2[0]-h1[0], h2[1]-h1[1]; Lg = math.hypot(dx, dy); w = Lg/2
        ang = math.degrees(math.atan2(dy, dx))
        self.door(h1, w, ang, swing=swing_side, lay=lay)
        self.door(h2, w, ang+180, swing=-swing_side, lay=lay)
    def sliding(self, a, b, t=150, lay='ACUT'):
        """two sliding leaves in an opening a->b (on wall centreline)."""
        dx, dy = b[0]-a[0], b[1]-a[1]; Lg = math.hypot(dx, dy); ux, uy = dx/Lg, dy/Lg; nx, ny = -uy, ux
        w = Lg*0.55; th = 50
        for k, (st, o) in enumerate([(0, th/2+5), (Lg-w, -th/2-5)]):
            p0 = (a[0]+ux*st+nx*o, a[1]+uy*st+ny*o)
            self.pl([(p0[0]-nx*th/2, p0[1]-ny*th/2), (p0[0]+ux*w-nx*th/2, p0[1]+uy*w-ny*th/2),
                     (p0[0]+ux*w+nx*th/2, p0[1]+uy*w+ny*th/2), (p0[0]+nx*th/2, p0[1]+ny*th/2)], lay, True)
    def window(self, a, b, t=150, lay='AELE'):
        """glazing in a wall opening a->b (centreline): two lines at the wall faces (office convention, AELE)."""
        dx, dy = b[0]-a[0], b[1]-a[1]; Lg = math.hypot(dx, dy); ux, uy = dx/Lg, dy/Lg; nx, ny = -uy, ux
        for o in (t/2, -t/2):
            self.line((a[0]+nx*o, a[1]+ny*o), (b[0]+nx*o, b[1]+ny*o), lay)
    def stair(self, x0, y0, x1, y1, n, axis='y', lay='AELE', arrow=True):
        self.rect(x0, y0, x1, y1, lay)
        for k in range(1, n):
            if axis == 'y':
                y = y0 + (y1-y0)*k/n; self.line((x0, y), (x1, y), lay)
            else:
                x = x0 + (x1-x0)*k/n; self.line((x, y0), (x, y1), lay)
        if arrow:
            if axis == 'y':
                xm = (x0+x1)/2; self.line((xm, y0), (xm, y1), lay)
                d = 300 if y1 > y0 else -300
                self.pl([(xm-150, y1-d), (xm, y1), (xm+150, y1-d)], lay)
            else:
                ym = (y0+y1)/2; self.line((x0, ym), (x1, ym), lay)
                d = 300 if x1 > x0 else -300
                self.pl([(x1-d, ym-150), (x1, ym), (x1-d, ym+150)], lay)
    # ---------- output
    def preview_segments(self):
        """list of (layer, [pts]) for matplotlib preview."""
        out = []
        for k, d, lay in self.ents:
            if k == 'line': out.append((lay, list(d)))
            elif k == 'pl':
                pts, closed, bl = d
                out.append((lay, pts + ([pts[0]] if closed else [])))
            elif k == 'arc':
                c, r, a0, a1 = d
                if a1 < a0: a1 += 360
                n = 12; out.append((lay, [(c[0]+r*math.cos(math.radians(a0+(a1-a0)*i/n)), c[1]+r*math.sin(math.radians(a0+(a1-a0)*i/n))) for i in range(n+1)]))
            elif k == 'circle':
                c, r = d; out.append((lay, [(c[0]+r*math.cos(i*math.pi/12), c[1]+r*math.sin(i*math.pi/12)) for i in range(25)]))
        for gname, polys in self.walls.items():
            for p in polys: out.append(('ACUT', p + [p[0]]))
        return out
    def emit(self, path, wall_layer='ACUT'):
        o = L(); o.raw(HEADER)
        o.raw('(setq cl:oldos (getvar "OSMODE")) (setvar "OSMODE" 0) (setvar "HPASSOC" 0) (setvar "CMDECHO" 0) (setvar "DELOBJ" 1)')
        for k, d, lay in self.ents:
            if k == 'line': o.line(d[0], d[1], lay)
            elif k == 'pl': o.pline(d[0], lay, d[1], d[2])
            elif k == 'arc': o.arc(d[0], d[1], math.radians(d[2]), math.radians(d[3]), lay)
            elif k == 'circle': o.circle(d[0], d[1], lay)
        for loops, pat, sc, ang, lay in self.hatches:
            o.hatch(loops, pat, sc, ang, lay)
        # walls: polygons -> regions -> union per group -> solid fill -> explode back to ACUT lines
        o.raw(WALLFN)
        for gname, polys in self.walls.items():
            o.raw('(setq cl:ws (ssadd))')
            for p in polys:
                o.pline(p, wall_layer, True); o.raw('(ssadd (entlast) cl:ws)')
            o.raw('(cl:walls cl:ws)')
        o.raw('(setvar "OSMODE" cl:oldos) (princ "\\nCL %s done") (princ)' % self.name)
        open(path, 'w', encoding='cp1252').write(o.text_out())

class Frame:
    """local drawing frame: origin O, rotation ang (deg). u along ang, v to the left."""
    def __init__(self, P, O, ang):
        self.P, self.O, self.a = P, O, math.radians(ang); self.ang = ang
    def g(self, u, v):
        ca, sa = math.cos(self.a), math.sin(self.a)
        return (self.O[0] + u*ca - v*sa, self.O[1] + u*sa + v*ca)
    def wall(self, u0, v0, u1, v1, group='W'):
        self.P.walls.setdefault(group, []).append([self.g(u0, v0), self.g(u1, v0), self.g(u1, v1), self.g(u0, v1)])
    def rect(self, u0, v0, u1, v1, lay):
        self.P.pl([self.g(u0, v0), self.g(u1, v0), self.g(u1, v1), self.g(u0, v1)], lay, True)
    def line(self, a, b, lay): self.P.line(self.g(*a), self.g(*b), lay)
    def door(self, h, w, closed_ang, swing=1): self.P.door(self.g(*h), w, closed_ang + self.ang, swing)
    def ddoor(self, h1, h2, side=1): self.P.ddoor(self.g(*h1), self.g(*h2), side)
    def window(self, a, b, t=150): self.P.window(self.g(*a), self.g(*b), t)
    def sliding(self, a, b, t=150): self.P.sliding(self.g(*a), self.g(*b), t)

def _curve(self, pts, lay, closed=False):
    """smooth curve: polyline through fit points, spline-fitted in AutoCAD (PEDIT Spline)."""
    self.ents.append(('curve', (list(pts), closed), lay))
Plan.curve = _curve
_old_prev = Plan.preview_segments
def _prev(self):
    out = _old_prev(self)
    for k, d, lay in self.ents:
        if k == 'curve':
            pts, closed = d; out.append((lay, pts + ([pts[0]] if closed else [])))
    return out
Plan.preview_segments = _prev
_old_emit = Plan.emit
def _emit(self, path, wall_layer='ACUT'):
    _old_emit(self, path, wall_layer)
    from lisp import L
    o = L()
    o.raw('(setq cl:oldos (getvar "OSMODE")) (setvar "OSMODE" 0) (setvar "CMDECHO" 0) (setvar "SPLINESEGS" 8)')
    for k, d, lay in self.ents:
        if k == 'curve':
            pts, closed = d
            o.pline(pts, lay, closed)
            o.raw('(command "_.PEDIT" (entlast) "_S" "")')
            o.raw('(setq cl:cv (cons (entlast) cl:cv))')
    t = open(path, encoding='cp1252').read()
    open(path, 'w', encoding='cp1252').write('(setq cl:cv nil)\n' + o.text_out() + '\n' + t)
Plan.emit = _emit
