-- Diario da Camera
--
-- Diagnostico das situacoes do DynamicCam. Cada troca de situacao vira uma
-- linha em DiarioDaCameraDB.linhas (gravado ao sair do jogo ou no /reload):
--   hora | antiga -> nova | zoom antes | zoom 1,5 s depois | contexto
-- Contexto: em combate, montado, voando, no taxi, conjurando, janelas abertas.
-- Tambem anota situacoes que o DynamicCam marcou com erro no script.
--
-- /diariocamera         liga/desliga (comeca ligado)
-- /diariocamera limpar  apaga o diario

local MAX_LINHAS = 2000

local function db()
    DiarioDaCameraDB = DiarioDaCameraDB or {}
    DiarioDaCameraDB.linhas = DiarioDaCameraDB.linhas or {}
    if DiarioDaCameraDB.ligado == nil then DiarioDaCameraDB.ligado = true end
    return DiarioDaCameraDB
end

local function legivel(v) return v ~= nil and not (issecretvalue and issecretvalue(v)) end

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

local function anotar(texto)
    local d = db()
    if not d.ligado then return end
    local linhas = d.linhas
    linhas[#linhas + 1] = date("%d/%m %H:%M:%S") .. " | " .. texto
    while #linhas > MAX_LINHAS do table.remove(linhas, 1) end
end

local errosAnotados = {}

local function aoTrocar(dc, antiga, nova)
    local antes = GetCameraZoom()
    local linha = ("%s -> %s | zoom %.1f"):format(nomeDa(antiga), nomeDa(nova), antes)
    local ctx = contexto()
    C_Timer.After(1.5, function()
        anotar(("%s -> %.1f (1,5s, agora %s) | %s"):format(linha, GetCameraZoom(), tostring(DynamicCam.currentSituationID or "livre"), ctx))
    end)
    -- Situacoes com erro de script ficam desligadas pelo DynamicCam.
    for id, s in pairs(dc.db.profile.situations) do
        if s.errorEncountered and not errosAnotados[id] then
            errosAnotados[id] = true
            anotar(("ERRO no script da situacao %s: %s"):format(nomeDa(id), tostring(s.errorMessage)))
        end
    end
end

local instalado = false
local function instalar()
    if instalado or not (DynamicCam and DynamicCam.ChangeSituation) then return end
    instalado = true
    hooksecurefunc(DynamicCam, "ChangeSituation", aoTrocar)
    anotar("--- sessao iniciada | zoom " .. ("%.1f"):format(GetCameraZoom()) .. " | " .. contexto())
end

local eventos = CreateFrame("Frame")
eventos:RegisterEvent("ADDON_LOADED")
eventos:RegisterEvent("PLAYER_LOGIN")
eventos:SetScript("OnEvent", instalar)

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
