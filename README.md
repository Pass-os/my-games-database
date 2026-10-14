# my-game-mods

Monorepo de mods, **uma pasta por jogo**. Cada pasta e autocontida: tem a
propria solution, as proprias dependencias e o proprio guia.

| Jogo | Pasta | Stack | Status |
| --- | --- | --- | --- |
| Valheim | [`valheim/`](valheim/) | BepInEx 5 + HarmonyX, C# `net472` | configurado |
| Project Zomboid | [`project-zomboid/`](project-zomboid/) | Lua (B42) + ZombieBuddy (Java); REA/Ghidra para o nativo | configurado |

## Ferramentas (fora dos jogos)

| Ferramenta | Pasta | Para que |
| --- | --- | --- |
| Ghidra + MCP | [`tools/ghidra/`](tools/ghidra/) | Engenharia reversa de binarios nativos/IL2CPP; Ghidra 12.1.4 instalado, usado via REA |

## Ideias para o futuro

Estudos e guias de coisas que ainda nao foram implementadas ficam em
[`ideias/`](ideias/), uma pasta por ideia.

## Como adicionar um jogo novo

1. Crie `nome-do-jogo/` na raiz.
2. Coloque ali `Directory.Build.props`, `NuGet.config` e a solution do jogo.
3. Documente a stack no `README.md` da pasta.
4. Adicione a linha na tabela acima.

O `.gitignore` e o `.editorconfig` da raiz valem para todos os jogos.
