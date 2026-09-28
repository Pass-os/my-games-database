-- DynamicCam > Situacoes > "NPC grande (dialogo)" > Controles de Situacao > Script de Inicializacao
-- Cria o comando /npcgrande: marca/desmarca o NPC do dialogo (ou o alvo) como grande.
-- A lista fica em DynamicCam.db.profile.dcBigNPCs (salva com o perfil).
--
-- Os scripts do DynamicCam rodam num ambiente isolado: LER globais funciona,
-- mas ESCREVER uma global (SLASH_...) cai numa tabela do proprio ambiente e o
-- WoW nunca ve. Por isso SLASH_DCNPCGRANDE1 vai via getfenv(0), o _G de verdade.
-- (SlashCmdList e so lida, e a atribuicao e dentro dela, entao funciona direto.)

this.frames = {"AuctionHouseFrame", "BankFrame", "ClassTrainerFrame", "GossipFrame", "ImmersionFrame", "MerchantFrame", "QuestFrame"}

DynamicCam.db.profile.dcBigNPCs = DynamicCam.db.profile.dcBigNPCs or {}

this.GetNpcId = function(unit)
  local guid = UnitGUID(unit)
  if not guid or (issecretvalue and issecretvalue(guid)) then return nil end
  local unitType, _, _, _, _, npcId = strsplit("-", guid)
  if unitType == "Creature" or unitType == "Vehicle" then return npcId end
  return nil
end

getfenv(0).SLASH_DCNPCGRANDE1 = "/npcgrande"
SlashCmdList["DCNPCGRANDE"] = function()
  local list = DynamicCam.db.profile.dcBigNPCs
  local unit = UnitExists("npc") and "npc" or "target"
  local npcId = this.GetNpcId(unit)
  if not npcId then
    print("|cff33ccffDynamicCam:|r fale com o NPC (ou selecione-o) antes de usar /npcgrande")
    return
  end
  local name = UnitName(unit)
  if issecretvalue and issecretvalue(name) then name = nil end
  if list[npcId] then
    list[npcId] = nil
    print("|cff33ccffDynamicCam:|r " .. (name or npcId) .. " removido da lista de NPCs grandes")
  else
    list[npcId] = name or true
    print("|cff33ccffDynamicCam:|r " .. (name or npcId) .. " marcado como NPC grande - a camera vai afastar nele")
  end
  DynamicCam:EvaluateSituations()
end
