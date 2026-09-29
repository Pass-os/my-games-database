-- DynamicCam > Situacoes > "Mirar no alvo (habilidade)" > Controles de Situacao > Condicao
-- OPCIONAL (nao configurado): so para habilidades INSTANTANEAS. As de conjuracao usam o Foco no Alvo da "Conjurando (em combate)".
-- Verdadeira em combate, logo depois de usar uma habilidade num inimigo.
-- Prioridade 62: abaixo de "Conjurando (em combate)" (65), acima de "Conjurando (fora de combate)" (60).
-- Eventos: PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED, PLAYER_TARGET_CHANGED

if not UnitAffectingCombat("player") then return false end

local mirar = DynamicCam.mirarAlvo
if not mirar or not mirar.ultimaHabilidade then return false end

local segundosDesdeAHabilidade = GetTime() - mirar.ultimaHabilidade
return segundosDesdeAHabilidade < mirar.segundosMirando
