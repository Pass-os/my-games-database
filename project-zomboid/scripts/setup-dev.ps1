<#
.SYNOPSIS
    Prepara o ambiente de desenvolvimento Lua: baixa as tipagens Umbrella da
    mesma versao do jogo para re/umbrella (gitignored).
.EXAMPLE
    .\scripts\setup-dev.ps1
#>
param(
    [string] $Versao
)
$ErrorActionPreference = 'Stop'

if (-not $Versao) {
    # version.txt: "42.21.0 4a0e9546ec"
    $Versao = (Get-Content (Join-Path $env:USERPROFILE 'Zomboid\version.txt') -TotalCount 1).Split(' ')[0]
}
$destino = Join-Path $PSScriptRoot '..\re\umbrella'

if (Test-Path $destino) {
    $atual = git -C $destino describe --tags 2>$null
    if ($atual -eq $Versao) { "Umbrella $Versao ja esta em re\umbrella"; return }
    Remove-Item -Recurse -Force $destino
}

# Umbrella publica uma tag por versao do jogo
git clone -q --depth 1 --branch $Versao https://github.com/PZ-Umbrella/Umbrella.git $destino
if ($LASTEXITCODE -ne 0) { throw "Sem tag $Versao no Umbrella; rode com -Versao <tag> (ver github.com/PZ-Umbrella/Umbrella/releases)" }
"Umbrella $Versao -> $destino"
"VS Code: instale a extensao tangzx.emmylua e abra a pasta project-zomboid."
