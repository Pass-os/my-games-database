-- DynamicCam > Situacoes > "Conjurando (fora de combate)" e "Conjurando (em combate)"
-- > Controles de Situacao > Script de Entrada (o mesmo nas duas)
-- Zoom RELATIVO: aproxima APROXIMAR metros a partir de onde a camera esta
-- (nao usa valor fixo). O "Script de Saida" afasta de volta o mesmo tanto.
-- Na secao Zoom/Visao das duas situacoes o zoom tem que ficar DESLIGADO.

local APROXIMAR = 4   -- quanto aproximar ao conjurar
local MINIMO = 1.5    -- nunca chega mais perto que isso

local z = DynamicCam.zoomConjurar or {}
DynamicCam.zoomConjurar = z

C_Timer.After(0, function()
  if z.ativo then return end -- ja aproximou (ex.: passou de fora para dentro de combate)
  local atual = GetCameraZoom()
  local alvo = math.max(atual - APROXIMAR, MINIMO)
  if alvo >= atual then return end
  z.ativo = true
  z.delta = atual - alvo
  DynamicCam:ResetReactiveZoomTarget()
  LibStub("LibCamera-1.0"):SetZoom(alvo, 0.6)
end)
