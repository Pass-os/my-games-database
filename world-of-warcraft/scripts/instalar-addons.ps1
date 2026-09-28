<#
.SYNOPSIS
    Instala no WoW Retail os addons listados em addons.json, nas versoes fixadas.

.DESCRIPTION
    Baixa cada arquivo direto do CurseForge (mesmo arquivo, mesmo tamanho que foi
    testado), confere o tamanho, rejeita .zip com executavel dentro e extrai em
    _retail_\Interface\AddOns. Pastas de addon ja existentes sao substituidas;
    as outras pastas de AddOns nao sao tocadas.

    Depois copia os addons feitos neste repositorio (pasta addons-proprios).

.PARAMETER WowPath
    Pasta do World of Warcraft (ou a _retail_). Se omitido, le do registro.

.EXAMPLE
    .\instalar-addons.ps1
.EXAMPLE
    .\instalar-addons.ps1 -WowPath "X:\Battle.net\World of Warcraft"
#>
param([string]$WowPath)

. "$PSScriptRoot\wow-comum.ps1"

$retail = Get-WowRetailPath $WowPath
$addonsDir = Join-Path $retail 'Interface\AddOns'
New-Item -ItemType Directory -Force $addonsDir | Out-Null

$manifesto = Get-Content (Join-Path $PSScriptRoot '..\addons.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$temp = Join-Path ([IO.Path]::GetTempPath()) "wow-addons-$(Get-Random)"
New-Item -ItemType Directory $temp | Out-Null

Write-Host "WoW: $retail (addons para $($manifesto.gameVersion))"
if (Get-Process -Name 'Wow' -ErrorAction SilentlyContinue) {
    Write-Warning 'O WoW esta aberto: os addons so aparecem depois de fechar e abrir o jogo.'
}

try {
    foreach ($a in $manifesto.addons) {
        $url = "https://www.curseforge.com/api/v1/mods/$($a.projectId)/files/$($a.fileId)/download"
        $zip = Join-Path $temp "$($a.projectId).zip"
        Write-Host ("- {0} {1} ... " -f $a.name, $a.version) -NoNewline

        Invoke-WebRequest $url -OutFile $zip -UseBasicParsing -UserAgent 'Mozilla/5.0'

        $tamanho = (Get-Item $zip).Length
        if ($tamanho -ne $a.size) {
            throw "$($a.name): baixou $tamanho bytes, esperado $($a.size). Arquivo diferente do testado."
        }

        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $arquivo = [IO.Compression.ZipFile]::OpenRead($zip)
        try {
            $binarios = $arquivo.Entries | Where-Object { $_.Name -match '\.(exe|dll|bat|cmd|ps1|vbs|js)$' }
            if ($binarios) { throw "$($a.name): o .zip tem executavel ($($binarios.Name -join ', ')). Abortado." }
        } finally { $arquivo.Dispose() }

        foreach ($pasta in $a.folders) {
            $destino = Join-Path $addonsDir $pasta
            if (Test-Path $destino) { Remove-Item $destino -Recurse -Force }
        }
        Expand-Archive $zip -DestinationPath $addonsDir -Force
        Write-Host 'ok'
    }
} finally {
    Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue
}

# Addons feitos neste repositorio: copiados direto da pasta addons-proprios.
$proprios = Join-Path $PSScriptRoot '..\addons-proprios'
Get-ChildItem $proprios -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $destino = Join-Path $addonsDir $_.Name
    if (Test-Path $destino) { Remove-Item $destino -Recurse -Force }
    Copy-Item $_.FullName $destino -Recurse
    Write-Host ("- {0} (proprio) ... ok" -f $_.Name)
}

Write-Host ''
Write-Host 'Pronto. Proximo passo: .\restaurar-config.ps1 (com o WoW fechado).'
