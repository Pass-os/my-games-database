# CLAUDE.md

Monorepo de mods de jogos. **Uma pasta por jogo**, cada uma autocontida.

## Valheim (`valheim/`)

Leia `valheim/README.md` e `valheim/docs/setup.md` antes de mexer no build.

### Fatos verificados na maquina (set/2026)

- Jogo: `G:\SteamLibrary\steamapps\common\Valheim` — **mudou** de
  `C:\Program Files (x86)\Steam\...` (era o valor ate ago/2026). A deteccao
  automatica do `Directory.Build.props` nao cobre `G:`, entao esta maquina
  **depende** do `Environment.props` para achar o jogo.
- Unity **6000.0.61f1** (Unity 6), backend **Mono** — nao IL2CPP
- Perfil .NET do jogo e .NET Framework 4.x (`mscorlib 4.6.57`), portanto os
  plugins compilam em **`net472`**. Nunca use `net8.0`+ aqui.
- BepInEx **5.4.23.3** (nao 6.x), instalado pelo Thunderstore Mod Manager, nao
  na pasta do jogo
- Perfis existentes no mod manager: `Default`, `CO-OP`, `SINGLEPLAYER`.
  Apenas `CO-OP` e `SINGLEPLAYER` tem o ConfigurationManager (F1 no jogo).
- Deploy de teste (via `Environment.props`): perfil **`CO-OP`** —
  `%APPDATA%\Thunderstore Mod Manager\DataFolder\Valheim\profiles\CO-OP\BepInEx\plugins`

### Comandos

```powershell
cd valheim
dotnet build -c Debug     # compila + copia pro perfil do mod manager
dotnet build -c Release   # compila + gera dist/<Mod>-<versao>.zip
```

### Convencoes do build

- `Directory.Build.props` centraliza TFM, deteccao do jogo e pasta de deploy.
  `Environment.props` (gitignored) sobrescreve por maquina.
- Publicizacao e automatica via `BepInEx.AssemblyPublicizer.MSBuild`
  (`Publicize="true"` nas refs). **Nao** gere nem versione
  `publicized_assemblies/` — sao codigo do jogo.
- Refs de DLL do jogo sempre com `Private="false"` (nao copiar pro output).
- A classe de metadados gerada chama-se **`MyPluginInfo`**, nao `PluginInfo`
  (`PluginInfo` colide com `BepInEx.PluginInfo`).
- `NuGet.config` inclui o feed `https://nuget.bepinex.dev/v3/index.json` —
  `BepInEx.Core` nao esta no nuget.org.
- Nao defina `AssemblySearchPaths` no `Directory.Build.props`: ele sobrescreve
  os defaults do SDK (incluindo `{HintPathFromItem}`) e quebra a resolucao dos
  pacotes NuGet.

### Ao escrever patches

- Prefira `[HarmonyPostfix]`. `Prefix` com `return false` cancela o metodo para
  todos os mods e e a maior fonte de incompatibilidade.
- Verifique a assinatura do metodo contra a build atual antes de patchear
  (dnSpy/ILSpy, ou o dump por PowerShell em `docs/harmony.md`).
- Em multiplayer, cheque posse antes de alterar estado persistente:
  `if (!__instance.m_nview.IsOwner()) return;`
- Mudou regra de jogo + servidor dedicado? Precisa de ServerSync
  (`docs/serversync.md`).

### Ao adicionar conteudo (itens/pecas)

- Jotunn (`<UseJotunn>true</UseJotunn>`) para conteudo variado; Managers
  (arquivos `.cs` copiados) para mods enxutos sem dependencia. Ver
  `docs/conteudo.md`.
- AssetBundles precisam ser construidos na **mesma versao da Unity do jogo**.

## World of Warcraft (`world-of-warcraft/`)

Nao e mod: lista de addons (`addons.json`), scripts PowerShell e a
configuracao salva (SavedVariables + macros). Leia `world-of-warcraft/README.md`.

### Fatos verificados na maquina (set/2026)

- Jogo: `X:\Battle.net\World of Warcraft\_retail_`, Retail 12.1.0 (interface
  `120100`), cliente `ptBR`.
- Uma conta em `WTF\Account`. O numero dela **nao** vai para o repo (publico).

### Ao mexer

- SavedVariables e macros so podem ser editados com o **WoW fechado**: o jogo
  regrava tudo ao sair. Antes de editar, leia o arquivo atual e preserve o
  que o usuario configurou pela interface.
- Addon novo: conferir no `.toc` a linha `## Interface` (tem que incluir a
  versao atual) e `## Dependencies`/`RequiredDeps` antes de por no `addons.json`.
- Scripts do DynamicCam rodam em ambiente isolado: global so com `getfenv(0)`.
- Nome de janela da Blizzard: conferir no codigo da versao atual
  (github.com/Gethe/wow-ui-source, branch `live` = build do Retail). Nomes
  mudam entre expansoes (ex.: WardrobeFrame -> TransmogFrame).
- Situacao custom do DynamicCam escrita no arquivo: sempre com todos os
  campos (transitionTime, delay, hideUI, situationSettings.cvars...). Sem
  valores de fabrica, campo faltando = erro de Lua no jogo.

