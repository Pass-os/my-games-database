-- Zoom Livre Estavel
--
-- "Zoom livre" e a distancia da camera quando nenhuma situacao do DynamicCam
-- esta ativa (a que voce escolhe com a roda do mouse / Page Up / Page Down).
--
-- O DynamicCam guarda essa distancia ao entrar numa situacao e a devolve ao
-- sair. O problema: ele guarda GetCameraZoom() daquele instante. Se voce entra
-- numa situacao enquanto a camera ainda esta voltando da anterior (desmontou e
-- montou de novo, falou com dois NPCs seguidos...), ele guarda o MEIO do
-- caminho, e na volta a camera para ali. A cada repeticao ela "anda".
-- (DynamicCam 2.21.1, SituationManager.lua, ChangeSituation: lastZoom["no-situation"].)
--
-- Aqui guardamos a distancia livre por conta propria: se a camera ainda esta
-- voltando, vale o DESTINO da volta, nao o meio. Ao voltar para a camera
-- livre, levamos a camera para essa distancia.

local zoomLivre            -- distancia escolhida por voce
local destinoDaVolta       -- para onde a camera esta voltando agora
local fimDaVolta           -- quando essa volta termina (GetTime)

local function libCamera()
    return LibStub and LibStub("LibCamera-1.0", true)
end

local function aoTrocarDeSituacao(dynamicCam, situacaoAntiga, situacaoNova)
    if dynamicCam.db.profile.zoomRestoreSetting == "never" then return end

    -- Saindo da camera livre: anota a distancia escolhida.
    if situacaoAntiga == nil and situacaoNova ~= nil then
        local aindaVoltando = fimDaVolta and GetTime() < fimDaVolta
        zoomLivre = aindaVoltando and destinoDaVolta or GetCameraZoom()
        fimDaVolta = nil
        return
    end

    -- Voltando para a camera livre: leva a camera para a distancia anotada
    -- (o DynamicCam acabou de mandar para o valor dele; este SetZoom substitui).
    if situacaoAntiga ~= nil and situacaoNova == nil and zoomLivre then
        local lib = libCamera()
        if not lib then return end
        local situacao = dynamicCam.db.profile.situations[situacaoAntiga]
        local segundos = situacao and situacao.transitionTime and situacao.transitionTime.timeToExit or 0.75
        dynamicCam:ResetReactiveZoomTarget()
        lib:SetZoom(zoomLivre, segundos)
        destinoDaVolta = zoomLivre
        fimDaVolta = GetTime() + segundos
    end
end

local instalado = false
local function instalar()
    if instalado or not (DynamicCam and DynamicCam.ChangeSituation) then return end
    instalado = true
    hooksecurefunc(DynamicCam, "ChangeSituation", aoTrocarDeSituacao)
end

local eventos = CreateFrame("Frame")
eventos:RegisterEvent("ADDON_LOADED")
eventos:RegisterEvent("PLAYER_LOGIN")
eventos:SetScript("OnEvent", instalar)

-- /zoomlivre mostra o que esta anotado (para conferir).
SLASH_ZOOMLIVRE1 = "/zoomlivre"
SlashCmdList["ZOOMLIVRE"] = function()
    print(("|cff33ccffZoom Livre:|r anotado %s | camera agora %.1f | situacao %s"):format(
        zoomLivre and ("%.1f"):format(zoomLivre) or "nada",
        GetCameraZoom(),
        tostring(DynamicCam and DynamicCam.currentSituationID)))
end
