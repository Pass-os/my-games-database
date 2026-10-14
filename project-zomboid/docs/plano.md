# Plano macro — modding do Project Zomboid (B42.21)

| Etapa | Status |
| --- | --- |
| 1. Ambiente Lua | **feita** (14/out/2026) — Umbrella + EmmyLua verificados por LSP, `log.ps1` |
| 2. Referencia do codigo (decompilar) | proxima |
| 3. Padronizar mods Lua | pendente |
| 4. Primeiro mod Java | pendente |
| 5. Primeiro mod de verdade | pendente (usuario escolhe) |
| 6. Workshop | opcional |

## Contexto

O objetivo é modificar o Project Zomboid. As ferramentas já estão prontas: REA, Ghidra 12.1.4, JDK 21 e a pasta
`my-game-mods/project-zomboid` (branch `project-zomboid`, já no GitHub, repo público). O usuário quer avançar
por etapas, sem fazer tudo de uma vez, e me deixou decidir. A pesquisa mostrou o seguinte:

- O jogo tem 3 camadas: **Lua** (gameplay e UI, texto puro em `media/lua`), **Java**
  (`projectzomboid.jar`, Java 25, *sem* ofuscação, ~26 mil classes) e **nativo** (`PZPopMan64.dll` e outras,
  chamadas pelo Java via JNI).
- Para mexer no Java em 2026, a única opção viva é o **ZombieBuddy 2.3.4** (patches ByteBuddy com
  `@Patch` e `Exposer` para Lua). Já está instalado. O **Viewpoint** (Workshop 3809306528) é um mod Java
  funcionando que serve de modelo. Storm e pz-zdoc estão mortos. Substituir `.class` soltos na pasta
  viola o §3.1 dos termos de uso.
- Termos de uso: mods são permitidos, mas não se pode redistribuir o jar nem código decompilado, nem
  vender mods. Por isso `re/` continua fora do git.

**Decisões que tomei:**
1. Lua primeiro e Java depois. Lua cobre ~80% do que se quer num mod e tem o ciclo mais rápido.
2. Java só via ZombieBuddy, nunca substituindo arquivos do jogo.
3. Decompilar com o **Vineflower** (roda no JDK 21 que já está instalado) e só o pacote `zombie/**`.
4. Para *compilar* mods Java, instalar o **JDK 25** (Microsoft, via aka.ms). O javac 21 não lê classes
   versão 69. Um script `build.ps1` simples, sem Gradle.
5. O REA/Ghidra fica para dúvidas pontuais sobre o nativo. A pesquisa mostrou que quem manda é o Java.
6. Cada etapa termina com um commit na branch `project-zomboid` e pode ser feita numa sessão separada.

---

## Etapa 1 — Ambiente de desenvolvimento Lua
- `project-zomboid/.luarc.json` + tipagens **Umbrella** (PZ-Umbrella/Umbrella), apontando `Lua.workspace.library`
  para `media/lua` do jogo, para ter autocomplete no VS Code. As tipagens baixadas ficam em `re/` (gitignored).
- `scripts/log.ps1`: acompanha o `%USERPROFILE%\Zomboid\console.txt` filtrando `ERROR|MOD:|STACK`, e opcionalmente
  só um mod.
- Documentar em `docs/setup.md`: modo `-debug` (opção de inicialização na Steam, o usuário liga), F11 = debugger Lua,
  backtick = console, `reloadLuaFile`. Mudanças em scripts de item ou receita exigem reiniciar o jogo.
- Observação: o console tem ~1900 erros do mod "Read While Walking" que poluem o log. Sugerir desativar enquanto
  desenvolvemos.
- **Pronto quando:** autocomplete de `getPlayer()` e `Events.` funcionando no VS Code, e o `log.ps1` mostrando erros.

## Etapa 2 — Referência do código do jogo
- `scripts/decompile.ps1`: baixa o Vineflower 1.12 (com verificação de hash) para `re/tools/` e decompila só
  `zombie/**` do `projectzomboid.jar` para `re/java/` (`-Xmx4g`). Se o `--only` não funcionar, filtra o jar antes.
- `docs/mapa-do-jogo.md`: um índice curto de onde fica cada coisa (populacao → `zombie.popman.ZombiePopulationManager`,
  sandbox → `zombie.SandboxOptions`, Lua ↔ Java → `zombie.Lua.LuaManager$Exposer`, menus de contexto → `ISWorldObjectContextMenu`...),
  preenchido conforme formos descobrindo.
- **Pronto quando:** `re/java/zombie/popman/ZombiePopulationManager.java` existe e é legível, com as chamadas `n_config*`
  visíveis. Isso fecha o achado do REA.

## Etapa 3 — Padronizar mods Lua
- `scripts/new-mod.ps1 <ModId>`: gera o esqueleto B42 (`42/mod.info` com `versionMin=42.21.0`, `common/`,
  `media/lua/{client,server,shared}`, `common/media/lua/shared/Translate/{EN,PTBR}/*.json`, `sandbox-options.txt` opcional).
- Ajustar o **NoHouseAlarms** para servir de mod de referência:
  - descrição honesta (ele também mexe em respawn e redistribuição);
  - os valores saem de `sandbox-options.txt` (`SandboxVars.NoHouseAlarms.*`) em vez de fixos no código;
  - tradução EN + PT-BR;
  - testar em save novo e num save existente.
- **Pronto quando:** `deploy.ps1 NoHouseAlarms`, o jogo carrega sem erro no `log.ps1`, e as opções aparecem na tela de sandbox.

## Etapa 4 — Primeiro mod Java (ZombieBuddy)
- Instalar o JDK 25 (Microsoft) em `G:\Program`, com verificação do SHA-256.
- `project-zomboid/java/<Mod>/` + `scripts/build-java.ps1`: javac com `projectzomboid.jar` e `ZombieBuddy.jar` no
  classpath (só para compilar, sem empacotar), e jar em `mods/<Mod>/42/media/java/<Mod>.jar`.
  A estrutura copia a do Viewpoint e do `doc/ModdingGuide.md` do ZombieBuddy (`require=\ZombieBuddy`, `javaJarFile`, `javaPkgName`).
- Mod "hello": um `@Patch` em `ZombiePopulationManager` que só registra no log, mais uma função Java exposta ao Lua via `@Exposer.LuaClass`
  e chamada de um `.lua`.
- O ZombieBuddy vai pedir aprovação do jar novo (janela com o SHA-256). Explicar isso ao usuário.
- O `.jar` gerado fica no git, porque é código nosso. O `re/` continua fora.
- **Pronto quando:** a linha do patch aparece no console e o Lua recebe o valor do Java.

## Etapa 5 — Primeiro mod de verdade (decisão do usuário)
Aqui eu pergunto o que ele quer. Sugestões, a partir dos mods que ele já usa (UI/QoL, NPCs do A-Life, população):
- uma melhoria de qualidade de vida em Lua (menu de contexto, inventário, HUD);
- ajuste fino de população e hordas via Java (agora que sabemos onde fica);
- consertar ou substituir o "Read While Walking", que hoje gera os erros.

## Etapa 6 (opcional) — Publicar no Workshop
- `scripts/package-workshop.ps1`: monta `%USERPROFILE%\Zomboid\Workshop\<Mod>\{workshop.txt, preview.png 256x256, Contents/mods/<Mod>}`
  (a ModTemplate local está no formato B41, não copiar), e o upload é pelo menu do jogo.
- Para mod Java: assinatura `.zbs` do ZombieBuddy (opcional, vinculada ao SteamID).

---

## Arquivos principais
- Novos: `project-zomboid/scripts/{log,decompile,new-mod,build-java,package-workshop}.ps1`, `.luarc.json`,
  `docs/mapa-do-jogo.md`, `java/<Mod>/`
- Alterados: `project-zomboid/docs/setup.md`, `README.md`, `mods/NoHouseAlarms/*`, `CLAUDE.md` da raiz (seção PZ)
- Reaproveitar: `scripts/deploy.ps1` (já faz o espelhamento para `Zomboid\mods`), o padrão do Viewpoint
  (`workshop/content/108600/3809306528/mods/Viewpoint/42`) e o guia do ZombieBuddy
  (`workshop/content/108600/3619862853/mods/ZombieBuddy/doc/ModdingGuide.md`).

## Verificação (por etapa)
Cada etapa tem um "Pronto quando" verificado no jogo de verdade (deploy → abrir o jogo → `log.ps1` sem erro do mod),
seguido de commit e push na branch `project-zomboid`. Quem abre o jogo e confirma visualmente é o usuário; eu leio
o `console.txt`.

**Execução imediata, se o plano for aprovado:** só a **Etapa 1**. As outras ficam para as próximas sessões.
