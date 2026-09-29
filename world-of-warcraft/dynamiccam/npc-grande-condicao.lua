-- DynamicCam > Situacoes > "NPC grande (dialogo)" > Controles de Situacao > Condicao
-- Ativa quando ha dialogo aberto com um NPC grande. "Grande" e:
--   - marcado a mao com /npcgrande (lista em DynamicCam.db.profile.dcBigNPCs), ou
--   - medido pelo addon proprio NpcAltura com altura >= limite (/altura limite N).
-- Sem o NpcAltura instalado, vale so a lista manual.
-- Prioridade da situacao: 115 (acima dos 110 da "Interacao com NPC", para vencer).

if not UnitExists("npc") then return false end
local npcId = this.GetNpcId("npc")
if not npcId then return false end

local list = DynamicCam.db.profile.dcBigNPCs
local grande = list and list[npcId]
if not grande and NpcAltura and NpcAltura.EhGrande then
  grande = NpcAltura.EhGrande(npcId)
end
if not grande then return false end

for _, v in pairs(this.frames) do
  if _G[v] and _G[v]:IsShown() then return true end
end
return false
