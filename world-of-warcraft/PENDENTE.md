# Pendente (28/09/2026)

Feito: `/npcgrande` corrigido no arquivo do PC (`getfenv(0)`), configuracao
e macros salvas em `config/` pelo `salvar-config.ps1`.

## Decisoes do usuario

1. **NPC grande (custom1) esta com Afastar 1.5**, que nao faz nada. Voltar
   para 18? (Provavelmente mudou sem querer.)
2. **Montaria no ar (situacao 102) sem Ocultar Interface**: copiar o da 100
   (opacidade 0, Minimapa, vigor, `MainActionBar`)?
3. **Transformacao (historia)** (`custom2`): condicao em
   `dynamiccam/transformacao-condicao.lua`, prioridade 1001, zoom Definir 20.
   O Ocultar Interface dela deveria copiar o da montaria no ar - que hoje nao
   existe (item 2). Decidir junto.
4. **Conjurando (fora de combate)** (`custom3`): so fora de combate? zoom
   Aproximar 8? Proposta em `dynamiccam/conjuracao-condicao.lua`.
5. Branch `world-of-warcraft`: juntar na `main` direto ou via Pull Request?

## Como aplicar

Com o WoW **fechado**: ler o `DynamicCam.lua` do PC, preservar o que o
usuario mudou pela interface, editar so o necessario, rodar o
`salvar-config.ps1`, commitar. Os valores atuais estao em
`dynamiccam/SITUACOES.md`.
