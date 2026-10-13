# DynamicCam: todas as situacoes possiveis

Levantamento de 12/10/2026 (WoW 12.1.0, DynamicCam 2.21.1). Tres fontes:

1. **As que ja vem no DynamicCam** (`DefaultSettings.lua` do addon instalado).
2. **As personalizadas** que ja temos (ver `SITUACOES.md`).
3. **As que da para criar** com eventos e funcoes que existem na 12.1,
   conferidos na documentacao oficial gerada pela Blizzard
   (github.com/Gethe/wow-ui-source, branch `live`,
   `Blizzard_APIDocumentationGenerated`) e em exemplos da comunidade.

Como funciona uma situacao: uma lista de **eventos** faz o DynamicCam
reavaliar a **condicao** (Lua que devolve true/false). Se valer e tiver a
maior **prioridade** entre as que valem, ela manda na camera. So da para
fazer situacao de **estado que tem comeco e fim** (dentro da casa, com
janela aberta, morto); coisas instantaneas nao servem.

**Limite do Midnight:** em combate e em instancia, buffs, recursos e recargas
viram "valores secretos" para addons. Condicao que le aura (`UNIT_AURA`) ou
nome de magia pode nao funcionar em combate. As de estado (zona, janela,
montaria, veiculo, casa) nao tem esse problema.

Legenda da coluna "Nossa": **ligada** = configurada e ativa; **padrao** =
desligada, como vem do DynamicCam; **nova** = nao existe, da para criar.

## 1. As que vem no DynamicCam (35)

| ID | Situacao (nome no `/dc` em ptBR) | Prioridade | Nossa |
| --- | --- | --- | --- |
| 001 | Cidade | 1 | padrao |
| 002 | Cidade (Interiores) | 11 | ligada |
| 004 | Mundo | 0 | padrao |
| 005 | Mundo (Interiores) | 10 | ligada |
| 006 | Mundo (Combate) | 50 | padrao |
| 020 | Masmorra/Cenario (inclui Imersoes/Delves) | 2 | ligada |
| 021 | Masmorra/Cenario (Ao ar livre) | 12 | padrao |
| 023 | Masmorra/Cenario (Combate, Chefe) | 302 | padrao |
| 024 | Masmorra/Cenario (Combate, Lixo) | 202 | padrao |
| 030 | Raide | 3 | ligada |
| 031 | Raide (Ao ar livre) | 13 | padrao |
| 033 | Raide (Combate, Chefe) | 303 | padrao |
| 034 | Raide (Combate, Lixo) | 203 | padrao |
| 050 | Arena | 3 | ligada |
| 051 | Arena (Combate) | 203 | padrao |
| 060 | Campo de Batalha | 3 | ligada |
| 061 | Campo de Batalha (Combate) | 203 | padrao |
| 100 | Montaria (qualquer) | 100 | ligada |
| 101 | Montaria (apenas montaria voadora) | 101 | padrao |
| 102 | Montaria (voadora + no ar) | 102 | ligada |
| 103 | Montaria (voadora + no ar + pilotagem aerea) | 103 | padrao |
| 104 | Montaria (voadora + pilotagem aerea) | 102 | padrao |
| 105 | Montaria (apenas no ar) | 101 | padrao |
| 106 | Montaria (no ar + pilotagem aerea) | 102 | padrao |
| 107 | Montaria (apenas pilotagem aerea) | 101 | padrao |
| 115 | Forma de Viagem de Druida | - | padrao (nao se aplica ao mago) |
| 120 | Dracthyr Voar Alto | 100 | padrao (so Dracthyr) |
| 130 | Corrida de pilotagem aerea | - | padrao |
| 160 | Taxi | 1000 | ligada |
| 170 | Veiculo | 1000 | padrao |
| 200 | Pedra de Regresso/Teletransporte | - | ligada |
| 201 | Feiticos Irritantes | - | padrao |
| 300 | Interacao com NPC | - | ligada |
| 301 | Caixa de Correio | 110 | ligada |
| 302 | Pesca | 20 | ligada |
| 303 | Ausente (AFK) | 120 | ligada |
| 310 | Batalha de Mascote | 130 | padrao |
| 320 | Coleta | - | ligada (condicao propria) |
| 323 | Nadando | 105 | padrao |
| 325 | Acampamento | 40 | padrao (nao existe no Retail) |
| 330 | Janela de Profissoes Aberta | 1100 | ligada |

A Interacao com NPC (300) ja reage a: leilao, banco, tabardo, conversa,
guilda, comerciante, estabulo, missao, oficina, treinador, transmog e mapa
de voo. Nao precisa de situacao separada para esses.

## 2. Personalizadas que ja temos

As tres da secao 3 marcadas como criadas ja estao no `DynamicCam.lua`.

| ID | Situacao | Prioridade | Nossa |
| --- | --- | --- | --- |
| custom1 | NPC grande (dialogo) | 115 | ligada |
| custom3 | Conjurando (fora de combate) | 60 | ligada |
| custom4 | Conjurando (em combate) | 65 | ligada |
| custom5 | Dentro da casa (`casa-condicao.lua`) | 14 | ligada (13/10/2026) |
| custom6 | Morto / fantasma (`morto-condicao.lua`) | 1200 | ligada (13/10/2026) |
| custom7 | Imersao (Delve) (`imersao-condicao.lua`) | 4 | ligada (13/10/2026) |
| - | Transformacao (historia) | 1001 | so a condicao (`transformacao-condicao.lua`), nao criada |

## 3. Novas que da para criar (12.1)

Eventos e funcoes conferidos na documentacao da 12.1. A prioridade sugerida
diz quem ganha de quem.

### Midnight: casa e Imersoes

| Situacao | Condicao | Eventos | Prioridade | Ideia de camera |
| --- | --- | --- | --- | --- |
| Dentro da casa | `C_Housing.IsInsideHouse()` | `HOUSE_PLOT_ENTERED, HOUSE_PLOT_EXITED, ZONE_CHANGED_INDOORS, ZONE_CHANGED` | 14 | zoom perto (4-6), ombro 0 |
| No terreno da casa (lado de fora) | `C_Housing.IsInsidePlot() and not C_Housing.IsInsideHouse()` | iguais | 13 | zoom medio (8-10) para ver a fachada |
| Decorando a casa (editor) | `C_HouseEditor.IsHouseEditorActive()` | `HOUSE_EDITOR_MODE_CHANGED` | 1050 | zoom longe, sem ombro, inclinacao desligada; nada de ocultar interface (o editor precisa dela) |
| Imersao/Delve em andamento | `C_PartyInfo.IsDelveInProgress()` | `SCENARIO_UPDATE, ZONE_CHANGED_NEW_AREA, ACTIVE_DELVE_DATA_UPDATE` | 4 | separa das masmorras (hoje caem na 020) |
| Covil (Lair) | `C_DelvesUI.IsInLair()` | `ZONE_CHANGED_NEW_AREA, SCENARIO_UPDATE` | 5 | igual a Imersao |
| Mitica+ com chave rodando | `C_ChallengeMode.IsChallengeModeActive()` | `CHALLENGE_MODE_START, CHALLENGE_MODE_COMPLETED, CHALLENGE_MODE_RESET, ZONE_CHANGED_NEW_AREA` | 6 | zoom mais longe e fixo, sem balanco de cabeca |

### Janelas e cenas

| Situacao | Condicao | Eventos | Prioridade | Ideia de camera |
| --- | --- | --- | --- | --- |
| Barbearia | `BarberShopFrame and BarberShopFrame:IsShown()` | `BARBER_SHOP_OPEN, BARBER_SHOP_CLOSE` | 1100 | o jogo controla a camera aqui; a situacao serve para **nao** atrapalhar (zoom desligado) e rodar scripts |
| Escolha de historia (janela de opcoes) | `PlayerChoiceFrame and PlayerChoiceFrame:IsShown()` | `PLAYER_CHOICE_UPDATE, PLAYER_CHOICE_CLOSE` | 300 | igual a conversa com NPC |
| Saque aberto | `LootFrame and LootFrame:IsShown()` | `LOOT_OPENED, LOOT_CLOSED` | 30 | aproximar um pouco |
| Mapa do mundo aberto | `WorldMapFrame:IsShown()` | `WORLD_MAP_OPEN` + `PLAYER_STARTED_MOVING` (o mapa nao tem evento de fechar) | 25 | girar devagar ou afastar |
| Janela do personagem / colecoes | `CharacterFrame:IsShown() or (CollectionsJournal and CollectionsJournal:IsShown())` | `PLAYER_STARTED_MOVING, PLAYER_STOPPED_MOVING, UNIT_INVENTORY_CHANGED` | 26 | camera de frente, como na profissao |
| Cinematica / video | o jogo assume a camera | `CINEMATIC_START, CINEMATIC_STOP, PLAY_MOVIE, STOP_MOVIE` | - | so serve para scripts (ex.: baixar a musica); a camera e da Blizzard |
| Cabeca falante (NPC falando no canto) | `TalkingHeadFrame and TalkingHeadFrame:IsShown()` | `TALKINGHEAD_REQUESTED, TALKINGHEAD_CLOSE` | 35 | nao recomendo: aparece no meio de combate |

### Estado do personagem

| Situacao | Condicao | Eventos | Prioridade | Ideia de camera |
| --- | --- | --- | --- | --- |
| Morto / fantasma | `UnitIsDeadOrGhost("player")` | `PLAYER_DEAD, PLAYER_ALIVE, PLAYER_UNGHOST` | 1200 | afastar bem para achar o corpo |
| Planando / caindo devagar | `IsFalling()` + planador (`PLAYER_IS_GLIDING_CHANGED`) | `PLAYER_IS_GLIDING_CHANGED` | 104 | afastar como a montaria no ar |
| Mergulhado (embaixo da agua) | `IsSubmerged()` | `MIRROR_TIMER_START, MIRROR_TIMER_STOP, ZONE_CHANGED` | 106 | diferente de nadar na superficie (323) |
| Parado x andando | `not IsPlayerMoving()` | `PLAYER_STARTED_MOVING, PLAYER_STOPPED_MOVING` | 1 | ex.: aproximar devagar quando para (efeito "foto") |
| Controlando veiculo x passageiro | `UnitControllingVehicle("player")` | `UNIT_ENTERED_VEHICLE, UNIT_EXITED_VEHICLE` | 1001 | complemento da Veiculo (170) |
| Transformacao (historia) | ja escrita em `transformacao-condicao.lua` | `UNIT_ENTERED_VEHICLE, UNIT_EXITED_VEHICLE, UPDATE_OVERRIDE_ACTIONBAR, UPDATE_POSSESS_BAR, UPDATE_VEHICLE_ACTIONBAR` | 1001 | zoom 20 e mantem a `OverrideActionBar` |
| Duelo | `this.duelo` (marcado por evento) | `DUEL_INBOUNDS, DUEL_FINISHED, DUEL_REQUESTED` | 210 | parecido com arena |

### Combate fora de instancia

| Situacao | Condicao | Eventos | Prioridade | Ideia de camera |
| --- | --- | --- | --- | --- |
| Chefe de mundo / encontro | `this.encontro` (marcado no evento) ou `UnitIsBossMob("target")` em combate | `ENCOUNTER_START, ENCOUNTER_END, PLAYER_REGEN_ENABLED` | 301 | afastar para ver as mecanicas |
| Mundo (Combate) | ja existe (006) | - | 50 | hoje desligada: em combate no mundo vale a camera livre |

### Coisas que **nao** da para fazer

- **Altura da camera:** nao existe ajuste (so ombro, que e para o lado).
- **Ler o angulo da camera em combate ou ao vivo com precisao:** o jogo nao tem funcao; o PainelDaCamera usa `cameraSavedPitch`.
- **Camera em cinematicas e voos guiados:** e roteirizada pela Blizzard; addon nao mexe.
- **Situacao por buff em combate** (ex.: "Veias Gelidas ativo"): o Midnight esconde os buffs dos addons em combate.
- **Velocidade de corrida:** nenhum addon muda (ver MoveRapido).

## Referencias

- Documentacao oficial gerada (12.1): `Interface/AddOns/Blizzard_APIDocumentationGenerated/`
  em github.com/Gethe/wow-ui-source (branch `live`).
- [Custom situation - WoWInterface](https://www.wowinterface.com/forums/showthread.php?t=58122):
  situacoes so para estados com comeco e fim; magia instantanea precisa
  guardar o evento numa variavel.
- [Issue #34 do DynamicCam](https://github.com/mpstark/DynamicCam/issues/34):
  situacao por buff com `UNIT_AURA` na condicao.
- [DynamicCam no CurseForge](https://www.curseforge.com/wow/addons/dynamiccam).
