-- Diario da Camera
--
-- Diario de diagnostico dos addons proprios e do DynamicCam, para conferir
-- depois o que aconteceu e melhorar. Cada linha vai para
-- DiarioDaCameraDB.linhas (gravado ao sair do jogo ou no /reload):
--   hora | origem | texto
--
-- Origens:
--   sessao   inicio da sessao: versao do jogo e dos addons
--   camera   cada troca de situacao do DynamicCam: antiga -> nova, zoom antes,
--            zoom 1,5 s depois e contexto (combate, montado, voando, taxi,
--            conjurando, interior, instancia, janelas abertas)
--   erro     erro de Lua dos addons proprios ou do DynamicCam (inclusive de
--            script de situacao)
--   zoom, janelas, combate, altura: os outros addons proprios, pela API abaixo
--   gostei   camera marcada como favorita no PainelDaCamera
--
-- API (outros addons, sem depender deste):
--   if DiarioDaCamera then DiarioDaCamera.Anotar("zoom", "texto") end
--
-- /diariocamera         liga/desliga (comeca ligado)
-- /diariocamera limpar  apaga o diario

local MAX_LINHAS = 4000

-- Erros so destes addons (o resto ja tem o aviso padrao do jogo).
local ADDONS_VIGIADOS = {
    "DynamicCam", "DiarioDaCamera", "ZoomLivreEstavel", "MantemJanelasNPC",
    "FechaDialogoEmCombate", "NpcAltura", "PainelDaCamera",
}

local carregado = false   -- SavedVariables ja chegaram
local antesDeCarregar = {} -- linhas anotadas antes disso

local function db()
    DiarioDaCameraDB = DiarioDaCameraDB or {}
    DiarioDaCameraDB.linhas = DiarioDaCameraDB.linhas or {}
    if DiarioDaCameraDB.ligado == nil then DiarioDaCameraDB.ligado = true end
    return DiarioDaCameraDB
end

local function guardar(linha)
    local d = db()
    if not d.ligado then return end
    local linhas = d.linhas
    linhas[#linhas + 1] = linha
    while #linhas > MAX_LINHAS do table.remove(linhas, 1) end
end

local function anotar(origem, texto)
    local linha = date("%d/%m %H:%M:%S") .. " | " .. origem .. " | " .. tostring(texto)
    if carregado then
        guardar(linha)
    else
        antesDeCarregar[#antesDeCarregar + 1] = linha
    end
end

DiarioDaCamera = { Anotar = anotar }

local function legivel(v) return v ~= nil and not (issecretvalue and issecretvalue(v)) end

local function versao(addon)
    local v = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addon, "Version")
    return v or "-"
end

-- Camera ------------------------------------------------------------------------

local function nomeDa(id)
    if not id then return "livre" end
    local s = DynamicCam.db.profile.situations[id]
    local nome = s and s.name or "?"
    nome = nome:gsub("|T[^|]*|t ", "")
    return id .. ":" .. nome
end

local function contexto()
    local partes = {}
    if UnitAffectingCombat("player") then partes[#partes + 1] = "combate" end
    if IsMounted() then partes[#partes + 1] = "montado" end
    if IsFlying() then partes[#partes + 1] = "voando" end
    if UnitOnTaxi("player") then partes[#partes + 1] = "taxi" end
    if UnitInVehicle and UnitInVehicle("player") then partes[#partes + 1] = "veiculo" end
    local c = UnitCastingInfo("player")
    if c ~= nil then partes[#partes + 1] = "conjurando=" .. (legivel(c) and c or "secreto") end
    local ch = UnitChannelInfo("player")
    if ch ~= nil then partes[#partes + 1] = "canalizando=" .. (legivel(ch) and ch or "secreto") end
    if IsIndoors() then partes[#partes + 1] = "interior" end
    local _, tipo = IsInInstance()
    if tipo and tipo ~= "none" then partes[#partes + 1] = "instancia=" .. tipo end
    for _, f in ipairs({ "ImmersionFrame", "MerchantFrame", "MailFrame", "ProfessionsFrame", "TaxiFrame", "FlightMapFrame" }) do
        if _G[f] and _G[f]:IsShown() then partes[#partes + 1] = f end
    end
    return table.concat(partes, ",")
end

local errosAnotados = {}

local function aoTrocar(dc, antiga, nova)
    local antes = GetCameraZoom()
    local linha = ("%s -> %s | zoom %.1f"):format(nomeDa(antiga), nomeDa(nova), antes)
    local ctx = contexto()
    C_Timer.After(1.5, function()
        anotar("camera", ("%s -> %.1f (1,5s, agora %s) | %s"):format(linha, GetCameraZoom(), tostring(DynamicCam.currentSituationID or "livre"), ctx))
    end)
    -- Situacoes com erro de script ficam desligadas pelo DynamicCam.
    for id, s in pairs(dc.db.profile.situations) do
        if s.errorEncountered and not errosAnotados[id] then
            errosAnotados[id] = true
            anotar("erro", ("script da situacao %s: %s"):format(nomeDa(id), tostring(s.errorMessage)))
        end
    end
end

-- Erros de Lua -------------------------------------------------------------------

local errosDaSessao = {}

local function ehVigiado(texto)
    for _, nome in ipairs(ADDONS_VIGIADOS) do
        if texto:find("AddOns[/\\]" .. nome .. "[/\\]") then return true end
    end
    return false
end

local function vigiarErros()
    local anterior = geterrorhandler()
    seterrorhandler(function(msg, ...)
        local ok = pcall(function()
            local texto = tostring(msg)
            local pilha = debugstack and debugstack(3, 6, 0) or ""
            if (ehVigiado(texto) or ehVigiado(pilha)) and not errosDaSessao[texto] then
                errosDaSessao[texto] = true -- o mesmo erro repetido vira uma linha so
                anotar("erro", texto .. " || " .. pilha:gsub("\n", " / "))
            end
        end)
        return anterior(msg, ...)
    end)
end

-- Inicio ---------------------------------------------------------------------------

local function inicioDaSessao()
    local versaoJogo, build, _, interface = GetBuildInfo()
    local zoom = GetCameraZoom()
    local partes = {}
    for _, nome in ipairs(ADDONS_VIGIADOS) do
        if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(nome) then
            partes[#partes + 1] = nome .. " " .. versao(nome)
        end
    end
    if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Immersion") then
        partes[#partes + 1] = "Immersion " .. versao("Immersion")
    end
    anotar("sessao", ("--- sessao iniciada | WoW %s (%s, %s) | %s | zoom %.1f | %s"):format(
        versaoJogo, build, interface, table.concat(partes, ", "), zoom, contexto()))
end

local eventos = CreateFrame("Frame")
eventos:RegisterEvent("ADDON_LOADED")
eventos:RegisterEvent("PLAYER_LOGIN")
eventos:SetScript("OnEvent", function(_, evento, addon)
    if evento == "ADDON_LOADED" and addon == "DiarioDaCamera" then
        carregado = true
        for _, linha in ipairs(antesDeCarregar) do guardar(linha) end
        antesDeCarregar = {}
        vigiarErros()
    elseif evento == "PLAYER_LOGIN" then
        if DynamicCam and DynamicCam.ChangeSituation then
            hooksecurefunc(DynamicCam, "ChangeSituation", aoTrocar)
        end
        inicioDaSessao()
    end
end)

SLASH_DIARIOCAMERA1 = "/diariocamera"
SlashCmdList["DIARIOCAMERA"] = function(msg)
    local d = db()
    if (msg or ""):lower():find("limpar") then
        wipe(d.linhas)
        print("|cff33ccffDiario da Camera:|r diario apagado.")
        return
    end
    d.ligado = not d.ligado
    print("|cff33ccffDiario da Camera:|r " .. (d.ligado and "ligado" or "desligado") .. " (" .. #d.linhas .. " linhas).")
end
