-- DynamicCam > Situacoes > "Conjurando (fora de combate)" > Controles de Situacao > Condicao
-- PROPOSTA, ainda nao aplicada. Aproxima a camera enquanto voce conjura ou
-- canaliza uma magia: profissoes, magias de historia, invocacoes, rituais.
--
-- Fora de combate de proposito: magias de combate tem 1-2 s de conjuracao e a
-- camera ficaria indo e voltando a cada uma. Tirar a primeira linha libera
-- em combate tambem.
--
-- Eventos (campo "Eventos"):
--   UNIT_SPELLCAST_START, UNIT_SPELLCAST_STOP, UNIT_SPELLCAST_SUCCEEDED,
--   UNIT_SPELLCAST_INTERRUPTED, UNIT_SPELLCAST_FAILED,
--   UNIT_SPELLCAST_CHANNEL_START, UNIT_SPELLCAST_CHANNEL_STOP,
--   PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED
--
-- Prioridade sugerida: 60 (abaixo de Pedra de regresso/teleporte, NPC,
-- montaria e taxi). Zoom sugerido: Aproximar 8. Transicao 0.6 / 0.8 s.
--
-- No 12.x algumas informacoes de conjuracao podem vir como "valor secreto";
-- um valor secreto so existe se ha conjuracao, entao conta como verdadeiro.

if UnitAffectingCombat("player") then return false end
local c = UnitCastingInfo("player")
local ch = UnitChannelInfo("player")
local function tem(v) return (issecretvalue and issecretvalue(v)) or v ~= nil end
return tem(c) or tem(ch)
