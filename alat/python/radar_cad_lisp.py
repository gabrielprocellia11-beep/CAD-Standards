"""Emit AutoLISP entmake code."""
import math

def f(v): return ('%.3f' % v).rstrip('0').rstrip('.') if abs(v - round(v)) > 1e-6 else str(int(round(v)))
def pt(p): return '(list %s %s 0.0)' % (f(p[0]), f(p[1]))
def s(txt): return '"' + txt.replace('\\', '\\\\').replace('"', '\\"') + '"'

class L:
    def __init__(self):
        self.out = []
    def raw(self, x): self.out.append(x)
    def _e(self, body):
        self.out.append('(entmake (list %s))' % body)
    def line(self, a, b, lay, extra=''):
        self._e('(cons 0 "LINE") (cons 8 %s) (list 10 %s %s 0.0) (list 11 %s %s 0.0)%s' % (s(lay), f(a[0]), f(a[1]), f(b[0]), f(b[1]), extra))
    def pline(self, pts, lay, closed=False, bulges=None, extra='', width=None):
        b = ''
        for i, p in enumerate(pts):
            b += ' (list 10 %s %s)' % (f(p[0]), f(p[1]))
            if bulges and abs(bulges[i]) > 1e-9: b += ' (cons 42 %s)' % ('%.6f' % bulges[i])
        w = ' (cons 43 %s)' % f(width) if width else ''
        self._e('(cons 0 "LWPOLYLINE") (cons 100 "AcDbEntity") (cons 8 %s)%s (cons 100 "AcDbPolyline") (cons 90 %d) (cons 70 %d)%s%s' % (s(lay), extra, len(pts), 1 if closed else 0, w, b))
    def arc(self, c, r, a0, a1, lay, extra=''):
        self._e('(cons 0 "ARC") (cons 8 %s) (list 10 %s %s 0.0) (cons 40 %s) (cons 50 %.6f) (cons 51 %.6f)%s' % (s(lay), f(c[0]), f(c[1]), f(r), a0, a1, extra))
    def circle(self, c, r, lay, extra=''):
        self._e('(cons 0 "CIRCLE") (cons 8 %s) (list 10 %s %s 0.0) (cons 40 %s)%s' % (s(lay), f(c[0]), f(c[1]), f(r), extra))
    def mtext(self, p, h, txt, lay, attach=5, width=0, style='ROMANS', rot=0.0, extra=''):
        self._e('(cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 8 %s) (cons 100 "AcDbMText") (list 10 %s %s 0.0) (cons 40 %s) (cons 41 %s) (cons 71 %d) (cons 1 %s) (cons 7 %s) (cons 50 %.6f)%s' % (
            s(lay), f(p[0]), f(p[1]), f(h), f(width), attach, s(txt), s(style), rot, extra))
    def text(self, p, h, txt, lay, style='ROMANS', just=1, rot=0.0):
        # just: 0 left, 1 center (72), uses 11 alignment
        self._e('(cons 0 "TEXT") (cons 8 %s) (list 10 %s %s 0.0) (list 11 %s %s 0.0) (cons 40 %s) (cons 1 %s) (cons 7 %s) (cons 72 %d) (cons 73 2) (cons 50 %.6f)' % (
            s(lay), f(p[0]), f(p[1]), f(p[0]), f(p[1]), f(h), s(txt), s(style), just, rot))
    def insert(self, name, p, lay, sx=1, sy=1, rot=0.0):
        self._e('(cons 0 "INSERT") (cons 2 %s) (cons 8 %s) (list 10 %s %s 0.0) (cons 41 %s) (cons 42 %s) (cons 50 %.6f)' % (s(name), s(lay), f(p[0]), f(p[1]), f(sx), f(sy), rot))
    def hatch(self, loops, pat, scale, ang_deg, lay):
        """loops: list of (pts, bulges). Uses -HATCH on temp boundaries."""
        self.out.append('(setq cl:ss (ssadd))')
        for pts, bl in loops:
            self.pline(pts, 'DEFPOINTS', True, bl)
            self.out.append('(ssadd (entlast) cl:ss)')
        if pat.upper() == 'SOLID':
            self.out.append('(cl:hatch cl:ss "SOLID" nil nil %s)' % s(lay))
        else:
            self.out.append('(cl:hatch cl:ss %s %s %s %s)' % (s(pat), f(scale), f(ang_deg), s(lay)))
    def dim(self, a, b, loc, lay='ADIM', rot=None):
        # rotated linear dim via command
        if rot is None:
            self.out.append('(command "_.DIMALIGNED" %s %s %s)' % (pt(a), pt(b), pt(loc)))
        else:
            self.out.append('(command "_.DIMLINEAR" %s %s "_R" %s %s)' % (pt(a), pt(b), f(rot), pt(loc)))
    def text_out(self):
        return '\n'.join(self.out)

HEADER = r'''
(vl-load-com)
(defun cl:hatch (ss pat sc ang lay / ol)
  (setq ol (getvar "CLAYER")) (setvar "HPISLANDDETECTION" 1)
  (setvar "CLAYER" lay)
  (if (= pat "SOLID")
    (vl-cmdf "_.-HATCH" "_P" "_S" "_S" ss "" "")
    (vl-cmdf "_.-HATCH" "_P" pat sc ang "_S" ss "" ""))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (command "_.ERASE" ss "")
  (setvar "CLAYER" ol))
'''
