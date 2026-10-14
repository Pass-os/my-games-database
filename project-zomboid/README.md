# Project Zomboid

Mods e engenharia reversa do Project Zomboid (Build 42).

| Camada | Onde fica no jogo | Como mexer |
| --- | --- | --- |
| Gameplay, UI, receitas, itens, sandbox | `media/lua`, `media/scripts` (texto) | Mod Lua normal, em [`mods/`](mods/) |
| Engine (Java) | `projectzomboid.jar` | Decompilar (Vineflower/JADX) e patchear via ZombieBuddy |
| Nativo (pathfinding, populacao, fisica) | `PZPathFind64.dll`, `PZPopMan64.dll`, `PZBullet64.dll` | REA + Ghidra, so para entender; o Java controla tudo |

Leia [`docs/plano.md`](docs/plano.md) (etapas e status),
[`docs/setup.md`](docs/setup.md) (caminhos, versoes, ambiente de dev) e
[`docs/engenharia-reversa.md`](docs/engenharia-reversa.md) (REA/Ghidra).

## Layout

```
project-zomboid/
  mods/<ModId>/          um mod por pasta, no formato B42 (42/ + common/)
  scripts/setup-dev.ps1  baixa as tipagens Umbrella para re/umbrella
  scripts/deploy.ps1     copia um mod do repo para %USERPROFILE%\Zomboid\mods
  scripts/log.ps1        console.txt ao vivo, so erros e print() de mod
  .emmyrc.json           autocomplete Lua (VS Code + EmmyLua) — abra esta pasta
  docs/                  plano, setup, engenharia reversa, achados
  re/                    (gitignored) Umbrella, snapshots do REA, codigo decompilado
```

`re/` nunca vai pro git: e codigo do jogo.

## Mods

| Mod | O que faz |
| --- | --- |
| [`NoHouseAlarms`](mods/NoHouseAlarms/) | Forca sandbox: alarmes Never, zumbi nao dispara alarme, sem respawn, redistribuicao 168h, pico 1.0x |

## Deploy

```powershell
.\scripts\deploy.ps1 NoHouseAlarms
```

Mods Lua sao lidos ao carregar o save: com o jogo aberto, volte ao menu e
recarregue.
