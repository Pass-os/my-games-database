<#
.SYNOPSIS
    Copia configuracao de addons e macros do WoW deste PC para o repositorio.

.DESCRIPTION
    Rode depois de mudar algo no jogo e de sair ou dar /reload (o jogo so grava
    SavedVariables e macros nessas horas). Depois e so revisar e commitar.

    O que vai para o repositorio:
      config\SavedVariables\<addon>.lua   - so os addons de $SavedVariablesVersionados
      config\macros\conta.txt             - macros de conta
      config\macros\<reino>\<personagem>.txt - macros de cada personagem

    O que NAO vai (repositorio publico):
      - o numero da conta Battle.net (nome da pasta WTF\Account\<numero>#1)
      - o bloco profileKeys, que liga "Personagem - Reino" a perfis. Sem ele o
        addon usa o perfil "Default" em todo personagem, que e o que usamos.

.PARAMETER WowPath
    Pasta do World of Warcraft (ou a _retail_). Se omitido, le do registro.
#>
param([string]$WowPath)

. "$PSScriptRoot\wow-comum.ps1"

$retail = Get-WowRetailPath $WowPath
# So le os arquivos do jogo, entao pode rodar com o WoW aberto; mas o que foi
# mudado depois do ultimo /reload (ou login) ainda nao esta no disco.
if (Get-Process -Name 'Wow' -ErrorAction SilentlyContinue) {
    Write-Warning 'O WoW esta aberto: sera salvo o que o jogo gravou no ultimo /reload ou login.'
}

$contas = @(Get-WowAccountDirs $retail)
if ($contas.Count -ne 1) {
    throw "Esperava 1 pasta de conta em WTF\Account, achei $($contas.Count). Ajuste o script se tiver mais de uma conta."
}
$conta = $contas[0].FullName

$config = Join-Path $PSScriptRoot '..\config'
$svDestino = Join-Path $config 'SavedVariables'
$macrosDestino = Join-Path $config 'macros'
New-Item -ItemType Directory -Force $svDestino, $macrosDestino | Out-Null

$utf8 = New-Object System.Text.UTF8Encoding($false)

foreach ($nome in $SavedVariablesVersionados) {
    $origem = Join-Path $conta "SavedVariables\$nome.lua"
    if (-not (Test-Path $origem)) {
        Write-Host "- $nome (sem SavedVariables ainda, pulado)"
        continue
    }
    $texto = [IO.File]::ReadAllText($origem, $utf8)
    # profileKeys so contem pares "Personagem - Reino" = "perfil" (strings), sem tabelas aninhadas.
    $texto = [regex]::Replace($texto, '\[\"profileKeys\"\]\s*=\s*\{[^{}]*\},\s*', '')
    [IO.File]::WriteAllText((Join-Path $svDestino "$nome.lua"), $texto, $utf8)
    Write-Host "- $nome"
}

$macroConta = Join-Path $conta 'macros-cache.txt'
if (Test-Path $macroConta) {
    Copy-Item $macroConta (Join-Path $macrosDestino 'conta.txt') -Force
    Write-Host '- macros de conta'
}

Get-ChildItem $conta -Directory | Where-Object { $_.Name -ne 'SavedVariables' } | ForEach-Object {
    $reino = $_
    Get-ChildItem $reino.FullName -Directory | ForEach-Object {
        $arquivo = Join-Path $_.FullName 'macros-cache.txt'
        if (Test-Path $arquivo) {
            $pastaReino = Join-Path $macrosDestino $reino.Name
            New-Item -ItemType Directory -Force $pastaReino | Out-Null
            Copy-Item $arquivo (Join-Path $pastaReino "$($_.Name).txt") -Force
            Write-Host "- macros de $($_.Name) ($($reino.Name))"
        }
    }
}

Write-Host ''
Write-Host 'Pronto. Revise com "git diff" e faca o commit.'
