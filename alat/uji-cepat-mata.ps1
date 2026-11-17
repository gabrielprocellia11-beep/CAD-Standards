<#
  Uji cepat autocad-mcp-mata.ps1 tanpa Bambang.
  1. Buka AutoCAD dengan sebuah drawing.
  2. Jalankan:  powershell -NoProfile -ExecutionPolicy Bypass -File uji-cepat-mata.ps1
  Hasil: daftar tool, status AutoCAD, cek denah area contoh, dan 1 file PNG screenshot.
  Optional: -X1 -Y1 -X2 -Y2 untuk area yang dicek (default: frame Level 1 HABCO DENAH 9 LANTAI).
#>
param(
    [double]$X1 = 0, [double]$Y1 = 0, [double]$X2 = 168000, [double]$Y2 = 118800
)
$ErrorActionPreference = 'Stop'
$server = Join-Path $PSScriptRoot 'autocad-mcp-mata.ps1'

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = 'powershell.exe'
$psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$server`""
$psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.StandardOutputEncoding = New-Object System.Text.UTF8Encoding($false)
$p = [System.Diagnostics.Process]::Start($psi)

$script:nextId = 1
function Call($method, $params) {
    $id = $script:nextId; $script:nextId++
    $req = @{ jsonrpc = '2.0'; id = $id; method = $method; params = $params } | ConvertTo-Json -Depth 20 -Compress
    $p.StandardInput.WriteLine($req); $p.StandardInput.Flush()
    $resp = $p.StandardOutput.ReadLine() | ConvertFrom-Json
    if ($resp.error) { throw "$method -> $($resp.error.message)" }
    return $resp.result
}
function Tool($name, $arguments) {
    $r = Call 'tools/call' @{ name = $name; arguments = $arguments }
    if ($r.isError) { Write-Host "  GAGAL: $($r.content[0].text)" -ForegroundColor Red }
    return $r
}

try {
    $init = Call 'initialize' @{ protocolVersion = '2024-11-05'; capabilities = @{}; clientInfo = @{ name = 'uji'; version = '1' } }
    Write-Host "Server: $($init.serverInfo.name) $($init.serverInfo.version)" -ForegroundColor Green
    $p.StandardInput.WriteLine('{"jsonrpc":"2.0","method":"notifications/initialized"}')

    $list = Call 'tools/list' @{}
    Write-Host "Tools ($($list.tools.Count)): $(($list.tools | ForEach-Object name) -join ', ')"

    Write-Host "`n[acad_status]"; (Tool 'acad_status' @{}).content[0].text

    Write-Host "`n[acad_cek_denah] area $X1,$Y1 - $X2,$Y2"
    (Tool 'acad_cek_denah' @{ x1 = $X1; y1 = $Y1; x2 = $X2; y2 = $Y2 }).content[0].text

    Write-Host "`n[acad_lihat_area]"
    $shot = Tool 'acad_lihat_area' @{ x1 = $X1; y1 = $Y1; x2 = $X2; y2 = $Y2; label = 'uji' }
    $img = $shot.content | Where-Object { $_.type -eq 'image' }
    if ($img) {
        Write-Host ("  OK - gambar {0} KB terkirim sebagai image." -f [int]($img.data.Length * 3 / 4 / 1024)) -ForegroundColor Green
        Write-Host "  $(($shot.content | Where-Object { $_.type -eq 'text' }).text)"
    }
} finally {
    $p.StandardInput.Close()
    if (-not $p.WaitForExit(3000)) { $p.Kill() }
    $err = $p.StandardError.ReadToEnd(); if ($err) { Write-Host "`n[stderr]`n$err" -ForegroundColor DarkGray }
}
