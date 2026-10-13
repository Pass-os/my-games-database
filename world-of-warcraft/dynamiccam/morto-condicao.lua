-- DynamicCam > Situacoes > "Morto / fantasma" > Controles de Situacao > Condicao
-- Ativa morto ou correndo como fantasma ate o corpo.
--
-- Eventos: PLAYER_DEAD, PLAYER_ALIVE, PLAYER_UNGHOST, ZONE_CHANGED_NEW_AREA
-- Prioridade: 1200 (acima de taxi/veiculo e profissoes).
-- Zoom: Afastar 15 (so afasta se estiver mais perto), para achar o corpo.

return UnitIsDeadOrGhost("player") and true or false
