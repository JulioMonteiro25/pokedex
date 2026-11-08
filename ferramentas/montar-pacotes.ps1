param([string]$Site, [int]$Per = 80, [int]$Max = 1025)
# Junta as imagens $Site\pub\img\N.png em pacotes img-K.json (lista de PNGs em base64)
$utf8 = [Text.UTF8Encoding]::new($false)
for ($k = 0; $k * $Per -lt $Max; $k++) {
  $items = @()
  for ($j = 1; $j -le $Per; $j++) {
    $id = $k * $Per + $j; if ($id -gt $Max) { break }
    $items += '"' + [Convert]::ToBase64String([IO.File]::ReadAllBytes("$Site\pub\img\$id.png")) + '"'
  }
  [IO.File]::WriteAllText("$Site\pub\img-$k.json", '[' + ($items -join ',') + ']', $utf8)
}