-- DynamicCam > Situacoes > "Conjurando (fora de combate)" e "Conjurando (em combate)"
-- > Controles de Situacao > Script de Saida
-- Volta para o ponto de partida anotado pelo Script de Entrada.
-- Excecao: se depois da magia vem a camera livre (ou, com zoom fixo, uma
-- situacao sem zoom, como Masmorra) e o addon ZoomLivreEstavel
-- esta instalado, quem leva a camera de volta e ele (para a SUA distancia).
-- Sem isso, conjurar montado (montaria 15 -> magia -> livre) devolvia a
-- camera para 15, e 15 virava a distancia livre.

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

  if ZoomLivreEstavel and ZoomLivreEstavel.CuidaDe and ZoomLivreEstavel.CuidaDe(situacaoAtual) then
    estado.fimDoRetorno = nil
    return
  end

  -- Anota quando a volta termina: se conjurar de novo antes, o Script de
  -- Entrada parte do mesmo ponto de partida, nao do meio do caminho.
  estado.fimDoRetorno = GetTime() + segundosParaAfastar
  DynamicCam:ResetReactiveZoomTarget()
  LibStub("LibCamera-1.0"):SetZoom(estado.pontoDePartida, segundosParaAfastar)
end)
