-- DynamicCam > Situacoes > "Conjurando (fora de combate)" e "Conjurando (em combate)"
-- > Controles de Situacao > Script de Saida (o mesmo nas duas)
-- Afasta o mesmo tanto que o Script de Entrada aproximou, a partir de onde a
-- camera estiver (se voce mexeu no zoom durante a conjuracao, respeita isso).

local z = DynamicCam.zoomConjurar
if not z then return end

C_Timer.After(0.05, function()
  -- Passou direto para a outra situacao de conjuracao: continua aproximado.
  local id = DynamicCam.currentSituationID
  if id == "custom3" or id == "custom4" then return end
  if not z.ativo then return end
  z.ativo = false
  DynamicCam:ResetReactiveZoomTarget()
  LibStub("LibCamera-1.0"):SetZoom(GetCameraZoom() + z.delta, 0.8)
end)
