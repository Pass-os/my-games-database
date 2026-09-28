-- DynamicCam > Situacoes > "Transformacao (historia)" > Controles de Situacao > Condicao
-- Ativa quando a historia te poe em outra forma/criatura (virar aguia, controlar
-- um bicho, montar num veiculo de missao). A Blizzard usa tres mecanismos:
--   veiculo            -> UnitUsingVehicle("player")
--   barra substituta   -> HasOverrideActionBar()
--   possessao          -> IsPossessBarVisible()
--
-- Eventos da situacao (campo "Eventos", separados por virgula):
--   UNIT_ENTERED_VEHICLE, UNIT_EXITED_VEHICLE, UPDATE_OVERRIDE_ACTIONBAR,
--   UPDATE_POSSESS_BAR, UPDATE_VEHICLE_ACTIONBAR
--
-- Prioridade: 1001 (acima do "Veiculo" padrao, 1000, e de qualquer montaria).
-- Zoom: Definir 20 (a "Montaria (apenas no ar)" usa 18).
-- Ocultar Interface: igual a montaria no ar, mas mantendo tambem
-- OverrideActionBar - e nela que ficam as habilidades da transformacao
-- (a MainActionBar e a barra normal do personagem).
--
-- Cenas com camera roteirizada pela Blizzard (cinematicas, voos guiados)
-- ignoram qualquer addon de camera.

if UnitUsingVehicle("player") then return true end
if HasOverrideActionBar and HasOverrideActionBar() then return true end
if IsPossessBarVisible and IsPossessBarVisible() then return true end
return false
