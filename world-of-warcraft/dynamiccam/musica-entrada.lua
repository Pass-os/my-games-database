-- DynamicCam > Situacoes > NPC Interaction > Controles de Situacao > Script de Entrada
-- Abaixa a musica ao abrir um dialogo, com fade suave (smoothstep).
-- Cole SO este codigo (sem estas linhas de comentario, se preferir) e clique em Salvar.
--
-- this.vol  guarda o volume que voce usa, para o Script de Saida devolver.
-- this.t    invalida um fade em andamento se o dialogo fechar no meio.
-- to        volume durante o dialogo (0 = silencio total).
-- dur       duracao do fade em segundos.

this.vol = this.vol or tonumber(GetCVar("Sound_MusicVolume")) or 0.4
this.t = (this.t or 0) + 1
local t, from, to = this.t, tonumber(GetCVar("Sound_MusicVolume")) or this.vol, 0.03
local steps, dur = 30, 2.5
for i = 1, steps do
  C_Timer.After(i * dur / steps, function()
    if this.t == t then
      local p = i / steps
      p = p * p * (3 - 2 * p)
      SetCVar("Sound_MusicVolume", from + (to - from) * p)
    end
  end)
end
