# Setup (fatos verificados na maquina, out/2026)

## Jogo

- Pasta: `G:\SteamLibrary\steamapps\common\ProjectZomboid` (app Steam 108600)
- Versao: **42.21.0** (revision `4a0e9546ec`, Steam buildid `25485521`) —
  ver `%USERPROFILE%\Zomboid\version.txt`
- Java: JRE **Zulu 25.0.1** embutido em `jre64\` (so runtime, sem `javac`)
- Main class: `zombie/gameStates/MainScreenState`, classpath `projectzomboid.jar`
- Lua do jogo: `media\lua\{client,server,shared}` (~1400 arquivos)

## Pasta do usuario

- `%USERPROFILE%\Zomboid\mods\` — mods locais (onde o `deploy.ps1` copia)
- `%USERPROFILE%\Zomboid\Workshop\` — projetos para publicar no Workshop
  (`ModTemplate` e o exemplo do jogo)
- `%USERPROFILE%\Zomboid\console.txt` — log da ultima sessao (erros Lua aparecem aqui)
- Mods do Workshop instalados: `G:\SteamLibrary\steamapps\workshop\content\108600\`

## Launch config ja alterado (nao e padrao)

`ProjectZomboid64.json` e `ProjectZomboid64.bat` foram editados para o
**ZombieBuddy** (framework de mods Java, Workshop): `-agentlib:zbNative` e
`-Xmx8192m`. Os originais estao nos `.bak` ao lado. Uma verificacao de
arquivos da Steam desfaz isso.

- ZombieBuddy **2.3.4** (`ZombieBuddy.jar` na pasta do jogo, ByteBuddy por baixo)

## Ambiente de desenvolvimento Lua

1. `.\scripts\setup-dev.ps1` — baixa as tipagens **Umbrella** da versao do jogo
   (le `version.txt`) para `re\umbrella`. Rodar de novo apos update do jogo.
2. VS Code com a extensao **EmmyLua** (`tangzx.emmylua`) — ja instalada. Abra a
   pasta `project-zomboid` (nao a raiz do repo): o `.emmyrc.json` daqui aponta a
   library para `${workspaceFolder}/re/umbrella/library`, runtime Lua 5.1 (Kahlua).
   Verificado: hover em `getSandboxOptions()` mostra `-> SandboxOptions` e
   `Events.*` traz a doc de cada evento.
3. `.\scripts\log.ps1` — acompanha o `console.txt` ao vivo, so erros e `print()`
   de mod. `-Mod <Nome>` filtra um mod; `-Ignorar 'Read While Walking'` esconde
   um mod barulhento (hoje ele gera ~5000 linhas de erro por sessao).
   `print("[MeuMod] ...")` aparece no console como
   `LOG  : Lua  f:123> :<tab>[MeuMod] ...`.

### Modo debug do jogo

- Steam → Project Zomboid → Propriedades → Opcoes de inicializacao: `-debug`
- No jogo: **F11** abre o debugger Lua, **`** (crase) abre o console Lua
- Arquivo Lua alterado: `reloadLuaFile("media/lua/...")` no console, ou pelo
  navegador de arquivos do debugger. Scripts de item/receita (`media/scripts`)
  e `mod.info` so recarregam reiniciando o jogo.

## Formato de mod B42

```
<ModId>/
  42/
    mod.info             name=, id=, description=, versionMin=42.0.0
    media/lua/{client,server,shared}/...
  common/                obrigatoria, mesmo vazia
```
