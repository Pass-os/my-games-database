<#
.SYNOPSIS
    Acompanha o console.txt do jogo mostrando so erros e prints de mods.
    O jogo recria o arquivo a cada abertura; o script detecta e recomeca.
.EXAMPLE
    .\scripts\log.ps1                      # erros + linhas [Mod] de todos os mods
    .\scripts\log.ps1 -Mod NoHouseAlarms   # so o que menciona esse mod
    .\scripts\log.ps1 -Tudo                # o arquivo inteiro, sem filtro
    .\scripts\log.ps1 -Ignorar 'Read While Walking'   # esconde um mod barulhento
#>
param(
    [string] $Mod,
    [string] $Ignorar,
    [switch] $Tudo,
    [string] $Arquivo = (Join-Path $env:USERPROFILE 'Zomboid\console.txt')
)

# ERROR / Exception / stack de Lua, e print() de mod no formato "[Tag] ...",
# que o jogo grava como "LOG  : Lua  f:123> :<tab>[Tag] ..."
$padrao = if ($Mod) { [regex]::Escape($Mod) } else { 'ERROR|Exception|STACK TRACE|MOD:|^LOG\s*: Lua\s.*>\s*:\s*\[' }

$script:pulando = $false
function Mostrar([string] $linha) {
    if ($Ignorar) {
        # um erro ocupa varias linhas (indentadas ou "STACK TRACE"); pula o bloco todo
        $continuacao = $linha -match '^(\s|$|STACK TRACE|-{5,})' -or $linha -match 'flushErrorMessage'
        if ($linha -match [regex]::Escape($Ignorar)) { $script:pulando = $true; return }
        if ($script:pulando -and $continuacao) { return }
        $script:pulando = $false
    }
    if (-not $Tudo -and $linha -notmatch $padrao) { return }
    $cor = if ($linha -match 'ERROR|Exception') { 'Red' } elseif ($linha -match 'WARN') { 'Yellow' } else { 'Gray' }
    Write-Host $linha -ForegroundColor $cor
}

"Acompanhando $Arquivo (Ctrl+C para sair)"
$pos = 0
while ($true) {
    if (-not (Test-Path $Arquivo)) { Start-Sleep -Milliseconds 500; continue }
    $tam = (Get-Item $Arquivo).Length
    if ($tam -lt $pos) { Write-Host '--- console.txt recriado (jogo reiniciou) ---' -ForegroundColor Cyan; $pos = 0 }
    if ($tam -gt $pos) {
        # FileShare ReadWrite: o jogo mantem o arquivo aberto para escrita
        $fs = [IO.File]::Open($Arquivo, 'Open', 'Read', 'ReadWrite')
        try {
            $fs.Seek($pos, 'Begin') | Out-Null
            $sr = New-Object IO.StreamReader($fs)
            while ($null -ne ($l = $sr.ReadLine())) { Mostrar $l }
            $pos = $fs.Position
        } finally { $fs.Dispose() }
    }
    Start-Sleep -Milliseconds 500
}
