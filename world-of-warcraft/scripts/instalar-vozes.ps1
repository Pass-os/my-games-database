<#
.SYNOPSIS
    Deixa as vozes em portugues disponiveis para o TTS do WoW (narracao do Dialogue UI).

.DESCRIPTION
    O WoW so lista vozes registradas fixas no SAPI classico
    (HKLM\SOFTWARE\Microsoft\Speech\Voices\Tokens). O pacote de fala pt-BR do
    Windows traz a Maria (feminina) ja no SAPI, mas o Daniel (masculina) so no
    OneCore. Este script copia o Daniel para o SAPI e testa as vozes.

    Pede permissao de administrador (janela do Windows) uma vez.

    Vozes naturais (Francisca, Antonio, Thalita) NAO funcionam no WoW: elas
    precisam do NaturalVoiceSAPIAdapter, e o WoW 12.1 nao carrega a DLL dele
    (testado em 02/10/2026: a voz aparece na lista, mas o jogo nunca abre o
    motor e fica mudo; Maria e Daniel no mesmo teste falaram).

.EXAMPLE
    .\instalar-vozes.ps1
#>
$ErrorActionPreference = 'Stop'

$tokens        = 'HKLM:\SOFTWARE\Microsoft\Speech\Voices\Tokens'
$danielOneCore = 'HKLM:\SOFTWARE\Microsoft\Speech_OneCore\Voices\Tokens\MSTTS_V110_ptBR_DanielM'

if (Test-Path "$tokens\MSTTS_V110_ptBR_DanielM") {
    Write-Host '- Daniel ja esta no SAPI'
} elseif (Test-Path $danielOneCore) {
    $cmd = "Copy-Item '$danielOneCore' '$tokens\' -Recurse -Force"
    $p = Start-Process powershell.exe -ArgumentList '-NoProfile', '-Command', $cmd -Verb RunAs -Wait -PassThru
    if ($p.ExitCode -ne 0) { throw "Copia do Daniel terminou com codigo $($p.ExitCode)" }
    Write-Host '- Daniel registrado no SAPI'
} else {
    Write-Warning 'Voz Daniel nao encontrada. Instale o pacote de fala: Configuracoes > Hora e idioma > Fala > Adicionar vozes > Portugues (Brasil). Depois rode de novo.'
}

Write-Host ''
Write-Host 'Teste de cada voz em portugues (gera audio num arquivo, sem tocar):'
$v = New-Object -ComObject SAPI.SpVoice
foreach ($token in $v.GetVoices()) {
    $nome = $token.GetDescription()
    if ($nome -notmatch 'Portug') { continue }
    try {
        $v.Voice = $token
        $wav = Join-Path ([IO.Path]::GetTempPath()) 'teste-voz-wow.wav'
        $fs = New-Object -ComObject SAPI.SpFileStream
        $fs.Open($wav, 3)
        $v.AudioOutputStream = $fs
        [void]$v.Speak('Saudacoes, aventureiro.')
        $fs.Close()
        Write-Host ("  {0,-4} {1}" -f ($(if ((Get-Item $wav).Length -gt 10000) { 'ok' } else { 'MUDA' })), $nome)
        Remove-Item $wav -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Host "  FALHOU $nome :: $($_.Exception.Message)"
    }
}

Write-Host ''
Write-Host 'No WoW (reabra o jogo para ver o Daniel):'
Write-Host '  1. Opcoes > Acessibilidade > Assistencia de Audio: "Ler texto do chat em voz alta";'
Write-Host '     em "Configurar Conversao de Texto em Fala", desmarque todos os canais de chat.'
Write-Host '  2. Num dialogo, F1 > Narracao: Maria (feminina) e Daniel (masculina).'
