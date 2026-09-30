-- DynamicCam > Situacoes > "Conjurando (fora de combate)" e "Conjurando (em combate)"
-- > Controles de Situacao > Script de Saida
-- Afasta o mesmo tanto que o Script de Entrada aproximou, a partir de onde a
-- camera estiver (se voce mexeu no zoom durante a magia, respeita isso).

-- ===== AJUSTE AQUI =====
local segundosParaAfastar = 0.8   -- duracao do movimento de voltar
-- =======================

local estado = DynamicCam.zoomConjurar
if not estado then return end

C_Timer.After(0.05, function()
  -- Passou direto para a outra situacao de conjuracao: continua aproximado.
  local situacaoAtual = DynamicCam.currentSituationID
  local aindaConjurando = situacaoAtual == "custom3" or situacaoAtual == "custom4"
  if aindaConjurando or not estado.aproximado then return end

  estado.aproximado = false
  local zoomDestino = GetCameraZoom() + estado.quantoAproximou
  -- Anota para onde esta voltando: se conjurar de novo antes de chegar,
  -- o Script de Entrada parte daqui e nao do meio do caminho.
  estado.zoomDoRetorno = zoomDestino
  estado.fimDoRetorno = GetTime() + segundosParaAfastar
  DynamicCam:ResetReactiveZoomTarget()
  LibStub("LibCamera-1.0"):SetZoom(zoomDestino, segundosParaAfastar)
end)
