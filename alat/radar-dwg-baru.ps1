<#
  radar-dwg-baru.ps1  -  Buka gambar AutoCAD BARU dalam millimetre
                          dengan standar RAD+ar (layer, style, dimstyle, blok).

  Contoh:
    powershell -NoProfile -ExecutionPolicy Bypass -File radar-dwg-baru.ps1 -Skala 100
    powershell -NoProfile -ExecutionPolicy Bypass -File radar-dwg-baru.ps1 `
        -Skala 500 -Frame -Proyek "DAAN MOGOT" -Judul "GROUND FLOOR PLAN" `
        -Simpan "D:\000 RAD+AR\009 DAAN MOGOT\CAD\002 denah.dwg"

  - Selalu membuat dokumen BARU (acadiso.dwt = metrik). Gambar yang sedang
    terbuka tidak disentuh.
  - -Simpan tidak akan menimpa file yang sudah ada (pakai -Timpa untuk itu).
#>
param(
  [int]$Skala = 100,
  [string]$Simpan = "",
  [switch]$Frame,
  [string]$Proyek = "PROJECT NAME",
  [string]$Judul = "GROUND FLOOR PLAN",
  [string]$Template = "acadiso.dwt",
  [string]$Lsp = "",
  [switch]$Timpa
)
$ErrorActionPreference = "Stop"

if (-not $Lsp) { $Lsp = Join-Path $PSScriptRoot "RADAR-SETUP.lsp" }
if (-not (Test-Path $Lsp)) { throw "RADAR-SETUP.lsp tidak ditemukan: $Lsp" }
$Lsp = (Resolve-Path $Lsp).Path
$lspDir = Split-Path $Lsp
if ($Simpan -and (Test-Path $Simpan) -and -not $Timpa) {
  throw "File sudah ada: $Simpan  (pakai nama lain, atau -Timpa kalau memang mau ditimpa)"
}

# --- COM dengan retry (AutoCAD sering menolak panggilan saat sibuk) ---
function Retry([scriptblock]$sb, [int]$n = 60) {
  for ($i = 0; $i -lt $n; $i++) {
    try { return & $sb } catch {
      if ($_.Exception.HResult -in @(-2147418111, -2147417846, -2147023170) -or
          $_.Exception.Message -match "rejected|busy|RPC") { Start-Sleep -Milliseconds 500 }
      else { throw }
    }
  }
  throw "AutoCAD tidak merespons."
}
function Wait-Idle($app, [int]$detik = 120) {
  $t = [DateTime]::Now.AddSeconds($detik)
  Start-Sleep -Milliseconds 400
  while ([DateTime]::Now -lt $t) {
    try { if ($app.GetAcadState().IsQuiescent) { return } } catch {}
    Start-Sleep -Milliseconds 400
  }
  throw "AutoCAD masih sibuk setelah $detik detik."
}

# --- sambung ke AutoCAD yang terbuka, atau jalankan ---
$acad = $null
try { $acad = [Runtime.InteropServices.Marshal]::GetActiveObject("AutoCAD.Application") } catch {}
if (-not $acad) {
  Write-Output "Menjalankan AutoCAD ..."
  $acad = New-Object -ComObject AutoCAD.Application
}
Retry { $acad.Visible = $true } | Out-Null
Wait-Idle $acad 300

# --- izinkan folder LISP ini (hindari dialog SECURELOAD, tanpa SECURELOAD 0) ---
$doc0 = Retry { $acad.ActiveDocument }
try {
  $tp = [string](Retry { $doc0.GetVariable("TRUSTEDPATHS") })
  if (($tp -split ";") -notcontains $lspDir) {
    Retry { $doc0.SetVariable("TRUSTEDPATHS", (($tp.Trim(";") + ";" + $lspDir).Trim(";"))) } | Out-Null
  }
} catch { Write-Output "Catatan: TRUSTEDPATHS tidak bisa diubah - kalau muncul dialog, pilih 'Load Once'." }

# --- dokumen BARU, metrik ---
$doc = Retry { $acad.Documents.Add($Template) }
Retry { $doc.Activate() } | Out-Null
Wait-Idle $acad

$lspFwd = $Lsp -replace "\\", "/"
Retry { $doc.SendCommand("(load `"$lspFwd`") (radar:setup $Skala) ") } | Out-Null
Wait-Idle $acad

if ($Frame) {
  $p = $Proyek -replace '"', "'"
  $j = $Judul -replace '"', "'"
  Retry { $doc.SendCommand("(radar:frame $Skala `"$p`" `"$j`" '(0 0)) _.ZOOM _E ") } | Out-Null
  Wait-Idle $acad
}

if ($Simpan) {
  $dir = Split-Path $Simpan
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
  Retry { $doc.SaveAs($Simpan) } | Out-Null
  Wait-Idle $acad
}

# --- laporan ---
$ins  = Retry { $doc.GetVariable("INSUNITS") }
$nLay = Retry { $doc.Layers.Count }
$dim  = Retry { $doc.GetVariable("DIMSTYLE") }
Write-Output ("OK - gambar baru: {0} | INSUNITS={1} (4 = mm) | {2} layer | dimstyle {3} | skala 1:{4}" -f `
  (Retry { if ($doc.FullName) { $doc.FullName } else { $doc.Name } }), $ins, $nLay, $dim, $Skala)
if ($ins -ne 4) { Write-Output "PERINGATAN: INSUNITS bukan 4 - LISP mungkin belum termuat (cek dialog SECURELOAD)." }
