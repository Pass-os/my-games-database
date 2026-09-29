# Funcoes compartilhadas pelos scripts do World of Warcraft.
# Carregado com:  . "$PSScriptRoot\wow-comum.ps1"

$ErrorActionPreference = 'Stop'

# Addons cuja configuracao (SavedVariables) e versionada neste repositorio.
# O nome e o do arquivo em WTF\Account\<conta>\SavedVariables\<nome>.lua
$SavedVariablesVersionados = @(
    'DynamicCam'
    'Immersion'
    'Leatrix_Plus'
    'HandyNotes'
    'MapPinEnhanced'
    'BetterMacroIcons'
    'MacroToolkit'
    'BtWQuests'
    'Narcissus'
    'BetterWardrobe'
    'CanIMogIt'
    'BarberShopProfiles'
)

function Get-WowRetailPath {
    param([string]$WowPath)

    if ($WowPath) {
        $retail = if ((Split-Path $WowPath -Leaf) -eq '_retail_') { $WowPath } else { Join-Path $WowPath '_retail_' }
        if (-not (Test-Path (Join-Path $retail 'Wow.exe'))) {
            throw "Nao achei Wow.exe em '$retail'. Passe -WowPath com a pasta do World of Warcraft."
        }
        return $retail
    }

    # Mesma fonte que o Battle.net usa: a entrada de desinstalacao do jogo.
    $chaves = @(
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $entrada = Get-ItemProperty $chaves -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -eq 'World of Warcraft' -and $_.InstallLocation } |
        Select-Object -First 1

    if (-not $entrada) {
        throw 'World of Warcraft nao encontrado no registro. Passe -WowPath "X:\caminho\World of Warcraft".'
    }

    $retail = Join-Path $entrada.InstallLocation '_retail_'
    if (-not (Test-Path (Join-Path $retail 'Wow.exe'))) {
        throw "O registro aponta para '$($entrada.InstallLocation)', mas nao ha _retail_\Wow.exe la. Passe -WowPath."
    }
    return $retail
}

function Assert-WowFechado {
    if (Get-Process -Name 'Wow' -ErrorAction SilentlyContinue) {
        throw 'Feche o World of Warcraft antes. O jogo regrava SavedVariables e macros ao sair e desfaria o que este script fizer.'
    }
}

function Get-WowAccountDirs {
    param([string]$Retail)

    $raiz = Join-Path $Retail 'WTF\Account'
    if (-not (Test-Path $raiz)) { return @() }
    # Pastas de conta tem o formato <numero>#<n>. "SavedVariables" na raiz de Account nao e conta.
    Get-ChildItem $raiz -Directory | Where-Object { $_.Name -match '^\d+#\d+$' }
}
