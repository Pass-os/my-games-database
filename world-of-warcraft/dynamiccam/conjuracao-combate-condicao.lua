-- DynamicCam > Situacoes > "Conjurando (em combate)" > Controles de Situacao > Condicao
-- Verdadeira em combate enquanto uma conjuracao/canalizacao esta em andamento.
-- Quem marca inicio e fim e o Script de Inicializacao desta situacao.
-- Prioridade 65 (acima da "Conjurando (fora de combate)", 60).

if not UnitAffectingCombat("player") then return false end

local conjuracao = DynamicCam.conjuracaoEmCombate
return conjuracao ~= nil and conjuracao.conjurando == true
