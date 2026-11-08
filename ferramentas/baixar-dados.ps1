param([string]$Out, [int]$Max = 1025, [int]$Threads = 16)
$ErrorActionPreference = 'Continue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
New-Item -ItemType Directory -Force "$Out\img" | Out-Null
New-Item -ItemType Directory -Force "$Out\raw" | Out-Null

$work = {
  param($job, $Out)
  $api = 'https://pokeapi.co/api/v2/'
  $art = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/'
  for ($try = 0; $try -lt 4; $try++) {
    try {
      switch ($job.kind) {
        'pokemon' {
          $r = Invoke-WebRequest -UseBasicParsing -Uri ($api + 'pokemon/' + $job.id) -TimeoutSec 60
          $p = [Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray()) | ConvertFrom-Json
          $o = [ordered]@{
            id = $p.id; name = $p.name; h = $p.height; w = $p.weight; xp = $p.base_experience
            types = @($p.types | ForEach-Object { $_.type.name })
            stats = @($p.stats | ForEach-Object { $_.base_stat })
            abil = @($p.abilities | ForEach-Object { ,@($_.ability.name, [int][bool]$_.is_hidden) })
            species = [int](($p.species.url -replace '/$','') -split '/')[-1]
          }
          [IO.File]::WriteAllText("$Out\raw\p$($job.id).json", ($o | ConvertTo-Json -Depth 6 -Compress), [Text.UTF8Encoding]::new($false))
        }
        'species' {
          $r = Invoke-WebRequest -UseBasicParsing -Uri ($api + 'pokemon-species/' + $job.id) -TimeoutSec 60
          $s = [Text.Encoding]::UTF8.GetString($r.RawContentStream.ToArray()) | ConvertFrom-Json
          $fl = @($s.flavor_text_entries | Where-Object { $_.language.name -eq 'en' }) | Select-Object -Last 1
          $ge = @($s.genera | Where-Object { $_.language.name -eq 'en' }) | Select-Object -First 1
          $o = [ordered]@{
            id = $s.id; name = $s.name
            flavor = $(if ($fl) { ($fl.flavor_text -replace '[\n\f\r]+', ' ') } else { '' })
            genus = $(if ($ge) { $ge.genus } else { '' })
            chain = [int](($s.evolution_chain.url -replace '/$','') -split '/')[-1]
          }
          [IO.File]::WriteAllText("$Out\raw\s$($job.id).json", ($o | ConvertTo-Json -Depth 4 -Compress), [Text.UTF8Encoding]::new($false))
        }
        'chain' {
          $r = Invoke-WebRequest -UseBasicParsing -Uri ($api + 'evolution-chain/' + $job.id) -TimeoutSec 60
          [IO.File]::WriteAllText("$Out\raw\c$($job.id).json", $r.Content, [Text.UTF8Encoding]::new($false))
        }
        'img' {
          $dest = "$Out\img\$($job.id).png"
          if (-not (Test-Path $dest) -or (Get-Item $dest).Length -lt 500) {
            Invoke-WebRequest -UseBasicParsing -Uri ($art + $job.id + '.png') -OutFile $dest -TimeoutSec 60
          }
        }
      }
      return $null
    } catch { Start-Sleep -Milliseconds (500 * ($try + 1)) }
  }
  return "FAIL $($job.kind) $($job.id)"
}

function Run-Jobs($jobs) {
  $pool = [runspacefactory]::CreateRunspacePool(1, $Threads); $pool.Open()
  $handles = foreach ($j in $jobs) {
    $ps = [powershell]::Create(); $ps.RunspacePool = $pool
    [void]$ps.AddScript($work).AddArgument($j).AddArgument($Out)
    [pscustomobject]@{ ps = $ps; h = $ps.BeginInvoke() }
  }
  $fails = @()
  foreach ($x in $handles) { $res = $x.ps.EndInvoke($x.h); if ($res) { $fails += $res }; $x.ps.Dispose() }
  $pool.Close()
  return $fails
}

$ids = 1..$Max
Write-Output "Pokemon + species..."
$jobs = @(); foreach ($i in $ids) { if (-not (Test-Path "$Out\raw\p$i.json")) { $jobs += @{ kind = 'pokemon'; id = $i } }; if (-not (Test-Path "$Out\raw\s$i.json")) { $jobs += @{ kind = 'species'; id = $i } } }
Run-Jobs $jobs | ForEach-Object { Write-Output $_ }

$chains = @{}
foreach ($i in $ids) { if (Test-Path "$Out\raw\s$i.json") { $chains[[int](Get-Content "$Out\raw\s$i.json" -Raw -Encoding UTF8 | ConvertFrom-Json).chain] = 1 } }
Write-Output "Chains: $($chains.Count)"
$jobs = @(); foreach ($c in $chains.Keys) { if (-not (Test-Path "$Out\raw\c$c.json")) { $jobs += @{ kind = 'chain'; id = $c } } }
Run-Jobs $jobs | ForEach-Object { Write-Output $_ }

Write-Output "Images..."
$jobs = @(); foreach ($i in $ids) { $jobs += @{ kind = 'img'; id = $i } }
Run-Jobs $jobs | ForEach-Object { Write-Output $_ }
Write-Output "DONE"
