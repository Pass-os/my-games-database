-- DynamicCam > Situacoes > "Taxi" (160) > Controles de Situacao > Script de Inicializacao
-- A condicao original (UnitOnTaxi) so e verificada nos eventos
-- PLAYER_CONTROL_LOST/GAINED. Se o jogo marca "no taxi" um pouco depois desse
-- evento (ou nao manda o evento), a situacao nunca liga. Aqui reavaliamos
-- tambem quando o mapa de voo fecha (destino escolhido) e quando o estado do
-- jogador muda, e de novo 0,5 s e 1,5 s depois, para pegar o embarque.

local taxi = DynamicCam.taxiReavaliar or {}
DynamicCam.taxiReavaliar = taxi

local function reavaliar()
  DynamicCam:EvaluateSituations()
  C_Timer.After(0.5, function() DynamicCam:EvaluateSituations() end)
  C_Timer.After(1.5, function() DynamicCam:EvaluateSituations() end)
end

-- Um so frame, mesmo que o script rode de novo ao editar a situacao.
if not taxi.frame then
  taxi.frame = CreateFrame("Frame")
  taxi.frame:RegisterEvent("TAXIMAP_CLOSED")
  taxi.frame:RegisterEvent("PLAYER_CONTROL_LOST")
  taxi.frame:RegisterEvent("PLAYER_CONTROL_GAINED")
  taxi.frame:RegisterUnitEvent("UNIT_FLAGS", "player")
  taxi.frame:SetScript("OnEvent", reavaliar)
end
