-- Zoom Livre Estavel
--
-- "Zoom livre" e a distancia da camera quando nenhuma situacao do DynamicCam
-- mexe no zoom: camera livre e situacoes sem acao de zoom (Masmorra/Cenario,
-- Raide, Arena, Campo de Batalha). Aqui chamamos essas de "base".
--
-- Dois modos:
--
-- * Zoom FIXO (padrao, /zoomlivre fixo N): ao voltar para a base, a camera vai
--   sempre para N. A roda do mouse continua mexendo, mas so ate a proxima
--   situacao; depois volta para N.
-- * Zoom SOLTO (/zoomlivre solto): volta para a distancia que voce tinha
--   antes da situacao. O DynamicCam faz isso com GetCameraZoom() do instante
--   em que entra na situacao; se a camera ainda estava voltando da anterior,
--   ele guarda o MEIO do caminho e a camera "anda". Aqui guardamos o DESTINO
--   da volta. (DynamicCam 2.21.1, SituationManager.lua, ChangeSituation.)
--
-- Tela de carregamento (entrar/sair de masmorra, portal, pedra): durante ela
-- GetCameraZoom() devolve 0 e o LibCamera, que move a camera em passos
-- relativos a esse valor, erra a conta. Saindo da masmorra a camera ia para
-- longe. Por isso nada e movido durante o carregamento; quando ele termina e a
-- camera volta a responder, a camera vai para o zoom livre.

local ZOOM_FIXO_PADRAO = 7

local zoomLivre            -- modo solto: distancia escolhida por voce
local destinoDaVolta       -- para onde a camera esta voltando agora
local fimDaVolta           -- quando essa volta termina (GetTime)
local carregando = false   -- tela de carregamento na frente

local function db()
    ZoomLivreEstavelDB = ZoomLivreEstavelDB or {}
    if ZoomLivreEstavelDB.fixo == nil then ZoomLivreEstavelDB.fixo = ZOOM_FIXO_PADRAO end
    return ZoomLivreEstavelDB
end

-- false = modo solto
local function zoomFixo()
    local fixo = db().fixo
    return type(fixo) == "number" and fixo or nil
end

local function libCamera()
    return LibStub and LibStub("LibCamera-1.0", true)
end

local function situacao(id)
    return id and DynamicCam.db.profile.situations[id]
end

-- Situacao "base": nao mexe no zoom nem pela secao Zoom/Visao nem por script
-- (as de conjuracao tem o zoom desligado mas aproximam pelo Script de Entrada).
local function ehBase(id)
    if id == nil then return true end
    local s = situacao(id)
    if not s then return false end
    if s.viewZoom and s.viewZoom.enabled then return false end
    if s.executeOnEnter and s.executeOnEnter:find("SetZoom", 1, true) then return false end
    return true
end

-- Quem leva a camera de volta ao entrar nesta situacao e este addon?
local function cuidaDe(id)
    if DynamicCam.db.profile.zoomRestoreSetting == "never" then return false end
    if id == nil then return true end
    return zoomFixo() ~= nil and ehBase(id)
end

-- Diario (addon DiarioDaCamera, se instalado): o que este addon fez e quando
-- a camera nao chegou onde devia.
local function anotar(texto)
    if DiarioDaCamera then DiarioDaCamera.Anotar("zoom", texto) end
end

local function destinoLivre()
    return zoomFixo() or zoomLivre
end

local function moverPara(destino, segundos, motivo)
    local lib = libCamera()
    if not (lib and destino) then return end
    local antes = GetCameraZoom()
    anotar(("volta para %.1f em %.1fs (camera %.1f) | %s"):format(destino, segundos, antes, motivo))
    -- Confere depois se chegou: outra coisa pode ter movido a camera no meio.
    C_Timer.After(segundos + 0.5, function()
        if carregando or destinoDaVolta ~= destino then return end
        local agora = GetCameraZoom()
        if math.abs(agora - destino) > 1 then
            anotar(("NAO chegou: esperado %.1f, camera %.1f, situacao %s | %s"):format(
                destino, agora, tostring(DynamicCam.currentSituationID or "livre"), motivo))
        end
    end)
    lib:StopZooming()
    DynamicCam:ResetReactiveZoomTarget()
    lib:SetZoom(destino, segundos)
    destinoDaVolta = destino
    fimDaVolta = GetTime() + segundos
end

local function cameraPronta()
    return not carregando and GetCameraZoom() > 0
end

local function aoTrocarDeSituacao(dynamicCam, situacaoAntiga, situacaoNova)
    if dynamicCam.db.profile.zoomRestoreSetting == "never" then return end
    -- No carregamento o zoom lido e 0: nada de anotar nem mover. aoCarregar acerta depois.
    if not cameraPronta() then
        anotar(("carregando: troca %s -> %s ignorada (zoom lido %.1f)"):format(
            tostring(situacaoAntiga or "livre"), tostring(situacaoNova or "livre"), GetCameraZoom()))
        return
    end

    -- Modo solto, saindo da camera livre: anota a distancia escolhida.
    if not zoomFixo() and situacaoAntiga == nil and situacaoNova ~= nil then
        local aindaVoltando = fimDaVolta and GetTime() < fimDaVolta
        zoomLivre = aindaVoltando and destinoDaVolta or GetCameraZoom()
        fimDaVolta = nil
        return
    end

    -- Entrando na base: leva a camera para o zoom livre
    -- (o DynamicCam acabou de mandar para o valor dele; este SetZoom substitui).
    if cuidaDe(situacaoNova) and situacaoAntiga ~= situacaoNova then
        local antiga = situacao(situacaoAntiga)
        local segundos = antiga and antiga.transitionTime and antiga.transitionTime.timeToExit or 0.75
        moverPara(destinoLivre(), segundos, ("%s -> %s"):format(
            tostring(situacaoAntiga or "livre"), tostring(situacaoNova or "livre")))
    end
end

-- Depois da tela de carregamento: espera a camera responder e, se estiver na
-- base, leva para o zoom livre.
local tentativas = 0
local function aoCarregar()
    tentativas = tentativas + 1
    if GetCameraZoom() <= 0 and tentativas < 50 then
        C_Timer.After(0.1, aoCarregar)
        return
    end
    local lido = GetCameraZoom()
    anotar(("carregamento terminou: zoom lido %.1f apos %d tentativa(s)%s"):format(
        lido, tentativas, lido <= 0 and " - camera NAO respondeu" or ""))
    -- Mais um pouco: o DynamicCam reavalia as situacoes logo depois de carregar.
    C_Timer.After(0.5, function()
        if carregando or not DynamicCam then return end
        if cuidaDe(DynamicCam.currentSituationID) then
            moverPara(destinoLivre(), 0.5, "depois do carregamento, situacao " .. tostring(DynamicCam.currentSituationID or "livre"))
        end
    end)
end

-- Para os scripts das situacoes do DynamicCam (conjuracao).
ZoomLivreEstavel = {
    ativo = true,
    -- Se a camera ainda esta voltando, para qual distancia.
    DestinoSeVoltando = function()
        if fimDaVolta and GetTime() < fimDaVolta then return destinoDaVolta end
        return nil
    end,
    -- Se e este addon que leva a camera de volta ao entrar na situacao id.
    CuidaDe = function(id) return cuidaDe(id) end,
}

local instalado = false
local eventos = CreateFrame("Frame")
eventos:RegisterEvent("ADDON_LOADED")
eventos:RegisterEvent("PLAYER_LOGIN")
eventos:RegisterEvent("LOADING_SCREEN_ENABLED")
eventos:RegisterEvent("LOADING_SCREEN_DISABLED")
eventos:SetScript("OnEvent", function(_, evento)
    if evento == "LOADING_SCREEN_ENABLED" then
        carregando = true
        local lib = libCamera()
        if lib then lib:StopZooming() end
        fimDaVolta = nil
        return
    elseif evento == "LOADING_SCREEN_DISABLED" then
        carregando = false
        tentativas = 0
        if instalado then aoCarregar() end
        return
    end
    if instalado or not (DynamicCam and DynamicCam.ChangeSituation) then return end
    instalado = true
    db()
    hooksecurefunc(DynamicCam, "ChangeSituation", aoTrocarDeSituacao)
end)

-- /zoomlivre            mostra o que esta valendo
-- /zoomlivre fixo N     zoom livre fixo em N (sem N: a distancia da camera agora)
-- /zoomlivre solto      volta para a distancia que voce tinha antes da situacao
local function mostrar()
    local fixo = zoomFixo()
    print(("|cff33ccffZoom Livre:|r %s | camera agora %.1f | situacao %s"):format(
        fixo and ("fixo %.1f"):format(fixo)
            or ("solto, anotado %s"):format(zoomLivre and ("%.1f"):format(zoomLivre) or "nada"),
        GetCameraZoom(),
        tostring(DynamicCam and DynamicCam.currentSituationID or "livre")))
end

SLASH_ZOOMLIVRE1 = "/zoomlivre"
SlashCmdList["ZOOMLIVRE"] = function(msg)
    local comando, valor = strtrim(msg or ""):lower():match("^(%S*)%s*(.-)$")
    if comando == "fixo" then
        local n = tonumber((valor:gsub(",", ".")))
        if valor ~= "" and not n then
            print("|cff33ccffZoom Livre:|r use /zoomlivre fixo 7 (ou sem numero para a distancia atual)")
            return
        end
        db().fixo = math.floor((n or GetCameraZoom()) * 10 + 0.5) / 10
    elseif comando == "solto" then
        db().fixo = false
        zoomLivre = GetCameraZoom()
    end
    if comando == "fixo" or comando == "solto" then
        anotar("comando /zoomlivre " .. comando .. " -> " .. tostring(db().fixo))
    end
    mostrar()
end
