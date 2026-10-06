# Pendente (28/09/2026)

Feito: `/npcgrande` corrigido no arquivo do PC (`getfenv(0)`), configuracao
e macros salvas em `config/` pelo `salvar-config.ps1`.

## Decisoes do usuario

1. **NPC grande (custom1) esta com Afastar 1.5**, que nao faz nada. Voltar
   para 18? (Provavelmente mudou sem querer.)
2. **Montaria voando (situacao 102, "apenas montaria voadora + no ar") sem
   Ocultar Interface**: copiar o da 100 (opacidade 0, Minimapa, vigor,
   `MainActionBar`)?
3. **Transformacao (historia)** (`custom2`): condicao em
   `dynamiccam/transformacao-condicao.lua`, prioridade 1001, zoom Definir 20.
   O Ocultar Interface dela deveria copiar o da montaria no ar - que hoje nao
   existe (item 2). Decidir junto.
4. **Conjurando**: criadas `custom3` "Conjurando (fora de combate)"
   (Aproximar 8, 0.6 / 0.8 s) e `custom4` "Conjurando (em combate)" (sem
   acoes), ambas prioridade 60. O usuario vai ajustar pela interface;
   depois, `salvar-config.ps1`.
5. Branch `world-of-warcraft`: juntar na `main` direto ou via Pull Request?

## Para testar no futuro

- **Vozes naturais pt-BR no WoW (Francisca/Antonio/Thalita).** Videos mostram
  funcionando com o NaturalVoiceSAPIAdapter pelo instalador grafico; aqui, em
  02/10/2026 (WoW 12.1, adapter v0.2.9 registrado por regsvr32), o WoW nao
  carregou a DLL e ficou mudo. Testar com `scripts\testar-vozes-naturais.ps1`
  (usa o Installer.exe como nos videos), de preferencia no PC de casa (no do
  trabalho as vozes do Edge tambem davam "Timer Expired" fora do jogo).
  Resultado no `-Diagnostico`: "CARREGOU" = funciona (se mudo, e rede);
  "NAO carregou" = o WoW recusa, desinstalar. Se funcionar, juntar ao
  `instalar-vozes.ps1` e atualizar o README.

## Como aplicar

Com o WoW **fechado**: ler o `DynamicCam.lua` do PC, preservar o que o
usuario mudou pela interface, editar so o necessario, rodar o
`salvar-config.ps1`, commitar. Os valores atuais estao em
`dynamiccam/SITUACOES.md`.
