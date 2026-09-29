-- NPC Altura: mede a altura do modelo 3D do NPC com quem voce fala.
--
-- O WoW nao tem uma funcao "altura da unidade". O que existe e o ator de uma
-- ModelScene (o mesmo tipo de objeto do provador): carrega o modelo de uma
-- unidade e informa a caixa de contorno com GetActiveBoundingBox(), que
-- devolve o ponto mais baixo e o mais alto. Altura = topo.z - base.z.
--
-- Carregar o modelo nao e instantaneo, entao a medida chega alguns
-- milissegundos depois de o dialogo abrir. Ela fica guardada por NPC
-- (NpcAlturaDB.cache) e, quando chega, o DynamicCam e avisado para reavaliar
-- as situacoes - a "NPC grande (dialogo)" consulta NpcAltura.EhGrande().
--
-- /altura            mostra a altura do NPC do dialogo (ou do alvo)
-- /altura limite N   NPCs com altura >= N contam como grandes
-- /altura limpar     esquece as medidas guardadas

NpcAltura = {}

local LIMITE_PADRAO = 4

local scene = CreateFrame("ModelScene", nil, UIParent)
scene:SetSize(64, 64)
-- Fora da tela e transparente: precisa estar "mostrada" para o modelo carregar.
scene:SetPoint("TOPLEFT", UIParent, "BOTTOMRIGHT", 200, -200)
scene:SetAlpha(0)
scene:Show()

local actor = scene:CreateActor()
local pendente -- { id, nome, mostrar }

local function db()
    NpcAlturaDB = NpcAlturaDB or {}
    NpcAlturaDB.cache = NpcAlturaDB.cache or {}
    NpcAlturaDB.limite = NpcAlturaDB.limite or LIMITE_PADRAO
    return NpcAlturaDB
end

local function secreto(v)
    return issecretvalue and issecretvalue(v)
end

local function npcId(unit)
    local guid = UnitGUID(unit)
    if not guid or secreto(guid) then return nil end
    local tipo, _, _, _, _, id = strsplit("-", guid)
    if tipo == "Creature" or tipo == "Vehicle" then return id end
    return nil
end

local function alturaDoAtor()
    local base, topo = actor:GetActiveBoundingBox()
    if type(base) ~= "table" or type(topo) ~= "table" or not base.z or not topo.z then
        return nil
    end
    local h = (topo.z - base.z) * (actor:GetScale() or 1)
    if h <= 0 then return nil end
    return h
end

local function relatar(id, nome, h)
    local d = db()
    local grande = h >= d.limite
    print(("|cff33ccffNPC Altura:|r %s (%s) = %.2f  (limite %.2f) -> %s"):format(
        nome or "?", id, h, d.limite, grande and "GRANDE" or "normal"))
end

local function concluir()
    if not pendente then return end
    local h = alturaDoAtor()
    if not h then return end -- ainda nao carregou; o ticker de medir() tenta de novo
    local p = pendente
    pendente = nil
    db().cache[p.id] = h
    if p.mostrar then relatar(p.id, p.nome, h) end
    if DynamicCam and DynamicCam.EvaluateSituations then
        DynamicCam:EvaluateSituations()
    end
end

-- Ator criado sem template nao tem SetScript("OnModelLoaded"); em vez disso
-- confere a cada 0,05 s, por ate 2 s, se o modelo ja carregou.
local ticker
local function esperarCarregar()
    if ticker then ticker:Cancel() end
    ticker = C_Timer.NewTicker(0.05, function(t)
        if not pendente then t:Cancel() return end
        if actor:IsLoaded() then concluir() end
        if not pendente then t:Cancel() end
    end, 40)
end

local function medir(unit, mostrar)
    if not UnitExists(unit) then return false end
    local id = npcId(unit)
    if not id then return false end
    local nome = UnitName(unit)
    if secreto(nome) then nome = nil end

    local guardada = db().cache[id]
    if guardada and not mostrar then return true end

    pendente = { id = id, nome = nome, mostrar = mostrar }
    actor:ClearModel()
    if not actor:SetModelByUnit(unit) then
        pendente = nil
        return false
    end
    if actor:IsLoaded() then concluir() end
    if pendente then esperarCarregar() end
    if mostrar then
        C_Timer.After(2, function()
            if pendente and pendente.id == id then
                pendente = nil
                print("|cff33ccffNPC Altura:|r nao consegui medir este NPC (o modelo nao carregou ou nao informou o contorno).")
            end
        end)
    end
    return true
end

-- API para o DynamicCam -------------------------------------------------------

function NpcAltura.Get(id)
    return id and db().cache[id]
end

function NpcAltura.EhGrande(id)
    local h = NpcAltura.Get(id)
    return h ~= nil and h >= db().limite
end

-- Mede ao abrir qualquer dialogo/interacao com NPC ----------------------------

local eventos = CreateFrame("Frame")
for _, e in ipairs({
    "GOSSIP_SHOW", "QUEST_GREETING", "QUEST_DETAIL", "QUEST_PROGRESS",
    "QUEST_COMPLETE", "MERCHANT_SHOW", "TRAINER_SHOW", "BANKFRAME_OPENED",
    "PLAYER_INTERACTION_MANAGER_FRAME_SHOW",
}) do
    eventos:RegisterEvent(e)
end
eventos:SetScript("OnEvent", function()
    medir("npc", false)
end)

-- /altura ----------------------------------------------------------------------

SLASH_NPCALTURA1 = "/altura"
SlashCmdList["NPCALTURA"] = function(msg)
    local cmd, arg = strsplit(" ", strtrim(msg or ""), 2)
    cmd = (cmd or ""):lower()
    local d = db()

    if cmd == "limite" then
        local n = tonumber(arg)
        if n and n > 0 then
            d.limite = n
            print(("|cff33ccffNPC Altura:|r limite = %.2f"):format(n))
            if DynamicCam and DynamicCam.EvaluateSituations then DynamicCam:EvaluateSituations() end
        else
            print(("|cff33ccffNPC Altura:|r limite atual = %.2f. Use /altura limite 4.5"):format(d.limite))
        end
        return
    end

    if cmd == "limpar" then
        wipe(d.cache)
        print("|cff33ccffNPC Altura:|r medidas apagadas.")
        return
    end

    local unit = UnitExists("npc") and "npc" or "target"
    if not medir(unit, true) then
        print("|cff33ccffNPC Altura:|r fale com um NPC (ou selecione-o) e use /altura.")
    end
end
