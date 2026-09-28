# DynamicCam: situacoes configuradas

Retrato de `config/SavedVariables/DynamicCam.lua` em 28/09/2026 (perfil
`Default`). Serve para duas coisas:

- **Restaurar:** nao precisa refazer nada disto a mao. O
  `scripts\restaurar-config.ps1` copia o arquivo e tudo volta como esta aqui.
- **Entender ou refazer pela interface:** cada linha diz onde fica no `/dc`,
  com os rotulos como aparecem no cliente em portugues.

O que nao esta listado numa situacao fica no padrao do DynamicCam.

## Como a interface se organiza

`/dc` abre a janela. Duas abas importam:

- **Configuracoes Base**: vale sempre que nenhuma situacao ativa muda aquele item.
- **Situacoes**: escolha a situacao em "Selecione uma situacao para
  configurar". Verde = ativa agora. Cada situacao tem:
  - **Ativar** (no topo);
  - **Acoes da Situacao** > **Zoom/Visao**, **Rotacao**, **Ocultar Interface**;
  - **Tempo de Transicao** (Entrada / Saida, em segundos);
  - **Configuracoes de Situacao**: sobrescreve itens da Configuracoes Base
    (ombro, balanco de cabeca, foco no alvo...) so enquanto a situacao esta ativa;
  - **Controles de Situacao**: prioridade, eventos, condicao e scripts (Lua).

Quando mais de uma situacao vale ao mesmo tempo, ganha a de **Prioridade**
maior. Tipo de Zoom: **Definir** (vai sempre para o valor), **Aproximar**
(so se estiver mais longe), **Afastar** (so se estiver mais perto),
**Intervalo** (mantem entre Zoom Min e Zoom Max).

## Configuracoes Base

| Item | Valor |
| --- | --- |
| Distancia maxima da camera | 39 jardas (`cameraDistanceMaxZoomFactor` 2.6) |
| Deslocamento Horizontal (ombro) | padrao do jogo (0) |
| Inclinacao vertical (dynamic pitch) | ligada |
| Rastreamento de Cabeca | 0.5 |
| Foco no Alvo > interacao | ligado |

## Situacoes ativas

| Situacao (nome no `/dc`) | ID | Zoom | Outras acoes | Configuracoes de Situacao | Transicao |
| --- | --- | --- | --- | --- | --- |
| Cidade (Interiores) | 002 | Intervalo, max 12 (min padrao 5) | | ombro 0.3 | padrao |
| Mundo (Interiores) | 005 | Intervalo, max 12 (min padrao 5) | | ombro 0.3 | padrao |
| Masmorra/Cenario | 020 | | | ombro 0, cabeca 0 | padrao |
| Raide | 030 | | | ombro 0, cabeca 0 | padrao |
| Arena | 050 | | | ombro 0, cabeca 0 | padrao |
| Campo de Batalha | 060 | | | ombro 0, cabeca 0 | padrao |
| Montaria (qualquer) | 100 | Definir 15 | Ocultar Interface: opacidade 0, mantem Minimapa, Quadro de Encontro (vigor) e quadros adicionais `MainActionBar` | distancia max 39 | 1.5 / 2.0 s |
| Montaria (apenas montaria voadora + no ar) | 102 | Definir 20 | | | padrao |
| Taxi | 160 | Definir 19 | Ocultar Interface: opacidade 0, mantem Chat | | padrao |
| Pedra de Regresso/Teletransporte | 200 | Definir 8 | Rotacao continua 20; Ocultar Interface opacidade 0 | | padrao |
| Interacao com NPC | 300 | Aproximar 3 | Rotacao: graus, inclinacao -5 (Ativar **desmarcado**); scripts de musica | ombro 0.6, foco de interacao 1.0 / 0.75 | 0.2 / 0.5 s |
| Caixa de Correio | 301 | Aproximar 6 | | foco de interacao ligado | 0.3 / 0.5 s |
| Pesca | 302 | Aproximar 7 | | | padrao |
| Ausente (AFK) | 303 | Definir 12 | Rotacao continua 5; Ocultar Interface opacidade 0 | | padrao |
| NPC grande (dialogo) | custom1 | Afastar **1.5** (ver pendencias) | | ombro 0.6, foco de interacao 1.0 / 0.75 | 0.3 / 0.5 s |
| Conjurando (fora de combate) | custom3 | Aproximar 8 | | | 0.6 / 0.8 s |
| Conjurando (em combate) | custom4 | | (sem acoes, configurar pela interface) | | padrao |

As duas "Conjurando" tem prioridade 60 e condicao em
`conjuracao-condicao.lua` / `conjuracao-combate-condicao.lua`. A de combate
ganha das situacoes de instancia (020/030/050/060): enquanto conjura, ombro
e balanco voltam ao da base, a menos que se ponha ombro 0 e cabeca 0 nela.

Ocultar Interface fica **desligado** na Interacao com NPC de proposito: quem
esconde a interface no dialogo e o Immersion (Opcoes > AddOns > Immersion >
Ocultar interface). Com os dois, a caixa de dialogo nao some ao fechar.

## Situacoes no padrao (desligadas)

Nao aparecem no arquivo porque estao como vem do DynamicCam: desligadas.
Ligar qualquer uma e so marcar **Ativar** nela.

| ID | Situacao |
| --- | --- |
| 001 | Cidade |
| 004 | Mundo |
| 006 | Mundo (Combate) |
| 021 | Masmorra/Cenario (Ao ar livre) |
| 023 | Masmorra/Cenario (Combate, Chefe) |
| 024 | Masmorra/Cenario (Combate, Lixo) |
| 031 | Raide (Ao ar livre) |
| 033 | Raide (Combate, Chefe) |
| 034 | Raide (Combate, Lixo) |
| 051 | Arena (Combate) |
| 061 | Campo de Batalha (Combate) |
| 101 | Montaria (apenas montaria voadora) |
| 103 | Montaria (apenas montaria voadora + no ar + pilotagem aerea) |
| 104 | Montaria (apenas montaria voadora + pilotagem aerea) |
| 105 | Montaria (apenas no ar) |
| 106 | Montaria (apenas no ar + pilotagem aerea) |
| 107 | Montaria (apenas pilotagem aerea) |
| 115 | Forma de Viagem de Druida |
| 120 | Dracthyr Voar Alto |
| 130 | Corrida de pilotagem aerea |
| 170 | Veiculo |
| 201 | Feiticos Irritantes |
| 310 | Batalha de Mascote |
| 320 | Coleta |
| 323 | Nadando |
| 325 | Acampamento (so no Forever; nao existe no Retail) |
| 330 | Janela de Profissoes Aberta |

Masmorra/Raide/Arena/BG com combate estao desligadas, entao em combate
nessas instancias vale a situacao sem combate (020/030/050/060): sem ombro
e sem balanco de cabeca.

## Scripts

Os arquivos desta pasta sao os mesmos textos que estao dentro do
`DynamicCam.lua`; so servem para colar pela interface se precisar:

| Arquivo | Situacao > Controles de Situacao > |
| --- | --- |
| `musica-entrada.lua` | Interacao com NPC > Script de Entrada |
| `musica-saida.lua` | Interacao com NPC > Script de Saida |
| `npc-grande-inicializacao.lua` | NPC grande (dialogo) > Script de Inicializacao |
| `npc-grande-condicao.lua` | NPC grande (dialogo) > Condicao |

### Criar a "NPC grande" do zero pela interface

1. `/dc` > Situacoes > botao de criar situacao personalizada > nome
   `NPC grande (dialogo)`.
2. Controles de Situacao: **Prioridade** 115; **Eventos** (virgula):
   `GOSSIP_SHOW, GOSSIP_CLOSED, QUEST_DETAIL, QUEST_PROGRESS, QUEST_COMPLETE,
   QUEST_GREETING, QUEST_FINISHED, MERCHANT_SHOW, MERCHANT_CLOSED,
   TRAINER_SHOW, TRAINER_CLOSED, BANKFRAME_OPENED, BANKFRAME_CLOSED,
   AUCTION_HOUSE_SHOW, AUCTION_HOUSE_CLOSED, PLAYER_TARGET_CHANGED,
   PLAYER_INTERACTION_MANAGER_FRAME_SHOW, PLAYER_INTERACTION_MANAGER_FRAME_HIDE`;
   **Script de Inicializacao** e **Condicao** dos arquivos acima. Salvar.
3. Zoom/Visao: Ativar, Definir Zoom, Tipo **Afastar**, valor 18.
4. Configuracoes de Situacao: ombro 0.6, Foco no Alvo de interacao 1.0 / 0.75.
5. No jogo, com o dialogo aberto: `/npcgrande` marca/desmarca o NPC.

## Pendencias (decidir)

- **NPC grande com zoom 1.5 Afastar.** "Afastar 1.5" so afasta se a camera
  estiver a menos de 1.5 jardas, ou seja, na pratica nao faz nada. O valor
  pensado era 18. Parece ter mudado sem querer.
- **Voando sem esconder a interface.** Ao decolar numa montaria voadora
  (voo normal ou dinamico) vale a 102, prioridade 102 > 100: zoom 20, como
  pedido. Mas a 102 nao tem Ocultar Interface, entao a interface escondida
  pela "Montaria (qualquer)" volta no ar. Para manter igual, copiar na 102
  o Ocultar Interface da 100.
- **Ombro na Configuracoes Base voltou ao padrao** (era 1.2). Se foi de
  proposito, ignorar.
- Ainda nao criada: "Transformacao (historia)". Ver `../PENDENTE.md`.
