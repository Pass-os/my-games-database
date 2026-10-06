# Ghidra (engenharia reversa) + MCP

Referencia para uso futuro. **Nada aqui esta instalado** — e so o mapa de
como instalar quando precisar.

- Repo oficial: <https://github.com/NationalSecurityAgency/ghidra>
- Releases: <https://github.com/NationalSecurityAgency/ghidra/releases>
  (12.1.x em out/2026)
- Requer **JDK 21** (64-bit). Sem instalador: baixa o zip, extrai e roda
  `ghidraRun.bat`.

## Quando usar (e quando nao)

| Alvo | Ferramenta |
| --- | --- |
| Jogo Unity **Mono** (ex.: Valheim, `Assembly-CSharp.dll`) | **ILSpy/dnSpy**, nao Ghidra. IL .NET decompila quase pra C# original. |
| Jogo Unity **IL2CPP** (`GameAssembly.dll` + `global-metadata.dat`) | Ghidra + Il2CppDumper/Cpp2IL (gera script de simbolos pro Ghidra). |
| Jogo nativo C/C++ (Unreal, engines proprias), DLLs nativas | Ghidra. |

Ou seja: pro Valheim atual o Ghidra **nao** e necessario.

## MCP (deixar o Claude operar o Ghidra)

O Ghidra **nao tem MCP oficial**. O MCP vem de extensoes da comunidade, que
sobem um servidor HTTP dentro do Ghidra + uma "bridge" Python que fala MCP.

| Projeto | Notas |
| --- | --- |
| [LaurieWired/GhidraMCP](https://github.com/LaurieWired/GhidraMCP) | O mais popular. Simples: extensao + `bridge_mcp_ghidra.py`. Porta padrao 8080. |
| [bethington/ghidra-mcp](https://github.com/bethington/ghidra-mcp) | Mais completo (debugger, batch). Alvo Ghidra 12.1.x, usa `uv`. Porta 8089. |
| [mrphrazer/ghidra-headless-mcp](https://github.com/mrphrazer/ghidra-headless-mcp) | Headless (sem GUI), muitas ferramentas. |

### Instalacao (LaurieWired/GhidraMCP)

1. Instale JDK 21 e o Ghidra.
2. Baixe o zip da extensao em
   [releases](https://github.com/LaurieWired/GhidraMCP/releases) e extraia
   (vem o zip da extensao + `bridge_mcp_ghidra.py`).
3. No Ghidra: `File > Install Extensions > +` → escolha o zip da extensao →
   reinicie.
4. Abra um programa no CodeBrowser e habilite o plugin em
   `File > Configure > Developer > GhidraMCPPlugin`.
   Porta: `Edit > Tool Options > GhidraMCP HTTP Server` (padrao 8080).
5. Instale as deps da bridge: `pip install -r requirements.txt` (pacote `mcp`).
6. Registre no Claude Code (o Ghidra precisa estar aberto com o plugin ativo):

   ```powershell
   claude mcp add ghidra -- python C:\caminho\bridge_mcp_ghidra.py --ghidra-server http://127.0.0.1:8080/
   ```

   Ou copie [`mcp.example.json`](mcp.example.json) para `.mcp.json` na raiz do
   repo e ajuste o caminho. Nao versionamos `.mcp.json` ativo: sem o Ghidra
   aberto o servidor falha ao conectar em toda sessao.
