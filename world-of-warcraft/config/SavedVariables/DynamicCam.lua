
DynamicCamDB = {
["global"] = {
["popOutFrame"] = {
["height"] = 499.9999389648438,
["opacity"] = 0,
["left"] = 306.6658325195313,
["top"] = 730,
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
["executeOnEnter"] = "-- ===== AJUSTE AQUI =====\nlocal distanciaParaAproximar = 3      -- quanto a camera chega mais perto ao conjurar\nlocal distanciaMinimaDaCamera = 1.5   -- a camera nunca fica mais perto que isso\nlocal segundosParaAproximar = 0.6     -- duracao do movimento de aproximar\n-- =======================\n\nlocal estado = DynamicCam.zoomConjurar or {}\nDynamicCam.zoomConjurar = estado\n\nC_Timer.After(0, function()\n  if estado.aproximado then return end -- ja aproximou (ex.: entrou em combate no meio da magia)\n\n  -- Se a camera ainda esta voltando da magia anterior (conjurou de novo rapido),\n  -- o ponto de partida e o destino dessa volta, nao o meio do caminho.\n  local aindaVoltando = estado.fimDoRetorno and GetTime() < estado.fimDoRetorno\n  local pontoDePartida = aindaVoltando and estado.pontoDePartida or GetCameraZoom()\n  local zoomDestino = math.max(pontoDePartida - distanciaParaAproximar, distanciaMinimaDaCamera)\n  if zoomDestino >= pontoDePartida then return end\n\n  estado.aproximado = true\n  estado.pontoDePartida = pontoDePartida\n  estado.fimDoRetorno = nil\n  DynamicCam:ResetReactiveZoomTarget()\n  LibStub(\"LibCamera-1.0\"):SetZoom(zoomDestino, segundosParaAproximar)\nend)\n",
["executeOnInit"] = "local conjuracao = DynamicCam.conjuracaoEmCombate or {}\nDynamicCam.conjuracaoEmCombate = conjuracao\n\n-- Um so frame, mesmo que o script rode de novo ao editar a situacao.\nif not conjuracao.frame then\n  local eventosQueComecam = {\n    UNIT_SPELLCAST_START = true,\n    UNIT_SPELLCAST_CHANNEL_START = true,\n    UNIT_SPELLCAST_EMPOWER_START = true,\n  }\n  local eventosQueTerminam = {\n    UNIT_SPELLCAST_STOP = true,\n    UNIT_SPELLCAST_CHANNEL_STOP = true,\n    UNIT_SPELLCAST_EMPOWER_STOP = true,\n    UNIT_SPELLCAST_INTERRUPTED = true,\n  }\n\n  conjuracao.frame = CreateFrame(\"Frame\")\n  for evento in pairs(eventosQueComecam) do conjuracao.frame:RegisterUnitEvent(evento, \"player\") end\n  for evento in pairs(eventosQueTerminam) do conjuracao.frame:RegisterUnitEvent(evento, \"player\") end\n\n  conjuracao.frame:SetScript(\"OnEvent\", function(_, evento)\n    if eventosQueComecam[evento] then\n      conjuracao.conjurando = true\n    elseif eventosQueTerminam[evento] then\n      conjuracao.conjurando = false\n    end\n    DynamicCam:EvaluateSituations()\n  end)\nend\n",
["condition"] = "if not UnitAffectingCombat(\"player\") then return false end\n\nlocal conjuracao = DynamicCam.conjuracaoEmCombate\nreturn conjuracao ~= nil and conjuracao.conjurando == true\n",
["name"] = "|TInterface\\Icons\\Spell_Fire_FlameBolt:16|t Conjurando (em combate)",
["rotation"] = {
["enabled"] = false,
["pitchDegrees"] = 0,
["rotationType"] = "degrees",
["rotationSpeed"] = 3,
["yawDegrees"] = 5,
["rotateBack"] = true,
},
["executeOnExit"] = "-- ===== AJUSTE AQUI =====\nlocal segundosParaAfastar = 0.8   -- duracao do movimento de voltar\n-- =======================\n\nlocal estado = DynamicCam.zoomConjurar\nif not estado then return end\n\nC_Timer.After(0.05, function()\n  -- Passou direto para a outra situacao de conjuracao: continua aproximado.\n  local situacaoAtual = DynamicCam.currentSituationID\n  local aindaConjurando = situacaoAtual == \"custom3\" or situacaoAtual == \"custom4\"\n  if aindaConjurando or not estado.aproximado then return end\n\n  estado.aproximado = false\n  -- Anota quando a volta termina: se conjurar de novo antes, o Script de\n  -- Entrada parte do mesmo ponto de partida, nao do meio do caminho.\n  estado.fimDoRetorno = GetTime() + segundosParaAfastar\n  DynamicCam:ResetReactiveZoomTarget()\n  LibStub(\"LibCamera-1.0\"):SetZoom(estado.pontoDePartida, segundosParaAfastar)\nend)\n",
["viewZoom"] = {
["enabled"] = false,
["zoomMax"] = 15,
["zoomMin"] = 5,
["viewZoomType"] = "zoom",
["zoomType"] = "set",
["zoomTimeIsMax"] = false,
["viewInstant"] = false,
["viewRestore"] = true,
["restoreDefaultViewNumber"] = 1,
["viewNumber"] = 2,
["zoomValue"] = 4,
},
["hideUI"] = {
["enabled"] = false,
["customFramesToKeep"] = {
},
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
["transitionTime"] = {
["timeToEnter"] = 0.5,
["timeToExit"] = 0.5,
},
},
["custom3"] = {
["enabled"] = true,
["name"] = "|TInterface\\Icons\\Spell_Holy_MagicalSentry:16|t Conjurando (fora de combate)",
["executeOnEnter"] = "-- ===== AJUSTE AQUI =====\nlocal distanciaParaAproximar = 3      -- quanto a camera chega mais perto ao conjurar\nlocal distanciaMinimaDaCamera = 1.5   -- a camera nunca fica mais perto que isso\nlocal segundosParaAproximar = 0.6     -- duracao do movimento de aproximar\n-- =======================\n\nlocal estado = DynamicCam.zoomConjurar or {}\nDynamicCam.zoomConjurar = estado\n\nC_Timer.After(0, function()\n  if estado.aproximado then return end -- ja aproximou (ex.: entrou em combate no meio da magia)\n\n  -- Se a camera ainda esta voltando da magia anterior (conjurou de novo rapido),\n  -- o ponto de partida e o destino dessa volta, nao o meio do caminho.\n  local aindaVoltando = estado.fimDoRetorno and GetTime() < estado.fimDoRetorno\n  local pontoDePartida = aindaVoltando and estado.pontoDePartida or GetCameraZoom()\n  local zoomDestino = math.max(pontoDePartida - distanciaParaAproximar, distanciaMinimaDaCamera)\n  if zoomDestino >= pontoDePartida then return end\n\n  estado.aproximado = true\n  estado.pontoDePartida = pontoDePartida\n  estado.fimDoRetorno = nil\n  DynamicCam:ResetReactiveZoomTarget()\n  LibStub(\"LibCamera-1.0\"):SetZoom(zoomDestino, segundosParaAproximar)\nend)\n",
["executeOnInit"] = "",
["condition"] = "if UnitAffectingCombat(\"player\") then return false end\n\nlocal function existe(valor) return (issecretvalue and issecretvalue(valor)) or valor ~= nil end\nlocal function legivel(valor) return valor ~= nil and not (issecretvalue and issecretvalue(valor)) end\n\nlocal function ehMontaria(magia)\n  return C_MountJournal and C_MountJournal.GetMountFromSpell and C_MountJournal.GetMountFromSpell(magia) ~= nil\nend\n\n\n-- Janela de profissoes aberta: quem cuida da camera e a situacao 330.\nif ProfessionsFrame and ProfessionsFrame:IsShown() then return false end\n\nlocal nomeConjuracao, _, _, _, _, conjuracaoDeProfissao, _, _, magiaConjurada = UnitCastingInfo(\"player\")\nif existe(nomeConjuracao) then\n  if legivel(conjuracaoDeProfissao) and conjuracaoDeProfissao then return false end\n  if legivel(magiaConjurada) and ehMontaria(magiaConjurada) then\n    return false\n  end\n  return true\nend\n\nlocal nomeCanalizacao, _, _, _, _, canalizacaoDeProfissao = UnitChannelInfo(\"player\")\nif not existe(nomeCanalizacao) then return false end\nif legivel(canalizacaoDeProfissao) and canalizacaoDeProfissao then return false end\nlocal PESCA = 7620\nif legivel(nomeCanalizacao) and C_Spell and C_Spell.GetSpellName and nomeCanalizacao == C_Spell.GetSpellName(PESCA) then\n  return false\nend\nreturn true\n",
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
["executeOnExit"] = "-- ===== AJUSTE AQUI =====\nlocal segundosParaAfastar = 0.8   -- duracao do movimento de voltar\n-- =======================\n\nlocal estado = DynamicCam.zoomConjurar\nif not estado then return end\n\nC_Timer.After(0.05, function()\n  -- Passou direto para a outra situacao de conjuracao: continua aproximado.\n  local situacaoAtual = DynamicCam.currentSituationID\n  local aindaConjurando = situacaoAtual == \"custom3\" or situacaoAtual == \"custom4\"\n  if aindaConjurando or not estado.aproximado then return end\n\n  estado.aproximado = false\n  -- Anota quando a volta termina: se conjurar de novo antes, o Script de\n  -- Entrada parte do mesmo ponto de partida, nao do meio do caminho.\n  estado.fimDoRetorno = GetTime() + segundosParaAfastar\n  DynamicCam:ResetReactiveZoomTarget()\n  LibStub(\"LibCamera-1.0\"):SetZoom(estado.pontoDePartida, segundosParaAfastar)\nend)\n",
["viewZoom"] = {
["enabled"] = false,
["zoomMax"] = 15,
["zoomMin"] = 5,
["viewZoomType"] = "zoom",
["zoomType"] = "in",
["zoomTimeIsMax"] = false,
["viewInstant"] = false,
["viewRestore"] = true,
["restoreDefaultViewNumber"] = 1,
["viewNumber"] = 2,
["zoomValue"] = 2,
},
["hideUI"] = {
["enabled"] = false,
["customFramesToKeep"] = {
},
},
["rotation"] = {
["enabled"] = false,
["pitchDegrees"] = -5,
["rotationType"] = "degrees",
["rotationSpeed"] = 10,
["yawDegrees"] = 10,
["rotateBack"] = true,
},
["priority"] = 60,
["delay"] = 0,
["transitionTime"] = {
["timeToEnter"] = 1.5,
["timeToExit"] = 1,
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
["name"] = "|TInterface\\Icons\\Ability_DualWield:16|t Arena",
},
["330"] = {
["enabled"] = true,
["transitionTime"] = {
["timeToEnter"] = 1.2,
},
["situationSettings"] = {
["cvars"] = {
["test_cameraOverShoulder"] = -1.2,
["test_cameraDynamicPitch"] = 0,
},
},
["viewZoom"] = {
["viewZoomType"] = "view",
["enabled"] = true,
["viewNumber"] = 3,
},
["name"] = "|TInterface\\Icons\\Trade_BlackSmithing:16|t Janela de Profissões Aberta",
},
["030"] = {
["enabled"] = true,
["situationSettings"] = {
["cvars"] = {
["test_cameraHeadMovementStrength"] = 0,
["test_cameraOverShoulder"] = 0,
},
},
["name"] = "|TInterface\\Icons\\INV_Misc_Head_Dragon_01:16|t Raide",
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
["name"] = "|TInterface\\Icons\\INV_Misc_Lantern_01:16|t Mundo (Interiores)",
},
["custom1"] = {
["enabled"] = false,
["rotation"] = {
["enabled"] = false,
["pitchDegrees"] = 0,
["rotationType"] = "continuous",
["rotationSpeed"] = 10,
["yawDegrees"] = 0,
["rotateBack"] = true,
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
["zoomValue"] = 1.5,
["zoomType"] = "out",
["viewNumber"] = 2,
["viewInstant"] = false,
["viewRestore"] = true,
["restoreDefaultViewNumber"] = 1,
["zoomTimeIsMax"] = false,
["viewZoomType"] = "zoom",
},
["situationSettings"] = {
["cvars"] = {
["test_cameraTargetFocusInteractEnable"] = 1,
["test_cameraDynamicPitchBaseFovPadDownScale"] = 0.25,
["test_cameraDynamicPitchBaseFovPad"] = 0.62,
["test_cameraOverShoulder"] = 0.5,
["test_cameraTargetFocusInteractStrengthPitch"] = 0.75,
["test_cameraDynamicPitchSmartPivotCutoffDist"] = 10,
["test_cameraDynamicPitchBaseFovPadFlying"] = 0.75,
["test_cameraDynamicPitch"] = 1,
["test_cameraTargetFocusInteractStrengthYaw"] = 1,
},
},
["executeOnEnter"] = "",
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
["hideUI"] = {
["enabled"] = false,
["customFramesToKeep"] = {
},
},
["executeOnExit"] = "",
["priority"] = 115,
["delay"] = 0,
["name"] = "|TInterface\\Icons\\Spell_Nature_Strength:16|t NPC grande (dialogo)",
},
["302"] = {
["enabled"] = true,
["name"] = "|TInterface\\Icons\\Trade_Fishing:16|t Pesca",
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
["name"] = "|TInterface\\Icons\\INV_Misc_Key_03:16|t Masmorra/Cenário",
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
["name"] = "|TInterface\\Icons\\INV_Misc_Lantern_01:16|t Cidade (Interiores)",
},
["102"] = {
["enabled"] = true,
["viewZoom"] = {
["enabled"] = true,
["zoomValue"] = 22,
},
["hideUI"] = {
["customFramesToKeep"] = {
["ZoneTextFrame"] = true,
["BagnonBankFrame1"] = false,
["MainActionBar"] = true,
["ClassTrainerFrame"] = false,
["StaticPopup1"] = false,
["BuffFrame"] = false,
["BankFrame"] = false,
["AuctionHouseFrame"] = false,
["WardrobeFrame"] = false,
["GossipFrame"] = false,
["DebuffFrame"] = false,
["SubZoneTextFrame"] = true,
["QuestFrame"] = false,
["MerchantFrame"] = false,
["PetStableFrame"] = false,
["EventToastManagerFrame"] = true,
},
["enabled"] = true,
["keepCustomFrames"] = true,
["fadeOpacity"] = 0,
["keepMinimap"] = true,
},
["name"] = "|TInterface\\Icons\\Ability_Mount_Wyvern_01:16|t Montaria (apenas montaria voadora + no ar)",
},
["160"] = {
["enabled"] = true,
["viewZoom"] = {
["enabled"] = true,
["zoomValue"] = 19.5,
},
["hideUI"] = {
["fadeOpacity"] = 0,
["enabled"] = true,
["keepMinimap"] = true,
},
["name"] = "|TInterface\\Icons\\Ability_Mount_Gryphon_01:16|t Táxi",
},
["060"] = {
["enabled"] = true,
["situationSettings"] = {
["cvars"] = {
["test_cameraHeadMovementStrength"] = 0,
["test_cameraOverShoulder"] = 0,
},
},
["name"] = "|TInterface\\Icons\\INV_BannerPVP_02:16|t Campo de Batalha",
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
["name"] = "|TInterface\\Icons\\Spell_Nature_Sleep:16|t Ausente (AFK)",
},
["320"] = {
["enabled"] = true,
["name"] = "|TInterface\\Icons\\Trade_Herbalism:16|t Coleta",
["transitionTime"] = {
["timeToEnter"] = 0.5,
["timeToExit"] = 0.8,
},
["condition"] = "local MAGIAS_BASE_DE_COLETA = {\n  2575,  -- Mineracao\n  2366,  -- Herborismo\n  8613,  -- Esfolar\n}\n\nlocal function legivel(valor) return valor ~= nil and not (issecretvalue and issecretvalue(valor)) end\n\nlocal nomeDaMagia = UnitCastingInfo(\"player\")\nif not legivel(nomeDaMagia) then\n  nomeDaMagia = UnitChannelInfo(\"player\")\nend\nif not legivel(nomeDaMagia) then return false end\n\nfor _, magia in ipairs(MAGIAS_BASE_DE_COLETA) do\n  if C_Spell.GetSpellName(magia) == nomeDaMagia then return true end\nend\nreturn false\n",
["viewZoom"] = {
["enabled"] = true,
["zoomType"] = "in",
["zoomValue"] = 5,
},
},
["300"] = {
["viewZoom"] = {
["enabled"] = true,
["zoomType"] = "in",
["zoomValue"] = 3,
},
["executeOnExit"] = "if not this.vol then return end\nthis.t = (this.t or 0) + 1\nlocal t, from, to = this.t, tonumber(GetCVar(\"Sound_MusicVolume\")) or 0, this.vol\nlocal steps, dur = 40, 3.5\nfor i = 1, steps do\n  C_Timer.After(i * dur / steps, function()\n    if this.t == t then\n      local p = i / steps\n      p = p * p * (3 - 2 * p)\n      SetCVar(\"Sound_MusicVolume\", from + (to - from) * p)\n      if i == steps then this.vol = nil end\n    end\n  end)\nend",
["situationSettings"] = {
["cvars"] = {
["test_cameraOverShoulder"] = 0.6,
["test_cameraTargetFocusInteractEnable"] = 1,
["test_cameraTargetFocusInteractStrengthPitch"] = 0.75,
["test_cameraTargetFocusInteractStrengthYaw"] = 1,
},
},
["transitionTime"] = {
["timeToEnter"] = 0.2,
["timeToExit"] = 0.5,
},
["name"] = "|TInterface\\Icons\\INV_Misc_Note_01:16|t Interação com NPC",
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
["rotation"] = {
["pitchDegrees"] = -5,
["rotationType"] = "degrees",
},
["executeOnEnter"] = "this.vol = this.vol or tonumber(GetCVar(\"Sound_MusicVolume\")) or 0.4\nthis.t = (this.t or 0) + 1\nlocal t, from, to = this.t, tonumber(GetCVar(\"Sound_MusicVolume\")) or this.vol, 0.03\nlocal steps, dur = 30, 2.5\nfor i = 1, steps do\n  C_Timer.After(i * dur / steps, function()\n    if this.t == t then\n      local p = i / steps\n      p = p * p * (3 - 2 * p)\n      SetCVar(\"Sound_MusicVolume\", from + (to - from) * p)\n    end\n  end)\nend",
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
["name"] = "|TInterface\\Icons\\INV_Misc_Rune_01:16|t Pedra de Regresso/Teletransporte",
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
["enabled"] = true,
["customFramesToKeep"] = {
["ZoneTextFrame"] = true,
["BagnonBankFrame1"] = false,
["MainActionBar"] = true,
["ClassTrainerFrame"] = false,
["StaticPopup1"] = false,
["BuffFrame"] = false,
["BankFrame"] = false,
["AuctionHouseFrame"] = false,
["WardrobeFrame"] = false,
["GossipFrame"] = false,
["DebuffFrame"] = false,
["SubZoneTextFrame"] = true,
["QuestFrame"] = false,
["MerchantFrame"] = false,
["PetStableFrame"] = false,
["EventToastManagerFrame"] = true,
},
["keepCustomFrames"] = true,
["keepEncounterBar"] = true,
["fadeOpacity"] = 0,
["keepMinimap"] = true,
},
["name"] = "|TInterface\\Icons\\Ability_Mount_RidingHorse:16|t Montaria (qualquer)",
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
["name"] = "|TInterface\\Icons\\INV_Letter_15:16|t Caixa de Correio",
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
