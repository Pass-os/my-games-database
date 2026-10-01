-- DynamicCam > Situacoes > "Conjurando (fora de combate)" > Controles de Situacao > Condicao
-- Verdadeira fora de combate enquanto voce conjura ou canaliza uma magia
-- "comum" (historia, invocacao, ritual...). Ficam de fora, porque tem
-- situacao propria:
--   - criar item de profissao   -> "Janela de Profissoes Aberta" (330)
--   - coletar (minerar, herborismo, esfolar) -> "Coleta" (320, prioridade 120 vence esta)
--   - pescar                    -> "Pesca" (302)
--   - pedra de regresso/teleporte -> "Pedra de Regresso/Teleporte" (200, prioridade 130 vence esta)
--   - invocar montaria          -> nada (nao faz sentido aproximar)
--
-- Eventos: UNIT_SPELLCAST_START, UNIT_SPELLCAST_STOP, UNIT_SPELLCAST_SUCCEEDED,
--   UNIT_SPELLCAST_INTERRUPTED, UNIT_SPELLCAST_FAILED, UNIT_SPELLCAST_CHANNEL_START,
--   UNIT_SPELLCAST_CHANNEL_STOP, PLAYER_REGEN_DISABLED, PLAYER_REGEN_ENABLED
-- Prioridade 60. Zoom/Visao DESLIGADO: o zoom e relativo, pelos scripts de entrada/saida.

if UnitAffectingCombat("player") then return false end

local function existe(valor) return (issecretvalue and issecretvalue(valor)) or valor ~= nil end
local function legivel(valor) return valor ~= nil and not (issecretvalue and issecretvalue(valor)) end

local function ehMontaria(magia)
  return C_MountJournal and C_MountJournal.GetMountFromSpell and C_MountJournal.GetMountFromSpell(magia) ~= nil
end


-- Janela de profissoes aberta: quem cuida da camera e a situacao 330.
if ProfessionsFrame and ProfessionsFrame:IsShown() then return false end

local nomeConjuracao, _, _, _, _, conjuracaoDeProfissao, _, _, magiaConjurada = UnitCastingInfo("player")
if existe(nomeConjuracao) then
  if legivel(conjuracaoDeProfissao) and conjuracaoDeProfissao then return false end
  if legivel(magiaConjurada) and ehMontaria(magiaConjurada) then
    return false
  end
  return true
end

local nomeCanalizacao, _, _, _, _, canalizacaoDeProfissao = UnitChannelInfo("player")
if not existe(nomeCanalizacao) then return false end
if legivel(canalizacaoDeProfissao) and canalizacaoDeProfissao then return false end
local PESCA = 7620
if legivel(nomeCanalizacao) and C_Spell and C_Spell.GetSpellName and nomeCanalizacao == C_Spell.GetSpellName(PESCA) then
  return false
end
return true
