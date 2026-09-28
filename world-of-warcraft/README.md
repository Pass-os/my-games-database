# World of Warcraft (Retail)

Addons, configuracao e macros do WoW, para refazer tudo num PC novo sem
reconfigurar na mao. Nao e um mod: aqui nao ha codigo de addon, so a lista
do que usar, os scripts que instalam/restauram e a configuracao salva.

Testado no Retail **12.1.0** (interface `120100`), cliente em **ptBR**.

## Num PC novo

Com o Battle.net e o WoW instalados:

1. **Entre no jogo uma vez** e logue com cada personagem que tem macros. Isso
   cria as pastas `WTF\Account\...` que o restaurar precisa. Feche o jogo.
2. No PowerShell, dentro de `world-of-warcraft\scripts`:

   ```powershell
   .\instalar-addons.ps1     # baixa as versoes fixadas do CurseForge
   .\restaurar-config.ps1    # copia config dos addons e macros (WoW fechado)
   ```

   Os dois acham o WoW pelo registro. Se nao acharem:
   `-WowPath "X:\Battle.net\World of Warcraft"`.
   Se o PowerShell recusar rodar scripts:
   `powershell -ExecutionPolicy Bypass -File .\instalar-addons.ps1`.
3. Abra o WoW e confira a lista de AddOns na tela de personagem.

O `restaurar-config.ps1` guarda tudo que sobrescrever em
`_retail_\WTF\backup-antes-restaurar-<data>`.

## Depois de mudar algo no jogo

Feche o WoW (ele so grava ao sair) e:

```powershell
.\salvar-config.ps1
git diff    # revisar
```

Commit e push em seguida.

## Addons

Versoes exatas e IDs do CurseForge em [`addons.json`](addons.json).

| Addon | Para que | Comando |
| --- | --- | --- |
| DynamicCam | camera por situacao (NPC, montaria, taxi, interiores...) | `/dc` |
| Immersion | dialogo de NPC em estilo legenda de cinema | `/immersion` |
| BtWQuests (+ Midnight, The War Within) | diario de cadeias de missao da historia | aba no mapa |
| Narcissus | tela de personagem e modo foto | `/narcissus` |
| HandyNotes | anotacoes no mapa | Alt + clique direito no mapa |
| Map Pin Enhanced | varios waypoints | `/mph`, `/pin`, `/way` |
| Leatrix Plus | qualidade de vida (tudo desligado por padrao) | `/ltp` |
| Macro Toolkit | editor de macros | `/mt` |
| BetterMacroIcons (+ LibNAddOn, LibNUI) | busca de icones | `/bmi` |

### Decisoes que nao sao obvias

- **Immersion fixado na 1.4.60.** A 1.4.61 (24/09/2026) trocou o painel de
  config do Ace pelo nativo e, aqui, a caixa de dialogo parou de responder
  ao X, ESC e Espaco. Voltando para a 1.4.60 resolveu. Antes de subir a
  versao em `addons.json`, testar se fecha.
- **Max Camera Distance nao e usado.** Conflita com o DynamicCam: os dois
  mexem em `cameraDistanceMaxZoomFactor` e no zoom de montaria, e a camera
  fica dando tranco. O DynamicCam cobre o que ele fazia.
- **BetterMacroIcons precisa de LibNAddOn.** A pagina do CurseForge nao lista
  dependencia; so o `.toc` (`## Dependencies: LibNAddOn`).
- **Leatrix Plus: arquivo de Retail.** O projeto publica um `.zip` por
  cliente (`-classic`, `-mists`, `-forever`, `-titan`, `-bcc`); o de Retail
  e o sem sufixo.
- **Macro Toolkit:** macro "estendida" (>255 caracteres) nao existe mais
  desde The War Within; a funcao ainda aparece no addon mas nao faz nada.

## DynamicCam

A configuracao inteira esta em `config/SavedVariables/DynamicCam.lua` e volta
com o `restaurar-config.ps1`. Situacao por situacao, com o caminho de cada
opcao no `/dc` e as pendencias: [`dynamiccam/SITUACOES.md`](dynamiccam/SITUACOES.md).

### Scripts (para colar pela interface)

Ficam em [`dynamiccam/`](dynamiccam/), um arquivo por campo:

- `musica-entrada.lua` / `musica-saida.lua`: NPC Interaction >
  Controles de Situacao > Script de Entrada / Saida. Abaixa a musica no
  dialogo (fade de 2,5 s) e devolve ao sair (3,5 s).
- `npc-grande-inicializacao.lua` / `npc-grande-condicao.lua`: situacao
  personalizada "NPC grande (dialogo)", prioridade 115.

Ao colar, copie **so o codigo**. Texto a mais vira erro de sintaxe
("'=' expected near ...") e o DynamicCam abre um aviso; nesse aviso **nao**
clique em "Reset to default", que apaga o resto da situacao.

### Armadilhas do DynamicCam

- **Scripts rodam num ambiente isolado.** Ler global funciona; escrever
  global (`SLASH_X1 = ...`) grava so dentro do ambiente e o WoW nunca ve.
  Use `getfenv(0).NOME = valor`.
- **Nao esconda a interface do DynamicCam no dialogo junto com o Immersion.**
  Com `ImmersionFrame` em "Quadros personalizados para manter", os dois
  addons disputam a transparencia da janela e a caixa nao some ao fechar.
  Aqui o Ocultar Interface da NPC Interaction fica **desligado** e quem
  esconde e o Immersion (Opcoes > AddOns > Immersion > Ocultar interface).
- **Nomes de quadro para "manter" (Retail 12.x):** barra de acao 1 e
  `MainActionBar` (era `MainMenuBar` ate 11.2.7), e e ela que vira a barra
  de habilidades do voo dinamico. Vigor tem opcao propria ("Manter Quadro de
  Encontro"). Para descobrir outros nomes: `/fstack`.
- **Configurar pela interface com o jogo aberto e editar o arquivo ao mesmo
  tempo nao combina:** o WoW regrava SavedVariables ao sair. Edite arquivo
  so com o jogo fechado, e rode o `salvar-config.ps1` depois de mexer pela
  interface.

## Macros

`config/macros/conta.txt` sao as macros de conta; `config/macros/<reino>/<personagem>.txt`
as de cada personagem. Sao os `macros-cache.txt` do WoW, copiados como estao.

Com "Sincronizar configuracoes" ligado (padrao), a Blizzard tambem guarda as
macros no servidor; este backup e para ter historico e nao depender disso.

## O que fica fora do repositorio

O repositorio e publico, entao o `salvar-config.ps1` nao grava:

- o numero da conta Battle.net (nome da pasta `WTF\Account\<numero>#1`);
- o bloco `profileKeys` dos SavedVariables, que liga "Personagem - Reino"
  ao perfil. Sem ele os addons usam o perfil `Default`, que e o usado aqui.

Os nomes dos personagens aparecem nas pastas de macros, porque e por eles
que o restaurar sabe onde por cada arquivo.
