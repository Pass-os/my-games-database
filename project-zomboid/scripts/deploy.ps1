<#
.SYNOPSIS
    Copia um mod de project-zomboid/mods/<ModId> para %USERPROFILE%\Zomboid\mods\<ModId>.
.EXAMPLE
    .\scripts\deploy.ps1 NoHouseAlarms
#>
param(
    [Parameter(Mandatory)] [string] $ModId,
    [string] $Destino = (Join-Path $env:USERPROFILE 'Zomboid\mods')
)
$ErrorActionPreference = 'Stop'

$origem = Join-Path $PSScriptRoot "..\mods\$ModId" | Resolve-Path
if (-not (Test-Path (Join-Path $origem '42\mod.info'))) {
    throw "$origem nao tem 42\mod.info (formato B42)."
}
$alvo = Join-Path $Destino $ModId

# /MIR deixa o destino igual ao repo; .gitkeep so existe para o git
robocopy $origem $alvo /MIR /XF .gitkeep /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy falhou ($LASTEXITCODE)" }
"$ModId -> $alvo"
