<#
.SYNOPSIS
  AutoCAD MCP server "mata" (eyes) for Bambang - RAD+ar.

  Everything the old autocad-mcp.ps1 did, PLUS tools that let the AI SEE and
  CHECK the drawing:
    acad_zoom_window   - zoom to a rectangle in model space
    acad_screenshot    - capture the AutoCAD window and return it as an IMAGE
    acad_lihat_area    - zoom to a rectangle + capture in one call
    acad_cek_denah     - count entities per layer/type in a rectangle,
                         find duplicate lines, flag required layers that are empty

  Speaks MCP (JSON-RPC 2.0, newline-delimited) over stdio and drives a RUNNING
  full AutoCAD (not LT) through COM.

  Run with Windows PowerShell 5.1:
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File autocad-mcp-mata.ps1
  acad_run_command is disabled unless -AllowCommands or ACAD_MCP_ALLOW_COMMANDS=1.

  stdout is reserved for protocol messages. Logging goes to stderr.
  This file is ASCII only on purpose (PowerShell 5.1 reads BOM-less files as ANSI).
#>
param(
    [switch]$AllowCommands
)

$ErrorActionPreference = 'Stop'
if ($env:ACAD_MCP_ALLOW_COMMANDS -eq '1') { $AllowCommands = $true }

$script:ServerName    = 'autocad-mata'
$script:ServerVersion = '1.0.0'
$script:ShotDir       = if ($env:ACAD_MCP_SHOT_DIR) { $env:ACAD_MCP_SHOT_DIR } else { Join-Path $env:TEMP 'autocad-mcp-mata' }
$script:MaxShotWidth  = 1600
$script:RequiredLayers = @('AGRI', 'ASTR', 'ACUT', 'AHAT', 'ATEX')
if ($env:ACAD_MCP_REQUIRED_LAYERS) { $script:RequiredLayers = $env:ACAD_MCP_REQUIRED_LAYERS.Split(',') | ForEach-Object { $_.Trim() } }

# ---------- stdio setup (UTF-8, no BOM) ----------
$utf8 = New-Object System.Text.UTF8Encoding($false)
$script:reader = New-Object System.IO.StreamReader([Console]::OpenStandardInput(), $utf8)
$script:writer = New-Object System.IO.StreamWriter([Console]::OpenStandardOutput(), $utf8)
$script:writer.AutoFlush = $true
$script:writer.NewLine = "`n"

function Log($msg) { [Console]::Error.WriteLine("[autocad-mata] $msg") }

function Send($obj) {
    $json = $obj | ConvertTo-Json -Depth 30 -Compress
    $script:writer.WriteLine($json)
}

# ---------- Win32 helpers for screenshots ----------
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class MataWin {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hWnd, IntPtr hdcBlt, uint nFlags);
    [DllImport("user32.dll")] public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
}
"@
[void][MataWin]::SetProcessDPIAware()

# ---------- AutoCAD connection ----------
$script:acad = $null

function Get-Acad {
    if ($script:acad) {
        try { $null = $script:acad.Name; return $script:acad } catch { $script:acad = $null }
    }
    try {
        $script:acad = [System.Runtime.InteropServices.Marshal]::GetActiveObject('AutoCAD.Application')
    } catch {
        throw "AutoCAD is not running (or is AutoCAD LT). Open AutoCAD with the drawing first. Do NOT start a new instance. ($($_.Exception.Message))"
    }
    return $script:acad
}

function Get-Doc {
    $doc = (Get-Acad).ActiveDocument
    if (-not $doc) { throw 'AutoCAD has no active document.' }
    return $doc
}

function Ensure-Layer($doc, [string]$name) {
    try { $null = $doc.Layers.Item($name) } catch { $null = $doc.Layers.Add($name) }
}

function Apply-Layer($doc, $entity, $layer) {
    if ($layer) { Ensure-Layer $doc $layer; $entity.Layer = $layer }
}

function Arg($a, [string]$name, $default = $null) {
    if ($null -ne $a -and ($a.PSObject.Properties.Name -contains $name) -and $null -ne $a.$name) { return $a.$name }
    return $default
}

function Pt([double]$x, [double]$y, [double]$z = 0) { return [double[]]@($x, $y, $z) }

function Get-Rect($a) {
    $x1 = [double](Arg $a 'x1'); $y1 = [double](Arg $a 'y1')
    $x2 = [double](Arg $a 'x2'); $y2 = [double](Arg $a 'y2')
    return @{
        x1 = [Math]::Min($x1, $x2); y1 = [Math]::Min($y1, $y2)
        x2 = [Math]::Max($x1, $x2); y2 = [Math]::Max($y1, $y2)
    }
}

# ---------- seeing ----------
function Invoke-ZoomWindow($r, [double]$marginPct = 3) {
    $app = Get-Acad
    $mx = ($r.x2 - $r.x1) * $marginPct / 100.0
    $my = ($r.y2 - $r.y1) * $marginPct / 100.0
    $app.ZoomWindow((Pt ($r.x1 - $mx) ($r.y1 - $my)), (Pt ($r.x2 + $mx) ($r.y2 + $my)))
    try { (Get-Doc).Regen(1) } catch { }   # 1 = acAllViewports
}

function Test-BlankBitmap($bmp) {
    # true if every sampled pixel in the CENTRE (the drawing area) has the same colour.
    # PrintWindow can return the toolbars fine but a black viewport, so only the centre is checked.
    $first = $bmp.GetPixel([int]($bmp.Width / 2), [int]($bmp.Height / 2)).ToArgb()
    for ($i = 0; $i -le 30; $i++) {
        for ($j = 0; $j -le 30; $j++) {
            $px = $bmp.GetPixel([int]($bmp.Width * (0.25 + 0.5 * $i / 30)), [int]($bmp.Height * (0.25 + 0.5 * $j / 30))).ToArgb()
            if ($px -ne $first) { return $false }
        }
    }
    return $true
}

function Invoke-Screenshot([string]$label = 'shot') {
    $app = Get-Acad
    $hwnd = [IntPtr]([int64]$app.HWND)
    if ([MataWin]::IsIconic($hwnd)) { [void][MataWin]::ShowWindow($hwnd, 9) }  # 9 = SW_RESTORE
    Start-Sleep -Milliseconds 600   # let AutoCAD finish redrawing

    $rect = New-Object MataWin+RECT
    if (-not [MataWin]::GetWindowRect($hwnd, [ref]$rect)) { throw 'Could not read the AutoCAD window position.' }
    $w = $rect.Right - $rect.Left; $h = $rect.Bottom - $rect.Top
    if ($w -le 0 -or $h -le 0) { throw 'AutoCAD window has no size (minimized?).' }

    # 1st try: PrintWindow (works even when another window, e.g. Bambang, covers AutoCAD)
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $hdc = $g.GetHdc()
    $ok = [MataWin]::PrintWindow($hwnd, $hdc, 2)   # 2 = PW_RENDERFULLCONTENT
    $g.ReleaseHdc($hdc); $g.Dispose()

    if (-not $ok -or (Test-BlankBitmap $bmp)) {
        # 2nd try: bring AutoCAD to front and copy the screen
        $bmp.Dispose()
        [MataWin]::keybd_event(0x12, 0, 0, [UIntPtr]::Zero)   # ALT down: allows SetForegroundWindow
        [void][MataWin]::SetForegroundWindow($hwnd)
        [MataWin]::keybd_event(0x12, 0, 2, [UIntPtr]::Zero)   # ALT up
        Start-Sleep -Milliseconds 700
        $bmp = New-Object System.Drawing.Bitmap($w, $h)
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bmp.Size)
        $g.Dispose()
        if (Test-BlankBitmap $bmp) { $bmp.Dispose(); throw 'Screenshot is blank. Make sure AutoCAD is visible on screen, then try again. Do NOT continue drawing without seeing.' }
    }

    if ($w -gt $script:MaxShotWidth) {
        $nw = $script:MaxShotWidth; $nh = [int]($h * $nw / $w)
        $small = New-Object System.Drawing.Bitmap($nw, $nh)
        $g2 = [System.Drawing.Graphics]::FromImage($small)
        $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g2.DrawImage($bmp, 0, 0, $nw, $nh)
        $g2.Dispose(); $bmp.Dispose(); $bmp = $small
    }

    if (-not (Test-Path $script:ShotDir)) { $null = New-Item -ItemType Directory -Path $script:ShotDir }
    $safe = ($label -replace '[^A-Za-z0-9_-]', '_')
    $path = Join-Path $script:ShotDir ("{0}_{1}.png" -f (Get-Date -Format 'yyyyMMdd_HHmmss'), $safe)
    $ms = New-Object System.IO.MemoryStream
    $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $bytes = $ms.ToArray(); $ms.Dispose(); $bmp.Dispose()
    [System.IO.File]::WriteAllBytes($path, $bytes)

    return @{ path = $path; base64 = [Convert]::ToBase64String($bytes) }
}

function Get-Selection($doc, $r) {
    $name = 'MATA_' + [Guid]::NewGuid().ToString('N').Substring(0, 8)
    $ss = $doc.SelectionSets.Add($name)
    # 1 = acSelectionSetCrossing
    $ss.Select(1, (Pt $r.x1 $r.y1), (Pt $r.x2 $r.y2))
    return , $ss   # comma: stop PowerShell from unrolling the COM collection
}

function Invoke-CekDenah($r, [double]$tol = 5) {
    $doc = Get-Doc
    Invoke-ZoomWindow $r 0   # selection by window only works on what is on screen
    $ss = Get-Selection $doc $r
    $perLayer = @{}; $perType = @{}; $lineKeys = @{}; $dup = 0; $short = 0; $total = 0
    try {
        foreach ($e in $ss) {
            $total++
            $lay = [string]$e.Layer; $typ = [string]$e.ObjectName
            if (-not $perLayer.ContainsKey($lay)) { $perLayer[$lay] = 0 }; $perLayer[$lay]++
            if (-not $perType.ContainsKey($typ)) { $perType[$typ] = 0 }; $perType[$typ]++
            if ($typ -eq 'AcDbLine') {
                $s = $e.StartPoint; $t = $e.EndPoint
                $a = @([Math]::Round($s[0] / $tol), [Math]::Round($s[1] / $tol))
                $b = @([Math]::Round($t[0] / $tol), [Math]::Round($t[1] / $tol))
                if (($a[0] -gt $b[0]) -or ($a[0] -eq $b[0] -and $a[1] -gt $b[1])) { $tmp = $a; $a = $b; $b = $tmp }
                $key = "$lay|$($a[0]),$($a[1]),$($b[0]),$($b[1])"
                if ($lineKeys.ContainsKey($key)) { $dup++ } else { $lineKeys[$key] = 1 }
                if ($e.Length -lt 50) { $short++ }
            }
        }
    } finally {
        $ss.Delete()
    }
    $missing = @($script:RequiredLayers | Where-Object { -not $perLayer.ContainsKey($_) -or $perLayer[$_] -eq 0 })
    $warn = @()
    if ($missing.Count -gt 0) { $warn += "Layer wajib kosong: $($missing -join ', ')" }
    if ($dup -gt 0) { $warn += "$dup garis dobel - hapus dulu sebelum lanjut" }
    if ($short -gt 0) { $warn += "$short garis sangat pendek (<50 mm) - kemungkinan sisa potongan/furnitur" }
    $lines = 0; if ($perType.ContainsKey('AcDbLine')) { $lines = $perType['AcDbLine'] }
    $hatch = 0; if ($perType.ContainsKey('AcDbHatch')) { $hatch = $perType['AcDbHatch'] }
    if ($lines -gt 200 -and $hatch -eq 0) { $warn += "Ada $lines LINE tapi 0 HATCH - dinding belum digambar sebagai polyline+hatch" }
    return @{
        area             = $r
        total_entitas    = $total
        per_layer        = $perLayer
        per_tipe         = $perType
        garis_dobel      = $dup
        garis_pendek     = $short
        layer_wajib      = $script:RequiredLayers
        layer_wajib_kosong = $missing
        peringatan       = $warn
        lolos            = ($warn.Count -eq 0)
    }
}

# ---------- Tool definitions ----------
$N = @{ type = 'number' }
$S = @{ type = 'string' }
$B = @{ type = 'boolean' }

function Tool($name, $desc, $props, $required) {
    return @{
        name        = $name
        description = $desc
        inputSchema = @{ type = 'object'; properties = $props; required = @($required) }
    }
}

$layerProp = @{ type = 'string'; description = 'Optional layer name (created if missing).' }
$rectProps = @{
    x1 = @{ type = 'number'; description = 'Model-space X of one corner (mm).' }
    y1 = @{ type = 'number'; description = 'Model-space Y of one corner (mm).' }
    x2 = @{ type = 'number'; description = 'Model-space X of the opposite corner (mm).' }
    y2 = @{ type = 'number'; description = 'Model-space Y of the opposite corner (mm).' }
}
$lihatProps = $rectProps.Clone(); $lihatProps['label'] = @{ type = 'string'; description = 'Short name for the saved PNG, e.g. L1_tahap2_kolom.' }
$cekProps   = $rectProps.Clone(); $cekProps['toleransi'] = @{ type = 'number'; description = 'Tolerance in mm for duplicate lines (default 5).' }

$tools = @(
    (Tool 'acad_status' 'Get AutoCAD version, active drawing name/path, and entity/layer counts.' @{} @()),
    (Tool 'acad_list_layers' 'List all layers with color, on/off, frozen and locked state.' @{} @()),
    (Tool 'acad_create_layer' 'Create a layer (or update its color if it exists).' @{ name = $S; color = @{ type = 'integer'; description = 'AutoCAD Color Index 1-255.' } } @('name')),
    (Tool 'acad_set_active_layer' 'Set the current (active) layer.' @{ name = $S } @('name')),
    (Tool 'acad_draw_line' 'Draw a line in model space.' @{ x1 = $N; y1 = $N; x2 = $N; y2 = $N; layer = $layerProp } @('x1', 'y1', 'x2', 'y2')),
    (Tool 'acad_draw_circle' 'Draw a circle in model space.' @{ cx = $N; cy = $N; radius = $N; layer = $layerProp } @('cx', 'cy', 'radius')),
    (Tool 'acad_draw_polyline' 'Draw a 2D lightweight polyline from [x,y] points. Use closed=true for walls/cores that will be hatched.' @{
        points = @{ type = 'array'; description = 'Array of [x, y] pairs.'; items = @{ type = 'array'; items = $N } }
        closed = $B; layer = $layerProp
    } @('points')),
    (Tool 'acad_add_text' 'Add single-line text in model space.' @{ text = $S; x = $N; y = $N; height = $N; layer = $layerProp } @('text', 'x', 'y', 'height')),
    (Tool 'acad_list_entities' 'List model-space entities (type, handle, layer).' @{ limit = @{ type = 'integer' }; layer = $S } @()),
    (Tool 'acad_delete_entity' 'Delete a model-space entity by handle.' @{ handle = $S } @('handle')),
    (Tool 'acad_zoom_extents' 'Zoom the view to the drawing extents.' @{} @()),
    (Tool 'acad_save' 'Save the active drawing (must already have a file name).' @{} @()),
    (Tool 'acad_zoom_window' 'Zoom the view to a model-space rectangle (e.g. one floor frame). Use before acad_screenshot.' $rectProps @('x1', 'y1', 'x2', 'y2')),
    (Tool 'acad_screenshot' 'Capture the AutoCAD window and return it as an IMAGE so you can SEE the drawing. Call after every drawing step. Also saves a PNG.' @{ label = $S } @()),
    (Tool 'acad_lihat_area' 'LIHAT: zoom to a model-space rectangle (one floor/frame) and return a screenshot IMAGE of it. Use after EVERY drawing stage to check your work against the reference.' $lihatProps @('x1', 'y1', 'x2', 'y2')),
    (Tool 'acad_cek_denah' 'CEK: count entities per layer and type inside a rectangle, find duplicate and very short lines, and list required layers (AGRI, ASTR, ACUT, AHAT, ATEX) that are empty. Returns lolos=true only if no warnings.' $cekProps @('x1', 'y1', 'x2', 'y2'))
)

if ($AllowCommands) {
    $tools += (Tool 'acad_run_command' 'Send a raw command string to the AutoCAD command line (include trailing newline/space). POWERFUL.' @{ command = $S } @('command'))
}

function TextResult($obj) {
    $txt = if ($obj -is [string]) { $obj } else { $obj | ConvertTo-Json -Depth 20 -Compress }
    return @{ content = @(@{ type = 'text'; text = $txt }); isError = $false }
}

function ImageResult($shot, $extra) {
    $info = @{ saved_png = $shot.path }
    if ($extra) { foreach ($k in $extra.Keys) { $info[$k] = $extra[$k] } }
    return @{
        content = @(
            @{ type = 'image'; data = $shot.base64; mimeType = 'image/png' },
            @{ type = 'text'; text = (($info | ConvertTo-Json -Depth 10 -Compress) + ' -- Describe what you see (grid, columns, walls, core, labels, composition) before drawing the next stage.') }
        )
        isError = $false
    }
}

# ---------- Tool implementations ----------
function Invoke-Tool([string]$name, $a) {
    switch ($name) {
        'acad_status' {
            $app = Get-Acad; $doc = Get-Doc
            return TextResult @{ application = $app.Name; version = $app.Version; drawing = $doc.Name; path = $doc.FullName
                                 entities = $doc.ModelSpace.Count; layers = $doc.Layers.Count; activeLayer = $doc.ActiveLayer.Name }
        }
        'acad_list_layers' {
            $doc = Get-Doc; $out = @()
            foreach ($l in $doc.Layers) { $out += @{ name = $l.Name; color = $l.Color; on = $l.LayerOn; frozen = $l.Freeze; locked = $l.Lock } }
            return TextResult @{ layers = $out }
        }
        'acad_create_layer' {
            $doc = Get-Doc; $n = [string](Arg $a 'name'); Ensure-Layer $doc $n
            $c = Arg $a 'color'; if ($null -ne $c) { $doc.Layers.Item($n).Color = [int]$c }
            return TextResult @{ layer = $n; status = 'ok' }
        }
        'acad_set_active_layer' {
            $doc = Get-Doc; $n = [string](Arg $a 'name'); Ensure-Layer $doc $n
            $doc.ActiveLayer = $doc.Layers.Item($n)
            return TextResult @{ activeLayer = $n }
        }
        'acad_draw_line' {
            $doc = Get-Doc
            $e = $doc.ModelSpace.AddLine((Pt ([double](Arg $a 'x1')) ([double](Arg $a 'y1'))), (Pt ([double](Arg $a 'x2')) ([double](Arg $a 'y2'))))
            Apply-Layer $doc $e (Arg $a 'layer')
            return TextResult @{ handle = $e.Handle; type = $e.ObjectName; layer = $e.Layer }
        }
        'acad_draw_circle' {
            $doc = Get-Doc
            $e = $doc.ModelSpace.AddCircle((Pt ([double](Arg $a 'cx')) ([double](Arg $a 'cy'))), [double](Arg $a 'radius'))
            Apply-Layer $doc $e (Arg $a 'layer')
            return TextResult @{ handle = $e.Handle; type = $e.ObjectName; layer = $e.Layer }
        }
        'acad_draw_polyline' {
            $doc = Get-Doc; $pts = @(Arg $a 'points')
            if ($pts.Count -lt 2) { throw 'Need at least 2 points.' }
            $flat = New-Object 'double[]' ($pts.Count * 2)
            for ($i = 0; $i -lt $pts.Count; $i++) { $flat[2 * $i] = [double]$pts[$i][0]; $flat[2 * $i + 1] = [double]$pts[$i][1] }
            $e = $doc.ModelSpace.AddLightWeightPolyline($flat)
            if (Arg $a 'closed' $false) { $e.Closed = $true }
            Apply-Layer $doc $e (Arg $a 'layer')
            return TextResult @{ handle = $e.Handle; type = $e.ObjectName; layer = $e.Layer; vertices = $pts.Count }
        }
        'acad_add_text' {
            $doc = Get-Doc
            $e = $doc.ModelSpace.AddText([string](Arg $a 'text'), (Pt ([double](Arg $a 'x')) ([double](Arg $a 'y'))), [double](Arg $a 'height'))
            Apply-Layer $doc $e (Arg $a 'layer')
            return TextResult @{ handle = $e.Handle; type = $e.ObjectName; layer = $e.Layer }
        }
        'acad_list_entities' {
            $doc = Get-Doc; $limit = [int](Arg $a 'limit' 100); $layer = Arg $a 'layer'; $out = @()
            foreach ($e in $doc.ModelSpace) {
                if ($layer -and $e.Layer -ne $layer) { continue }
                $out += @{ handle = $e.Handle; type = $e.ObjectName; layer = $e.Layer }
                if ($out.Count -ge $limit) { break }
            }
            return TextResult @{ count = $out.Count; entities = $out }
        }
        'acad_delete_entity' {
            $doc = Get-Doc; $e = $doc.HandleToObject([string](Arg $a 'handle')); $e.Delete()
            return TextResult @{ deleted = (Arg $a 'handle') }
        }
        'acad_zoom_extents' { (Get-Acad).ZoomExtents(); return TextResult 'zoomed to extents' }
        'acad_save' { $doc = Get-Doc; $doc.Save(); return TextResult @{ saved = $doc.FullName } }
        'acad_zoom_window' { $r = Get-Rect $a; Invoke-ZoomWindow $r; return TextResult @{ zoomed = $r } }
        'acad_screenshot' { $shot = Invoke-Screenshot ([string](Arg $a 'label' 'shot')); return ImageResult $shot $null }
        'acad_lihat_area' {
            $r = Get-Rect $a; Invoke-ZoomWindow $r
            $shot = Invoke-Screenshot ([string](Arg $a 'label' 'area'))
            return ImageResult $shot @{ area = $r }
        }
        'acad_cek_denah' {
            $r = Get-Rect $a
            return TextResult (Invoke-CekDenah $r ([double](Arg $a 'toleransi' 5)))
        }
        'acad_run_command' {
            if (-not $AllowCommands) { throw 'acad_run_command is disabled.' }
            (Get-Doc).SendCommand([string](Arg $a 'command'))
            return TextResult 'sent'
        }
        default { throw "Unknown tool: $name" }
    }
}

# ---------- JSON-RPC loop ----------
Log "started (shots in $script:ShotDir)"
while ($true) {
    $line = $script:reader.ReadLine()
    if ($null -eq $line) { break }
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    try { $msg = $line | ConvertFrom-Json } catch { Log "bad json: $line"; continue }
    $hasId = $msg.PSObject.Properties.Name -contains 'id'
    $id = if ($hasId) { $msg.id } else { $null }
    $method = [string]$msg.method
    try {
        switch ($method) {
            'initialize' {
                $pv = '2024-11-05'
                if ($msg.params -and $msg.params.protocolVersion) { $pv = [string]$msg.params.protocolVersion }
                Send @{ jsonrpc = '2.0'; id = $id; result = @{
                    protocolVersion = $pv
                    capabilities    = @{ tools = @{ listChanged = $false } }
                    serverInfo      = @{ name = $script:ServerName; version = $script:ServerVersion }
                } }
            }
            'ping'       { Send @{ jsonrpc = '2.0'; id = $id; result = @{} } }
            'tools/list' { Send @{ jsonrpc = '2.0'; id = $id; result = @{ tools = $tools } } }
            'tools/call' {
                $tname = [string]$msg.params.name
                $targs = $msg.params.arguments
                try {
                    $res = Invoke-Tool $tname $targs
                } catch {
                    $res = @{ content = @(@{ type = 'text'; text = "Error: $($_.Exception.Message)" }); isError = $true }
                }
                Send @{ jsonrpc = '2.0'; id = $id; result = $res }
            }
            default {
                if ($hasId -and $null -ne $id) {
                    Send @{ jsonrpc = '2.0'; id = $id; error = @{ code = -32601; message = "Method not found: $method" } }
                }
                # notifications (no id), e.g. notifications/initialized: no reply
            }
        }
    } catch {
        Log "error in ${method}: $($_.Exception.Message)"
        if ($hasId -and $null -ne $id) {
            Send @{ jsonrpc = '2.0'; id = $id; error = @{ code = -32603; message = $_.Exception.Message } }
        }
    }
}
