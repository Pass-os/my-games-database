-- Mantem Janelas de NPC
--
-- DynamicCam ("Ocultar Interface" numa situacao) e Immersion ("Ocultar
-- interface") escondem a interface deixando o UIParent transparente. Toda
-- janela filha do UIParent some junto - inclusive a loja, o treinador ou a
-- janela de recrutar tropas do salao de classe que o NPC abre.
--
-- O DynamicCam tem uma lista "quadros para manter", mas decide isso no
-- momento em que esconde a interface e so tenta de novo uma vez, 0,3 s
-- depois. Janela carregada sob demanda (salao de classe, guarnicao, pacto,
-- escolhas de historia) costuma aparecer depois disso e fica invisivel.
--
-- Aqui a regra e simples: se uma janela desta lista esta aberta e o UIParent
-- esta transparente, ela passa a ignorar a transparencia do pai (fica
-- visivel). Vale quando a interface e escondida com a janela ja aberta (gancho
-- no UIParent:SetAlpha) e quando a janela abre depois (gancho no OnShow). Ao
-- fechar, a janela volta a seguir o UIParent.
--
-- Nomes conferidos no codigo da interface da Blizzard, Retail 12.1.0 (69933):
-- github.com/Gethe/wow-ui-source, branch live.

local JANELAS = {
    -- Dialogo e missao (ignoradas com Immersion ativo, que as substitui)
    "GossipFrame", "QuestFrame", "ItemTextFrame",
    -- Escolhas de historia e confirmacoes
    "PlayerChoiceFrame", "AdventureMapQuestChoiceDialog",
    "StaticPopup1", "StaticPopup2", "StaticPopup3", "StaticPopup4",
    -- Comercio e servicos
    "MerchantFrame", "ClassTrainerFrame", "BankFrame", "GuildBankFrame",
    "AuctionHouseFrame", "BlackMarketFrame", "TransmogFrame", "TabardFrame",
    "GuildRegistrarFrame", "PetitionFrame", "GuildRenameFrame", "StableFrame",
    "MailFrame", "FlightMapFrame", "TaxiFrame", "ProfessionsCustomerOrdersFrame",
    -- Itens
    "ItemUpgradeFrame", "ItemInteractionFrame", "ItemSocketingFrame",
    "ScrappingMachineFrame", "ObliterumForgeFrame", "AzeriteRespecFrame",
    "AzeriteEssenceUI", "RuneforgeFrame", "ArtifactFrame",
    -- Guarnicao (WoD), salao de classe (Legion), BfA, pactos (Shadowlands)
    "GarrisonCapacitiveDisplayFrame", "GarrisonMissionFrame", "GarrisonShipyardFrame",
    "GarrisonRecruiterFrame", "GarrisonBuildingFrame", "GarrisonMonumentFrame",
    "OrderHallMissionFrame", "OrderHallTalentFrame", "BFAMissionFrame",
    "CovenantMissionFrame", "CovenantSanctumFrame", "CovenantRenownFrame",
    "CovenantPreviewFrame", "SoulbindViewer", "AnimaDiversionFrame",
    -- Sistemas mais novos
    "GenericTraitFrame", "ChromieTimeFrame", "ContributionCollectionFrame",
    "IslandsQueueFrame", "WeeklyRewardsFrame", "AlliedRacesFrame", "PerksProgramFrame",
    "DelvesDifficultyPickerFrame", "DelvesCompanionConfigurationFrame",
    "EncounterJournal", "WorldMapFrame",
    "HousingBulletinBoardFrame", "NeighborhoodChangeNameDialog", "HouseFinderFrame",
    -- Provador e bolsas (vender, provar recompensa)
    "DressUpFrame", "SideDressUpFrame", "ContainerFrameCombinedBags",
    "ContainerFrame1", "ContainerFrame2", "ContainerFrame3",
    "ContainerFrame4", "ContainerFrame5", "ContainerFrame6", "ContainerFrame7",
}

local SUBSTITUIDAS_PELO_IMMERSION = { GossipFrame = true, QuestFrame = true, ItemTextFrame = true }

local NA_LISTA = {}
for _, nome in ipairs(JANELAS) do NA_LISTA[nome] = true end

-- Diario (addon DiarioDaCamera, se instalado): janelas mantidas, bloqueios em
-- combate e janelas que ficaram escondidas sem estar na lista (candidatas a
-- entrar nela).
local function anotar(texto)
    if DiarioDaCamera then DiarioDaCamera.Anotar("janelas", texto) end
end
local anotadasForaDaLista = {}

local enganchadas = {}

local function immersionAtivo()
    return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Immersion")
end

local function interfaceEscondida()
    return UIParent:GetAlpha() < 0.99
end

local function podeMexer(frame)
    return not (InCombatLockdown() and frame:IsProtected())
end

local function manter(frame)
    if not frame:IsShown() or not interfaceEscondida() then return end
    if not podeMexer(frame) then
        if not frame.mantemJanelasNPCBloqueada then
            frame.mantemJanelasNPCBloqueada = true
            anotar("bloqueada em combate (janela protegida): " .. (frame:GetName() or "?"))
        end
        return
    end
    if SUBSTITUIDAS_PELO_IMMERSION[frame:GetName() or ""] and immersionAtivo() then return end
    if not frame:IsIgnoringParentAlpha() then
        frame:SetIgnoreParentAlpha(true)
        frame.mantemJanelasNPC = true
        anotar(("mantida visivel: %s (interface em %.2f)"):format(frame:GetName() or "?", UIParent:GetAlpha()))
    end
    if frame:GetAlpha() < 1 then frame:SetAlpha(1) end
end

local function soltar(frame)
    frame.mantemJanelasNPCBloqueada = nil
    if frame.mantemJanelasNPC and podeMexer(frame) then
        frame:SetIgnoreParentAlpha(false)
        frame.mantemJanelasNPC = nil
    end
end

local function enganchar(nome)
    if enganchadas[nome] then return end
    local frame = _G[nome]
    if type(frame) ~= "table" or not frame.HookScript then return end
    enganchadas[nome] = frame
    frame:HookScript("OnShow", manter)
    frame:HookScript("OnHide", soltar)
    manter(frame)
end

local function engancharTodas()
    for _, nome in ipairs(JANELAS) do enganchar(nome) end
end

-- Interface sendo escondida com a janela ja aberta: DynamicCam e Immersion
-- mudam o alfa do UIParent aos poucos (fade), um SetAlpha por quadro.
-- Janelas que fecham com ESC (UISpecialFrames) abertas com a interface
-- escondida e fora da lista: anota uma vez por sessao.
local function procurarForaDaLista()
    if not interfaceEscondida() or not UISpecialFrames then return end
    for _, nome in ipairs(UISpecialFrames) do
        local frame = _G[nome]
        if not NA_LISTA[nome] and not anotadasForaDaLista[nome] and type(frame) == "table"
            and frame.IsShown and frame:IsShown() and not frame:IsIgnoringParentAlpha() then
            anotadasForaDaLista[nome] = true
            anotar("escondida e FORA da lista (avaliar incluir): " .. nome)
        end
    end
end

local procurando = false
hooksecurefunc(UIParent, "SetAlpha", function(_, alfa)
    if alfa and alfa < 0.99 then
        for _, frame in pairs(enganchadas) do manter(frame) end
        -- Uma busca por fade, 1 s depois (as janelas sob demanda chegam atrasadas).
        if not procurando then
            procurando = true
            C_Timer.After(1, function()
                procurando = false
                procurarForaDaLista()
            end)
        end
    end
end)

-- Muitas dessas janelas so existem depois que o addon da Blizzard carrega.
local eventos = CreateFrame("Frame")
eventos:RegisterEvent("PLAYER_LOGIN")
eventos:RegisterEvent("ADDON_LOADED")
eventos:SetScript("OnEvent", engancharTodas)
