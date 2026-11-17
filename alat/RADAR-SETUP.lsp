;;; =====================================================================
;;;  RADAR-SETUP.lsp  -  Standar CAD kantor RAD+ar untuk gambar baru (mm)
;;;  Repo: github.com/gabrielprocellia11-beep/CAD-Standards  (alat/)
;;;
;;;  Perintah:
;;;    RADARSETUP   - pasang standar ke gambar yang sedang aktif
;;;                   (satuan mm, layer, linetype, text style, dimstyle WMS,
;;;                    blok & style dari "Cad standards.dwg" kalau ada)
;;;    RADARFRAME   - gambar frame A3 + title block di model space
;;;
;;;  Fungsi untuk skrip / Bambang (tanpa dialog):
;;;    (radar:setup 100)
;;;    (radar:frame 100 "PROJECT NAME" "GROUND FLOOR PLAN" '(0 0))
;;;
;;;  Aturan: TIDAK pernah PURGE, tidak mengubah objek yang sudah ada.
;;; =====================================================================
(vl-load-com)

;;; ---------------------------------------------------------------------
;;; Data standar
;;; ---------------------------------------------------------------------
;; (nama warna linetype lineweight[1/100 mm] plot?)
(setq radar:*layers*
  '(("0"         200 "Continuous" 15 T)
    ("ACUT"        7 "Continuous" 15 T)
    ("ASTR"        1 "Continuous" 18 T)
    ("AELE"        5 "Continuous" 13 T)
    ("AWIN"        5 "Continuous" 13 T)
    ("ABOV"        6 "HIDDEN"      5 T)
    ("AHAT"        3 "Continuous"  5 T)
    ("APAT"       64 "Continuous"  5 T)
    ("AFUR"        9 "Continuous"  5 T)
    ("ASAN"        5 "PHANTOM"    13 T)
    ("ALAND"       3 "Continuous"  5 T)
    ("AELELT"      3 "Continuous"  5 T)
    ("AGRI"        4 "PHANTOM"     5 T)
    ("ADIM"        3 "Continuous"  5 T)
    ("ATEX"        8 "Continuous"  9 T)
    ("ATEXNRL"     8 "Continuous"  9 T)
    ("ATEXRM"      1 "Continuous" 30 T)
    ("ATEXTIT"     2 "Continuous" 40 T)
    ("ATEXDTL"     8 "Continuous" 15 T)
    ("ATEXERL"     8 "Continuous" 15 T)
    ("ATIT"        7 "Continuous" 15 T)
    ("ASIT"        1 "PHANTOM"    18 T)
    ("ASET"        6 "PHANTOM"    18 T)
    ("AEXTG"      50 "HIDDEN2"    15 T)
    ("ADRAIN"      5 "PHANTOM"    13 T)
    ("ALIG"        1 "Continuous" 18 T)
    ("AWIR"        1 "PHANTOM"    18 T)
    ("ARCP"        5 "Continuous" 13 T)
    ("AREA"        2 "Continuous" 13 T)
    ("AELEC"       1 "Continuous" 20 T)
    ("AOUTL"       1 "Continuous" 20 T)
    ("AREV"        3 "Continuous" 13 T)
    ("URACAD"      3 "Continuous"  5 T)
    ("ATHRES"      3 "Continuous" 13 T)
    ("Defpoints" 181 "Continuous" -3 nil)))

;; skala yang dibuatkan dimstyle WMS<skala>
(setq radar:*scales* '(100 150 200 250 300 400 500 750 1000))

;; lokasi file standar kantor (dicoba berurutan)
(setq radar:*std-files*
  '("D:/000 RAD+AR/Cad standards.dwg"
    "D:/000 CAD Content/Cad Standard/Cad standards.dwg"))
(setq radar:*hatch-dir* "D:/000 CAD Content/Hatch")

;; angka scale bar (meter) per skala
(setq radar:*scalebars*
  '((100 0 1 2 5) (150 0 1 2 5) (200 0 1 2 5) (250 0 2 4 10) (300 0 3 6 15)
    (400 0 2 4 10 20) (500 0 5 10 25) (600 0 6 12 30) (750 0 5 10 25)
    (1000 0 5 10 25 50)))

;;; ---------------------------------------------------------------------
;;; Utilitas
;;; ---------------------------------------------------------------------
(defun radar:doc () (vla-get-ActiveDocument (vlax-get-acad-object)))

(defun radar:try (f args / r)
  (setq r (vl-catch-all-apply f args))
  (if (vl-catch-all-error-p r) nil (if r r T)))

(defun radar:item (coll name / r)
  (setq r (vl-catch-all-apply 'vla-item (list coll name)))
  (if (vl-catch-all-error-p r) nil r))

(defun radar:units ()
  (setvar "INSUNITS" 4)            ; millimetres
  (setvar "MEASUREMENT" 1)         ; metric hatch/linetype files
  (setvar "LUNITS" 2)              ; decimal
  (setvar "LUPREC" 0)              ; whole mm
  (setvar "AUNITS" 0)
  (setvar "AUPREC" 0)
  (radar:try 'setvar '("INSUNITSDEFSOURCE" 4))
  (radar:try 'setvar '("INSUNITSDEFTARGET" 4))
  (setvar "LWDISPLAY" 0)
  (princ "\n  Satuan: millimetre (INSUNITS 4)."))

(defun radar:linetypes (/ lts)
  (setq lts (vla-get-Linetypes (radar:doc)))
  (foreach lt '("HIDDEN" "PHANTOM" "HIDDEN2")
    (if (not (tblsearch "LTYPE" lt))
      (radar:try 'vla-load (list lts lt "acadiso.lin")))))

(defun radar:layers (/ lays rec lay)
  (setq lays (vla-get-Layers (radar:doc)))
  (foreach rec radar:*layers*
    (setq lay (or (radar:item lays (car rec)) (vla-add lays (car rec))))
    (radar:try 'vla-put-Color (list lay (nth 1 rec)))
    (if (tblsearch "LTYPE" (nth 2 rec))
      (radar:try 'vla-put-Linetype (list lay (nth 2 rec))))
    (radar:try 'vla-put-Lineweight (list lay (nth 3 rec)))
    (radar:try 'vla-put-Plottable (list lay (if (nth 4 rec) :vlax-true :vlax-false))))
  (princ (strcat "\n  " (itoa (length radar:*layers*)) " layer standar siap.")))

(defun radar:textstyles (/ sts st)
  (setq sts (vla-get-TextStyles (radar:doc)))
  ;; ROMANS - teks denah
  (setq st (or (radar:item sts "ROMANS") (vla-add sts "ROMANS")))
  (radar:try 'vla-put-fontFile (list st "romans.shx"))
  (radar:try 'vla-put-Height (list st 0.0))
  (radar:try 'vla-put-Width (list st 1.0))
  ;; GILLSANS - judul / title block
  (setq st (or (radar:item sts "GILLSANS") (vla-add sts "GILLSANS")))
  (if (not (radar:try 'vla-SetFont (list st "Gill Sans MT" :vlax-true :vlax-false 0 34)))
    (radar:try 'vla-SetFont (list st "Gill Sans" :vlax-true :vlax-false 0 34)))
  (radar:try 'vla-put-Height (list st 0.0))
  (princ "\n  Text style ROMANS & GILLSANS siap."))

;; dimstyle WMS<scale> - text 2, tick oblique 2, warna teks 8, gap 1,
;; ext offset 2, ext extend 2, presisi 0, ROMANS
(defun radar:dimstyle (s / nm)
  (setq nm (strcat "WMS" (itoa s)))
  (setvar "DIMSCALE" s)
  (setvar "DIMTXT" 2.0)
  (setvar "DIMASZ" 2.0)
  (setvar "DIMBLK" "_OBLIQUE")
  (setvar "DIMCLRT" 8)
  (setvar "DIMGAP" 1.0)
  (setvar "DIMEXO" 2.0)
  (setvar "DIMEXE" 2.0)
  (setvar "DIMDEC" 0)
  (setvar "DIMLUNIT" 2)
  (setvar "DIMTXSTY" "ROMANS")
  (if (tblsearch "DIMSTYLE" nm)
    (command "_.-DIMSTYLE" "_S" nm "_Y")
    (command "_.-DIMSTYLE" "_S" nm))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  nm)

(defun radar:dimstyles (cur / s)
  (foreach s radar:*scales*
    ;; jangan timpa WMS yang dibawa dari Cad standards.dwg
    (if (not (tblsearch "DIMSTYLE" (strcat "WMS" (itoa s))))
      (radar:dimstyle s)))
  (if (not (tblsearch "DIMSTYLE" (strcat "WMS" (itoa cur))))
    (radar:dimstyle cur))
  (command "_.-DIMSTYLE" "_R" (strcat "WMS" (itoa cur)))
  (while (> (getvar "CMDACTIVE") 0) (command ""))
  (princ (strcat "\n  Dimstyle aktif: WMS" (itoa cur) ".")))

;; Salin definisi blok kantor (level-reduced, room data, label, section,
;; material key, ARROW1 ...) + text/dim style dari Cad standards.dwg
;; lewat ObjectDBX - tanpa INSERT, tanpa PURGE.
(defun radar:copy-standards (/ f path dbx src objs n doc blk nm)
  (setq path nil)
  (foreach f radar:*std-files* (if (and (not path) (findfile f)) (setq path f)))
  (if (not path)
    (princ "\n  (Cad standards.dwg tidak ditemukan - blok kantor dilewati.)")
    (progn
      (setq doc (radar:doc)
            dbx (vl-catch-all-apply 'vla-GetInterfaceObject
                  (list (vlax-get-acad-object)
                        (strcat "ObjectDBX.AxDbDocument." (substr (getvar "ACADVER") 1 2)))))
      (if (vl-catch-all-error-p dbx)
        (princ "\n  (ObjectDBX tidak tersedia - blok kantor dilewati.)")
        (if (vl-catch-all-error-p (vl-catch-all-apply 'vla-Open (list dbx path)))
          (princ "\n  (Cad standards.dwg sedang terkunci/tidak bisa dibuka - blok dilewati.)")
          (progn
            ;; blok bernama (bukan layout, xref, anonim) yang belum ada
            (setq objs '() n 0)
            (vlax-for blk (vla-get-Blocks dbx)
              (setq nm (vla-get-Name blk))
              (if (and (= (vla-get-IsLayout blk) :vlax-false)
                       (= (vla-get-IsXRef blk) :vlax-false)
                       (/= (substr nm 1 1) "*")
                       (not (tblsearch "BLOCK" nm)))
                (setq objs (cons blk objs))))
            (if objs
              (progn
                (radar:try 'vla-CopyObjects
                  (list dbx
                        (vlax-make-variant
                          (vlax-safearray-fill
                            (vlax-make-safearray vlax-vbObject (cons 0 (1- (length objs)))) objs))
                        (vla-get-Blocks doc)))
                (setq n (length objs))))
            ;; dimstyle WMS* dan text style kantor
            (setq objs '())
            (vlax-for blk (vla-get-DimStyles dbx)
              (if (and (wcmatch (strcase (vla-get-Name blk)) "WMS*")
                       (not (tblsearch "DIMSTYLE" (vla-get-Name blk))))
                (setq objs (cons blk objs))))
            (if objs
              (radar:try 'vla-CopyObjects
                (list dbx (vlax-make-variant
                            (vlax-safearray-fill
                              (vlax-make-safearray vlax-vbObject (cons 0 (1- (length objs)))) objs))
                      (vla-get-DimStyles doc))))
            (princ (strcat "\n  " (itoa n) " blok kantor disalin dari " path "."))
            (vlax-release-object dbx)))))))

;; tambahkan folder hatch kantor ke Support File Search Path (kalau ada)
(defun radar:hatchpath (/ files sp)
  (if (vl-file-directory-p radar:*hatch-dir*)
    (progn
      (setq files (vla-get-Files (vla-get-Preferences (vlax-get-acad-object)))
            sp (vla-get-SupportPath files))
      (if (not (vl-string-search (strcase (vl-string-translate "/" "\\" radar:*hatch-dir*)) (strcase sp)))
        (progn
          (vla-put-SupportPath files (strcat sp ";" (vl-string-translate "/" "\\" radar:*hatch-dir*)))
          (princ "\n  Folder hatch kantor ditambahkan ke support path."))))))

;;; ---------------------------------------------------------------------
;;; SETUP utama
;;; ---------------------------------------------------------------------
(defun radar:setup (scale / oce)
  (if (not (numberp scale)) (setq scale 100))
  (setq scale (fix scale))
  (setq oce (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (princ "\nRAD+ar setup ...")
  (radar:units)
  (radar:linetypes)
  (radar:layers)
  (radar:textstyles)
  (radar:copy-standards)
  (radar:dimstyles scale)
  (radar:hatchpath)
  ;; linetype scale: dash PHANTOM/HIDDEN acadiso.lin terbaca di kertas
  ;; (default kerja - samakan dengan Cad standards.dwg bila berbeda)
  (setvar "LTSCALE" (* scale 0.25))
  (setvar "PSLTSCALE" 1)
  (setvar "HPSCALE" 1.0)
  (setvar "TEXTSTYLE" "ROMANS")
  (setvar "TEXTSIZE" (* 2.0 scale))
  (setvar "CLAYER" "0")
  (command "_.UCS" "_W")
  (setvar "CMDECHO" oce)
  (princ (strcat "\nRAD+ar setup selesai - mm, skala 1:" (itoa scale) ". JANGAN PURGE.\n"))
  (princ))

(defun c:RADARSETUP (/ s)
  (initget 6)
  (setq s (getint "\nSkala gambar 1:<100>: "))
  (radar:setup (if s s 100)))

;;; ---------------------------------------------------------------------
;;; FRAME A3 + title block
;;; ---------------------------------------------------------------------
(defun radar:spaced (str gap / i c out)
  ;; "GROUND FLOOR" -> "G R O U N D   F L O O R"
  (setq out "" i 1 str (strcase str))
  (while (<= i (strlen str))
    (setq c (substr str i 1))
    (cond ((= c " ") (setq out (strcat out gap)))
          ((or (= out "") (= (substr out (strlen out)) " ")) (setq out (strcat out c)))
          (T (setq out (strcat out " " c))))
    (setq i (1+ i)))
  out)

(defun radar:month-year (/ d m y names)
  (setq d (rtos (getvar "CDATE") 2 0)
        y (substr d 1 4)
        m (atoi (substr d 5 2))
        names '("JANUARY" "FEBRUARY" "MARCH" "APRIL" "MAY" "JUNE" "JULY"
                "AUGUST" "SEPTEMBER" "OCTOBER" "NOVEMBER" "DECEMBER"))
  (list (nth (1- m) names) y))

(defun radar:rect (p w h lay col)
  (entmake (list '(0 . "LWPOLYLINE") '(100 . "AcDbEntity") (cons 8 lay)
                 (cons 62 col) '(100 . "AcDbPolyline") '(90 . 4) '(70 . 1)
                 (list 10 (car p) (cadr p))
                 (list 10 (+ (car p) w) (cadr p))
                 (list 10 (+ (car p) w) (+ (cadr p) h))
                 (list 10 (car p) (+ (cadr p) h)))))

(defun radar:solid-rect (p w h lay)
  (entmake (list '(0 . "SOLID") (cons 8 lay) '(62 . 7)
                 (list 10 (car p) (cadr p) 0.0)
                 (list 11 (+ (car p) w) (cadr p) 0.0)
                 (list 12 (car p) (+ (cadr p) h) 0.0)
                 (list 13 (+ (car p) w) (+ (cadr p) h) 0.0))))

(defun radar:ctext (str x y h sty col lay)
  (entmake (list '(0 . "TEXT") (cons 8 lay) (cons 62 col) (cons 7 sty)
                 (list 10 x y 0.0) (list 11 x y 0.0) (cons 40 h)
                 (cons 1 str) '(72 . 1) '(73 . 0))))

(defun radar:frame (s proj title org / x0 y0 W H cx bar vals len x i a b my)
  (setq s (fix s) x0 (car org) y0 (cadr org)
        W (* 420.0 s) H (* 297.0 s) cx (+ x0 (/ W 2.0)))
  ;; sheet, border, guide box (DEFPOINTS - tidak di-plot)
  (radar:rect (list x0 y0) W H "Defpoints" 1)
  (radar:rect (list (+ x0 (* 5 s)) (+ y0 (* 5 s))) (- W (* 10 s)) (- H (* 10 s)) "Defpoints" 256)
  (radar:rect (list (+ x0 (* 9 s)) (+ y0 (* 9 s))) (- W (* 18 s)) (- H (* 18 s)) "Defpoints" 2)
  ;; title block - y & tinggi teks dalam mm-kertas x skala
  (radar:ctext (radar:spaced proj "   ")  cx (+ y0 (* 31.5 s))   (* 2.25 s)   "GILLSANS" 2 "ATEX")
  (radar:ctext (radar:spaced title "   ") cx (+ y0 (* 27.0 s))   (* 1.875 s)  "GILLSANS" 2 "ATEX")
  ;; scale bar
  (setq vals (cdr (assoc s radar:*scalebars*)))
  (if vals
    (progn
      (setq len (* (last vals) 1000.0)          ; panjang bar di model (mm)
            x   (- cx (/ len 2.0)) i 0)
      (while (< i (1- (length vals)))
        (setq a (* (nth i vals) 1000.0) b (* (nth (1+ i) vals) 1000.0))
        (if (= (rem i 2) 0)
          (radar:solid-rect (list (+ x a) (+ y0 (* 18.125 s))) (- b a) (* 2.0 s) "ATEX")
          (radar:rect (list (+ x a) (+ y0 (* 18.125 s))) (- b a) (* 2.0 s) "ATEX" 256))
        (setq i (1+ i)))
      (foreach v vals
        (radar:ctext (if (= v (last vals)) (strcat (itoa v) " M") (itoa v))
                     (+ x (* v 1000.0)) (+ y0 (* 22.375 s)) (* 1.4625 s) "GILLSANS" 256 "ATEX"))))
  (radar:ctext (strcat "1:" (itoa s) " - A3") cx (+ y0 (* 16.125 s)) (* 1.6875 s) "GILLSANS" 256 "ATEX")
  (radar:ctext "R A D + a r" cx (+ y0 (* 12.225 s)) (* 1.5 s) "GILLSANS" 256 "ATEX")
  (setq my (radar:month-year))
  (radar:ctext (strcat (radar:spaced (car my) " ") "    " (radar:spaced (cadr my) " "))
               cx (+ y0 (* 9.475 s)) (* 1.2 s) "GILLSANS" 256 "ATEX")
  (radar:ctext (strcat "\\U+00A9 RAD+ar " (cadr my) ".  All rights reserved.")
               cx (+ y0 (* 6.725 s)) (* 1.125 s) "GILLSANS" 256 "ATEX")
  ;; north arrow sederhana kanan judul (ganti dengan blok kantor bila ada)
  (setq a (list (+ cx (* 70 s)) (+ y0 (* 25 s))))
  (entmake (list '(0 . "CIRCLE") '(8 . "ATEX") (list 10 (car a) (cadr a) 0.0) (cons 40 (* 4.0 s))))
  (entmake (list '(0 . "SOLID") '(8 . "ATEX")
                 (list 10 (- (car a) (* 1.5 s)) (- (cadr a) (* 3.0 s)) 0.0)
                 (list 11 (+ (car a) (* 1.5 s)) (- (cadr a) (* 3.0 s)) 0.0)
                 (list 12 (car a) (+ (cadr a) (* 4.0 s)) 0.0)
                 (list 13 (car a) (+ (cadr a) (* 4.0 s)) 0.0)))
  (radar:ctext "N" (car a) (+ (cadr a) (* 5.0 s)) (* 1.5 s) "GILLSANS" 256 "ATEX")
  (princ (strcat "\nFrame A3 1:" (itoa s) " dibuat di " (rtos x0 2 0) "," (rtos y0 2 0)
                 ". Isi gambar harus di dalam guide box kuning.\n"))
  (princ))

(defun c:RADARFRAME (/ s p t1 t2)
  (initget 6)
  (setq s (getint "\nSkala 1:<100>: ")) (if (not s) (setq s 100))
  (setq t1 (getstring T "\nNama proyek: "))
  (setq t2 (getstring T "\nJudul gambar <GROUND FLOOR PLAN>: "))
  (if (= t2 "") (setq t2 "GROUND FLOOR PLAN"))
  (setq p (getpoint "\nTitik kiri-bawah frame <0,0>: ")) (if (not p) (setq p '(0 0)))
  (radar:frame s t1 t2 p))

(princ "\nRAD+ar: RADARSETUP (standar mm) dan RADARFRAME (frame A3) siap.")
(princ)
