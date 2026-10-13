-- DynamicCam > Situacoes > "Imersao (Delve)" > Controles de Situacao > Condicao
-- Ativa com uma Imersao (Delve) em andamento. Sem ela, Imersoes caem na
-- "Masmorra/Cenario" (020), junto com as masmorras de grupo.
--
-- Eventos: SCENARIO_UPDATE, ZONE_CHANGED_NEW_AREA, ACTIVE_DELVE_DATA_UPDATE
-- Prioridade: 4 (acima da Masmorra/Cenario, 2).
-- Zoom: desligado - vale o zoom fixo do ZoomLivreEstavel.
-- Configuracoes de Situacao: como a 020, mas com ombro 0.3 (voce sozinho
-- com o companheiro, sem grupo para enxergar).

return C_PartyInfo and C_PartyInfo.IsDelveInProgress and C_PartyInfo.IsDelveInProgress() or false
