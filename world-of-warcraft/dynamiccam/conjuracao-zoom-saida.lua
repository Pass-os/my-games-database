-- DynamicCam > Situacoes > "Conjurando (fora de combate)" e "Conjurando (em combate)"
-- > Controles de Situacao > Script de Saida
-- Volta exatamente para o ponto de partida anotado pelo Script de Entrada.
-- (Nao faz "posicao atual + o que aproximou": com magia rapida a camera ainda
-- nao terminou de aproximar quando a magia acaba, e a conta fazia a camera
-- terminar cada vez mais longe.)

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
  -- Anota quando a volta termina: se conjurar de novo antes, o Script de
  -- Entrada parte do mesmo ponto de partida, nao do meio do caminho.
  estado.fimDoRetorno = GetTime() + segundosParaAfastar
  DynamicCam:ResetReactiveZoomTarget()
  LibStub("LibCamera-1.0"):SetZoom(estado.pontoDePartida, segundosParaAfastar)
end)
