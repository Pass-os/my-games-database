
DynamicCamDB = {
["global"] = {
["popOutFrame"] = {
["height"] = 499.9999084472656,
["opacity"] = 0,
["left"] = 506.0000915527344,
["top"] = 730,
},
},
["profiles"] = {
["Default"] = {
["version"] = 5,
["dcBigNPCs"] = {
},
["situations"] = {
["custom3"] = {
["name"] = "Conjurando (fora de combate)",
["enabled"] = true,
["priority"] = 60,
["delay"] = 0,
["events"] = {
"UNIT_SPELLCAST_START",
"UNIT_SPELLCAST_STOP",
"UNIT_SPELLCAST_SUCCEEDED",
"UNIT_SPELLCAST_INTERRUPTED",
"UNIT_SPELLCAST_FAILED",
"UNIT_SPELLCAST_CHANNEL_START",
"UNIT_SPELLCAST_CHANNEL_STOP",
"PLAYER_REGEN_DISABLED",
"PLAYER_REGEN_ENABLED",
},
["executeOnInit"] = "",
["condition"] = [=[if UnitAffectingCombat("player") then return false end
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
return true]=],
["executeOnEnter"] = "",
["executeOnExit"] = "",
["transitionTime"] = {
["timeToEnter"] = 0.6,
["timeToExit"] = 0.8,
},
["viewZoom"] = {
["enabled"] = true,
["viewZoomType"] = "zoom",
["zoomType"] = "in",
["zoomValue"] = 8,
["zoomMin"] = 5,
["zoomMax"] = 15,
["zoomTimeIsMax"] = false,
["viewNumber"] = 2,
["viewRestore"] = true,
["viewInstant"] = false,
["restoreDefaultViewNumber"] = 1,
},
["rotation"] = {
["enabled"] = false,
["rotationType"] = "continuous",
["rotationSpeed"] = 10,
["yawDegrees"] = 0,
["pitchDegrees"] = 0,
["rotateBack"] = true,
},
["hideUI"] = {
["enabled"] = false,
},
["situationSettings"] = {
["cvars"] = {
},
},
},
["custom4"] = {
["name"] = "Conjurando (em combate)",
["enabled"] = true,
["priority"] = 65,
["delay"] = 0,
["events"] = {
"UNIT_SPELLCAST_START",
"UNIT_SPELLCAST_STOP",
"UNIT_SPELLCAST_SUCCEEDED",
"UNIT_SPELLCAST_INTERRUPTED",
"UNIT_SPELLCAST_FAILED",
"UNIT_SPELLCAST_CHANNEL_START",
"UNIT_SPELLCAST_CHANNEL_STOP",
"PLAYER_REGEN_DISABLED",
"PLAYER_REGEN_ENABLED",
},
["executeOnInit"] = "",
["condition"] = [=[if not UnitAffectingCombat("player") then return false end
local c = UnitCastingInfo("player")
local ch = UnitChannelInfo("player")
local function tem(v) return (issecretvalue and issecretvalue(v)) or v ~= nil end
return tem(c) or tem(ch)]=],
["executeOnEnter"] = "",
["executeOnExit"] = "",
["transitionTime"] = {
["timeToEnter"] = 1,
["timeToExit"] = 1,
},
["viewZoom"] = {
["enabled"] = false,
["viewZoomType"] = "zoom",
["zoomType"] = "set",
["zoomValue"] = 10,
["zoomMin"] = 5,
["zoomMax"] = 15,
["zoomTimeIsMax"] = false,
["viewNumber"] = 2,
["viewRestore"] = true,
["viewInstant"] = false,
["restoreDefaultViewNumber"] = 1,
},
["rotation"] = {
["enabled"] = false,
["rotationType"] = "continuous",
["rotationSpeed"] = 10,
["yawDegrees"] = 0,
["pitchDegrees"] = 0,
["rotateBack"] = true,
},
["hideUI"] = {
["enabled"] = false,
},
["situationSettings"] = {
["cvars"] = {
},
},
},
["050"] = {
["enabled"] = true,
["situationSettings"] = {
["cvars"] = {
["test_cameraHeadMovementStrength"] = 0,
["test_cameraOverShoulder"] = 0,
},
},
},
["030"] = {
["enabled"] = true,
["situationSettings"] = {
["cvars"] = {
["test_cameraHeadMovementStrength"] = 0,
["test_cameraOverShoulder"] = 0,
},
},
},
["020"] = {
["enabled"] = true,
["situationSettings"] = {
["cvars"] = {
["test_cameraHeadMovementStrength"] = 0,
["test_cameraOverShoulder"] = 0,
},
},
},
["302"] = {
["enabled"] = true,
["viewZoom"] = {
["enabled"] = true,
["zoomType"] = "in",
["zoomValue"] = 7,
},
},
["custom1"] = {
["enabled"] = true,
["situationSettings"] = {
["cvars"] = {
["test_cameraOverShoulder"] = 0.6,
["test_cameraTargetFocusInteractEnable"] = 1,
["test_cameraTargetFocusInteractStrengthPitch"] = 0.75,
["test_cameraTargetFocusInteractStrengthYaw"] = 1,
},
},
["transitionTime"] = {
["timeToEnter"] = 0.3,
["timeToExit"] = 0.5,
},
["executeOnInit"] = "this.frames = {\"AuctionHouseFrame\", \"BankFrame\", \"ClassTrainerFrame\", \"GossipFrame\", \"ImmersionFrame\", \"MerchantFrame\", \"QuestFrame\"}\n\nDynamicCam.db.profile.dcBigNPCs = DynamicCam.db.profile.dcBigNPCs or {}\n\nthis.GetNpcId = function(unit)\n  local guid = UnitGUID(unit)\n  if not guid or (issecretvalue and issecretvalue(guid)) then return nil end\n  local unitType, _, _, _, _, npcId = strsplit(\"-\", guid)\n  if unitType == \"Creature\" or unitType == \"Vehicle\" then return npcId end\n  return nil\nend\n\ngetfenv(0).SLASH_DCNPCGRANDE1 = \"/npcgrande\"\nSlashCmdList[\"DCNPCGRANDE\"] = function()\n  local list = DynamicCam.db.profile.dcBigNPCs\n  local unit = UnitExists(\"npc\") and \"npc\" or \"target\"\n  local npcId = this.GetNpcId(unit)\n  if not npcId then\n    print(\"|cff33ccffDynamicCam:|r fale com o NPC (ou selecione-o) antes de usar /npcgrande\")\n    return\n  end\n  local name = UnitName(unit)\n  if issecretvalue and issecretvalue(name) then name = nil end\n  if list[npcId] then\n    list[npcId] = nil\n    print(\"|cff33ccffDynamicCam:|r \" .. (name or npcId) .. \" removido da lista de NPCs grandes\")\n  else\n    list[npcId] = name or true\n    print(\"|cff33ccffDynamicCam:|r \" .. (name or npcId) .. \" marcado como NPC grande - a camera vai afastar nele\")\n  end\n  DynamicCam:EvaluateSituations()\nend\n",
["condition"] = [=[if not UnitExists("npc") then return false end
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
return false]=],
["viewZoom"] = {
["enabled"] = true,
["zoomMax"] = 15,
["zoomMin"] = 5,
["viewNumber"] = 2,
["zoomType"] = "out",
["viewInstant"] = false,
["zoomValue"] = 1.5,
["viewRestore"] = true,
["restoreDefaultViewNumber"] = 1,
["zoomTimeIsMax"] = false,
["viewZoomType"] = "zoom",
},
["rotation"] = {
["enabled"] = false,
["pitchDegrees"] = 0,
["rotationType"] = "continuous",
["rotationSpeed"] = 10,
["yawDegrees"] = 0,
["rotateBack"] = true,
},
["executeOnEnter"] = "",
["name"] = "NPC grande (dialogo)",
["hideUI"] = {
["enabled"] = false,
},
["executeOnExit"] = "",
["priority"] = 115,
["delay"] = 0,
["events"] = {
"AUCTION_HOUSE_CLOSED",
"AUCTION_HOUSE_SHOW",
"BANKFRAME_CLOSED",
"BANKFRAME_OPENED",
"GOSSIP_CLOSED",
"GOSSIP_SHOW",
"MERCHANT_CLOSED",
"MERCHANT_SHOW",
"PLAYER_INTERACTION_MANAGER_FRAME_HIDE",
"PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
"PLAYER_TARGET_CHANGED",
"QUEST_COMPLETE",
"QUEST_DETAIL",
"QUEST_FINISHED",
"QUEST_GREETING",
"QUEST_PROGRESS",
"TRAINER_CLOSED",
"TRAINER_SHOW",
},
},
["002"] = {
["enabled"] = true,
["situationSettings"] = {
["cvars"] = {
["test_cameraOverShoulder"] = 0.3,
},
},
["viewZoom"] = {
["zoomMax"] = 12,
["zoomType"] = "range",
["enabled"] = true,
},
},
["005"] = {
["enabled"] = true,
["situationSettings"] = {
["cvars"] = {
["test_cameraOverShoulder"] = 0.3,
},
},
["viewZoom"] = {
["zoomMax"] = 12,
["zoomType"] = "range",
["enabled"] = true,
},
},
["102"] = {
["enabled"] = true,
["viewZoom"] = {
["enabled"] = true,
["zoomValue"] = 20,
},
},
["303"] = {
["enabled"] = true,
["rotation"] = {
["enabled"] = true,
["rotationSpeed"] = 5,
},
["viewZoom"] = {
["enabled"] = true,
["zoomValue"] = 12,
},
["hideUI"] = {
["fadeOpacity"] = 0,
["enabled"] = true,
},
},
["160"] = {
["enabled"] = true,
["viewZoom"] = {
["enabled"] = true,
["zoomValue"] = 19,
},
["hideUI"] = {
["enabled"] = true,
["fadeOpacity"] = 0,
["keepChatFrame"] = true,
},
},
["060"] = {
["enabled"] = true,
["situationSettings"] = {
["cvars"] = {
["test_cameraHeadMovementStrength"] = 0,
["test_cameraOverShoulder"] = 0,
},
},
},
["300"] = {
["enabled"] = true,
["transitionTime"] = {
["timeToEnter"] = 0.2,
["timeToExit"] = 0.5,
},
["executeOnEnter"] = "this.vol = this.vol or tonumber(GetCVar(\"Sound_MusicVolume\")) or 0.4\nthis.t = (this.t or 0) + 1\nlocal t, from, to = this.t, tonumber(GetCVar(\"Sound_MusicVolume\")) or this.vol, 0.03\nlocal steps, dur = 30, 2.5\nfor i = 1, steps do\n  C_Timer.After(i * dur / steps, function()\n    if this.t == t then\n      local p = i / steps\n      p = p * p * (3 - 2 * p)\n      SetCVar(\"Sound_MusicVolume\", from + (to - from) * p)\n    end\n  end)\nend",
["rotation"] = {
["pitchDegrees"] = -5,
["rotationType"] = "degrees",
},
["executeOnExit"] = "if not this.vol then return end\nthis.t = (this.t or 0) + 1\nlocal t, from, to = this.t, tonumber(GetCVar(\"Sound_MusicVolume\")) or 0, this.vol\nlocal steps, dur = 40, 3.5\nfor i = 1, steps do\n  C_Timer.After(i * dur / steps, function()\n    if this.t == t then\n      local p = i / steps\n      p = p * p * (3 - 2 * p)\n      SetCVar(\"Sound_MusicVolume\", from + (to - from) * p)\n      if i == steps then this.vol = nil end\n    end\n  end)\nend",
["viewZoom"] = {
["enabled"] = true,
["zoomType"] = "in",
["zoomValue"] = 3,
},
["situationSettings"] = {
["cvars"] = {
["test_cameraOverShoulder"] = 0.6,
["test_cameraTargetFocusInteractEnable"] = 1,
["test_cameraTargetFocusInteractStrengthPitch"] = 0.75,
["test_cameraTargetFocusInteractStrengthYaw"] = 1,
},
},
},
["200"] = {
["enabled"] = true,
["rotation"] = {
["enabled"] = true,
["rotationSpeed"] = 20,
},
["viewZoom"] = {
["enabled"] = true,
["zoomValue"] = 8,
},
["hideUI"] = {
["fadeOpacity"] = 0,
["enabled"] = true,
},
},
["100"] = {
["enabled"] = true,
["transitionTime"] = {
["timeToEnter"] = 1.5,
["timeToExit"] = 2,
},
["situationSettings"] = {
["cvars"] = {
["cameraDistanceMaxZoomFactor"] = 2.6,
},
},
["viewZoom"] = {
["enabled"] = true,
["zoomValue"] = 15,
},
["hideUI"] = {
["customFramesToKeep"] = {
["MerchantFrame"] = false,
["MainActionBar"] = true,
["ClassTrainerFrame"] = false,
["StaticPopup1"] = false,
["BankFrame"] = false,
["WardrobeFrame"] = false,
["BuffFrame"] = false,
["DebuffFrame"] = false,
["AuctionHouseFrame"] = false,
["QuestFrame"] = false,
["GossipFrame"] = false,
["PetStableFrame"] = false,
["BagnonBankFrame1"] = false,
},
["keepCustomFrames"] = true,
["enabled"] = true,
["fadeOpacity"] = 0,
["keepEncounterBar"] = true,
["keepMinimap"] = true,
},
},
["301"] = {
["enabled"] = true,
["transitionTime"] = {
["timeToEnter"] = 0.3,
["timeToExit"] = 0.5,
},
["situationSettings"] = {
["cvars"] = {
["test_cameraTargetFocusInteractEnable"] = 1,
},
},
["viewZoom"] = {
["enabled"] = true,
["zoomType"] = "in",
["zoomValue"] = 6,
},
},
},
["standardSettings"] = {
["cvars"] = {
["test_cameraTargetFocusInteractEnable"] = 1,
["test_cameraDynamicPitch"] = 1,
["test_cameraHeadMovementStrength"] = 0.5,
["cameraDistanceMaxZoomFactor"] = 2.6,
},
},
},
["MODO HISTORIA"] = {
["version"] = 5,
},
},
}
minZoomValues = {
}
