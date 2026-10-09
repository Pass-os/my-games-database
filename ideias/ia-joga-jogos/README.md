# IA jogando jogos — guia técnico de implementação

Guia para montar, do zero, um agente de LLM que joga um jogo sozinho. O exemplo de referência é **Pokémon Red (Game Boy) com PyBoy + Claude API em Python**, a mesma família de setup do *Claude Plays Pokémon* e do *Gemini Plays Pokémon*. A seção [Adaptando para outro jogo](#12-adaptando-para-outro-jogo) mostra o que muda em Minecraft, jogos de PC e jogos de navegador.

> Você precisa ter a ROM do jogo (dump do seu cartucho). Este repositório não inclui nem aponta ROMs.

---

## 1. A ideia em uma frase

O modelo **não joga sozinho**: um programa (o *harness*) lê o estado do jogo, transforma em texto e imagem, pede ao modelo uma decisão por *tool calling*, executa a decisão no emulador e repete.

```
┌──────────────┐  print + RAM decodificada   ┌──────────────────┐   prompt (texto+imagem)  ┌─────────┐
│  Emulador    │ ──────────────────────────▶ │     Harness      │ ───────────────────────▶ │  Claude │
│  (PyBoy)     │                             │  observa / age / │                          │         │
│              │ ◀────────────────────────── │  memória / logs  │ ◀─────────────────────── │         │
└──────────────┘  botões, frames             └──────────────────┘   tool_use (ação)        └─────────┘
```

Regra de ouro, tirada de todos os projetos que funcionam: **o LLM decide a estratégia ("o quê"); código determinístico cuida da execução ("como")**. Timing de menu, contagem de frames e pathfinding ficam no código, não no modelo.

---

## 2. Escolha do jogo e do canal de entrada

Antes de escrever código, decida **como o agente vai enxergar e agir**. Essa escolha pesa mais no resultado do que o modelo usado.

| Canal | Vê o jogo por | Age por | Dificuldade | Quando usar |
|---|---|---|---|---|
| **Emulador + RAM** | print + memória decodificada | botões virtuais | média | jogos retrô (GB, GBA, NES, SNES) |
| **API do jogo** | estado estruturado | comandos ou código | baixa | Minecraft (Mineflayer), jogos com mod/API, Showdown |
| **Pixels puros** | só a tela | mouse e teclado do SO | alta | qualquer jogo de PC, mas o resultado é fraco |

Recomendação: **comece com um jogo de turno ou de ritmo lento** (Pokémon, RPG, puzzle, roguelike). Jogos em tempo real (plataforma, tiro) exigem reação em milissegundos, e cada chamada ao modelo leva segundos. Nos benchmarks com pixels puros (VideoGameBench), os modelos de ponta mal passam do começo dos jogos.

---

## 3. Arquitetura

### Estrutura de pastas sugerida

```
agente-jogo/
├── pyproject.toml
├── .env                      # ANTHROPIC_API_KEY (ou use `ant auth login`)
├── roms/                     # sua ROM (fora do git)
├── saves/                    # save states (checkpoints)
├── runs/<timestamp>/         # logs de cada execução
│   ├── steps.jsonl           # 1 linha por passo: observação, raciocínio, ação, resultado
│   └── frames/000123.png
└── src/agente/
    ├── env.py                # interface genérica do jogo (observar / agir / salvar)
    ├── env_pyboy.py          # implementação para PyBoy
    ├── ram_map.py            # endereços de RAM e decodificação
    ├── observation.py        # monta o prompt (texto + imagem) a partir do estado
    ├── tools.py              # schemas das ferramentas e execução
    ├── navigation.py         # BFS/A* sobre o mapa aprendido
    ├── memory.py             # notas persistentes, objetivo atual, histórico curto
    ├── progress.py           # detecção de travamento e métricas de progresso
    ├── agent.py              # loop principal
    └── viewer.py             # (opcional) UI ao vivo: frame + último raciocínio
```

### Responsabilidade de cada camada

| Camada | Faz | Não faz |
|---|---|---|
| `env` | fala com o emulador: ler RAM, print, apertar botão, avançar frames, salvar/carregar estado | decidir nada |
| `observation` | transforma estado bruto em texto curto e útil | chamar a API |
| `tools` | define o que o modelo pode pedir e executa com segurança | interpretar intenção vaga |
| `memory` | guarda o que precisa sobreviver entre passos | guardar o histórico inteiro |
| `agent` | orquestra o loop, chama o modelo, registra logs | lógica de jogo |

Mantenha `env` atrás de uma interface (seção 4). Assim, trocar de jogo é escrever outro `env_*.py` e outro `ram_map.py`, e o resto continua igual.

---

## 4. Camada de ambiente

### Interface genérica

```python
# src/agente/env.py
from dataclasses import dataclass
from typing import Protocol
from PIL import Image


@dataclass
class GameState:
    map_id: int
    x: int
    y: int
    in_battle: bool
    party: list[dict]      # [{"species": ..., "hp": .., "max_hp": .., "level": ..}]
    badges: int
    raw: dict              # qualquer outro campo útil


class GameEnv(Protocol):
    def state(self) -> GameState: ...
    def screenshot(self) -> Image.Image: ...
    def press(self, buttons: list[str], hold_frames: int = 8, wait_frames: int = 16) -> None: ...
    def tick(self, frames: int) -> None: ...
    def save(self, path: str) -> None: ...
    def load(self, path: str) -> None: ...
```

### Implementação com PyBoy

```python
# src/agente/env_pyboy.py
from pyboy import PyBoy
from .env import GameState
from . import ram_map as R

VALID = {"a", "b", "start", "select", "up", "down", "left", "right"}


class PyBoyEnv:
    def __init__(self, rom: str, headless: bool = True):
        self.pb = PyBoy(rom, window="null" if headless else "SDL2")
        self.pb.set_emulation_speed(0)  # sem limite: o emulador não espera tempo real

    def press(self, buttons, hold_frames=8, wait_frames=16):
        for b in buttons:
            if b not in VALID:
                raise ValueError(f"botão inválido: {b}")
            self.pb.button(b, hold_frames)
            self.pb.tick(hold_frames + wait_frames)  # deixa a animação terminar

    def tick(self, frames):
        self.pb.tick(frames)

    def screenshot(self):
        return self.pb.screen.image.copy()

    def save(self, path):
        with open(path, "wb") as f:
            self.pb.save_state(f)

    def load(self, path):
        with open(path, "rb") as f:
            self.pb.load_state(f)

    def state(self) -> GameState:
        m = self.pb.memory
        return GameState(
            map_id=m[R.CUR_MAP],
            x=m[R.X_COORD],
            y=m[R.Y_COORD],
            in_battle=m[R.IS_IN_BATTLE] != 0,
            party=R.read_party(m),
            badges=bin(m[R.OBTAINED_BADGES]).count("1"),
            raw={},
        )
```

### Mapa de RAM

Ler a RAM é o que separa um agente que funciona de um que fica perdido. Os modelos de visão ainda erram bastante ao interpretar pixels, e a RAM entrega o estado exato.

```python
# src/agente/ram_map.py
# Endereços do Pokémon Red/Blue (EUA). Confira no arquivo de símbolos do
# disassembly `pret/pokered` (pokered.sym) antes de confiar: versões
# diferentes da ROM mudam os endereços.
CUR_MAP         = 0xD35E
Y_COORD         = 0xD361
X_COORD         = 0xD362
OBTAINED_BADGES = 0xD356
IS_IN_BATTLE    = 0xD057   # 0 = fora, 1 = selvagem, 2 = treinador
PARTY_COUNT     = 0xD163
PARTY_MON1      = 0xD16B   # início da struct do 1º Pokémon (44 bytes cada)
PARTY_MON_SIZE  = 44


def read_u16_be(m, addr):
    return (m[addr] << 8) | m[addr + 1]


def read_party(m):
    party = []
    for i in range(min(m[PARTY_COUNT], 6)):
        base = PARTY_MON1 + i * PARTY_MON_SIZE
        party.append({
            "species_id": m[base],
            "hp": read_u16_be(m, base + 1),
            "level": m[base + 0x21],
            "max_hp": read_u16_be(m, base + 0x22),
        })
    return party
```

Para outros jogos: procure o **disassembly** do jogo (o grupo `pret` tem Red, Crystal, Emerald e outros) ou descubra os endereços você mesmo com o *RAM search* de um emulador como BizHawk ou mGBA (busca o valor, muda no jogo, filtra os endereços que mudaram).

---

## 5. Observação: o que vai no prompt a cada passo

O prompt de cada passo deve ser **curto, factual e estável no formato**. Exemplo do texto gerado por `observation.py`:

```
## Estado
Mapa: PALLET_TOWN (id 0)  Posição: x=5, y=6
Em batalha: não
Insígnias: 0/8
Time:
  1. CHARMANDER nv.6  HP 21/21

## Objetivo atual
Ir ao laboratório do Prof. Carvalho e pegar a Pokédex.

## Notas (memória persistente, resumida)
- Laboratório fica ao sul de Pallet, porta em x=12,y=11.
- Saída norte de Pallet leva à Rota 1.

## Últimas 8 ações
#118 walk(up, 3)        -> posição mudou (5,9)->(5,6)
#119 press([a])         -> diálogo abriu
#120 press([a,a,a])     -> diálogo fechou
...

## Alerta
(vazio, ou: "Sem posição nova há 40 passos. Reveja a estratégia.")
```

Mais o **print da tela** como bloco de imagem. Dicas:

- **Amplie o print** (o GB tem 160×144 px): use 3× a 4× com `Image.NEAREST` para os pixels continuarem nítidos.
- **Traduza IDs em nomes** (mapa, espécie, item). O modelo raciocina melhor com `PALLET_TOWN` do que com `0`.
- **Diga explicitamente o que a RAM sabe e a imagem não** (por exemplo, o HP exato do inimigo).
- O *Claude Plays Pokémon* instrui o modelo a **confiar nas notas e no estado, não na própria memória do jogo**: o conhecimento de treino sobre o jogo costuma atrapalhar mais do que ajudar.

---

## 6. Ferramentas (tools)

Poucas ferramentas, bem descritas, com `strict: true` para o modelo sempre mandar argumentos válidos.

```python
# src/agente/tools.py
TOOLS = [
    {
        "name": "press_buttons",
        "description": (
            "Aperta botões do Game Boy em sequência. Use para menus, diálogos e "
            "batalhas. Máximo de 10 botões por chamada."
        ),
        "strict": True,
        "input_schema": {
            "type": "object",
            "properties": {
                "buttons": {
                    "type": "array",
                    "items": {"type": "string",
                              "enum": ["a", "b", "start", "select", "up", "down", "left", "right"]},
                    "maxItems": 10,
                },
            },
            "required": ["buttons"],
            "additionalProperties": False,
        },
    },
    {
        "name": "walk",
        "description": "Anda N passos numa direção no mapa. Retorna se a posição mudou.",
        "strict": True,
        "input_schema": {
            "type": "object",
            "properties": {
                "direction": {"type": "string", "enum": ["up", "down", "left", "right"]},
                "steps": {"type": "integer", "minimum": 1, "maximum": 15},
            },
            "required": ["direction", "steps"],
            "additionalProperties": False,
        },
    },
    {
        "name": "navigate_to",
        "description": (
            "Vai até a coordenada (x, y) do mapa atual usando pathfinding sobre os "
            "tiles já explorados. Prefira esta a 'walk' quando souber o destino."
        ),
        "strict": True,
        "input_schema": {
            "type": "object",
            "properties": {"x": {"type": "integer"}, "y": {"type": "integer"}},
            "required": ["x", "y"],
            "additionalProperties": False,
        },
    },
    {
        "name": "update_memory",
        "description": (
            "Atualiza a memória persistente. Use para registrar descobertas (onde "
            "fica algo, o que já foi feito) e para trocar o objetivo atual."
        ),
        "strict": True,
        "input_schema": {
            "type": "object",
            "properties": {
                "add_notes": {"type": "array", "items": {"type": "string"}},
                "remove_notes": {"type": "array", "items": {"type": "integer"},
                                 "description": "índices de notas obsoletas"},
                "new_objective": {"type": "string"},
            },
            "required": ["add_notes", "remove_notes", "new_objective"],
            "additionalProperties": False,
        },
    },
]
```

Por que cada uma existe:

- **`press_buttons`**: o controle cru, indispensável para menus e diálogos.
- **`walk`**: o modelo erra muito ao contar passos apertando direcional; aqui o código anda e informa o resultado.
- **`navigate_to`**: o maior ganho de eficiência. Em vez de 40 ações, sai uma só (seção 8).
- **`update_memory`**: a janela de contexto não guarda o jogo inteiro, então a memória precisa ser explícita.

Extensão natural para depois: ferramentas de batalha de alto nível (`use_move(slot)`, `switch(pokemon)`, `run()`) que já sabem navegar pelo menu. O agente de LeafGreen citado nas referências faz isso.

---

## 7. Loop do agente

### Decisão de design: cada passo é uma conversa nova

Em vez de uma conversa infinita que precisa de resumo e corte de histórico, **cada passo monta um prompt do zero**: system prompt fixo + ferramentas fixas + estado atual + memória + últimas N ações. Isso traz quatro vantagens:

1. O contexto nunca estoura; o tamanho do prompt é constante.
2. O *prompt caching* funciona sozinho, porque `tools` + `system` são o mesmo prefixo em todo passo.
3. Não é preciso editar histórico antigo, o que nos modelos atuais invalidaria os blocos de *thinking* preservados.
4. A "memória" fica explícita e auditável num arquivo, não perdida dentro do contexto.

### Código

```python
# src/agente/agent.py
import base64, io, json, time
import anthropic
from .env_pyboy import PyBoyEnv
from .observation import build_text
from .memory import Memory
from .progress import Progress
from .tools import TOOLS, execute_tool

MODEL = "claude-opus-5-5"
SYSTEM = open("prompts/system.md", encoding="utf-8").read()  # fixo: regras do jogo, estilo, dicas

client = anthropic.Anthropic()


def image_block(img, scale=3):
    img = img.resize((img.width * scale, img.height * scale), resample=0)  # NEAREST
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return {"type": "image",
            "source": {"type": "base64", "media_type": "image/png",
                       "data": base64.b64encode(buf.getvalue()).decode()}}


def step(env, memory, progress, log):
    state = env.state()
    content = [
        image_block(env.screenshot()),
        {"type": "text", "text": build_text(state, memory, progress)},
    ]

    resp = client.beta.messages.create(
        model=MODEL,
        max_tokens=8000,
        betas=["server-side-fallback-2026-07-01"],
        fallbacks="default",                      # se o modelo recusar, outro assume
        output_config={"effort": "low"},          # suba para "medium" em trechos difíceis
        system=[{"type": "text", "text": SYSTEM, "cache_control": {"type": "ephemeral"}}],
        tools=TOOLS,
        messages=[{"role": "user", "content": content}],
    )

    if resp.stop_reason in ("refusal", "max_tokens"):
        log.write({"event": "skip", "stop_reason": resp.stop_reason})
        return

    reasoning = " ".join(b.text for b in resp.content if b.type == "text")
    calls = [b for b in resp.content if b.type == "tool_use"]
    if not calls:
        memory.push_action("(nenhuma ação)", "modelo não chamou ferramenta")
        return

    for call in calls:  # pode vir update_memory + uma ação no mesmo passo
        result = execute_tool(env, memory, call.name, call.input)
        memory.push_action(f"{call.name}({json.dumps(call.input, ensure_ascii=False)})", result)
        log.write({"t": time.time(), "state": state.__dict__, "reasoning": reasoning,
                   "tool": call.name, "input": call.input, "result": result,
                   "usage": resp.usage.model_dump()})

    progress.update(env.state())


def run(rom, steps=10_000, checkpoint_every=100):
    env, memory, progress = PyBoyEnv(rom), Memory("saves/memory.json"), Progress()
    with RunLog() as log:   # grava runs/<ts>/steps.jsonl e frames
        for i in range(steps):
            step(env, memory, progress, log)
            if i % checkpoint_every == 0:
                env.save(f"saves/step_{i:06d}.state")
                memory.flush()
```

O `system.md` deve conter as regras de uso das ferramentas ("sempre chame exatamente uma ação de jogo por passo; use `update_memory` quando descobrir algo"), o objetivo de longo prazo ("zerar o jogo") e dicas de controle (A confirma, B volta, START abre o menu). Nos modelos atuais não é possível *forçar* uma ferramenta via `tool_choice`; a instrução no system prompt já resolve.

### Execução de ferramenta com retorno útil

O texto do resultado é o que o modelo vê no passo seguinte. Ele deve dizer **o que mudou**, não só "ok":

```python
def execute_tool(env, memory, name, args):
    before = env.state()
    if name == "press_buttons":
        env.press(args["buttons"])
    elif name == "walk":
        env.press([args["direction"]] * args["steps"])
    elif name == "navigate_to":
        path = memory.nav.path(before.map_id, (before.x, before.y), (args["x"], args["y"]))
        if path is None:
            return "sem caminho conhecido até lá; explore com walk"
        env.press(path)
    elif name == "update_memory":
        memory.apply(args)
        return "memória atualizada"
    after = env.state()
    memory.nav.observe(before, after, name, args)  # aprende tiles bloqueados
    return describe_diff(before, after)            # "posição (5,9)->(5,6)", "entrou em batalha", "mapa mudou: ROUTE_1"
```

---

## 8. Navegação

Começar simples e evoluir:

1. **Fase 1, sem navegação**: só `walk`. Funciona, mas gasta muitos passos.
2. **Fase 2, mapa aprendido**: a cada `walk`, registre por mapa quais tiles foram pisados e quais movimentos falharam (a posição não mudou, logo o tile está bloqueado). `navigate_to` roda BFS sobre os tiles conhecidos como andáveis e devolve a lista de direcionais.
3. **Fase 3, colisão real**: leia da RAM o mapa de tiles visível e a tabela de colisão do tileset (está documentada no disassembly) e gere a grade andável sem precisar explorar antes.

```python
# src/agente/navigation.py
from collections import deque

DIRS = {"up": (0, -1), "down": (0, 1), "left": (-1, 0), "right": (1, 0)}


class Navigator:
    def __init__(self):
        self.walkable: dict[int, set] = {}   # map_id -> {(x, y)}
        self.blocked: dict[int, set] = {}    # map_id -> {(x, y)}

    def observe(self, before, after, tool, args):
        if before.map_id != after.map_id:
            return
        self.walkable.setdefault(after.map_id, set()).add((after.x, after.y))
        if tool == "walk" and (before.x, before.y) == (after.x, after.y):
            dx, dy = DIRS[args["direction"]]
            self.blocked.setdefault(before.map_id, set()).add((before.x + dx, before.y + dy))

    def path(self, map_id, start, goal):
        ok = self.walkable.get(map_id, set()) | {goal}
        bad = self.blocked.get(map_id, set())
        prev, q = {start: None}, deque([start])
        while q:
            cur = q.popleft()
            if cur == goal:
                out = []
                while prev[cur] is not None:
                    p, d = prev[cur]
                    out.append(d)
                    cur = p
                return out[::-1]
            for d, (dx, dy) in DIRS.items():
                nxt = (cur[0] + dx, cur[1] + dy)
                if nxt in ok and nxt not in bad and nxt not in prev:
                    prev[nxt] = (cur, d)
                    q.append(nxt)
        return None
```

Cuidados específicos que o *Claude Plays Pokémon* precisou tratar: tiles de teleporte e de giro marcados como não navegáveis, Surf e entradas laterais de portões. Se o personagem entrar em batalha ou diálogo no meio do caminho, interrompa a sequência e devolva o controle ao modelo.

---

## 9. Progresso e travamento

O modo de falha mais comum é o agente andar em círculos por horas. Defesas:

- **Novidade**: guarde o conjunto de `(map_id, x, y)` visitados. Se passarem N passos (por exemplo, 40) sem posição nova, sem mapa novo e sem mudança relevante de estado, coloque um alerta no prompt.
- **Loop de ações**: se as últimas K ações forem idênticas e não mudarem o estado, avise e sugira outra abordagem.
- **Marcos**: insígnias, mapas novos e Pokémon capturados viram métricas no log e servem para comparar versões do harness.
- **Último recurso**: depois de M alertas ignorados, carregue o último checkpoint e registre o motivo.

---

## 10. Observabilidade

Sem logs bons é impossível melhorar o harness. Registre **por passo**: estado, frame, raciocínio do modelo, ferramenta e argumentos, resultado e uso de tokens.

- `runs/<ts>/steps.jsonl` + `frames/` permitem **replay** de qualquer trecho.
- Um `viewer.py` simples (Flask ou só um HTML que lê o JSONL) mostrando frame, raciocínio e ação lado a lado vale muito: é assim que se descobre *por que* o agente travou.
- Save state a cada N passos permite reproduzir um bug do agente exatamente no ponto em que aconteceu.

---

## 11. Modelo e custo

- Cada passo envia um prompt de alguns milhares de tokens (imagem + texto) e recebe pouca saída. Uma partida longa tem **milhares de passos**: faça a conta antes. Some `usage` no log desde o primeiro dia.
- **Prompt caching**: o prefixo `tools` + `system` fica idêntico entre passos e entra em cache (com `cache_control` no system). Confira `usage.cache_read_input_tokens` > 0 a partir do segundo passo; se continuar em zero, algo está mudando no prefixo (data/hora no system prompt, ordem das tools).
- **Effort**: comece em `low` para passos de rotina e use `medium` ou `high` só em situações difíceis (batalha de ginásio, puzzle, travamento detectado). Dá para trocar dinamicamente por passo.
- **Modelo**: o código usa `claude-opus-5-5`. Para baratear dá para testar `claude-sonnet-5-5` ou até `claude-haiku-5-5` nos passos simples, mas meça o progresso por real gasto, não o custo por chamada: um modelo mais barato que precisa do triplo de passos sai mais caro.
- O parâmetro `fallbacks="default"` (beta `server-side-fallback-2026-07-01`) faz outro modelo assumir se uma resposta for recusada por engano. Num jogo isso é raro; pode remover se preferir.

---

## 12. Adaptando para outro jogo

| Jogo | Troque `env` por | Observação | Ações |
|---|---|---|---|
| Outro Game Boy / GBC | PyBoy com outro ROM | novo `ram_map.py` (procure o disassembly) | mesmas |
| GBA (Emerald, FireRed) | `libmgba` (bindings Python do mGBA) | RAM via mGBA; dados de Pokémon da Gen III são criptografados por XOR, decodificar | mesmas + L/R |
| NES / SNES / Genesis | `stable-retro` (fork do Gym Retro) | RAM exposta via `data.json` de cada jogo | botões do console |
| **Minecraft** | bot **Mineflayer** (Node) | estado estruturado: inventário, blocos próximos, entidades; sem imagem | comandos de alto nível ou **código gerado** que vira skill reutilizável (padrão Voyager/Mindcraft) |
| Jogo de navegador | **Playwright** | DOM/estado JS (`page.evaluate`) + print | clique, tecla, `evaluate` |
| Jogo de PC sem API | `mss` (print) + `pydirectinput` (input) | só pixels; considere OCR e detecção de UI | mouse e teclado; o mais difícil e o mais lento |
| Pokémon Showdown (batalha) | cliente do protocolo do Showdown (`poke-env`) | estado da batalha completo em texto | `move`, `switch` |

Para Minecraft, a ideia que mais rende é a do **Voyager**: em vez de ações atômicas, o modelo escreve funções JavaScript (`async function mineWood(bot) {...}`) que são testadas e salvas numa **biblioteca de skills**, reutilizadas e combinadas depois. Atenção: isso executa código gerado pelo modelo na sua máquina, então rode numa VM ou num contêiner e nunca conecte em servidor público.

**Atalho sem escrever o loop**: existem servidores **MCP** para Game Boy ([mcp-gameboy](https://github.com/mario-andreschak/mcp-gameboy), [MCP PyBoy](https://glama.ai/mcp/servers/@ssimonitch/mcp-pyboy/inspect)) que você pluga direto no Claude Code. Servem para sentir o problema em 10 minutos, mas sem RAM decodificada nem navegação o agente fica bem limitado; o harness próprio é o que dá resultado.

---

## 13. Roteiro por fases

Cada fase tem um critério de "pronto" verificável antes de avançar.

| Fase | Entrega | Pronto quando |
|---|---|---|
| **0. Ambiente** | `PyBoyEnv`: carrega ROM, aperta botão, tira print, salva/carrega estado | um script aperta START e salva um PNG da tela de título |
| **1. RAM** | `ram_map.py` com posição, mapa, batalha, time | andar no jogo (manualmente, via script) muda x/y impressos corretamente |
| **2. Loop mínimo** | `agent.py` só com `press_buttons`, print + estado no prompt, log JSONL | o agente sai do quarto inicial sozinho |
| **3. Memória** | `update_memory`, objetivo atual, últimas N ações | as notas sobrevivem a reiniciar o processo e o agente as usa |
| **4. Movimento** | `walk` com retorno de diff; detecção de travamento | o agente chega à Rota 1 sem loop infinito |
| **5. Navegação** | `navigate_to` com mapa aprendido | menos de 30% dos passos são `walk`/direcional cru |
| **6. Batalha** | ferramentas de batalha de alto nível | vence batalhas selvagens sem se perder no menu |
| **7. Viewer + métricas** | UI ao vivo, gráfico de marcos × passos × custo | dá para comparar duas versões do harness com números |
| **8. Autonomia longa** | checkpoints, reload em travamento, ajuste de effort | roda uma noite inteira e acorda com progresso |

---

## 14. Armadilhas conhecidas

- **Confiar na visão**: o modelo erra a posição de objetos e a contagem de tiles no print. Dê as coordenadas pela RAM.
- **Ações cegas**: retornar só "ok" deixa o modelo sem saber se a ação funcionou. Sempre devolva o diff de estado.
- **Frames insuficientes**: apertar botão sem esperar a animação faz entradas se perderem. Calibre `hold_frames`/`wait_frames` e espere o diálogo terminar antes de ler o estado.
- **Memória que só cresce**: notas acumulam e contradizem umas às outras. Peça remoção de notas obsoletas e limite o total (por exemplo, 40 notas).
- **Conhecimento de treino**: o modelo "lembra" do jogo e acha que já sabe o caminho, mas o detalhe costuma estar errado. Instrua a confiar no estado e nas notas.
- **Data/hora no system prompt**: quebra o cache em todo passo e multiplica o custo.
- **Avaliar por impressão**: sem métricas (marcos por passo e custo por marco), cada mudança no harness vira palpite.

---

## 15. Referências

**Projetos para estudar o código**
- [pokemon-harness](https://github.com/maxkskhor/pokemon-harness): Pokémon Red, UI ao vivo, traces, replay turno a turno.
- [pokemon-agent](https://github.com/haggyroth/pokemon-agent): LeafGreen via libmgba, decodificação da Gen III, skills determinísticas de navegação e batalha.
- [llm_pokemon_scaffold](https://github.com/cicero225/llm_pokemon_scaffold)
- [continual-harness](https://github.com/sethkarten/continual-harness) · [paper](https://arxiv.org/html/2605.09998v1): harness que se melhora sozinho durante o jogo.
- [mindcraft-ce](https://github.com/mindcraft-ce/mindcraft-ce): agentes de LLM em Minecraft.
- [Voyager](https://voyager.minedojo.org/) · [paper](https://arxiv.org/abs/2305.16291): skill library em código.
- [GamingAgent / lmgame-bench](https://github.com/lmgame-org/GamingAgent): benchmark e harness para vários jogos.

**Contexto e lições aprendidas**
- [Anthropic: construindo o agente que joga Pokémon (ZenML)](https://www.zenml.io/llmops-database/building-and-deploying-a-pokemon-playing-llm-agent-at-anthropic)
- [Changelog do harness do Claude Plays Pokémon (comentário no LessWrong)](https://www.greaterwrong.com/posts/cxuzALcmucCndYv4a/daniel-kokotajlo-s-shortform/comment/sBtoCfWNnNxxGEgiL)
- [AI vs. Pokémon: Gemini e Claude como benchmark](https://artificialadvantage.substack.com/p/ai-vs-pokemon-how-gemini-and-claude)
- [VideoGameBench](https://arxiv.org/pdf/2505.18134): por que pixels puros ainda são difíceis.
- [Pokemon Showdown AI Arena](https://lakshyaag.com/blogs/building-a-pokemon-arena): agente só de batalha.

**Ferramentas**
- PyBoy: emulador de Game Boy em Python (`pip install pyboy`).
- `pret/pokered`: disassembly do Pokémon Red, com o arquivo de símbolos de RAM.
- Claude API: tool use, prompt caching e effort na documentação oficial da Anthropic.
