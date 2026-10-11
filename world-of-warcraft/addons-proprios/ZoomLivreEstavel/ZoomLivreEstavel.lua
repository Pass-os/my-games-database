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

local ZOOM_FIXO_PADRAO = 5.6

local zoomLivre            -- modo solto: distancia escolhida por voce
local destinoDaVolta       -- para onde a camera esta voltando agora
local fimDaVolta           -- quando essa volta termina (GetTime)
local carregando = false   -- tela de carregamento na frente
local esperandoCamera = true -- do carregamento (e do login) ate a camera responder

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

-- Logo depois de carregar, zoom 0 e leitura falsa; depois disso pode ser
-- primeira pessoa de verdade.
local function cameraPronta()
    return not carregando and (GetCameraZoom() > 0 or not esperandoCamera)
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
    esperandoCamera = false
    anotar(("carregamento terminou: zoom lido %.1f apos %d tentativa(s)%s"):format(
        lido, tentativas, lido <= 0 and " - camera NAO respondeu" or ""))
    -- Mais um pouco: o DynamicCam reavalia as situacoes logo depois de carregar.
    C_Timer.After(0.5, function()
        if carregando or not DynamicCam then return end
        if cuidaDe(DynamicCam.currentSituationID) then
            moverPara(destinoLivre(), 0.5, "depois do carregamento, situacao " .. tostring(DynamicCam.currentSituationID or "livre"))
        end
    end)
    -- Confere de novo: no login o jogo as vezes mexe na camera depois disso
    -- (comecava em 0, primeira pessoa).
    C_Timer.After(3, function()
        if carregando or not DynamicCam then return end
        if not cuidaDe(DynamicCam.currentSituationID) then return end
        if fimDaVolta and GetTime() < fimDaVolta then return end
        local destino, agora = destinoLivre(), GetCameraZoom()
        if destino and math.abs(agora - destino) > 1 then
            moverPara(destino, 0.5, ("correcao 3s depois do carregamento (camera %.1f)"):format(agora))
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

-- Mudar o modo (comando e tela de opcoes usam as mesmas funcoes) -----------------

local function arredondar(n)
    return math.floor(n * 10 + 0.5) / 10
end

local opcoes -- settings da tela de opcoes, para atualizar quando o comando muda algo
local atualizarJanela -- definida mais abaixo, com a janela

local function avisarOpcoes()
    if atualizarJanela then atualizarJanela() end
    if not (opcoes and Settings and Settings.NotifyUpdate) then return end
    pcall(Settings.NotifyUpdate, "ZoomLivreEstavel_ligado")
    pcall(Settings.NotifyUpdate, "ZoomLivreEstavel_distancia")
end

-- Liga o zoom fixo em n. Se a camera esta na base, ja leva para la (para ver
-- como fica enquanto ajusta).
local function definirFixo(n, origem)
    n = arredondar(n)
    db().fixo = n
    db().ultimoFixo = n
    anotar(("%s: fixo %.1f"):format(origem, n))
    if DynamicCam and cameraPronta() and cuidaDe(DynamicCam.currentSituationID) then
        moverPara(n, 0.3, origem)
    end
    avisarOpcoes()
end

local function soltar(origem)
    if zoomFixo() then db().ultimoFixo = zoomFixo() end
    db().fixo = false
    zoomLivre = GetCameraZoom()
    anotar(origem .. ": solto")
    avisarOpcoes()
end

-- Tela de opcoes: Opcoes > AddOns > Zoom Livre Estavel ---------------------------

local categoria

local function criarOpcoes()
    if categoria or not (Settings and Settings.RegisterVerticalLayoutCategory) then return end
    local layout
    categoria, layout = Settings.RegisterVerticalLayoutCategory("Zoom Livre Estavel")

    local ligado = Settings.RegisterProxySetting(categoria, "ZoomLivreEstavel_ligado",
        Settings.VarType.Boolean, "Zoom fixo", true,
        function() return zoomFixo() ~= nil end,
        function(valor)
            if valor == (zoomFixo() ~= nil) then return end
            if valor then
                definirFixo(db().ultimoFixo or ZOOM_FIXO_PADRAO, "opcoes")
            else
                soltar("opcoes")
            end
        end)
    Settings.CreateCheckbox(categoria, ligado,
        "Ligado: ao sair de qualquer situacao do DynamicCam (montaria, NPC, magia...) e em masmorra, raide, arena e BG, a camera volta sempre para a distancia abaixo.\n\n"
        .. "Desligado: volta para a distancia que voce tinha antes da situacao.")

    local distancia = Settings.RegisterProxySetting(categoria, "ZoomLivreEstavel_distancia",
        Settings.VarType.Number, "Distancia", ZOOM_FIXO_PADRAO,
        function() return zoomFixo() or db().ultimoFixo or ZOOM_FIXO_PADRAO end,
        function(valor)
            if math.abs(valor - (zoomFixo() or -1)) < 0.05 then return end
            definirFixo(valor, "opcoes")
        end)
    local faixa = Settings.CreateSliderOptions(1, 39, 0.1)
    faixa:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(v)
        return ("%.1f"):format(v)
    end)
    Settings.CreateSlider(categoria, distancia, faixa,
        "Distancia da camera (em jardas) do zoom fixo. Se nenhuma situacao estiver ativa, a camera ja vai para la enquanto voce arrasta.")

    layout:AddInitializer(CreateSettingsButtonInitializer("Distancia atual da camera",
        "Usar", function()
            definirFixo(GetCameraZoom(), "opcoes (distancia atual)")
        end,
        "Feche esta janela, ajuste a camera com a roda do mouse, volte aqui e clique: o zoom fixo passa a ser essa distancia. (O mesmo que /zoomlivre fixo.)",
        true))

    Settings.RegisterAddOnCategory(categoria)
    opcoes = true
end

-- Janela propria (/zoomlivre) ------------------------------------------------------
-- Mesmo conteudo da tela de opcoes, numa janela pequena que se arrasta e
-- fica aberta enquanto voce joga, com a distancia da camera ao vivo.

local janela

local function criarJanela()
    janela = CreateFrame("Frame", "ZoomLivreEstavelJanela", UIParent, "DefaultPanelFlatTemplate")
    janela:SetSize(290, 170)
    janela:SetFrameStrata("DIALOG")
    janela:SetClampedToScreen(true)
    janela:SetMovable(true)
    janela:EnableMouse(true)
    janela:RegisterForDrag("LeftButton")
    janela:SetScript("OnDragStart", janela.StartMoving)
    janela:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local ponto, _, relativo, x, y = self:GetPoint()
        db().janela = { ponto, relativo, x, y }
    end)
    local p = db().janela
    if p then
        janela:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        janela:SetPoint("CENTER", UIParent, "CENTER", 300, 100)
    end
    janela.TitleContainer.TitleText:SetText("Zoom Livre Estavel")
    tinsert(UISpecialFrames, "ZoomLivreEstavelJanela") -- ESC fecha

    local fechar = CreateFrame("Button", nil, janela, "UIPanelCloseButton")
    fechar:SetPoint("TOPRIGHT", 0, 0)

    local ligado = CreateFrame("CheckButton", nil, janela, "UICheckButtonTemplate")
    ligado:SetPoint("TOPLEFT", 14, -30)
    ligado.Text:SetText("Zoom fixo (volta sempre para a mesma distancia)")
    ligado.Text:SetFontObject("GameFontHighlightSmall")
    ligado:SetScript("OnClick", function(self)
        if self:GetChecked() then
            definirFixo(db().ultimoFixo or ZOOM_FIXO_PADRAO, "janela")
        else
            soltar("janela")
        end
    end)

    local rotulo = janela:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rotulo:SetPoint("TOPLEFT", 20, -66)
    rotulo:SetText("Distancia")

    local barra = CreateFrame("Frame", nil, janela, "MinimalSliderWithSteppersTemplate")
    barra:SetPoint("TOPLEFT", 16, -80)
    barra:SetSize(220, 20)
    barra:Init(ZOOM_FIXO_PADRAO, 1, 39, 380, {
        [MinimalSliderWithSteppersMixin.Label.Right] = function(v) return ("%.1f"):format(v) end,
    })
    local atualizando = false
    barra:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(_, valor)
        if atualizando or not zoomFixo() then return end
        if math.abs(valor - zoomFixo()) < 0.05 then return end
        definirFixo(valor, "janela")
    end, janela)

    local usar = CreateFrame("Button", nil, janela, "UIPanelButtonTemplate")
    usar:SetSize(160, 22)
    usar:SetPoint("TOPLEFT", 16, -112)
    usar:SetText("Usar distancia atual")
    usar:SetScript("OnClick", function() definirFixo(GetCameraZoom(), "janela (distancia atual)") end)

    local agora = janela:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    agora:SetPoint("BOTTOMLEFT", 20, 14)
    agora:SetJustifyH("LEFT")

    atualizarJanela = function()
        local fixo = zoomFixo()
        atualizando = true
        ligado:SetChecked(fixo ~= nil)
        barra:SetValue(fixo or db().ultimoFixo or ZOOM_FIXO_PADRAO)
        barra:SetEnabled(fixo ~= nil)
        usar:SetEnabled(fixo ~= nil)
        atualizando = false
    end

    local decorrido = 0
    janela:SetScript("OnUpdate", function(_, dt)
        decorrido = decorrido + dt
        if decorrido < 0.2 then return end
        decorrido = 0
        local id = DynamicCam and DynamicCam.currentSituationID
        agora:SetText(("Camera agora: |cffffffff%.1f|r   situacao: |cffffffff%s|r%s"):format(
            GetCameraZoom(), tostring(id or "livre"),
            cuidaDe(id) and "" or "\n|cff999999(situacao do DynamicCam ativa: volta ao sair dela)|r"))
    end)
    janela:SetScript("OnShow", atualizarJanela)
    janela:Hide()
end

local function alternarJanela()
    if not janela then criarJanela() end
    janela:SetShown(not janela:IsShown())
end

local instalado = false
local eventos = CreateFrame("Frame")
eventos:RegisterEvent("ADDON_LOADED")
eventos:RegisterEvent("PLAYER_LOGIN")
eventos:RegisterEvent("LOADING_SCREEN_ENABLED")
eventos:RegisterEvent("LOADING_SCREEN_DISABLED")
eventos:SetScript("OnEvent", function(_, evento)
    if evento == "LOADING_SCREEN_ENABLED" then
        carregando = true
        esperandoCamera = true
        local lib = libCamera()
        if lib then lib:StopZooming() end
        fimDaVolta = nil
        return
    elseif evento == "LOADING_SCREEN_DISABLED" then
        carregando = false
        tentativas = 0
        if instalado then aoCarregar() end
        return
    elseif evento == "PLAYER_LOGIN" then
        criarOpcoes()
    end
    if instalado or not (DynamicCam and DynamicCam.ChangeSituation) then return end
    instalado = true
    db()
    hooksecurefunc(DynamicCam, "ChangeSituation", aoTrocarDeSituacao)
end)

-- /zoomlivre            abre/fecha a janela
-- /zoomlivre status     mostra no chat o que esta valendo
-- /zoomlivre opcoes     abre a tela em Opcoes > AddOns
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
    if comando == "" then
        alternarJanela()
        return
    elseif comando == "opcoes" then
        if categoria then Settings.OpenToCategory(categoria:GetID()) end
        return
    elseif comando == "fixo" then
        local n = tonumber((valor:gsub(",", ".")))
        if valor ~= "" and not n then
            print("|cff33ccffZoom Livre:|r use /zoomlivre fixo 7 (ou sem numero para a distancia atual)")
            return
        end
        definirFixo(n or GetCameraZoom(), "comando /zoomlivre fixo")
    elseif comando == "solto" then
        soltar("comando /zoomlivre solto")
    end
    mostrar()
end
