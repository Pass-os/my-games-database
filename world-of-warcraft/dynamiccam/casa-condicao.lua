-- DynamicCam > Situacoes > "Dentro da casa" > Controles de Situacao > Condicao
-- Ativa dentro da sua casa (ou da casa de outro jogador) do Midnight.
-- O terreno do lado de fora nao conta (ver C_Housing.IsInsidePlot).
--
-- Eventos: HOUSE_PLOT_ENTERED, HOUSE_PLOT_EXITED, ZONE_CHANGED_INDOORS,
--          ZONE_CHANGED, ZONE_CHANGED_NEW_AREA
-- Prioridade: 14 (acima de Cidade/Mundo Interiores, 11/10).
-- Zoom: Aproximar 6 (so aproxima se estiver mais longe). Ombro 0: comodo apertado.

return C_Housing and C_Housing.IsInsideHouse and C_Housing.IsInsideHouse() or false
