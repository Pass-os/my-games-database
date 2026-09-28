-- DynamicCam > Situacoes > "Conjurando (em combate)" > Controles de Situacao > Condicao
-- Par da "Conjurando (fora de combate)": mesma deteccao, so que em combate.
-- Criada sem acoes (sem zoom): configurar pela interface.
--
-- Eventos (campo "Eventos"):
--   UNIT_SPELLCAST_START, UNIT_SPELLCAST_STOP, UNIT_SPELLCAST_SUCCEEDED,
--   UNIT_SPELLCAST_INTERRUPTED, UNIT_SPELLCAST_FAILED,
--   UNIT_SPELLCAST_CHANNEL_START, UNIT_SPELLCAST_CHANNEL_STOP,
--   PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED
--
-- Prioridade: 60. Ganha das situacoes de instancia (020/030/050/060), entao
-- enquanto conjura em masmorra/raide o ombro e o balanco voltam ao da base,
-- a menos que se ponha ombro 0 e cabeca 0 nas Configuracoes de Situacao dela.

if not UnitAffectingCombat("player") then return false end
local c = UnitCastingInfo("player")
local ch = UnitChannelInfo("player")
local function tem(v) return (issecretvalue and issecretvalue(v)) or v ~= nil end
return tem(c) or tem(ch)
