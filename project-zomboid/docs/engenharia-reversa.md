# Engenharia reversa

## Ferramentas instaladas (14/out/2026)

| Ferramenta | Onde | Notas |
| --- | --- | --- |
| REA 6.4.0 | `npm -g rea-agents` | MCP `rea` no Claude Code (`~/.claude.json`) + CLI `rea` |
| Ghidra 12.1.4 | `G:\Program\ghidra_12.1.4_PUBLIC` | variavel de usuario `GHIDRA_INSTALL_DIR` |
| JDK 21 (Microsoft) | `G:\Program\jdk-21.0.12.1+1` | `JAVA_HOME` + `bin` no PATH do usuario |

O registro MCP do REA ja leva `GHIDRA_INSTALL_DIR` e `JAVA_HOME` no `env`.
Diagnostico: `rea doctor --provider ghidra`.

O REA **nao** le `.jar`/Java. Para o `projectzomboid.jar`, use um
decompilador Java (Vineflower ou JADX) com saida em `re/java/`.

## Uso pela CLI

```powershell
$dll = "G:\SteamLibrary\steamapps\common\ProjectZomboid\PZPopMan64.dll"
$snap = "re\snapshots\PZPopMan64.rea-snapshot"
rea analyze $dll --provider ghidra --snapshot $snap --format md
rea search  $dll "Java_" --kind procedures --snapshot $snap
```

A primeira analise leva ~1 min; o snapshot evita refazer.

## Achados

### PZPopMan64.dll (populacao de zumbis + colisao do mapa)

- 4406 procedures, 931 strings, x86_64
- 59 exports JNI, todos chamados do Java:
  - `zombie.popman.ZombiePopulationManager` — `n_init`, `n_config`,
    `n_configInt`, `n_configFloat`, `n_spawnHorde`, `n_worldSound`,
    `n_aggroTarget`, `n_addZombie`, `n_updateMain`, `n_updateThread`...
  - `zombie.MapCollisionData` — `n_init`, `n_pathTask`, `n_chunkUpdateTask`,
    `n_setGameState`...
  - `zombie.popman.ZombiePopulationRenderer`, `MPDebugInfo`, `DebugCommands`
- Conclusao: os parametros de populacao (respawn, redistribuicao, pico) entram
  pelo Java via `n_config*`. Para mudar comportamento, patchear o lado Java
  (`ZombiePopulationManager`) ou usar as opcoes de sandbox em Lua — mexer na
  DLL so se a logica que voce quer for interna ao nativo.

## Download lento do GitHub

Releases do GitHub saem a ~75 KB/s por conexao nesta rede (o resto a ~78 MB/s).
Baixe com ranges paralelos ou prefira CDN (ex.: JDK em `aka.ms/download-jdk`).
