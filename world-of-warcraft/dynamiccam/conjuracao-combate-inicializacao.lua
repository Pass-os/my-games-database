-- DynamicCam > Situacoes > "Conjurando (em combate)" > Controles de Situacao > Script de Inicializacao
-- Marca quando uma conjuracao/canalizacao do jogador comeca e termina, pelos
-- eventos do jogo. Em combate o UnitCastingInfo pode devolver valores secretos
-- (WoW 12), e ai a condicao antiga nao sabia quando a magia tinha acabado.

local conjuracao = DynamicCam.conjuracaoEmCombate or {}
DynamicCam.conjuracaoEmCombate = conjuracao

-- Um so frame, mesmo que o script rode de novo ao editar a situacao.
if not conjuracao.frame then
  local eventosQueComecam = {
    UNIT_SPELLCAST_START = true,
    UNIT_SPELLCAST_CHANNEL_START = true,
    UNIT_SPELLCAST_EMPOWER_START = true,
  }
  local eventosQueTerminam = {
    UNIT_SPELLCAST_STOP = true,
    UNIT_SPELLCAST_CHANNEL_STOP = true,
    UNIT_SPELLCAST_EMPOWER_STOP = true,
    UNIT_SPELLCAST_INTERRUPTED = true,
  }

  conjuracao.frame = CreateFrame("Frame")
  for evento in pairs(eventosQueComecam) do conjuracao.frame:RegisterUnitEvent(evento, "player") end
  for evento in pairs(eventosQueTerminam) do conjuracao.frame:RegisterUnitEvent(evento, "player") end

  conjuracao.frame:SetScript("OnEvent", function(_, evento)
    if eventosQueComecam[evento] then
      conjuracao.conjurando = true
    elseif eventosQueTerminam[evento] then
      conjuracao.conjurando = false
    end
    DynamicCam:EvaluateSituations()
  end)
end
