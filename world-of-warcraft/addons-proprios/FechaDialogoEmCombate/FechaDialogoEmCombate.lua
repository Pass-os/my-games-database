-- Fecha o dialogo com NPC ao entrar em combate.
--
-- PLAYER_REGEN_DISABLED dispara quando o combate comeca. Nada aqui e
-- protegido (fechar gossip, missao e livro e permitido em combate), entao
-- funciona mesmo com o lockdown ja ativo.

-- Diario (addon DiarioDaCamera, se instalado): o que foi fechado.
local function anotar(texto)
    if DiarioDaCamera then DiarioDaCamera.Anotar("combate", texto) end
end

local function aberta(nome)
    return _G[nome] and _G[nome]:IsShown()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

frame:SetScript("OnEvent", function()
    -- Immersion: ForceClose e o mesmo caminho do ESC (fecha gossip, missao e
    -- livro e ainda toca a animacao de saida da caixa).
    local immersion = _G.ImmersionFrame
    if immersion and immersion:IsShown() and immersion.ForceClose then
        immersion:ForceClose()
        anotar("entrou em combate: fechou o dialogo do Immersion")
        return
    end

    -- Sem Immersion (ou com a caixa fechada): janelas padrao da Blizzard.
    local fechadas = {}
    for _, nome in ipairs({ "GossipFrame", "QuestFrame", "ItemTextFrame" }) do
        if aberta(nome) then fechadas[#fechadas + 1] = nome end
    end
    if #fechadas > 0 then
        anotar("entrou em combate: fechou " .. table.concat(fechadas, ", "))
    end
    if C_GossipInfo and C_GossipInfo.CloseGossip then
        C_GossipInfo.CloseGossip()
    end
    if CloseQuest then
        CloseQuest()
    end
    if CloseItemText then
        CloseItemText()
    end
end)
