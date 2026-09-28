-- DynamicCam > Situacoes > "Conjurando (fora de combate)" > Controles de Situacao > Script de Entrada
-- Treme a camera enquanto conjura: micro-giros de ida e volta, horizontal e
-- vertical em ritmos diferentes, com a intensidade crescendo no comeco.
--
-- Ajustes:
--   amp      intensidade maxima, em graus (0.4 sutil, 0.8 forte)
--   rampa    segundos ate chegar na intensidade maxima
--   passo    duracao de cada micro-giro (menor = tremor mais rapido)
--
-- Usa a LibCamera que vem dentro do DynamicCam. Cada micro-giro volta o que
-- andou, entao a camera termina onde comecou (sobra no maximo uma fracao de
-- grau se a conjuracao acabar no meio de um giro).

local cam = DynamicCam.LibCamera
if not cam then return end

local amp, rampa, passo = 0.6, 1.2, 0.05
this.tremor = (this.tremor or 0) + 1
local id, inicio = this.tremor, GetTime()

local function forca()
  local t = (GetTime() - inicio) / rampa
  if t > 1 then t = 1 end
  return amp * (0.3 + 0.7 * t)
end

-- Horizontal: vai e volta. Vertical: mesmo esquema, mais lento e mais fraco.
local function eixo(girar, fator, duracao, lado)
  if this.tremor ~= id then return end
  local a = forca() * fator * (0.6 + 0.4 * math.random())
  girar(cam, a * lado, duracao, nil, function()
    if this.tremor ~= id then return end
    girar(cam, -a * lado, duracao, nil, function()
      eixo(girar, fator, duracao, -lado)
    end)
  end)
end

eixo(cam.Yaw, 1.0, passo, 1)
eixo(cam.Pitch, 0.6, passo * 1.4, -1)
