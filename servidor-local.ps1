param([string]$Root, [int]$Port = 8765)
$l = [Net.HttpListener]::new(); $l.Prefixes.Add("http://localhost:$Port/"); $l.Start()
$types = @{ '.html' = 'text/html; charset=utf-8'; '.json' = 'application/json'; '.png' = 'image/png' }
while ($l.IsListening) {
  $c = $l.GetContext()
  $p = $c.Request.Url.LocalPath.TrimStart('/'); if (-not $p) { $p = 'index.html' }
  $f = Join-Path $Root $p
  if (Test-Path $f -PathType Leaf) {
    $b = [IO.File]::ReadAllBytes($f); $e = [IO.Path]::GetExtension($f)
    $c.Response.ContentType = $(if ($types[$e]) { $types[$e] } else { 'application/octet-stream' })
    $c.Response.OutputStream.Write($b, 0, $b.Length)
  } else { $c.Response.StatusCode = 404 }
  $c.Response.Close()
}
