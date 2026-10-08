"""Junta SavedVariables do WoW em 3 vias (base, casa, trabalho) pelo conteudo.

Uso: python merge_sv.py base casa trabalho saida
Para cada chave: so um lado mudou -> vale ele; os dois mudaram -> vale o trabalho.
Imprime as chaves em que os dois mudaram (conflitos resolvidos pelo trabalho).
"""
import re, sys

class Parser:
    def __init__(self, s):
        self.s, self.i = s, 0
    def ws(self):
        s = self.s
        while self.i < len(s):
            if s[self.i] in ' \t\r\n':
                self.i += 1
            elif s.startswith('--', self.i):
                if s.startswith('--[[', self.i):
                    self.i = s.index(']]', self.i) + 2
                else:
                    j = s.find('\n', self.i)
                    self.i = len(s) if j < 0 else j
            else:
                break
    def value(self):
        self.ws()
        s, c = self.s, self.s[self.i]
        if c == '{':
            return self.table()
        if c == '"' or c == "'":
            return ('str', self.string())
        if s.startswith('[', self.i) and re.match(r'\[=*\[', s[self.i:]):
            m = re.match(r'\[(=*)\[', s[self.i:])
            fim = ']' + m.group(1) + ']'
            j = s.index(fim, self.i + len(m.group(0)))
            txt = s[self.i + len(m.group(0)):j]
            self.i = j + len(fim)
            return ('str', txt)
        m = re.match(r'(true|false|nil)\b', s[self.i:])
        if m:
            self.i += len(m.group(0))
            return ('lit', m.group(1))
        m = re.match(r'-?(0x[0-9a-fA-F]+|[0-9.]+(e[-+]?\d+)?)', s[self.i:])
        if m:
            self.i += len(m.group(0))
            return ('num', m.group(0))
        raise ValueError('valor inesperado em %d: %r' % (self.i, s[self.i:self.i + 40]))
    def string(self):
        s, q = self.s, self.s[self.i]
        j = self.i + 1
        out = []
        while s[j] != q:
            if s[j] == '\\':
                out.append(s[j:j + 2]); j += 2
            else:
                out.append(s[j]); j += 1
        self.i = j + 1
        return ('raw', ''.join(out))  # mantem escapes como estao
    def table(self):
        self.i += 1
        d, arr = {}, []
        while True:
            self.ws()
            if self.s[self.i] == '}':
                self.i += 1
                break
            if self.s[self.i] == '[' and not re.match(r'\[=*\[', self.s[self.i:]):
                self.i += 1
                k = self.value()
                self.ws(); assert self.s[self.i] == ']'; self.i += 1
                self.ws(); assert self.s[self.i] == '='; self.i += 1
                d[self.key(k)] = self.value()
            else:
                arr.append(self.value())
            self.ws()
            if self.s[self.i] in ',;':
                self.i += 1
        return ('tab', d, arr)
    @staticmethod
    def key(k):
        if k[0] == 'str':
            return ('s', k[1] if isinstance(k[1], tuple) else ('raw', k[1]))
        return ('n', k[1])

def parse_file(path):
    s = open(path, encoding='utf-8').read()
    p = Parser(s)
    top = []
    while True:
        p.ws()
        if p.i >= len(s):
            break
        m = re.match(r'([A-Za-z_][A-Za-z0-9_]*)\s*=', s[p.i:])
        name = m.group(1); p.i += len(m.group(0))
        top.append((name, p.value()))
    return top

def merge(base, casa, trab, caminho, conflitos):
    if casa == trab:
        return casa
    if casa == base:
        return trab
    if trab == base:
        return casa
    if casa and trab and casa[0] == 'tab' and trab[0] == 'tab':
        b = base if base and base[0] == 'tab' else ('tab', {}, [])
        d = {}
        for k in list(casa[1].keys()) + [k for k in trab[1] if k not in casa[1]]:
            r = merge(b[1].get(k), casa[1].get(k), trab[1].get(k), caminho + [k], conflitos)
            if r is not None:
                d[k] = r
        arr = trab[2] if casa[2] == b[2] else (casa[2] if trab[2] == b[2] else trab[2])
        return ('tab', d, arr)
    conflitos.append(caminho)
    return trab

def fmt_str(v):
    if v[0] == 'raw':
        return '"' + v[1] + '"'
    t = v[1]
    if ']=]' not in t:
        return '[=[' + t + ']=]'
    return '[==[' + t + ']==]'

def fmt_key(k):
    if k[0] == 's':
        return '[' + fmt_str(k[1]) + ']'
    return '[' + k[1] + ']'

def dump(v, out):
    if v[0] == 'tab':
        out.append('{\n')
        for k, x in v[1].items():
            out.append(fmt_key(k) + ' = ')
            dump(x, out)
            out.append(',\n')
        for x in v[2]:
            dump(x, out)
            out.append(',\n')
        out.append('}')
    elif v[0] == 'str':
        out.append(fmt_str(v[1]))
    else:
        out.append(v[1])

def nome_caminho(c):
    return '.'.join((k[1][1] if k[0] == 's' else k[1]) for k in c)

if __name__ == '__main__':
    base, casa, trab, saida = sys.argv[1:5]
    B, C, T = dict(parse_file(base)), parse_file(casa), dict(parse_file(trab))
    conflitos = []
    out = ['\n']
    nomes = [n for n, _ in C] + [n for n in T if n not in dict(C)]
    C = dict(C)
    for n in nomes:
        r = merge(B.get(n), C.get(n), T.get(n), [('s', ('raw', n))], conflitos)
        if r is None:
            continue
        out.append(n + ' = ')
        dump(r, out)
        out.append('\n')
    open(saida, 'w', encoding='utf-8', newline='').write(''.join(out))
    for c in conflitos:
        print('  os dois mudaram (vale o trabalho):', nome_caminho(c))
