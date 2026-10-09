# Uso: python ler-diario.py [--sessoes N] [--origem zoom] [--tudo] [--arquivo <DiarioDaCamera.lua>]
"""Le o diario do addon DiarioDaCamera (SavedVariables) e mostra um resumo das
ultimas sessoes: quantas linhas por origem e o que pede atencao (erros, camera
que nao chegou no zoom, janelas escondidas fora da lista, NPC que nao mediu,
camera livre longe demais). Com --tudo, mostra as linhas tambem.

O diario so e gravado quando o jogo sai ou no /reload."""
import argparse, glob, os, re, sys
from collections import Counter

ORIGENS = ("sessao", "camera", "erro", "zoom", "janelas", "combate", "altura", "gostei")
ZOOM_LONGE = 15  # camera livre acima disso 1,5 s depois de voltar = suspeito


def achar_wow():
    if sys.platform != "win32":
        return None
    import winreg
    chaves = [
        r"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    ]
    for raiz in chaves:
        try:
            k = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, raiz)
        except OSError:
            continue
        for i in range(winreg.QueryInfoKey(k)[0]):
            try:
                sub = winreg.OpenKey(k, winreg.EnumKey(k, i))
                nome = winreg.QueryValueEx(sub, "DisplayName")[0]
                if nome == "World of Warcraft":
                    return winreg.QueryValueEx(sub, "InstallLocation")[0]
            except OSError:
                continue
    return None


def achar_arquivo(arg):
    if arg:
        return arg
    wow = achar_wow()
    if not wow:
        sys.exit("WoW nao encontrado no registro; use --arquivo")
    achados = glob.glob(os.path.join(wow, "_retail_", "WTF", "Account", "*", "SavedVariables", "DiarioDaCamera.lua"))
    if not achados:
        sys.exit("DiarioDaCamera.lua nao encontrado (o jogo grava ao sair ou no /reload)")
    return max(achados, key=os.path.getmtime)


def ler_linhas(caminho):
    texto = open(caminho, encoding="utf-8").read()
    linhas = []
    for m in re.finditer(r'^\s*"((?:[^"\\]|\\.)*)",?\s*$', texto, re.M):
        linhas.append(re.sub(r"\\(.)", lambda x: {"n": " / "}.get(x.group(1), x.group(1)), m.group(1)))
    return linhas


def origem_de(linha):
    partes = [p.strip() for p in linha.split("|")]
    if len(partes) > 1 and partes[1] in ORIGENS:
        return partes[1]
    # Formato antigo (versao 1.0 do diario): sem origem.
    if "sessao iniciada" in linha:
        return "sessao"
    if "ERRO" in linha:
        return "erro"
    return "camera"


def atencao(linha, origem):
    if origem == "erro":
        return "erro de Lua"
    if "NAO chegou" in linha:
        return "camera nao chegou no zoom"
    if "FORA da lista" in linha:
        return "janela fora da lista"
    if "NAO mediu" in linha:
        return "NPC sem medida"
    if "camera NAO respondeu" in linha:
        return "camera sem resposta apos carregamento"
    if origem == "camera":
        m = re.search(r"-> livre \| zoom [\d.]+ -> ([\d.]+) \(1,5s, agora livre\)", linha)
        if m and float(m.group(1)) > ZOOM_LONGE:
            return "camera livre longe (%s)" % m.group(1)
    return None


def main():
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    ap = argparse.ArgumentParser()
    ap.add_argument("--arquivo")
    ap.add_argument("--sessoes", type=int, default=1, help="quantas sessoes do fim (0 = todas)")
    ap.add_argument("--origem", choices=ORIGENS)
    ap.add_argument("--tudo", action="store_true", help="mostra todas as linhas")
    a = ap.parse_args()

    caminho = achar_arquivo(a.arquivo)
    linhas = ler_linhas(caminho)
    if a.sessoes:
        inicios = [i for i, l in enumerate(linhas) if "sessao iniciada" in l]
        if len(inicios) >= a.sessoes:
            linhas = linhas[inicios[-a.sessoes]:]
    if a.origem:
        linhas = [l for l in linhas if origem_de(l) == a.origem]

    print("Arquivo:", caminho)
    print("Linhas:", len(linhas))
    for o, n in Counter(origem_de(l) for l in linhas).most_common():
        print("  %-8s %d" % (o, n))

    problemas = [(atencao(l, origem_de(l)), l) for l in linhas]
    problemas = [(t, l) for t, l in problemas if t]
    print("\nPede atencao: %d" % len(problemas))
    for t, n in Counter(t.split(" (")[0] for t, _ in problemas).most_common():
        print("  %-40s %d" % (t, n))
    for t, l in problemas[-30:]:
        print("  - " + l)

    gostei = [l for l in linhas if origem_de(l) == "gostei"]
    if gostei:
        print("\nCameras favoritas (Painel da Camera): %d" % len(gostei))
        for l in gostei[-10:]:
            print("  * " + l)

    if a.tudo:
        print("\nTodas as linhas:")
        for l in linhas:
            print(l)


if __name__ == "__main__":
    main()
