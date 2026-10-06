<#
.SYNOPSIS
    TESTE: vozes naturais pt-BR (Francisca, Antonio, Thalita) no WoW pelo
    NaturalVoiceSAPIAdapter, do jeito dos videos (instalador grafico).

.DESCRIPTION
    Em 02/10/2026 (WoW 12.1) NAO funcionou: a voz aparecia na lista do jogo,
    mas o WoW nunca carregou a DLL do adapter e ficava mudo (Maria e Daniel
    falavam). Na epoca a DLL foi registrada direto com regsvr32; este script
    usa o Installer.exe do projeto, como nos videos, para tirar essa duvida
    e para testar versoes novas do adapter ou do WoW.

    Passos:
    1. Baixa o adapter (versao -Versao) para %LOCALAPPDATA%\Programs\NaturalVoiceSAPIAdapter.
    2. Deixa as opcoes pre-marcadas: so vozes do Edge, so pt-BR, Narrador e
       Azure desligados (vozes locais do Narrador travam o WoW, issues #37/#116),
       log detalhado ligado.
    3. Abre o Installer.exe: clique em Install na linha 64-bit, confira que so
       "Edge" esta marcado e feche.
    4. Registra as tres vozes FIXAS no SAPI (o WoW ignora as vozes que o
       adapter cria "na hora") e desliga a lista dinamica para nao duplicar.
    5. Testa cada voz fora do jogo (mostra se a rede deixa as vozes do Edge
       falarem).

    Depois: abra o WoW, escolha Francisca no F1 > Narracao do Dialogue UI,
    fale com uma NPC, aperte R e, com o WoW AINDA ABERTO, rode
    .\testar-vozes-naturais.ps1 -Diagnostico

.PARAMETER Versao
    Tag do release do adapter. Padrao v0.2.9 (a testada em 02/10/2026).
    Para uma nova: veja github.com/gexgd0419/NaturalVoiceSAPIAdapter/releases.

.PARAMETER Diagnostico
    Com o WoW aberto: diz se o WoW carregou a DLL do adapter e mostra o fim do log.

.PARAMETER Desinstalar
    Remove o adapter, as vozes fixas, as opcoes e a pasta. Maria e Daniel ficam.

.EXAMPLE
    .\testar-vozes-naturais.ps1
.EXAMPLE
    .\testar-vozes-naturais.ps1 -Diagnostico
.EXAMPLE
    .\testar-vozes-naturais.ps1 -Desinstalar
#>
param(
    [string]$Versao = 'v0.2.9',
    [switch]$Diagnostico,
    [switch]$Desinstalar
)

$ErrorActionPreference = 'Stop'

$tamanhosConhecidos = @{ 'v0.2.9' = 22844904 }
$zipNome  = "NaturalVoiceSAPIAdapter_${Versao}_x86_x64.zip"
$zipUrl   = "https://github.com/gexgd0419/NaturalVoiceSAPIAdapter/releases/download/$Versao/$zipNome"
$pasta    = Join-Path $env:LOCALAPPDATA 'Programs\NaturalVoiceSAPIAdapter'
$dll      = Join-Path $pasta 'x64\NaturalVoiceSAPIAdapter.dll'
$config   = 'HKCU:\Software\NaturalVoiceSAPIAdapter'
$log      = Join-Path $env:LOCALAPPDATA 'NaturalVoiceSAPIAdapter\log.txt'
$tokens   = 'HKLM:\SOFTWARE\Microsoft\Speech\Voices\Tokens'
$clsid    = '{013AB33B-AD1A-401C-8BEE-F6E2B046A94E}'   # motor do adapter
# Mesmo endereco que o adapter v0.2.9 usa; {Sec-MS-GEC} ele calcula na hora.
$edgeUrl  = 'wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1?TrustedClientToken=6A5AA1D4EAFF4E9FB37E23D68491D6F4&Sec-MS-GEC={Sec-MS-GEC}&Sec-MS-GEC-Version=1-142.0.3595.94'
$vozes    = @(
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

function Show-Vozes {
    $v = New-Object -ComObject SAPI.SpVoice
    foreach ($t in $v.GetVoices()) { Write-Host "  $($t.GetDescription())" }
}

if ($Diagnostico) {
    $wow = Get-Process -Name 'Wow' -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $wow) { throw 'Abra o WoW, teste a Francisca (R num dialogo) e rode de novo com o jogo aberto.' }
    $carregada = $wow.Modules | Where-Object { $_.ModuleName -eq 'NaturalVoiceSAPIAdapter.dll' }
    if ($carregada) {
        Write-Host 'O WoW CARREGOU o adapter. Se ficou mudo, o problema e a rede (veja o log abaixo: "Timer Expired").'
    } else {
        Write-Host 'O WoW NAO carregou o adapter (mesmo resultado de 02/10/2026). Se testou com a Francisca, o jogo recusa a DLL.'
    }
    Write-Host ''
    Write-Host "Fim do log ($log):"
    if (Test-Path $log) { Get-Content $log -Tail 15 | ForEach-Object { Write-Host "  $_" } } else { Write-Host '  (sem log)' }
    return
}

if ($Desinstalar) {
    $admin = ($vozes | ForEach-Object { "Remove-Item '$tokens\Edge-$($_.Short)' -Recurse -Force -ErrorAction SilentlyContinue" }) -join "`n"
    if (Test-Path $dll) { $admin += "`n& regsvr32.exe /u /s '$dll'" }
    Invoke-ComoAdmin $admin
    Remove-Item $config -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\NaturalVoiceSAPIAdapter' -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $pasta -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item (Split-Path $log) -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host '- adapter, vozes do Edge, opcoes e pastas removidos'
    Write-Host ''
    Write-Host 'Vozes disponiveis agora:'
    Show-Vozes
    return
}

# 1. Download
if (-not (Test-Path $dll)) {
    $zip = Join-Path ([IO.Path]::GetTempPath()) $zipNome
    Write-Host "- baixando $zipNome ..."
    Invoke-WebRequest $zipUrl -OutFile $zip -UseBasicParsing
    $tamanho = (Get-Item $zip).Length
    if ($tamanhosConhecidos.ContainsKey($Versao)) {
        if ($tamanho -ne $tamanhosConhecidos[$Versao]) { throw "Baixou $tamanho bytes, esperado $($tamanhosConhecidos[$Versao])." }
    } else {
        Write-Warning "Versao $Versao nao conferida antes ($tamanho bytes). Confira o release no GitHub."
    }
    New-Item -ItemType Directory -Force $pasta | Out-Null
    Expand-Archive $zip $pasta -Force
    Remove-Item $zip -Force
}

# 2. Opcoes pre-marcadas (o instalador mostra o que estiver aqui)
New-Item -Path "$config\Enumerator" -Force | Out-Null
New-ItemProperty -Path $config -Name LogLevel -Value 0 -PropertyType DWord -Force | Out-Null
foreach ($o in ([ordered]@{ NoNarratorVoices = 1; NoAzureVoices = 1; NoEdgeVoices = 0; EdgeVoiceAllLanguages = 0; EdgeVoiceAllMultilingual = 0 }).GetEnumerator()) {
    New-ItemProperty -Path "$config\Enumerator" -Name $o.Key -Value $o.Value -PropertyType DWord -Force | Out-Null
}
New-ItemProperty -Path "$config\Enumerator" -Name EdgeVoiceLanguages -Value @('pt-BR') -PropertyType MultiString -Force | Out-Null

# 3. Instalador grafico (como nos videos)
Write-Host ''
Write-Host '- abrindo o instalador do adapter. Nele:'
Write-Host '    * clique em Install na linha 64-bit (o WoW e 64 bits; pede administrador);'
Write-Host '    * confira: Narrator DESMARCADO, Edge MARCADO, Azure desmarcado;'
Write-Host '    * feche a janela para continuar.'
Start-Process (Join-Path $pasta 'Installer.exe') -Wait

if (-not (Test-Path "Registry::HKEY_CLASSES_ROOT\CLSID\$clsid")) {
    throw 'O adapter nao ficou registrado (64-bit). Rode de novo e clique em Install na linha 64-bit.'
}
if ((Get-ItemProperty "$config\Enumerator").NoNarratorVoices -ne 1) {
    Write-Warning 'As vozes locais do Narrador ficaram MARCADAS no instalador: elas travam o WoW. Desligando.'
}

# 4. Vozes fixas para o WoW enxergar + lista dinamica desligada (senao duplica)
foreach ($o in ([ordered]@{ NoNarratorVoices = 1; NoAzureVoices = 1; NoEdgeVoices = 1 }).GetEnumerator()) {
    New-ItemProperty -Path "$config\Enumerator" -Name $o.Key -Value $o.Value -PropertyType DWord -Force | Out-Null
}
$admin = @()
foreach ($v in $vozes) {
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
Write-Host '- Francisca, Antonio e Thalita registradas fixas'

# 5. Teste fora do jogo
Write-Host ''
Write-Host 'Teste fora do jogo (gera audio num arquivo, sem tocar):'
foreach ($v in $vozes) {
    try {
        $sp = New-Object -ComObject SAPI.SpVoice
        $sp.Voice = $sp.GetVoices() | Where-Object { $_.GetDescription() -like "$($v.Nome)*" } | Select-Object -First 1
        $wav = Join-Path ([IO.Path]::GetTempPath()) 'teste-voz-natural.wav'
        $fs = New-Object -ComObject SAPI.SpFileStream
        $fs.Open($wav, 3)
        $sp.AudioOutputStream = $fs
        [void]$sp.Speak('Saudacoes, aventureiro.')
        $fs.Close()
        Write-Host ("  {0,-4} {1}" -f ($(if ((Get-Item $wav).Length -gt 10000) { 'ok' } else { 'MUDA' })), $v.Nome)
        Remove-Item $wav -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "  FALHOU $($v.Nome) :: $($_.Exception.Message)  (rede?)"
    }
}

Write-Host ''
Write-Host 'Agora: abra o WoW, F1 > Narracao do Dialogue UI, escolha a Francisca, fale com uma NPC e aperte R.'
Write-Host 'Com o WoW ainda aberto: .\testar-vozes-naturais.ps1 -Diagnostico'
Write-Host 'Para desfazer:          .\testar-vozes-naturais.ps1 -Desinstalar'
