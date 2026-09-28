# Pendente (28/09/2026)

Parou aqui porque o WoW estava aberto: o jogo so grava SavedVariables e
macros ao sair, e editar os arquivos com ele aberto seria desfeito.

## Com o WoW fechado

1. **Corrigir o `/npcgrande` no arquivo do PC.**
   `WTF\Account\<conta>\SavedVariables\DynamicCam.lua`, situacao `custom1`
   ("NPC grande (dialogo)"), campo `executeOnInit`: trocar
   `SLASH_DCNPCGRANDE1 = "/npcgrande"` por
   `getfenv(0).SLASH_DCNPCGRANDE1 = "/npcgrande"`. So essa linha.
   Versao completa e correta: `dynamiccam/npc-grande-inicializacao.lua`.
   No arquivo salvo pelo WoW (AceDB) as aspas aparecem escapadas (`\"`).

2. **Criar a situacao "Transformacao (historia)"** (`custom2`).
   - Condicao e eventos: `dynamiccam/transformacao-condicao.lua`.
   - Prioridade 1001. Zoom: Definir **20**. Transicao 1.0 / 1.0 s.
   - Ocultar Interface: **copiar** o que estiver na "Montaria (apenas no ar)"
     (`105`) do usuario e acrescentar `OverrideActionBar` aos quadros
     mantidos (habilidades da transformacao ficam nela, nao na
     `MainActionBar`).

3. **Situacao "Conjurando (fora de combate)"** (`custom3`) - esperando o
   usuario confirmar: so fora de combate? zoom Aproximar 8?
   Proposta: `dynamiccam/conjuracao-condicao.lua`.

4. **Salvar a configuracao e as macros no repo:** `scripts\salvar-config.ps1`,
   revisar o `git diff` (sem numero da conta, sem profileKeys) e commitar.
   Nesta sessao o usuario mudou pela interface e ainda nao esta em disco:
   - scripts de musica na NPC Interaction (`dynamiccam/musica-*.lua`);
   - Montaria (qualquer) zoom 15; Montaria (apenas no ar) ativada, zoom 18;
   - Ocultar Interface na montaria mantendo vigor e `MainActionBar`;
   - perfil "MODO HISTORIA".
   Conferir no arquivo salvo antes de mexer e **preservar** o que estiver la.

## Decisoes em aberto

- Nomes dos personagens nas pastas de macros (repo publico): ok?
- Branch `world-of-warcraft`: juntar na `main` direto ou via Pull Request?
