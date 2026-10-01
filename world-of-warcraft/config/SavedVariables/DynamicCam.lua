
DynamicCamDB = {
["global"] = {
["popOutFrame"] = {
["height"] = 499.9999084472656,
["opacity"] = 0,
["left"] = 1057.667358398438,
["top"] = 787.4442749023438,
},
},
["profiles"] = {
["Default"] = {
["version"] = 5,
["dcBigNPCs"] = {
},
["situations"] = {
["320"] = {
["enabled"] = true,
["condition"] = [=[local MAGIAS_BASE_DE_COLETA = {
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
]=],
["transitionTime"] = {
["timeToEnter"] = 0.5,
["timeToExit"] = 0.8,
},
["viewZoom"] = {
["enabled"] = true,
["zoomType"] = "in",
["zoomValue"] = 5,
},
},
["330"] = {
["enabled"] = true,
["transitionTime"] = {
["timeToEnter"] = 1.2,
["timeToExit"] = 1,
},
["viewZoom"] = {
["enabled"] = true,
["zoomType"] = "set",
["zoomValue"] = 3.5,
},
["rotation"] = {
["enabled"] = true,
["rotationType"] = "degrees",
["yawDegrees"] = 180,
["pitchDegrees"] = 0,
["rotateBack"] = true,
},
["situationSettings"] = {
["cvars"] = {
["test_cameraOverShoulder"] = -1.2,
},
},
},
["custom4"] = {
["enabled"] = true,
["executeOnExit"] = [=[-- ===== AJUSTE AQUI =====
local segundosParaAfastar = 0.8   -- duracao do movimento de voltar
-- =======================

local estado = DynamicCam.zoomConjurar
if not estado then return end

C_Timer.After(0.05, function()
  -- Passou direto para a outra situacao de conjuracao: continua aproximado.
  local situacaoAtual = DynamicCam.currentSituationID
  local aindaConjurando = situacaoAtual == "custom3" or situacaoAtual == "custom4"
  if aindaConjurando or not estado.aproximado then return end

  estado.aproximado = false
  local zoomDestino = GetCameraZoom() + estado.quantoAproximou
  -- Anota para onde esta voltando: se conjurar de novo antes de chegar,
  -- o Script de Entrada parte daqui e nao do meio do caminho.
  estado.zoomDoRetorno = zoomDestino
  estado.fimDoRetorno = GetTime() + segundosParaAfastar
  DynamicCam:ResetReactiveZoomTarget()
  LibStub("LibCamera-1.0"):SetZoom(zoomDestino, segundosParaAfastar)
end)
]=],
["transitionTime"] = {
["timeToEnter"] = 0.5,
["timeToExit"] = 0.5,
},
["executeOnInit"] = [=[local conjuracao = DynamicCam.conjuracaoEmCombate or {}
DynamicCam.conjuracaoEmCombate = conjuracao

-- Um so frame, mesmo que o script rode de novo ao editar a situacao.
if not conjuracao.frame then
  local eventosQueComecam = {
    UNIT_SPELLCAST_START = true,
    UNIT_SPELLCAST_CHANNEL_START = true,
    UNIT_SPELLCAST_EMPOWER_START = true,
  }
  local eventosQueTerminam = {
    UNIT_SPELLCAST_STOP = true,
    UNIT_SPELLCAST_CHANNEL_STOP = true,
    UNIT_SPELLCAST_EMPOWER_STOP = true,
    UNIT_SPELLCAST_INTERRUPTED = true,
  }

  conjuracao.frame = CreateFrame("Frame")
  for evento in pairs(eventosQueComecam) do conjuracao.frame:RegisterUnitEvent(evento, "player") end
  for evento in pairs(eventosQueTerminam) do conjuracao.frame:RegisterUnitEvent(evento, "player") end

  conjuracao.frame:SetScript("OnEvent", function(_, evento)
    if eventosQueComecam[evento] then
      conjuracao.conjurando = true
    elseif eventosQueTerminam[evento] then
      conjuracao.conjurando = false
    end
    DynamicCam:EvaluateSituations()
  end)
end
]=],
["condition"] = [=[if not UnitAffectingCombat("player") then return false end

local conjuracao = DynamicCam.conjuracaoEmCombate
return conjuracao ~= nil and conjuracao.conjurando == true
]=],
["viewZoom"] = {
["enabled"] = false,
["zoomMax"] = 15,
["zoomMin"] = 5,
["viewInstant"] = false,
["zoomType"] = "set",
["viewNumber"] = 2,
["zoomValue"] = 4,
["viewRestore"] = true,
["restoreDefaultViewNumber"] = 1,
["zoomTimeIsMax"] = false,
["viewZoomType"] = "zoom",
},
["rotation"] = {
["enabled"] = false,
["pitchDegrees"] = 0,
["rotationType"] = "degrees",
["rotationSpeed"] = 3,
["yawDegrees"] = 5,
["rotateBack"] = true,
},
["executeOnEnter"] = [=[-- ===== AJUSTE AQUI =====
local distanciaParaAproximar = 3      -- quanto a camera chega mais perto ao conjurar
local distanciaMinimaDaCamera = 1.5   -- a camera nunca fica mais perto que isso
local segundosParaAproximar = 0.6     -- duracao do movimento de aproximar
-- =======================

local estado = DynamicCam.zoomConjurar or {}
DynamicCam.zoomConjurar = estado

C_Timer.After(0, function()
  if estado.aproximado then return end -- ja aproximou (ex.: entrou em combate no meio da magia)

  -- Se a camera ainda esta voltando da magia anterior (conjurou de novo rapido),
  -- a base e o ponto para onde ela estava voltando, nao o meio do caminho.
  local aindaVoltando = estado.fimDoRetorno and GetTime() < estado.fimDoRetorno
  local zoomAtual = aindaVoltando and estado.zoomDoRetorno or GetCameraZoom()
  local zoomDestino = math.max(zoomAtual - distanciaParaAproximar, distanciaMinimaDaCamera)
  if zoomDestino >= zoomAtual then return end

  estado.aproximado = true
  estado.quantoAproximou = zoomAtual - zoomDestino
  estado.fimDoRetorno = nil
  DynamicCam:ResetReactiveZoomTarget()
  LibStub("LibCamera-1.0"):SetZoom(zoomDestino, segundosParaAproximar)
end)
]=],
["name"] = "Conjurando (em combate)",
["hideUI"] = {
["enabled"] = false,
},
["situationSettings"] = {
["cvars"] = {
["test_cameraTargetFocusEnemyStrengthPitch"] = 0.4,
["test_cameraTargetFocusInteractEnable"] = 1,
["test_cameraTargetFocusInteractStrengthPitch"] = 0.75,
["test_cameraTargetFocusEnemyEnable"] = 1,
["test_cameraTargetFocusInteractStrengthYaw"] = 1,
["test_cameraTargetFocusEnemyStrengthYaw"] = 0.6000000000000001,
},
},
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
},
["custom3"] = {
["enabled"] = true,
["executeOnExit"] = [=[-- ===== AJUSTE AQUI =====
local segundosParaAfastar = 0.8   -- duracao do movimento de voltar
-- =======================

local estado = DynamicCam.zoomConjurar
if not estado then return end

C_Timer.After(0.05, function()
  -- Passou direto para a outra situacao de conjuracao: continua aproximado.
  local situacaoAtual = DynamicCam.currentSituationID
  local aindaConjurando = situacaoAtual == "custom3" or situacaoAtual == "custom4"
  if aindaConjurando or not estado.aproximado then return end

  estado.aproximado = false
  local zoomDestino = GetCameraZoom() + estado.quantoAproximou
  -- Anota para onde esta voltando: se conjurar de novo antes de chegar,
  -- o Script de Entrada parte daqui e nao do meio do caminho.
  estado.zoomDoRetorno = zoomDestino
  estado.fimDoRetorno = GetTime() + segundosParaAfastar
  DynamicCam:ResetReactiveZoomTarget()
  LibStub("LibCamera-1.0"):SetZoom(zoomDestino, segundosParaAfastar)
end)
]=],
["transitionTime"] = {
["timeToEnter"] = 1.5,
["timeToExit"] = 1,
},
["executeOnInit"] = "",
["condition"] = [=[if UnitAffectingCombat("player") then return false end

local function existe(valor) return (issecretvalue and issecretvalue(valor)) or valor ~= nil end
local function legivel(valor) return valor ~= nil and not (issecretvalue and issecretvalue(valor)) end

local function ehMontaria(magia)
  return C_MountJournal and C_MountJournal.GetMountFromSpell and C_MountJournal.GetMountFromSpell(magia) ~= nil
end

local function ehReceitaDeProfissao(magia)
  if not (C_TradeSkillUI and C_TradeSkillUI.GetRecipeInfo) then return false end
  local ok, receita = pcall(C_TradeSkillUI.GetRecipeInfo, magia)
  return ok and receita ~= nil
end

-- Janela de profissoes aberta: quem cuida da camera e a situacao 330.
if ProfessionsFrame and ProfessionsFrame:IsShown() then return false end

local nomeConjuracao, _, _, _, _, conjuracaoDeProfissao, _, _, magiaConjurada = UnitCastingInfo("player")
if existe(nomeConjuracao) then
  if legivel(conjuracaoDeProfissao) and conjuracaoDeProfissao then return false end
  if legivel(magiaConjurada) and (ehMontaria(magiaConjurada) or ehReceitaDeProfissao(magiaConjurada)) then
    return false
  end
  return true
end

local nomeCanalizacao, _, _, _, _, canalizacaoDeProfissao, _, magiaCanalizada = UnitChannelInfo("player")
if not existe(nomeCanalizacao) then return false end
if legivel(canalizacaoDeProfissao) and canalizacaoDeProfissao then return false end
local PESCA = 7620
if legivel(nomeCanalizacao) and C_Spell and C_Spell.GetSpellName and nomeCanalizacao == C_Spell.GetSpellName(PESCA) then
  return false
end
if legivel(magiaCanalizada) and ehReceitaDeProfissao(magiaCanalizada) then return false end
return true
]=],
["viewZoom"] = {
["enabled"] = false,
["zoomMax"] = 15,
["zoomMin"] = 5,
["viewInstant"] = false,
["zoomType"] = "in",
["viewNumber"] = 2,
["zoomValue"] = 2,
["viewRestore"] = true,
["restoreDefaultViewNumber"] = 1,
["zoomTimeIsMax"] = false,
["viewZoomType"] = "zoom",
},
["rotation"] = {
["enabled"] = false,
["pitchDegrees"] = -5,
["rotationType"] = "degrees",
["rotationSpeed"] = 10,
["yawDegrees"] = 10,
["rotateBack"] = true,
},
["executeOnEnter"] = [=[-- ===== AJUSTE AQUI =====
local distanciaParaAproximar = 3      -- quanto a camera chega mais perto ao conjurar
local distanciaMinimaDaCamera = 1.5   -- a camera nunca fica mais perto que isso
local segundosParaAproximar = 0.6     -- duracao do movimento de aproximar
-- =======================

local estado = DynamicCam.zoomConjurar or {}
DynamicCam.zoomConjurar = estado

C_Timer.After(0, function()
  if estado.aproximado then return end -- ja aproximou (ex.: entrou em combate no meio da magia)

  -- Se a camera ainda esta voltando da magia anterior (conjurou de novo rapido),
  -- a base e o ponto para onde ela estava voltando, nao o meio do caminho.
  local aindaVoltando = estado.fimDoRetorno and GetTime() < estado.fimDoRetorno
  local zoomAtual = aindaVoltando and estado.zoomDoRetorno or GetCameraZoom()
  local zoomDestino = math.max(zoomAtual - distanciaParaAproximar, distanciaMinimaDaCamera)
  if zoomDestino >= zoomAtual then return end

  estado.aproximado = true
  estado.quantoAproximou = zoomAtual - zoomDestino
  estado.fimDoRetorno = nil
  DynamicCam:ResetReactiveZoomTarget()
  LibStub("LibCamera-1.0"):SetZoom(zoomDestino, segundosParaAproximar)
end)
]=],
["name"] = "Conjurando (fora de combate)",
["hideUI"] = {
["enabled"] = false,
},
["situationSettings"] = {
["cvars"] = {
["test_cameraTargetFocusEnemyStrengthPitch"] = 0.5,
["test_cameraTargetFocusInteractEnable"] = 1,
["test_cameraTargetFocusInteractStrengthPitch"] = 0.75,
["test_cameraTargetFocusEnemyEnable"] = 1,
["test_cameraTargetFocusInteractStrengthYaw"] = 1,
["test_cameraTargetFocusEnemyStrengthYaw"] = 1,
},
},
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
["executeOnEnter"] = "",
["executeOnInit"] = "this.frames = {\"AuctionHouseFrame\", \"BankFrame\", \"ClassTrainerFrame\", \"GossipFrame\", \"ImmersionFrame\", \"MerchantFrame\", \"QuestFrame\"}\n\nDynamicCam.db.profile.dcBigNPCs = DynamicCam.db.profile.dcBigNPCs or {}\n\nthis.GetNpcId = function(unit)\n  local guid = UnitGUID(unit)\n  if not guid or (issecretvalue and issecretvalue(guid)) then return nil end\n  local unitType, _, _, _, _, npcId = strsplit(\"-\", guid)\n  if unitType == \"Creature\" or unitType == \"Vehicle\" then return npcId end\n  return nil\nend\n\ngetfenv(0).SLASH_DCNPCGRANDE1 = \"/npcgrande\"\nSlashCmdList[\"DCNPCGRANDE\"] = function()\n  local list = DynamicCam.db.profile.dcBigNPCs\n  local unit = UnitExists(\"npc\") and \"npc\" or \"target\"\n  local npcId = this.GetNpcId(unit)\n  if not npcId then\n    print(\"|cff33ccffDynamicCam:|r fale com o NPC (ou selecione-o) antes de usar /npcgrande\")\n    return\n  end\n  local name = UnitName(unit)\n  if issecretvalue and issecretvalue(name) then name = nil end\n  if list[npcId] then\n    list[npcId] = nil\n    print(\"|cff33ccffDynamicCam:|r \" .. (name or npcId) .. \" removido da lista de NPCs grandes\")\n  else\n    list[npcId] = name or true\n    print(\"|cff33ccffDynamicCam:|r \" .. (name or npcId) .. \" marcado como NPC grande - a camera vai afastar nele\")\n  end\n  DynamicCam:EvaluateSituations()\nend\n",
["condition"] = "if not UnitExists(\"npc\") then return false end\nlocal npcId = this.GetNpcId(\"npc\")\nif not npcId then return false end\n\nlocal list = DynamicCam.db.profile.dcBigNPCs\nlocal grande = list and list[npcId]\nif not grande and NpcAltura and NpcAltura.EhGrande then\n  grande = NpcAltura.EhGrande(npcId)\nend\nif not grande then return false end\n\nfor _, v in pairs(this.frames) do\n  if _G[v] and _G[v]:IsShown() then return true end\nend\nreturn false",
["name"] = "NPC grande (dialogo)",
["situationSettings"] = {
["cvars"] = {
["test_cameraTargetFocusInteractEnable"] = 1,
["test_cameraOverShoulder"] = 0.6,
["test_cameraTargetFocusInteractStrengthPitch"] = 0.75,
["test_cameraTargetFocusInteractStrengthYaw"] = 1,
},
},
["transitionTime"] = {
["timeToEnter"] = 0.3,
["timeToExit"] = 0.5,
},
["viewZoom"] = {
["enabled"] = true,
["zoomMax"] = 15,
["zoomMin"] = 5,
["viewZoomType"] = "zoom",
["zoomType"] = "out",
["zoomTimeIsMax"] = false,
["viewInstant"] = false,
["viewRestore"] = true,
["restoreDefaultViewNumber"] = 1,
["viewNumber"] = 2,
["zoomValue"] = 1.5,
},
["hideUI"] = {
["enabled"] = false,
},
["executeOnExit"] = "",
["priority"] = 115,
["delay"] = 0,
["rotation"] = {
["enabled"] = false,
["pitchDegrees"] = 0,
["rotationType"] = "continuous",
["rotationSpeed"] = 10,
["yawDegrees"] = 0,
["rotateBack"] = true,
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
["BagnonBankFrame1"] = false,
["DebuffFrame"] = false,
["PetStableFrame"] = false,
["QuestFrame"] = false,
["GossipFrame"] = false,
["AuctionHouseFrame"] = false,
["BuffFrame"] = false,
},
["enabled"] = true,
["keepCustomFrames"] = true,
["fadeOpacity"] = 0,
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
["executeOnExit"] = "if not this.vol then return end\nthis.t = (this.t or 0) + 1\nlocal t, from, to = this.t, tonumber(GetCVar(\"Sound_MusicVolume\")) or 0, this.vol\nlocal steps, dur = 40, 3.5\nfor i = 1, steps do\n  C_Timer.After(i * dur / steps, function()\n    if this.t == t then\n      local p = i / steps\n      p = p * p * (3 - 2 * p)\n      SetCVar(\"Sound_MusicVolume\", from + (to - from) * p)\n      if i == steps then this.vol = nil end\n    end\n  end)\nend",
["transitionTime"] = {
["timeToEnter"] = 0.2,
["timeToExit"] = 0.5,
},
["rotation"] = {
["pitchDegrees"] = -5,
["rotationType"] = "degrees",
},
["executeOnEnter"] = "this.vol = this.vol or tonumber(GetCVar(\"Sound_MusicVolume\")) or 0.4\nthis.t = (this.t or 0) + 1\nlocal t, from, to = this.t, tonumber(GetCVar(\"Sound_MusicVolume\")) or this.vol, 0.03\nlocal steps, dur = 30, 2.5\nfor i = 1, steps do\n  C_Timer.After(i * dur / steps, function()\n    if this.t == t then\n      local p = i / steps\n      p = p * p * (3 - 2 * p)\n      SetCVar(\"Sound_MusicVolume\", from + (to - from) * p)\n    end\n  end)\nend",
["viewZoom"] = {
["enabled"] = true,
["zoomType"] = "in",
["zoomValue"] = 3,
},
["hideUI"] = {
["customFramesToKeep"] = {
["ContainerFrame4"] = true,
["SideDressUpFrame"] = true,
["ContainerFrame6"] = true,
["OverlayPlayerCastingBarFrame"] = true,
["ContainerFrameCombinedBags"] = true,
["ContainerFrame3"] = true,
["DressUpFrame"] = true,
["PlayerCastingBarFrame"] = true,
["ContainerFrame5"] = true,
["ContainerFrame2"] = true,
["ContainerFrame1"] = true,
},
["enabled"] = true,
["keepCustomFrames"] = true,
["fadeOpacity"] = 0,
["keepMinimap"] = true,
},
["situationSettings"] = {
["cvars"] = {
["test_cameraTargetFocusInteractEnable"] = 1,
["test_cameraOverShoulder"] = 0.6,
["test_cameraTargetFocusInteractStrengthPitch"] = 0.75,
["test_cameraTargetFocusInteractStrengthYaw"] = 1,
},
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
["test_cameraDynamicPitchBaseFovPadFlying"] = 0.75,
["test_cameraOverShoulder"] = 0,
["test_cameraDynamicPitchSmartPivotCutoffDist"] = 10,
},
},
["viewZoom"] = {
["zoomValue"] = 7.5,
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
["BagnonBankFrame1"] = false,
["DebuffFrame"] = false,
["PetStableFrame"] = false,
["QuestFrame"] = false,
["GossipFrame"] = false,
["AuctionHouseFrame"] = false,
["BuffFrame"] = false,
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
