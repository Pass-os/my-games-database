-- DynamicCam > Situacoes > "Coleta" (320) > Controles de Situacao > Condicao
-- Substitui a condicao original do DynamicCam, que so conhece os IDs de magia
-- de coleta ate The War Within. Aqui vale tambem pelo NOME da magia (o mesmo
-- em toda expansao), entao minerar/herborismo/esfolar do Midnight entram.
-- Prioridade 120 (vence "Conjurando (fora de combate)", 60).
-- Eventos: os mesmos da original (UNIT_SPELLCAST_START/STOP/SUCCEEDED/
--   CHANNEL_START/CHANNEL_STOP/CHANNEL_UPDATE/INTERRUPTED).

local MAGIAS_BASE_DE_COLETA = {
  2575,  -- Mineracao
  2366,  -- Herborismo
  8613,  -- Esfolar
}

local function legivel(valor) return valor ~= nil and not (issecretvalue and issecretvalue(valor)) end

local nomeDaMagia = UnitCastingInfo("player")
if not legivel(nomeDaMagia) then
  nomeDaMagia = UnitChannelInfo("player")
end
if not legivel(nomeDaMagia) then return false end

for _, magia in ipairs(MAGIAS_BASE_DE_COLETA) do
  if C_Spell.GetSpellName(magia) == nomeDaMagia then return true end
end
return false
