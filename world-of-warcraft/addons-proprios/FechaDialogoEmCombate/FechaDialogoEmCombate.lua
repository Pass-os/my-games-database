-- Fecha o dialogo com NPC ao entrar em combate.
--
-- PLAYER_REGEN_DISABLED dispara quando o combate comeca. Nada aqui e
-- protegido (fechar gossip, missao e livro e permitido em combate), entao
-- funciona mesmo com o lockdown ja ativo.

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

frame:SetScript("OnEvent", function()
    -- Immersion: ForceClose e o mesmo caminho do ESC (fecha gossip, missao e
    -- livro e ainda toca a animacao de saida da caixa).
    local immersion = _G.ImmersionFrame
    if immersion and immersion:IsShown() and immersion.ForceClose then
        immersion:ForceClose()
        return
    end

    -- Sem Immersion (ou com a caixa fechada): janelas padrao da Blizzard.
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
