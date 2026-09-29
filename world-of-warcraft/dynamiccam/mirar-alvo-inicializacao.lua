-- DynamicCam > Situacoes > "Mirar no alvo (habilidade)" > Controles de Situacao > Script de Inicializacao
-- OPCIONAL (nao configurado): so para habilidades INSTANTANEAS. As de conjuracao usam o Foco no Alvo da "Conjurando (em combate)".
-- Anota a hora em que voce usou uma habilidade com um inimigo selecionado.
-- A condicao fica verdadeira por alguns segundos depois disso; nesse tempo o
-- "Foco no Alvo > Alvo Inimigo" desta situacao gira a camera para o inimigo.

-- ===== AJUSTE AQUI =====
local segundosMirando = 1.5   -- quanto tempo a camera fica buscando o alvo depois da habilidade
-- =======================

local mirar = DynamicCam.mirarAlvo or {}
DynamicCam.mirarAlvo = mirar
mirar.segundosMirando = segundosMirando

-- Um so frame, mesmo que o script rode de novo ao editar a situacao.
if not mirar.frame then
  mirar.frame = CreateFrame("Frame")
  mirar.frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
  mirar.frame:SetScript("OnEvent", function()
    if not UnitExists("target") then return end
    local inimigo = UnitCanAttack("player", "target")
    if issecretvalue and issecretvalue(inimigo) then inimigo = true end
    if not inimigo then return end

    mirar.ultimaHabilidade = GetTime()
    DynamicCam:EvaluateSituations()
    -- Reavalia quando o tempo acabar, para a situacao sair sozinha.
    C_Timer.After(mirar.segundosMirando + 0.05, function() DynamicCam:EvaluateSituations() end)
  end)
end
