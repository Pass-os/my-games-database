<#
.SYNOPSIS
    Copia a configuracao de addons e as macros do repositorio para o WoW deste PC.

.DESCRIPTION
    Rode com o WoW FECHADO e depois de ter entrado no jogo pelo menos uma vez
    nesse PC (e com cada personagem, para as macros de personagem): e isso que
    cria as pastas WTF\Account\<conta>\<reino>\<personagem>.

    Tudo que for sobrescrito vai antes para WTF\backup-antes-restaurar-<data>.

.PARAMETER WowPath
    Pasta do World of Warcraft (ou a _retail_). Se omitido, le do registro.
#>
param([string]$WowPath)

. "$PSScriptRoot\wow-comum.ps1"

$retail = Get-WowRetailPath $WowPath
Assert-WowFechado

$contas = @(Get-WowAccountDirs $retail)
if ($contas.Count -eq 0) {
    throw 'Nenhuma conta em WTF\Account. Entre no jogo uma vez neste PC, saia, e rode de novo.'
}
if ($contas.Count -gt 1) {
    throw "Achei $($contas.Count) contas em WTF\Account ($($contas.Name -join ', ')). Ajuste o script para escolher uma."
}
$conta = $contas[0].FullName

$config = Join-Path $PSScriptRoot '..\config'
$backup = Join-Path $retail ("WTF\backup-antes-restaurar-{0:yyyyMMdd-HHmmss}" -f (Get-Date))

function Copiar-ComBackup([string]$origem, [string]$destino) {
    if (Test-Path $destino) {
        $relativo = $destino.Substring($conta.Length).TrimStart('\')
        $copia = Join-Path $backup $relativo
        New-Item -ItemType Directory -Force (Split-Path $copia) | Out-Null
        Copy-Item $destino $copia -Force
    }
    New-Item -ItemType Directory -Force (Split-Path $destino) | Out-Null
    Copy-Item $origem $destino -Force
}

Get-ChildItem (Join-Path $config 'SavedVariables') -Filter '*.lua' | ForEach-Object {
    Copiar-ComBackup $_.FullName (Join-Path $conta "SavedVariables\$($_.Name)")
    Write-Host "- $($_.BaseName)"
}

$macrosDir = Join-Path $config 'macros'
$macroConta = Join-Path $macrosDir 'conta.txt'
if (Test-Path $macroConta) {
    Copiar-ComBackup $macroConta (Join-Path $conta 'macros-cache.txt')
    Write-Host '- macros de conta'
}

Get-ChildItem $macrosDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $reino = $_.Name
    Get-ChildItem $_.FullName -Filter '*.txt' | ForEach-Object {
        $pastaPersonagem = Join-Path $conta "$reino\$($_.BaseName)"
        if (Test-Path $pastaPersonagem) {
            Copiar-ComBackup $_.FullName (Join-Path $pastaPersonagem 'macros-cache.txt')
            Write-Host "- macros de $($_.BaseName) ($reino)"
        } else {
            Write-Warning "$($_.BaseName) ($reino) ainda nao existe neste PC: entre no jogo com ele uma vez e rode de novo."
        }
    }
}

# Opcoes do jogo que valem em qualquer PC (escala da interface etc.). Ficam no
# WTF\Config.wtf, que e por maquina e nao e versionado inteiro: so as linhas
# de config\cvars.wtf sao aplicadas, o resto do arquivo fica como esta.
$cvars = Join-Path $config 'cvars.wtf'
$configWtf = Join-Path $retail 'WTF\Config.wtf'
if ((Test-Path $cvars) -and (Test-Path $configWtf)) {
    New-Item -ItemType Directory -Force $backup | Out-Null
    Copy-Item $configWtf (Join-Path $backup 'Config.wtf') -Force
    $linhas = [Collections.Generic.List[string]](Get-Content $configWtf)
    foreach ($novo in Get-Content $cvars) {
        if ($novo -notmatch '^SET (\S+) ".*"$') { continue }
        $nome = $Matches[1]
        $i = $linhas.FindIndex({ param($l) $l -match ('^SET ' + [regex]::Escape($nome) + ' "') })
        if ($i -ge 0) { $linhas[$i] = $novo } else { $linhas.Add($novo) }
    }
    [IO.File]::WriteAllLines($configWtf, $linhas, (New-Object Text.UTF8Encoding $false))
    Write-Host '- opcoes do jogo (config\cvars.wtf)'
}

Write-Host ''
if (Test-Path $backup) { Write-Host "Arquivos anteriores guardados em: $backup" }
Write-Host 'Pronto. Pode abrir o WoW.'
