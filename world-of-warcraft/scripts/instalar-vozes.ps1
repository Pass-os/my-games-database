<#
.SYNOPSIS
    Deixa as vozes em portugues disponiveis para o TTS do WoW (QuestSpeaker).

.DESCRIPTION
    O WoW so lista vozes do SAPI classico (HKLM\SOFTWARE\Microsoft\Speech\Voices).
    Este script, nesta ordem:

    1. Registra a voz "Microsoft Daniel" (pt-BR, masculina) no SAPI. Ela vem com o
       pacote de fala pt-BR do Windows, mas so no OneCore, entao o WoW nao a via.
       A Maria (feminina) ja vem no SAPI.
    2. Instala o NaturalVoiceSAPIAdapter (github.com/gexgd0419/NaturalVoiceSAPIAdapter)
       so com as vozes ONLINE do Edge em pt-BR: Antonio, Francisca e Thalita
       (naturais, bem mais fluidas). Precisa de internet enquanto o jogo fala.
       As vozes LOCAIS do Narrador ficam DESLIGADAS de proposito: com elas o WoW
       trava (issues #37 e #116 do projeto).
    3. Testa cada voz gerando um audio num arquivo temporario.

    Pede permissao de administrador (janela do Windows) para os passos 1 e 2.

    No PC do trabalho (02/10/2026) as vozes do Edge aparecem mas nao falam
    ("Timer Expired" no log do adapter), provavelmente pela rede de la.

.PARAMETER Desinstalar
    Desfaz o passo 2 (remove o adapter e as opcoes dele). O Daniel continua.

.EXAMPLE
    .\instalar-vozes.ps1
.EXAMPLE
    .\instalar-vozes.ps1 -Desinstalar
#>
param([switch]$Desinstalar)

$ErrorActionPreference = 'Stop'

$versao     = 'v0.2.9'
$zipNome    = "NaturalVoiceSAPIAdapter_${versao}_x86_x64.zip"
$zipTamanho = 22844904
$zipUrl     = "https://github.com/gexgd0419/NaturalVoiceSAPIAdapter/releases/download/$versao/$zipNome"
$pasta      = Join-Path $env:LOCALAPPDATA 'Programs\NaturalVoiceSAPIAdapter'
$dll        = Join-Path $pasta 'x64\NaturalVoiceSAPIAdapter.dll'
$opcoes     = 'HKCU:\Software\NaturalVoiceSAPIAdapter\Enumerator'

function Invoke-ComoAdmin([string]$exe, [string]$argumentos) {
    $p = Start-Process $exe -ArgumentList $argumentos -Verb RunAs -Wait -PassThru
    if ($p.ExitCode -ne 0) { throw "$exe $argumentos terminou com codigo $($p.ExitCode)" }
}

function Get-VozesSapi {
    $v = New-Object -ComObject SAPI.SpVoice
    foreach ($t in $v.GetVoices()) { $t.GetDescription() }
}

if ($Desinstalar) {
    if (Test-Path $dll) {
        Invoke-ComoAdmin 'regsvr32.exe' "/u /s `"$dll`""
        Write-Host '- adapter desregistrado'
    }
    Remove-Item 'HKCU:\Software\NaturalVoiceSAPIAdapter' -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $pasta -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host '- opcoes e pasta do adapter removidas'
    Write-Host ''
    Write-Host 'Vozes disponiveis agora:'
    Get-VozesSapi | ForEach-Object { Write-Host "  $_" }
    return
}

# 1. Daniel no SAPI
$danielOneCore = 'HKLM:\SOFTWARE\Microsoft\Speech_OneCore\Voices\Tokens\MSTTS_V110_ptBR_DanielM'
$danielSapi    = 'HKLM:\SOFTWARE\Microsoft\Speech\Voices\Tokens\MSTTS_V110_ptBR_DanielM'
if (Test-Path $danielSapi) {
    Write-Host '- Daniel ja esta no SAPI'
} elseif (Test-Path $danielOneCore) {
    Invoke-ComoAdmin 'powershell.exe' "-NoProfile -Command Copy-Item '$danielOneCore' 'HKLM:\SOFTWARE\Microsoft\Speech\Voices\Tokens\' -Recurse -Force"
    Write-Host '- Daniel registrado no SAPI'
} else {
    Write-Warning 'Voz Daniel nao encontrada. Instale o pacote de fala: Configuracoes > Hora e idioma > Fala > Adicionar vozes > Portugues (Brasil). Depois rode de novo.'
}

# 2. NaturalVoiceSAPIAdapter, so vozes do Edge em pt-BR
if (-not (Test-Path $dll)) {
    $zip = Join-Path ([IO.Path]::GetTempPath()) $zipNome
    Write-Host "- baixando $zipNome ..."
    Invoke-WebRequest $zipUrl -OutFile $zip -UseBasicParsing
    if ((Get-Item $zip).Length -ne $zipTamanho) {
        throw "Baixou $((Get-Item $zip).Length) bytes, esperado $zipTamanho. Arquivo diferente do testado."
    }
    New-Item -ItemType Directory -Force $pasta | Out-Null
    Expand-Archive $zip $pasta -Force
    Remove-Item $zip -Force
}

New-Item -Path $opcoes -Force | Out-Null
$dwords = [ordered]@{
    NoNarratorVoices         = 1   # vozes locais do Narrador travam o WoW
    NoAzureVoices            = 1   # precisa de chave paga
    NoEdgeVoices             = 0
    EdgeVoiceAllLanguages    = 0
    EdgeVoiceAllMultilingual = 0
}
foreach ($n in $dwords.Keys) {
    New-ItemProperty -Path $opcoes -Name $n -Value $dwords[$n] -PropertyType DWord -Force | Out-Null
}
New-ItemProperty -Path $opcoes -Name EdgeVoiceLanguages -Value @('pt-BR') -PropertyType MultiString -Force | Out-Null

# A pasta precisa ficar onde esta: o registro aponta para a DLL dela.
Invoke-ComoAdmin 'regsvr32.exe' "/s `"$dll`""
Write-Host "- adapter $versao registrado (64 bits), so vozes do Edge em pt-BR"

# 3. Teste
Write-Host ''
Write-Host 'Teste de cada voz em portugues (gera audio num arquivo, sem tocar):'
$frase = 'Saudacoes, aventureiro. Tenho uma missao urgente para voce.'
foreach ($nome in (Get-VozesSapi | Where-Object { $_ -match 'Portug' })) {
    try {
        $v = New-Object -ComObject SAPI.SpVoice
        $v.Voice = $v.GetVoices() | Where-Object { $_.GetDescription() -eq $nome } | Select-Object -First 1
        $wav = Join-Path ([IO.Path]::GetTempPath()) 'teste-voz-wow.wav'
        $fs = New-Object -ComObject SAPI.SpFileStream
        $fs.Open($wav, 3)
        $v.AudioOutputStream = $fs
        [void]$v.Speak($frase)
        $fs.Close()
        $ok = (Get-Item $wav).Length -gt 10000
        Write-Host ("  {0,-4} {1}" -f ($(if ($ok) { 'ok' } else { 'MUDA' })), $nome)
        Remove-Item $wav -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "  FALHOU $nome :: $($_.Exception.Message)"
    }
}

Write-Host ''
Write-Host 'No WoW (o jogo precisa ser reaberto para ver as vozes novas):'
Write-Host '  1. Tela de personagens > AddOns: "Carregar addons desatualizados" (QuestSpeaker e do 12.0.7).'
Write-Host '  2. Opcoes > Acessibilidade > Assistencia de Audio: "Ler texto do chat em voz alta";'
Write-Host '     em "Configurar Conversao de Texto em Fala", desmarque todos os canais de chat.'
Write-Host '  3. /qs: voz feminina e masculina (so escolha Francisca/Antonio/Thalita se deram "ok" acima).'
Write-Host "Log do adapter: $env:LOCALAPPDATA\NaturalVoiceSAPIAdapter\log.txt"
