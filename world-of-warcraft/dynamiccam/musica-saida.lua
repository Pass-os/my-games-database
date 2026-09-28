-- DynamicCam > Situacoes > NPC Interaction > Controles de Situacao > Script de Saida
-- Devolve a musica ao volume guardado pelo Script de Entrada, com fade suave.
-- Se o dialogo fechar no meio do fade de entrada, parte de onde o volume estiver.

if not this.vol then return end
this.t = (this.t or 0) + 1
local t, from, to = this.t, tonumber(GetCVar("Sound_MusicVolume")) or 0, this.vol
local steps, dur = 40, 3.5
for i = 1, steps do
  C_Timer.After(i * dur / steps, function()
    if this.t == t then
      local p = i / steps
      p = p * p * (3 - 2 * p)
      SetCVar("Sound_MusicVolume", from + (to - from) * p)
      if i == steps then this.vol = nil end
    end
  end)
end
