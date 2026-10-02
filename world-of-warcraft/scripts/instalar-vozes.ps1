<#
.SYNOPSIS
    Deixa as vozes em portugues disponiveis para o TTS do WoW (narracao do Dialogue UI).

.DESCRIPTION
    O WoW so lista vozes registradas fixas no SAPI classico
    (HKLM\SOFTWARE\Microsoft\Speech\Voices\Tokens). Vozes que um programa cria
    "na hora" (TokenEnums) aparecem no Windows mas NAO no WoW. Este script:

    1. Registra a voz "Microsoft Daniel" (pt-BR, masculina) no SAPI. Ela vem com
       o pacote de fala pt-BR do Windows, mas so no OneCore. A Maria ja vem no SAPI.
    2. Instala o NaturalVoiceSAPIAdapter (github.com/gexgd0419/NaturalVoiceSAPIAdapter)
       e registra FIXAS as vozes ONLINE do Edge em pt-BR: Francisca, Antonio e
       Thalita (naturais, bem mais fluidas). Precisam de internet enquanto o jogo
       fala. A lista dinamica do adapter fica desligada (senao as vozes aparecem
       duplicadas) e as vozes LOCAIS do Narrador tambem: com elas o WoW trava
       (issues #37 e #116 do projeto).
    3. Testa cada voz gerando um audio num arquivo temporario.

    Tudo que precisa de administrador vai numa janela de permissao so.

    No PC do trabalho (02/10/2026) as vozes do Edge aparecem mas nao falam
    ("Timer Expired" no log do adapter), provavelmente pela rede de la.

.PARAMETER Desinstalar
    Desfaz o passo 2 (adapter, vozes do Edge e opcoes). O Daniel continua.

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
$tokens     = 'HKLM:\SOFTWARE\Microsoft\Speech\Voices\Tokens'
$clsid      = '{013AB33B-AD1A-401C-8BEE-F6E2B046A94E}'   # motor do adapter
# Mesmo endereco que o adapter usa; {Sec-MS-GEC} ele calcula na hora.
$edgeUrl    = 'wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1?TrustedClientToken=6A5AA1D4EAFF4E9FB37E23D68491D6F4&Sec-MS-GEC={Sec-MS-GEC}&Sec-MS-GEC-Version=1-142.0.3595.94'
$vozesEdge  = @(
    @{ Short = 'pt-BR-FranciscaNeural';           Nome = 'Microsoft Francisca Online (Natural)';          Genero = 'Female' }
    @{ Short = 'pt-BR-AntonioNeural';             Nome = 'Microsoft Antonio Online (Natural)';            Genero = 'Male' }
    @{ Short = 'pt-BR-ThalitaMultilingualNeural'; Nome = 'Microsoft ThalitaMultilingual Online (Natural)'; Genero = 'Female' }
)

function Invoke-ComoAdmin([string]$script) {
    $arquivo = Join-Path ([IO.Path]::GetTempPath()) "vozes-admin-$(Get-Random).ps1"
    Set-Content $arquivo ("`$ErrorActionPreference = 'Stop'`n" + $script) -Encoding UTF8
    try {
        $p = Start-Process powershell.exe -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$arquivo`"" -Verb RunAs -Wait -PassThru
        if ($p.ExitCode -ne 0) { throw "a parte de administrador terminou com codigo $($p.ExitCode)" }
    } finally { Remove-Item $arquivo -Force -ErrorAction SilentlyContinue }
}

function Get-VozesSapi {
    $v = New-Object -ComObject SAPI.SpVoice
    foreach ($t in $v.GetVoices()) { $t.GetDescription() }
}

if ($Desinstalar) {
    $admin = ($vozesEdge | ForEach-Object { "Remove-Item '$tokens\Edge-$($_.Short)' -Recurse -Force -ErrorAction SilentlyContinue" }) -join "`n"
    if (Test-Path $dll) { $admin += "`n& regsvr32.exe /u /s '$dll'" }
    Invoke-ComoAdmin $admin
    Remove-Item 'HKCU:\Software\NaturalVoiceSAPIAdapter' -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $pasta -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host '- vozes do Edge, adapter, opcoes e pasta removidos'
    Write-Host ''
    Write-Host 'Vozes disponiveis agora:'
    Get-VozesSapi | ForEach-Object { Write-Host "  $_" }
    return
}

$admin = @()

# 1. Daniel no SAPI
$danielOneCore = 'HKLM:\SOFTWARE\Microsoft\Speech_OneCore\Voices\Tokens\MSTTS_V110_ptBR_DanielM'
if (Test-Path "$tokens\MSTTS_V110_ptBR_DanielM") {
    Write-Host '- Daniel ja esta no SAPI'
} elseif (Test-Path $danielOneCore) {
    $admin += "Copy-Item '$danielOneCore' '$tokens\' -Recurse -Force"
} else {
    Write-Warning 'Voz Daniel nao encontrada. Instale o pacote de fala: Configuracoes > Hora e idioma > Fala > Adicionar vozes > Portugues (Brasil). Depois rode de novo.'
}

# 2. Adapter + vozes do Edge registradas fixas
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
    NoNarratorVoices = 1   # vozes locais do Narrador travam o WoW
    NoAzureVoices    = 1   # precisa de chave paga
    NoEdgeVoices     = 1   # lista dinamica desligada: as vozes vao fixas abaixo
}
foreach ($n in $dwords.Keys) {
    New-ItemProperty -Path $opcoes -Name $n -Value $dwords[$n] -PropertyType DWord -Force | Out-Null
}

# A pasta precisa ficar onde esta: o registro aponta para a DLL dela.
$admin += "& regsvr32.exe /s '$dll'; if (`$LASTEXITCODE) { exit `$LASTEXITCODE }"
foreach ($v in $vozesEdge) {
    $k = "$tokens\Edge-$($v.Short)"
    $admin += @"
New-Item -Path '$k\Attributes' -Force | Out-Null
New-Item -Path '$k\NaturalVoiceConfig' -Force | Out-Null
Set-ItemProperty '$k' -Name '(default)' -Value '$($v.Nome) - Portuguese (Brazil)'
Set-ItemProperty '$k' -Name 'CLSID' -Value '$clsid'
Set-ItemProperty '$k\Attributes' -Name 'Name' -Value '$($v.Nome)'
Set-ItemProperty '$k\Attributes' -Name 'Gender' -Value '$($v.Genero)'
Set-ItemProperty '$k\Attributes' -Name 'Age' -Value 'Adult'
Set-ItemProperty '$k\Attributes' -Name 'Language' -Value '416'
Set-ItemProperty '$k\Attributes' -Name 'Locale' -Value 'pt-BR'
Set-ItemProperty '$k\Attributes' -Name 'Vendor' -Value 'Microsoft'
Set-ItemProperty '$k\Attributes' -Name 'NaturalVoiceType' -Value 'Edge;Cloud'
Set-ItemProperty '$k\NaturalVoiceConfig' -Name 'WebsocketURL' -Value '$edgeUrl'
Set-ItemProperty '$k\NaturalVoiceConfig' -Name 'Voice' -Value '$($v.Short)'
New-ItemProperty '$k\NaturalVoiceConfig' -Name 'IsEdgeVoice' -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty '$k\NaturalVoiceConfig' -Name 'ErrorMode' -Value 0 -PropertyType DWord -Force | Out-Null
"@
}

Invoke-ComoAdmin ($admin -join "`n")
Write-Host "- Daniel e vozes do Edge (Francisca, Antonio, Thalita) registrados; adapter $versao (64 bits)"

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
Write-Host 'No WoW (reabra o jogo para ver as vozes novas):'
Write-Host '  1. Opcoes > Acessibilidade > Assistencia de Audio: "Ler texto do chat em voz alta";'
Write-Host '     em "Configurar Conversao de Texto em Fala", desmarque todos os canais de chat.'
Write-Host '  2. Num dialogo, F1 > Narracao: escolha as vozes (so Francisca/Antonio/Thalita se deram "ok" acima).'
Write-Host "Log do adapter: $env:LOCALAPPDATA\NaturalVoiceSAPIAdapter\log.txt"
