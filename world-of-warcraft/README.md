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
| Dialogue UI | dialogo de NPC, narracao por voz e janela de livros (substitui o Immersion) | F1 no dialogo |
| BtWQuests (+ Midnight, The War Within) | diario de cadeias de missao da historia | aba no mapa |
| Narcissus | tela de personagem e modo foto | `/narcissus` |
| HandyNotes | anotacoes no mapa | Alt + clique direito no mapa |
| Map Pin Enhanced | varios waypoints | `/mph`, `/pin`, `/way` |
| Leatrix Plus | qualidade de vida (tudo desligado por padrao) | `/ltp` |
| Macro Toolkit | editor de macros | `/mt` |
| BetterMacroIcons (+ LibNAddOn, LibNUI) | busca de icones | `/bmi` |
| Better Wardrobe and Transmog | colecao de conjuntos, provador e transmog | abas na Colecao / Transmog |
| Can I Mog It? | mostra se a aparencia do item ja foi aprendida | `/cimi` |
| BarberShop Profiles | salva aparencias da barbearia por raca (conta toda) | botoes na barbearia |
**Dialogue UI:**

- Teclado: `1`-`9` escolhe a opcao, Espaco aceita, `R` le/para a narracao,
  Tab alterna recompensas, F1 abre as opcoes. Setas so com controle (gamepad).
- **Camera no dialogo e dele.** Por isso as situacoes do DynamicCam
  "Interacao com NPC" (300) e "NPC grande" (custom1) ficam **desativadas**
  (e com elas os scripts que abaixam a musica). Nao reativar com o Dialogue
  UI movendo a camera: os dois brigam. Ele ja se integra ao DynamicCam (pausa
  o ombro durante o dialogo e devolve depois).
- **Narracao (por PC):** ligada na config (`TTSEnabled`, leitura automatica
  com atraso para nao falar por cima da dublagem). Le o texto do jogo, entao
  sai em portugues com voz pt-BR. Precisa de "Ler texto do chat em voz alta"
  (Sistema > Acessibilidade > Assistencia de Audio), com os canais de chat
  desmarcados na configuracao de TTS. As vozes (masculina, feminina e, se
  quiser, narrador para titulo e descricoes entre `< >`) se escolhem no F1 >
  Narracao; o ID delas e do PC, confira depois de restaurar em outra maquina.
- Interface durante o dialogo: visivel (`HideUI = false`), como estava no
  Immersion. Muda em F1.
- Immersion e QuestSpeaker ficaram em `disabled` no `addons.json` (o
  `instalar-addons.ps1` apaga as pastas deles); a config dos dois continua em
  `config/` para poder voltar.

**Vozes (por PC):** `scripts\instalar-vozes.ps1` (uma janela de administrador).
O WoW so lista vozes **registradas fixas** no SAPI classico
(`HKLM\SOFTWARE\Microsoft\Speech\Voices\Tokens`); vozes que um programa cria
"na hora" aparecem no Windows mas nao no jogo. Entao o script:

- registra o **Daniel** (pt-BR masculina, vem do pacote de fala do Windows
  mas so no OneCore) ao lado da **Maria**;
- instala o NaturalVoiceSAPIAdapter e registra **fixas** as vozes **online
  do Edge** em pt-BR (**Francisca**, **Antonio**, **Thalita**), bem mais
  naturais, apontando para o motor do adapter. A lista dinamica dele fica
  desligada (senao duplica) e as vozes locais do Narrador tambem (travam o WoW);
- testa cada voz e mostra quais falam ("ok") e quais ficam mudas.

No PC do trabalho as do Edge aparecem mas ficam mudas ("Timer Expired" no
log). Se no outro PC tambem, `.\instalar-vozes.ps1 -Desinstalar` tira o
adapter e fica Maria/Daniel.

### Addons proprios

Feitos aqui, em [`addons-proprios/`](addons-proprios/). O `instalar-addons.ps1`
copia cada pasta de la direto para `Interface\AddOns`.

| Addon | Para que |
| --- | --- |
| FechaDialogoEmCombate | ao entrar em combate fecha o dialogo com NPC: a caixa do Immersion (mesmo caminho do ESC) ou, sem ela, gossip, missao e livro da Blizzard. Nao tem opcoes; desligar e desmarcar na lista de AddOns. |
| NpcAltura | mede a altura do modelo do NPC do dialogo (ModelScene + GetActiveBoundingBox) e guarda por NPC; a situacao "NPC grande" do DynamicCam usa isso para afastar a camera sozinha. `/altura` mostra a medida, `/altura limite N` calibra (padrao 4), `/altura limpar` esquece as medidas. |
| MantemJanelasNPC | mantem visiveis as janelas que um NPC abre (loja, treinador, bolsas, provador, escolhas de historia, salao de classe/guarnicao/pacto...) quando o DynamicCam ou o Immersion escondem a interface. Cobre a janela que abre depois de a interface sumir, que a lista "quadros para manter" do DynamicCam nao pega (ela so tenta de novo uma vez, 0,3 s depois). Com Immersion ativo nao mexe em GossipFrame/QuestFrame/ItemTextFrame, que ele substitui. Nomes conferidos no codigo da Blizzard 12.1.0 (wow-ui-source, branch live). |
| ZoomLivreEstavel | corrige o DynamicCam: ao sair de uma situacao (montaria, NPC, correio...) a camera volta sempre para a distancia que voce escolheu, mesmo se entrou na situacao com a camera ainda voltando da anterior (o DynamicCam anotava o meio do caminho e a camera ia "andando"). `/zoomlivre` mostra a distancia anotada. |

### Decisoes que nao sao obvias

- **Immersion trocado pelo Dialogue UI (out/2026).** Estava preso na 1.4.60
  (a 1.4.61 deixou a caixa de dialogo sem responder ao X, ESC e Espaco), e o
  Dialogue UI ja esta no 12.1 e traz narracao propria. Para voltar: mover o
  Immersion de `disabled` para `addons` e reativar as situacoes 300 e
  custom1 do DynamicCam.
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

- **Janela de transmog e `TransmogFrame` na 12.x.** A lista padrao de
  "quadros para manter" do DynamicCam ainda traz `WardrobeFrame`, que nao
  existe mais. Com o MantemJanelasNPC instalado a lista vira reserva.
- **Situacao personalizada escrita a mao precisa de todos os campos.**
  Situacao padrao herda os valores de fabrica; personalizada nao herda nada.
  O DynamicCam usa `transitionTime`, `delay`, `hideUI` e
  `situationSettings.cvars` sem checar se existem (Core.lua 807,
  SituationManager.lua 815/848/1096): faltando um, da erro de Lua quando a
  situacao entra ou sai. Copie a estrutura completa de uma que ja funciona
  (ex.: `custom3` em `config/SavedVariables/DynamicCam.lua`). Pela interface
  ("criar situacao") ele ja cria completa.
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

## Opcoes do jogo (`config/cvars.wtf`)

O `WTF\Config.wtf` e por maquina (resolucao, graficos, placa de video) e nao
vai inteiro para o repo. As opcoes que tem de ser iguais em todo PC ficam em
`config/cvars.wtf`, uma linha `SET nome "valor"` cada, e o
`restaurar-config.ps1` aplica so essas linhas no `Config.wtf`:

- **Usar escala de interface: 80%** (`useUiScale 1`, `uiScale 0.8`). Sem
  isso as barras de acao ficam desalinhadas.

Mudou uma dessas opcoes no jogo? Atualize o `cvars.wtf` a mao (o
`salvar-config.ps1` nao le o `Config.wtf`).

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
