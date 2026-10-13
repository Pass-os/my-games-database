-- Painel da Camera
--
-- Painel pequeno na tela com a distancia da camera e as configuracoes que o
-- DynamicCam esta usando agora, para ir descobrindo o que agrada. Quando
-- gostar de uma camera, clique com o botao direito no painel (ou /pcam gostei
-- <nota>): o retrato fica guardado em PainelDaCameraDB.favoritos (vai para o
-- repositorio com o salvar-config.ps1) e no diario do DiarioDaCamera.
--
-- Continua visivel quando o DynamicCam ou o Immersion escondem a interface
-- (montaria, dialogo), que e justamente quando se ajusta a camera. Some com
-- Alt+Z, junto com o resto.
--
-- /pcam              mostra/esconde
-- /pcam curto        so a distancia / tudo
-- /pcam gostei nota  guarda a camera de agora como favorita
-- /pcam favoritos    lista as ultimas favoritas no chat
-- arrastar           move o painel

local MAX_FAVORITOS = 100

local function db()
    PainelDaCameraDB = PainelDaCameraDB or {}
    local d = PainelDaCameraDB
    if d.visivel == nil then d.visivel = true end
    d.favoritos = d.favoritos or {}
    return d
end

local function cvar(nome)
    return tonumber(GetCVar(nome))
end

local function liga(nome)
    return GetCVar(nome) == "1"
end

local function nomeDaSituacao()
    if not (DynamicCam and DynamicCam.db) then return "sem DynamicCam" end
    local id = DynamicCam.currentSituationID
    if not id then return "livre" end
    local s = DynamicCam.db.profile.situations[id]
    local nome = (s and s.name or "?"):gsub("|T[^|]*|t ", "")
    return nome
end

-- Valor do ombro como aparece no /dc (o CVar e corrigido pelo modelo do personagem).
local function ombro()
    if DynamicCam and DynamicCam.currentShoulderOffset then return DynamicCam.currentShoulderOffset end
    return cvar("test_cameraOverShoulder") or 0
end

local function zoomFixo()
    local fixo = ZoomLivreEstavelDB and ZoomLivreEstavelDB.fixo
    return type(fixo) == "number" and fixo or nil
end

-- Tudo que o painel mostra, tambem usado no retrato das favoritas.
local function leitura()
    return {
        zoom = GetCameraZoom(),
        angulo = cvar("cameraSavedPitch"),
        inclinacao = cvar("test_cameraDynamicPitchBaseFovPad"),
        situacao = nomeDaSituacao(),
        id = DynamicCam and DynamicCam.currentSituationID or "livre",
        fixo = zoomFixo(),
        max = (cvar("cameraDistanceMaxZoomFactor") or 0) * 15,
        ombro = ombro(),
        pitch = liga("test_cameraDynamicPitch"),
        cabeca = cvar("test_cameraHeadMovementStrength") or 0,
        focoInteracao = liga("test_cameraTargetFocusInteractEnable"),
        focoInimigo = liga("test_cameraTargetFocusEnemyEnable"),
        fov = cvar("cameraFov") or 0,
        montado = IsMounted() and true or false,
        interior = IsIndoors() and true or false,
    }
end

local function simNao(v) return v and "sim" or "nao" end

-- Angulo do giro vertical: graus acima do personagem (0 = na altura dele,
-- maior = olhando mais de cima). O jogo nao tem funcao para isso; o valor
-- vem do CVar em que ele guarda a camera.
local function angulo(l)
    return l.angulo and ("%.0f graus"):format(l.angulo) or "-"
end

-- Inclinacao vertical do DynamicCam (0 a 0.99) ou "desligada".
local function inclinacao(l)
    return l.pitch and ("%.2f"):format(l.inclinacao or 0) or "desligada"
end

local function textoCompleto(l)
    return ("|cffffd100Zoom|r %.1f\n"
        .. "|cffffd100Angulo vertical|r %s\n"
        .. "|cffffd100Zoom fixo|r %s\n"
        .. "|cffffd100Zoom max|r %.0f\n"
        .. "|cffffd100Situacao|r %s\n"
        .. "|cffffd100Ombro|r %.2f\n"
        .. "|cffffd100Inclinacao|r %s\n"
        .. "|cffffd100Cabeca|r %.2f\n"
        .. "|cffffd100Foco NPC|r %s\n"
        .. "|cffffd100Foco inimigo|r %s\n"
        .. "|cffffd100FOV|r %.0f"):format(
        l.zoom, angulo(l), l.fixo and ("%.1f"):format(l.fixo) or "-", l.max,
        l.situacao,
        l.ombro, inclinacao(l), l.cabeca,
        simNao(l.focoInteracao), simNao(l.focoInimigo), l.fov)
end

local function textoCurto(l)
    return ("|cffffd100Zoom|r %.1f"):format(l.zoom)
end

local function resumo(l)
    return ("zoom %.1f | angulo %s | situacao %s (%s) | fixo %s | max %.0f | ombro %.2f | inclinacao %s | cabeca %.2f | foco NPC %s inimigo %s | fov %.0f | %s%s"):format(
        l.zoom, angulo(l), l.situacao, l.id, l.fixo and ("%.1f"):format(l.fixo) or "-", l.max,
        l.ombro, inclinacao(l), l.cabeca, simNao(l.focoInteracao), simNao(l.focoInimigo), l.fov,
        l.montado and "montado " or "", l.interior and "interior" or "")
end

-- Painel ---------------------------------------------------------------------------

local painel = CreateFrame("Frame", "PainelDaCameraFrame", UIParent, "BackdropTemplate")
painel:SetSize(200, 20)
painel:SetFrameStrata("MEDIUM")
painel:SetClampedToScreen(true)
painel:SetIgnoreParentAlpha(true)
painel:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
painel:SetBackdropColor(0, 0, 0, 0.45)
painel:EnableMouse(true)
painel:SetMovable(true)
painel:RegisterForDrag("LeftButton")

local texto = painel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
texto:SetPoint("TOPLEFT", 5, -4)
texto:SetJustifyH("LEFT")
texto:SetSpacing(2)

local function posicionar()
    local p = db().posicao
    painel:ClearAllPoints()
    if p then
        painel:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        painel:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -200)
    end
end

painel:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
painel:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local ponto, _, relativo, x, y = self:GetPoint()
    db().posicao = { ponto, relativo, x, y }
end)

local function atualizar()
    local l = leitura()
    texto:SetText(db().curto and textoCurto(l) or textoCompleto(l))
    painel:SetSize(math.max(60, texto:GetStringWidth() + 10), texto:GetStringHeight() + 8)
end

local mouseDentro, linhaMostrada, mostrarTooltip -- tooltip por linha (definidos mais abaixo)
local decorrido = 0
painel:SetScript("OnUpdate", function(_, dt)
    decorrido = decorrido + dt
    if decorrido < 0.1 then return end
    decorrido = 0
    atualizar()
    -- Troca o tooltip quando o mouse passa para outra linha.
    if mouseDentro then
        mostrarTooltip(painel)
    end
end)

-- Favoritas -----------------------------------------------------------------------

local function gostei(nota)
    local l = leitura()
    l.quando = date("%d/%m/%Y %H:%M:%S")
    l.nota = (nota and nota ~= "") and nota or nil
    local favoritos = db().favoritos
    favoritos[#favoritos + 1] = l
    while #favoritos > MAX_FAVORITOS do table.remove(favoritos, 1) end
    local linha = resumo(l) .. (l.nota and (" | nota: " .. l.nota) or "")
    if DiarioDaCamera then DiarioDaCamera.Anotar("gostei", linha) end
    print("|cff33ccffPainel da Camera:|r guardada como favorita (" .. #favoritos .. "): " .. linha)
end

painel:SetScript("OnMouseUp", function(_, botao)
    if botao == "RightButton" then gostei() end
end)

-- Tooltip de cada linha: o que o dado e e onde se muda. Mesma ordem do
-- textoCompleto. Nomes do /dc como aparecem no cliente em portugues.
local AJUDA = {
    { "Zoom", "Distancia da camera ate o personagem, em jardas. A roda do mouse muda.",
      "Zoom fixo (para onde ela volta): /zoomlivre" },
    { "Angulo vertical", "Quantos graus a camera esta acima do personagem. 0 = na altura dele; maior = olhando mais de cima. Gire com o botao direito do mouse.",
      "Giro automatico por situacao: /dc > Situacoes > (situacao) > Acoes da Situacao > Rotacao" },
    { "Zoom fixo", "Distancia para onde a camera volta ao sair de qualquer situacao (ZoomLivreEstavel). \"-\" = modo solto.",
      "/zoomlivre" },
    { "Zoom max", "Maior distancia que a roda do mouse alcanca.",
      "/dc > Configuracoes Base > Zoom do mouse > Distancia maxima da camera" },
    { "Situacao", "Situacao do DynamicCam que manda na camera agora. \"livre\" = nenhuma (vale a Configuracoes Base).",
      "/dc > Situacoes" },
    { "Ombro", "Deslocamento horizontal: tira o personagem do centro da tela, para o lado. 0 = centro.",
      "/dc > Configuracoes Base > Deslocamento Horizontal (ou na situacao: Configuracoes de Situacao)" },
    { "Inclinacao", "Inclinacao vertical (0 a 0.99): quanto maior, mais alto o personagem fica na tela. \"desligada\" = personagem no centro.",
      "/dc > Configuracoes Base > Inclinacao vertical > Inclinacao (no solo)" },
    { "Cabeca", "Rastreamento de Cabeca: a camera acompanha o balanco da cabeca do personagem. 0 = parada.",
      "/dc > Configuracoes Base > Rastreamento de Cabeca" },
    { "Foco NPC", "A camera vira sozinha para o NPC com quem voce conversa.",
      "/dc > Configuracoes Base > Foco no Alvo > Alvo de Interacao (NPCs)" },
    { "Foco inimigo", "A camera vira sozinha para o inimigo selecionado.",
      "/dc > Configuracoes Base > Foco no Alvo > Alvo Inimigo" },
    { "FOV", "Campo de visao em graus: maior mostra mais dos lados (padrao 90).",
      "/dc > Configuracoes Base > Campo de visao" },
}

-- Linha do texto sob o cursor (1 = primeira), ou nil.
local function linhaSobOCursor()
    local topo = texto:GetTop()
    if not topo then return nil end
    local _, cy = GetCursorPosition()
    cy = cy / texto:GetEffectiveScale()
    local _, altura = texto:GetFont()
    local passo = (altura or 10) + texto:GetSpacing()
    local i = math.floor((topo - cy) / passo) + 1
    return (i >= 1 and i <= #AJUDA) and i or nil
end

function mostrarTooltip(self)
    local i = not db().curto and linhaSobOCursor() or nil
    if i == linhaMostrada and GameTooltip:IsOwned(self) then return end
    linhaMostrada = i
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local ajuda = i and AJUDA[i]
    if ajuda then
        GameTooltip:AddLine(ajuda[1])
        GameTooltip:AddLine(ajuda[2], 1, 1, 1, true)
        GameTooltip:AddLine(ajuda[3], 0.4, 0.8, 1, true)
    else
        GameTooltip:AddLine("Painel da Camera")
        GameTooltip:AddLine("Passe o mouse num dado para ver o que ele e", 1, 1, 1)
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Botao direito: guardar esta camera como favorita", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("Arrastar: mover - /pcam curto, /pcam favoritos, /pcam", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end

painel:SetScript("OnEnter", function(self)
    mouseDentro = true
    linhaMostrada = false -- forca montar o tooltip
    mostrarTooltip(self)
end)
painel:SetScript("OnLeave", function()
    mouseDentro = false
    GameTooltip:Hide()
end)

-- Inicio ---------------------------------------------------------------------------

painel:Hide()
local eventos = CreateFrame("Frame")
eventos:RegisterEvent("PLAYER_LOGIN")
eventos:SetScript("OnEvent", function()
    posicionar()
    painel:SetShown(db().visivel)
end)

SLASH_PAINELDACAMERA1 = "/pcam"
SLASH_PAINELDACAMERA2 = "/painelcamera"
SlashCmdList["PAINELDACAMERA"] = function(msg)
    local comando, resto = strtrim(msg or ""):match("^(%S*)%s*(.-)$")
    comando = comando:lower()
    local d = db()
    if comando == "curto" then
        d.curto = not d.curto
        atualizar()
    elseif comando == "gostei" then
        gostei(resto)
    elseif comando == "favoritos" then
        local n = #d.favoritos
        if n == 0 then
            print("|cff33ccffPainel da Camera:|r nenhuma favorita ainda (botao direito no painel).")
        end
        for i = math.max(1, n - 9), n do
            local f = d.favoritos[i]
            print(("|cff33ccff%d|r %s | %s%s"):format(i, f.quando, resumo(f), f.nota and (" | " .. f.nota) or ""))
        end
    else
        d.visivel = not d.visivel
        painel:SetShown(d.visivel)
    end
end
