# Uso: python auditar-dynamiccam.py <WTFAccount...SavedVariablesDynamicCam.lua> <InterfaceAddOnsDynamicCam> <wow-ui-sourceInterface>
# Requer: pip install lupa. Compila os scripts das situacoes (Lua 5.1) e confere campos, prioridades e quadros.
"""Auditoria das situacoes do DynamicCam: compila scripts (Lua 5.1), confere campos,
prioridades e quadros mantidos."""
import os, re, subprocess, sys
from lupa import lua51

SV = sys.argv[1]
DC = sys.argv[2]           # pasta do addon DynamicCam instalado
UISRC = sys.argv[3]        # wow-ui-source (live)

L = lua51.LuaRuntime(unpack_returned_tuples=True)
g = L.globals()

# --- padroes do DynamicCam (DefaultSettings.lua) com stubs minimos ---
L.execute('''
  DynamicCam = { db = {} }
  local Lmeta = setmetatable({}, {__index = function(t, k) return k end})
  LibStub = setmetatable({}, {__call = function(self, name)
      if name == "AceLocale-3.0" then return { GetLocale = function() return Lmeta end } end
      if name == "AceAddon-3.0" then return { GetAddon = function() return DynamicCam end } end
      return {}
  end})
  GetCVarDefault = function() return "0" end
  GetCVar = function() return "0" end
  WOW_PROJECT_ID = 1; WOW_PROJECT_MAINLINE = 1; WOW_PROJECT_CLASSIC = 2; DynamicCam.projectId = 1; DynamicCam.WOW_PROJECT_FOREVER = 99
''')
src = open(os.path.join(DC, 'DefaultSettings.lua'), encoding='utf-8').read()
f = L.eval('function(s) return loadstring(s, "DefaultSettings") end')(src)
if not f:
    print('nao consegui carregar DefaultSettings'); sys.exit(1)
try:
    f('DynamicCam')
except Exception as e:
    print('aviso ao executar DefaultSettings:', e)
defaults = g.DynamicCam.defaults
sitdef = g.DynamicCam.situationDefaults
padrao = defaults.profile.situations

# --- configuracao salva ---
sv = open(SV, encoding='utf-8').read()
ok = L.eval('function(s) local f, e = loadstring(s, "SV") if not f then return e end f() return nil end')(sv)
if ok:
    print('ERRO no arquivo de configuracao:', ok); sys.exit(1)
prof = g.DynamicCamDB.profiles.Default
sits = prof.situations

def get(t, *keys):
    for k in keys:
        if t is None:
            return None
        try:
            t = t[k]
        except Exception:
            return None
    return t

def efetivo(sid, *keys):
    v = get(sits[sid], *keys)
    if v is None and padrao[sid] is not None:
        v = get(padrao[sid], *keys)
    if v is None:
        v = get(sitdef, *keys)
    return v

compila = L.eval('function(s, n) local f, e = loadstring(s, n) return e end')

# quadros que existem na interface da Blizzard (nome="X" em XML ou CreateFrame com nome)
quadros_blizz = set()
for raiz, _, arqs in os.walk(UISRC):
    for a in arqs:
        if a.endswith(('.xml', '.lua')):
            try:
                txt = open(os.path.join(raiz, a), encoding='utf-8', errors='ignore').read()
            except Exception:
                continue
            quadros_blizz.update(re.findall(r'name="([A-Za-z_][A-Za-z0-9_]*)"', txt))
            quadros_blizz.update(re.findall(r'CreateFrame\(\s*"[^"]+"\s*,\s*"([A-Za-z_][A-Za-z0-9_]*)"', txt))

ids = sorted(list(sits.keys()), key=str)
ativos = []
problemas = []
for sid in ids:
    s = sits[sid]
    en = efetivo(sid, 'enabled')
    nome = efetivo(sid, 'name') or '?'
    nome = re.sub(r'\|T[^|]*\|t ', '', str(nome))
    pr = efetivo(sid, 'priority')
    if not en:
        continue
    ativos.append((pr, sid, nome))
    p = []
    for campo in ('executeOnInit', 'condition', 'executeOnEnter', 'executeOnExit'):
        cod = efetivo(sid, campo) or ''
        if cod:
            err = compila(cod, '%s.%s' % (sid, campo))
            if err:
                p.append('ERRO de sintaxe em %s: %s' % (campo, err))
    cond = efetivo(sid, 'condition')
    if not cond or cond.strip() == 'return false':
        p.append('sem condicao (nunca ativa)')
    ev = efetivo(sid, 'events')
    if ev is None or len(list(ev.values())) == 0:
        p.append('sem eventos (so reavalia quando outra situacao dispara)')
    # campos que situacao personalizada precisa ter (nao recebem padrao)
    if str(sid).startswith('custom'):
        for k in (('transitionTime', 'timeToEnter'), ('transitionTime', 'timeToExit'), ('delay',),
                  ('hideUI', 'enabled'), ('hideUI', 'customFramesToKeep'), ('situationSettings', 'cvars'),
                  ('viewZoom', 'enabled'), ('rotation', 'enabled'), ('priority',)):
            if get(s, *k) is None:
                p.append('falta campo %s' % '.'.join(k))
    # zoom
    vz = efetivo(sid, 'viewZoom', 'enabled')
    if vz:
        tipo = efetivo(sid, 'viewZoom', 'viewZoomType')
        if tipo == 'view':
            p.append('zoom por VISAO salva %s (precisa /saveView %s no jogo)' % (efetivo(sid, 'viewZoom', 'viewNumber'), efetivo(sid, 'viewZoom', 'viewNumber')))
    # quadros mantidos
    if efetivo(sid, 'hideUI', 'enabled') and efetivo(sid, 'hideUI', 'keepCustomFrames'):
        cf = efetivo(sid, 'hideUI', 'customFramesToKeep')
        if cf is not None:
            for q, v in cf.items():
                if v and q not in quadros_blizz:
                    p.append('quadro mantido "%s" nao existe na interface 12.1 (pode ser de addon)' % q)
    if p:
        problemas.append((sid, nome, p))

print('Situacoes ATIVAS (prioridade, id, nome):')
for pr, sid, nome in sorted(ativos, key=lambda x: -(x[0] or 0)):
    print('  %5s  %-8s %s' % (pr, sid, nome))
print()
from collections import Counter
rep = [k for k, n in Counter(pr for pr, _, _ in ativos).items() if n > 1]
for r in rep:
    print('MESMA PRIORIDADE %s: %s' % (r, ', '.join(n for pr, _, n in ativos if pr == r)))
print()
for sid, nome, p in problemas:
    print('%s (%s):' % (nome, sid))
    for x in p:
        print('   -', x)
