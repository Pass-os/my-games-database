-- DynamicCam > Situacoes > "NPC grande (dialogo)" > Controles de Situacao > Condicao
-- Ativa so quando ha dialogo aberto com um NPC marcado por /npcgrande.
-- Prioridade da situacao: 115 (acima dos 110 do "NPC Interaction", para vencer).

local list = DynamicCam.db.profile.dcBigNPCs
if not list or not UnitExists("npc") then return false end
local npcId = this.GetNpcId("npc")
if not npcId or not list[npcId] then return false end

for _, v in pairs(this.frames) do
  if _G[v] and _G[v]:IsShown() then return true end
end
return false
