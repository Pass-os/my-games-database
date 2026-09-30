-- DynamicCam > Situacoes > "Conjurando (fora de combate)" e "Conjurando (em combate)"
-- > Controles de Situacao > Script de Entrada
-- Zoom RELATIVO: aproxima a partir de onde a camera esta (nao usa valor fixo).
-- O "Script de Saida" afasta de volta o mesmo tanto.
-- Na secao Zoom/Visao das duas situacoes o zoom tem que ficar DESLIGADO.

-- ===== AJUSTE AQUI =====
local distanciaParaAproximar = 3      -- quanto a camera chega mais perto ao conjurar
local distanciaMinimaDaCamera = 1.5   -- a camera nunca fica mais perto que isso
local segundosParaAproximar = 0.6     -- duracao do movimento de aproximar
-- =======================

local estado = DynamicCam.zoomConjurar or {}
DynamicCam.zoomConjurar = estado

C_Timer.After(0, function()
  if estado.aproximado then return end -- ja aproximou (ex.: entrou em combate no meio da magia)

  -- Se a camera ainda esta voltando da magia anterior (conjurou de novo rapido),
  -- a base e o ponto para onde ela estava voltando, nao o meio do caminho.
  local aindaVoltando = estado.fimDoRetorno and GetTime() < estado.fimDoRetorno
  local zoomAtual = aindaVoltando and estado.zoomDoRetorno or GetCameraZoom()
  local zoomDestino = math.max(zoomAtual - distanciaParaAproximar, distanciaMinimaDaCamera)
  if zoomDestino >= zoomAtual then return end

  estado.aproximado = true
  estado.quantoAproximou = zoomAtual - zoomDestino
  estado.fimDoRetorno = nil
  DynamicCam:ResetReactiveZoomTarget()
  LibStub("LibCamera-1.0"):SetZoom(zoomDestino, segundosParaAproximar)
end)
