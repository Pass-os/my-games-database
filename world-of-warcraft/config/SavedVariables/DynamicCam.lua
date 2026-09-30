
DynamicCamDB = {
["global"] = {
["popOutFrame"] = {
["height"] = 499.9999084472656,
["opacity"] = 0,
["left"] = 524.6671752929688,
["top"] = 734.4443969726562,
},
},
["profiles"] = {
["Default"] = {
["version"] = 5,
["dcBigNPCs"] = {
},
["situations"] = {
["custom4"] = {
["enabled"] = true,
["name"] = "Conjurando (em combate)",
["executeOnEnter"] = "-- ===== AJUSTE AQUI =====\nlocal distanciaParaAproximar = 3      -- quanto a camera chega mais perto ao conjurar\nlocal distanciaMinimaDaCamera = 1.5   -- a camera nunca fica mais perto que isso\nlocal segundosParaAproximar = 0.6     -- duracao do movimento de aproximar\n-- =======================\n\nlocal estado = DynamicCam.zoomConjurar or {}\nDynamicCam.zoomConjurar = estado\n\nC_Timer.After(0, function()\n  if estado.aproximado then return end -- ja aproximou (ex.: entrou em combate no meio da magia)\n\n  -- Se a camera ainda esta voltando da magia anterior (conjurou de novo rapido),\n  -- a base e o ponto para onde ela estava voltando, nao o meio do caminho.\n  local aindaVoltando = estado.fimDoRetorno and GetTime() < estado.fimDoRetorno\n  local zoomAtual = aindaVoltando and estado.zoomDoRetorno or GetCameraZoom()\n  local zoomDestino = math.max(zoomAtual - distanciaParaAproximar, distanciaMinimaDaCamera)\n  if zoomDestino >= zoomAtual then return end\n\n  estado.aproximado = true\n  estado.quantoAproximou = zoomAtual - zoomDestino\n  estado.fimDoRetorno = nil\n  DynamicCam:ResetReactiveZoomTarget()\n  LibStub(\"LibCamera-1.0\"):SetZoom(zoomDestino, segundosParaAproximar)\nend)",
["executeOnInit"] = "",
["condition"] = "if not UnitAffectingCombat(\"player\") then return false end\nlocal c = UnitCastingInfo(\"player\")\nlocal ch = UnitChannelInfo(\"player\")\nlocal function tem(v) return (issecretvalue and issecretvalue(v)) or v ~= nil end\nreturn tem(c) or tem(ch)",
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
["rotation"] = {
["enabled"] = false,
["pitchDegrees"] = 0,
["rotationType"] = "degrees",
["rotationSpeed"] = 3,
["yawDegrees"] = 5,
["rotateBack"] = true,
},
["transitionTime"] = {
["timeToEnter"] = 0.5,
["timeToExit"] = 0.5,
},
["viewZoom"] = {
["enabled"] = false,
["zoomMax"] = 15,
["zoomMin"] = 5,
["viewZoomType"] = "zoom",
["zoomType"] = "set",
["zoomTimeIsMax"] = false,
["zoomValue"] = 4,
["viewRestore"] = true,
["restoreDefaultViewNumber"] = 1,
["viewNumber"] = 2,
["viewInstant"] = false,
},
["hideUI"] = {
["enabled"] = false,
},
["situationSettings"] = {
["cvars"] = {
["test_cameraTargetFocusEnemyStrengthPitch"] = 0.4,
["test_cameraTargetFocusInteractEnable"] = 1,
["test_cameraTargetFocusInteractStrengthPitch"] = 0.75,
["test_cameraTargetFocusEnemyEnable"] = 1,
["test_cameraTargetFocusEnemyStrengthYaw"] = 0.6000000000000001,
["test_cameraTargetFocusInteractStrengthYaw"] = 1,
},
},
["priority"] = 65,
["delay"] = 0,
["executeOnExit"] = "-- ===== AJUSTE AQUI =====\nlocal segundosParaAfastar = 0.8   -- duracao do movimento de voltar\n-- =======================\n\nlocal estado = DynamicCam.zoomConjurar\nif not estado then return end\n\nC_Timer.After(0.05, function()\n  -- Passou direto para a outra situacao de conjuracao: continua aproximado.\n  local situacaoAtual = DynamicCam.currentSituationID\n  local aindaConjurando = situacaoAtual == \"custom3\" or situacaoAtual == \"custom4\"\n  if aindaConjurando or not estado.aproximado then return end\n\n  estado.aproximado = false\n  local zoomDestino = GetCameraZoom() + estado.quantoAproximou\n  -- Anota para onde esta voltando: se conjurar de novo antes de chegar,\n  -- o Script de Entrada parte daqui e nao do meio do caminho.\n  estado.zoomDoRetorno = zoomDestino\n  estado.fimDoRetorno = GetTime() + segundosParaAfastar\n  DynamicCam:ResetReactiveZoomTarget()\n  LibStub(\"LibCamera-1.0\"):SetZoom(zoomDestino, segundosParaAfastar)\nend)\n",
},
["custom3"] = {
["enabled"] = true,
["name"] = "Conjurando (fora de combate)",
["executeOnEnter"] = "-- ===== AJUSTE AQUI =====\nlocal distanciaParaAproximar = 3      -- quanto a camera chega mais perto ao conjurar\nlocal distanciaMinimaDaCamera = 1.5   -- a camera nunca fica mais perto que isso\nlocal segundosParaAproximar = 0.6     -- duracao do movimento de aproximar\n-- =======================\n\nlocal estado = DynamicCam.zoomConjurar or {}\nDynamicCam.zoomConjurar = estado\n\nC_Timer.After(0, function()\n  if estado.aproximado then return end -- ja aproximou (ex.: entrou em combate no meio da magia)\n\n  local zoomAtual = GetCameraZoom()\n  local zoomDestino = math.max(zoomAtual - distanciaParaAproximar, distanciaMinimaDaCamera)\n  if zoomDestino >= zoomAtual then return end\n\n  estado.aproximado = true\n  estado.quantoAproximou = zoomAtual - zoomDestino\n  DynamicCam:ResetReactiveZoomTarget()\n  LibStub(\"LibCamera-1.0\"):SetZoom(zoomDestino, segundosParaAproximar)\nend)",
["executeOnInit"] = "",
["condition"] = "if UnitAffectingCombat(\"player\") then return false end\nlocal function tem(v) return (issecretvalue and issecretvalue(v)) or v ~= nil end\nlocal function secreto(v) return issecretvalue and issecretvalue(v) end\n\nlocal nome, _, _, _, _, _, _, _, spellID = UnitCastingInfo(\"player\")\nif tem(nome) then\n  if spellID and not secreto(spellID) and C_MountJournal and C_MountJournal.GetMountFromSpell\n     and C_MountJournal.GetMountFromSpell(spellID) then\n    return false\n  end\n  return true\nend\n\nlocal canal = UnitChannelInfo(\"player\")\nif not tem(canal) then return false end\nif not secreto(canal) and C_Spell and C_Spell.GetSpellName and canal == C_Spell.GetSpellName(7620) then\n  return false\nend\nreturn true",
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
["rotation"] = {
["enabled"] = true,
["pitchDegrees"] = -5,
["rotationType"] = "degrees",
["rotationSpeed"] = 10,
["yawDegrees"] = 10,
["rotateBack"] = true,
},
["transitionTime"] = {
["timeToEnter"] = 1.5,
["timeToExit"] = 1,
},
["viewZoom"] = {
["enabled"] = false,
["zoomMax"] = 15,
["zoomMin"] = 5,
["viewZoomType"] = "zoom",
["zoomType"] = "in",
["zoomTimeIsMax"] = false,
["zoomValue"] = 2,
["viewRestore"] = true,
["restoreDefaultViewNumber"] = 1,
["viewNumber"] = 2,
["viewInstant"] = false,
},
["hideUI"] = {
["enabled"] = false,
},
["situationSettings"] = {
["cvars"] = {
["test_cameraTargetFocusEnemyStrengthPitch"] = 0.5,
["test_cameraTargetFocusInteractEnable"] = 1,
["test_cameraTargetFocusInteractStrengthPitch"] = 0.75,
["test_cameraTargetFocusEnemyEnable"] = 1,
["test_cameraTargetFocusEnemyStrengthYaw"] = 1,
["test_cameraTargetFocusInteractStrengthYaw"] = 1,
},
},
["priority"] = 60,
["delay"] = 0,
["executeOnExit"] = "-- ===== AJUSTE AQUI =====\nlocal segundosParaAfastar = 0.8   -- duracao do movimento de voltar\n-- =======================\n\nlocal estado = DynamicCam.zoomConjurar\nif not estado then return end\n\nC_Timer.After(0.05, function()\n  -- Passou direto para a outra situacao de conjuracao: continua aproximado.\n  local situacaoAtual = DynamicCam.currentSituationID\n  local aindaConjurando = situacaoAtual == \"custom3\" or situacaoAtual == \"custom4\"\n  if aindaConjurando or not estado.aproximado then return end\n\n  estado.aproximado = false\n  local zoomDestino = GetCameraZoom() + estado.quantoAproximou\n  DynamicCam:ResetReactiveZoomTarget()\n  LibStub(\"LibCamera-1.0\"):SetZoom(zoomDestino, segundosParaAfastar)\nend)",
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
["005"] = {
["enabled"] = true,
["situationSettings"] = {
["cvars"] = {
["test_cameraOverShoulder"] = 0.3,
},
},
["viewZoom"] = {
["enabled"] = true,
["zoomMax"] = 12,
["zoomType"] = "range",
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
["condition"] = "if not UnitExists(\"npc\") then return false end\nlocal npcId = this.GetNpcId(\"npc\")\nif not npcId then return false end\n\nlocal list = DynamicCam.db.profile.dcBigNPCs\nlocal grande = list and list[npcId]\nif not grande and NpcAltura and NpcAltura.EhGrande then\n  grande = NpcAltura.EhGrande(npcId)\nend\nif not grande then return false end\n\nfor _, v in pairs(this.frames) do\n  if _G[v] and _G[v]:IsShown() then return true end\nend\nreturn false",
["viewZoom"] = {
["enabled"] = true,
["zoomMax"] = 15,
["zoomMin"] = 5,
["viewInstant"] = false,
["zoomType"] = "out",
["viewNumber"] = 2,
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
["302"] = {
["enabled"] = true,
["viewZoom"] = {
["enabled"] = true,
["zoomType"] = "in",
["zoomValue"] = 7,
},
},
["020"] = {
["enabled"] = true,
["situationSettings"] = {
["cvars"] = {
["test_cameraDynamicPitchBaseFovPad"] = 0.09,
["test_cameraDynamicPitch"] = 1,
["test_cameraHeadMovementStrength"] = 0,
["test_cameraDynamicPitchBaseFovPadDownScale"] = 0.25,
["test_cameraDynamicPitchSmartPivotCutoffDist"] = 10,
["test_cameraOverShoulder"] = 0,
["test_cameraDynamicPitchBaseFovPadFlying"] = 0.75,
},
},
["viewZoom"] = {
["zoomValue"] = 7.5,
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
["enabled"] = true,
["zoomMax"] = 12,
["zoomType"] = "range",
},
},
["102"] = {
["enabled"] = true,
["viewZoom"] = {
["enabled"] = true,
["zoomValue"] = 20,
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
["enabled"] = true,
["keepCustomFrames"] = true,
["fadeOpacity"] = 0,
["keepMinimap"] = true,
},
},
["160"] = {
["enabled"] = true,
["viewZoom"] = {
["enabled"] = true,
["zoomValue"] = 19.5,
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
["300"] = {
["enabled"] = true,
["rotation"] = {
["pitchDegrees"] = -5,
["rotationType"] = "degrees",
},
["transitionTime"] = {
["timeToEnter"] = 0.2,
["timeToExit"] = 0.5,
},
["situationSettings"] = {
["cvars"] = {
["test_cameraOverShoulder"] = 0.6,
["test_cameraTargetFocusInteractEnable"] = 1,
["test_cameraTargetFocusInteractStrengthPitch"] = 0.75,
["test_cameraTargetFocusInteractStrengthYaw"] = 1,
},
},
["executeOnEnter"] = "this.vol = this.vol or tonumber(GetCVar(\"Sound_MusicVolume\")) or 0.4\nthis.t = (this.t or 0) + 1\nlocal t, from, to = this.t, tonumber(GetCVar(\"Sound_MusicVolume\")) or this.vol, 0.03\nlocal steps, dur = 30, 2.5\nfor i = 1, steps do\n  C_Timer.After(i * dur / steps, function()\n    if this.t == t then\n      local p = i / steps\n      p = p * p * (3 - 2 * p)\n      SetCVar(\"Sound_MusicVolume\", from + (to - from) * p)\n    end\n  end)\nend",
["viewZoom"] = {
["enabled"] = true,
["zoomType"] = "in",
["zoomValue"] = 3,
},
["hideUI"] = {
["customFramesToKeep"] = {
["ContainerFrame3"] = true,
["ContainerFrame1"] = true,
["ContainerFrame6"] = true,
["OverlayPlayerCastingBarFrame"] = true,
["ContainerFrameCombinedBags"] = true,
["ContainerFrame4"] = true,
["DressUpFrame"] = true,
["PlayerCastingBarFrame"] = true,
["ContainerFrame5"] = true,
["ContainerFrame2"] = true,
["SideDressUpFrame"] = true,
},
["enabled"] = true,
["keepCustomFrames"] = true,
["fadeOpacity"] = 0,
["keepMinimap"] = true,
},
["executeOnExit"] = "if not this.vol then return end\nthis.t = (this.t or 0) + 1\nlocal t, from, to = this.t, tonumber(GetCVar(\"Sound_MusicVolume\")) or 0, this.vol\nlocal steps, dur = 40, 3.5\nfor i = 1, steps do\n  C_Timer.After(i * dur / steps, function()\n    if this.t == t then\n      local p = i / steps\n      p = p * p * (3 - 2 * p)\n      SetCVar(\"Sound_MusicVolume\", from + (to - from) * p)\n      if i == steps then this.vol = nil end\n    end\n  end)\nend",
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
["enabled"] = true,
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
["keepEncounterBar"] = true,
["fadeOpacity"] = 0,
["keepMinimap"] = true,
},
["transitionTime"] = {
["timeToEnter"] = 1.5,
["timeToExit"] = 2,
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
["reactiveZoomAddIncrements"] = 0,
["cvars"] = {
["test_cameraTargetFocusInteractEnable"] = 1,
["cameraZoomSpeed"] = 15,
["test_cameraHeadMovementStrength"] = 0.5,
["test_cameraDynamicPitch"] = 1,
["cameraDistanceMaxZoomFactor"] = 1,
["test_cameraOverShoulder"] = 0.8000000000000007,
},
["reactiveZoomAddIncrementsAlways"] = 3,
},
},
["MODO HISTORIA"] = {
["version"] = 5,
},
},
}
minZoomValues = {
}
