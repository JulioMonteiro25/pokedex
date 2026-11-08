param([string]$Site, [int]$Max = 1025, [int]$Size = 280, [switch]$Collect)
Add-Type -AssemblyName System.Drawing
$utf8 = [Text.UTF8Encoding]::new($false)
function J($x) { return (ConvertTo-Json -InputObject $x -Compress) }
function Pretty($s) { return ($s -replace '-', ' ') }
$script:dict = @{}
$script:seen = New-Object 'System.Collections.Generic.HashSet[string]'
if (-not $Collect -and (Test-Path "$Site\pt.json")) {
  $o = Get-Content "$Site\pt.json" -Raw -Encoding UTF8 | ConvertFrom-Json
  foreach ($pr in $o.PSObject.Properties) { $script:dict[$pr.Name] = $pr.Value }
}
function T($s) {
  if (-not $s) { return $s }
  [void]$script:seen.Add($s)
  if ($script:dict.ContainsKey($s)) { return $script:dict[$s] }
  return $s
}

function Label($details) {
  $d = @($details)[0]
  if (-not $d) { return '' }
  $parts = @()
  if ($d.min_level) { $parts += "Nv. $($d.min_level)" }
  if ($d.item) { $parts += (T (Pretty $d.item.name)) }
  if ($d.held_item) { $parts += "segurando $(T (Pretty $d.held_item.name))" }
  if ($d.trigger -and $d.trigger.name -eq 'trade') { $parts += 'Troca' }
  if ($d.min_happiness) { $parts += 'Amizade' }
  if ($d.min_affection) { $parts += 'Afeto' }
  if ($d.known_move) { $parts += "golpe $(T (Pretty $d.known_move.name))" }
  if ($d.time_of_day) { $parts += $(if ($d.time_of_day -eq 'day') { 'de dia' } else { 'de noite' }) }
  if ($d.location) { $parts += (T (Pretty $d.location.name)) }
  if (-not $parts.Count -and $d.trigger) { $parts += (Pretty $d.trigger.name) }
  return ($parts -join ' · ')
}
function Node($n) {
  $id = [int](($n.species.url -replace '/$', '') -split '/')[-1]
  $kids = @()
  foreach ($c in @($n.evolves_to)) { $kids += ('[' + (J (Label $c.evolution_details)) + ',' + (Node $c) + ']') }
  return '{"i":' + $id + ',"e":[' + ($kids -join ',') + ']}'
}

$raw = "$Site\raw"
$rows = @(); $chainIds = @{}
foreach ($i in 1..$Max) {
  $p = Get-Content "$raw\p$i.json" -Raw -Encoding UTF8 | ConvertFrom-Json
  $s = Get-Content "$raw\s$i.json" -Raw -Encoding UTF8 | ConvertFrom-Json
  $chainIds[[int]$s.chain] = 1
  $types = '[' + ((@($p.types) | ForEach-Object { J $_ }) -join ',') + ']'
  $stats = '[' + (@($p.stats) -join ',') + ']'
  $abil = '[' + ((@($p.abil) | ForEach-Object { '[' + (J (T (Pretty $_[0]))) + ',' + $_[1] + ']' }) -join ',') + ']'
  $xp = if ($p.xp) { $p.xp } else { 0 }
  $rows += ('[' + $i + ',' + (J $p.name) + ',' + $types + ',' + $p.h + ',' + $p.w + ',' + $xp + ',' + $stats + ',' + $abil + ',' + (J (T $s.genus)) + ',' + (J (T $s.flavor)) + ',' + $s.chain + ']')
}
$chains = @()
foreach ($c in ($chainIds.Keys | Sort-Object)) {
  $ch = Get-Content "$raw\c$c.json" -Raw -Encoding UTF8 | ConvertFrom-Json
  $chains += ('"' + $c + '":' + (Node $ch.chain))
}
if ($Collect) { [IO.File]::WriteAllLines("$Site\strings.txt", [string[]]@($script:seen), $utf8); Write-Output "strings: $($script:seen.Count)"; return }
New-Item -ItemType Directory -Force "$Site\pub\img" | Out-Null
$json = '{"p":[' + ($rows -join ",`n") + '],"c":{' + ($chains -join ',') + '}}'
[IO.File]::WriteAllText("$Site\pub\data.json", $json, $utf8)
Write-Output "data.json: $((Get-Item "$Site\pub\data.json").Length) bytes"

# imagens reduzidas
$ok = 0
foreach ($i in 1..$Max) {
  $src = "$Site\img\$i.png"; $dst = "$Site\pub\img\$i.png"
  if (-not (Test-Path $src)) { Write-Output "sem imagem $i"; continue }
  if (Test-Path $dst) { $ok++; continue }
  $bmp = [Drawing.Image]::FromFile($src)
  $scale = [Math]::Min($Size / $bmp.Width, $Size / $bmp.Height)
  $w = [int]($bmp.Width * $scale); $h = [int]($bmp.Height * $scale)
  $out = New-Object Drawing.Bitmap $w, $h, ([Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [Drawing.Graphics]::FromImage($out)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'HighQuality'; $g.PixelOffsetMode = 'HighQuality'
  $g.DrawImage($bmp, 0, 0, $w, $h); $g.Dispose(); $bmp.Dispose()
  $out.Save($dst, [Drawing.Imaging.ImageFormat]::Png); $out.Dispose(); $ok++
}
Write-Output "imagens: $ok"

# icone pokebola (apple-touch-icon)
$n = 180
$b = New-Object Drawing.Bitmap $n, $n
$g = [Drawing.Graphics]::FromImage($b); $g.SmoothingMode = 'AntiAlias'
$g.Clear([Drawing.Color]::FromArgb(227, 53, 13))
$dark = [Drawing.Color]::FromArgb(29, 28, 26)
$rect = New-Object Drawing.Rectangle 20, 20, 140, 140
$g.FillEllipse([Drawing.Brushes]::White, $rect)
$g.FillPie((New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(255, 74, 36))), $rect, 180, 180)
$pen = New-Object Drawing.Pen $dark, 9
$g.DrawLine($pen, 20, 90, 160, 90); $g.DrawEllipse($pen, $rect)
$g.FillEllipse([Drawing.Brushes]::White, 68, 68, 44, 44); $g.DrawEllipse($pen, 68, 68, 44, 44)
$g.Dispose(); $b.Save("$Site\pub\icon.png", [Drawing.Imaging.ImageFormat]::Png); $b.Dispose()
Write-Output "ok"
