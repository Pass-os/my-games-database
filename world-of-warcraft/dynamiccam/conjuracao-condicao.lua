-- DynamicCam > Situacoes > "Conjurando (fora de combate)" > Controles de Situacao > Condicao
-- Aproxima a camera enquanto voce conjura ou
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
--
-- Ignora invocacao de montaria (C_MountJournal.GetMountFromSpell) e a pesca,
-- que tem situacao propria de prioridade menor (20) e perderia para esta.

if UnitAffectingCombat("player") then return false end
local function tem(v) return (issecretvalue and issecretvalue(v)) or v ~= nil end
local function secreto(v) return issecretvalue and issecretvalue(v) end

-- Conjuracao: ignora magias que invocam montaria.
local nome, _, _, _, _, _, _, _, spellID = UnitCastingInfo("player")
if tem(nome) then
  if spellID and not secreto(spellID) and C_MountJournal and C_MountJournal.GetMountFromSpell
     and C_MountJournal.GetMountFromSpell(spellID) then
    return false
  end
  return true
end

-- Canalizacao: ignora a pesca, que tem situacao propria (302). A pesca tem
-- prioridade 20, menor que os 60 desta, entao sem isso esta ganharia dela.
local canal = UnitChannelInfo("player")
if not tem(canal) then return false end
if not secreto(canal) and C_Spell and C_Spell.GetSpellName and canal == C_Spell.GetSpellName(7620) then
  return false
end
return true
