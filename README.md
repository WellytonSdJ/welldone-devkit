<div align="center">

```
 ██╗    ██╗███████╗██╗     ██╗     ██████╗  ██████╗ ███╗   ██╗███████╗
 ██║    ██║██╔════╝██║     ██║     ██╔══██╗██╔═══██╗████╗  ██║██╔════╝
 ██║ █╗ ██║█████╗  ██║     ██║     ██║  ██║██║   ██║██╔██╗ ██║█████╗
 ██║███╗██║██╔══╝  ██║     ██║     ██║  ██║██║   ██║██║╚██╗██║██╔══╝
 ╚███╔███╔╝███████╗███████╗███████╗██████╔╝╚██████╔╝██║ ╚████║███████╗
  ╚══╝╚══╝ ╚══════╝╚══════╝╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝
                    ░▒▓  D E V K I T  v 2 . 1  ▓▒░
```

**Instalador interativo de ambiente de desenvolvimento para Windows**

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=flat-square&logo=powershell)
![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4?style=flat-square&logo=windows)
![winget](https://img.shields.io/badge/winget-required-purple?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

</div>

---

## O que é?

**WellDone DevKit** é um instalador interativo em PowerShell que automatiza a configuração de um ambiente de desenvolvimento completo no Windows — com visual cyberpunk neon e navegação por número.

> Configure um PC do zero em minutos, sem abrir navegador.

---

## Preview

```
╔══════════════════════════════════════════════════════════════════════════╗
║              [  ASCII art WELLDONE DEVKIT  ]                             ║
╟─ v2.2  |  github.com/WellytonSdJ/welldone-devkit ──────────────────────╢
╠══════════════════════════════════════════════════════════════════════════╣
║  [1] Dev Essentials                                                      ║
║  [2] Terminal Theme                                                      ║
║  [3] PowerShell Setup                                                    ║
║  [4] Git Setup                                                           ║
║  [5] SSH Manager                                                         ║
║  [6] System Tweaks                                                       ║
║  [7] Pasta Inicial                                                       ║
║  [8] Apps Opcionais                                                      ║
║  ────────────────────────────────                                        ║
║  [9] Instalar Tudo                                                       ║
╠══════════════════════════════════════════════════════════════════════════╣
║  Digite o número e pressione Enter. [0] Sair                             ║
╚══════════════════════════════════════════════════════════════════════════╝
```

---

## Requisitos

| Requisito | Versão mínima |
|---|---|
| Windows | 10 (build 1809+) ou 11 |
| PowerShell | 5.1+ (já incluso no Windows) |
| winget | App Installer (Microsoft Store) |

> **winget** já vem instalado no Windows 11 e em versões atualizadas do Windows 10. Se não tiver, instale pelo [App Installer](https://apps.microsoft.com/detail/9NBLGGH4NNS1) na Microsoft Store.

---

## Instalação

```powershell
# Clone o repositório em Documentos\PROJECT
git clone https://github.com/WellytonSdJ/welldone-devkit "$env:USERPROFILE\Documents\PROJECT\welldone-devkit"

# Entre na pasta
cd "$env:USERPROFILE\Documents\PROJECT\welldone-devkit"

# Execute
.\welldone.ps1
```

> Se der erro de *Execution Policy*, rode antes:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

---

## Módulos disponíveis

### Dev Essentials
Instala as ferramentas base via winget:

| Ferramenta | Descrição |
|---|---|
| **Git** | Controle de versão |
| **NVS** | Gerenciador de versões do Node.js |
| **Node.js LTS** | Runtime JavaScript (via NVS) |
| **VS Code** | Editor de código |

---

### Terminal Theme — Oh My Posh
Configura um terminal com visual **cyberpunk neon** em dois ambientes:

- **JetBrainsMono Nerd Font** — fonte com suporte a ícones
- **Oh My Posh** — motor de temas para o prompt
- **Tema WellDone Neon** — tema personalizado com:
  - Segmento de OS, caminho atual, branch git, versão do Node
  - Execution time e horário no prompt direito
  - Paleta: cyan `#00eaff` · lavanda `#b388ff` · green `#0aff9d`

**PowerShell** — insere no `$PROFILE.CurrentUserAllHosts`:
```powershell
oh-my-posh init pwsh --config "welldone_neon.omp.json" | Invoke-Expression
```

**Git Bash** — insere no `~/.bashrc`:
```bash
eval "$(oh-my-posh init bash --config '/c/path/to/welldone_neon.omp.json')"
```

Após instalar, configure a fonte **JetBrainsMono Nerd Font** no Windows Terminal:
> `Settings → Profiles → Defaults → Appearance → Font face`

---

### PowerShell Setup
Instala e configura o PowerShell moderno com experiência aprimorada:

| Componente | Descrição |
|---|---|
| **PowerShell 7** | Versão multiplataforma, mais rápida que o PS 5.1 |
| **PSReadLine** | Syntax highlight com paleta neon, predição por histórico |
| **Terminal-Icons** | Ícones de arquivo e pasta coloridos no terminal |

Cores do PSReadLine mapeadas para a paleta WellDone Neon:

| Elemento | Cor |
|---|---|
| Command | `#0aff9d` (green) |
| Parameter | `#00eaff` (cyan) |
| String | `#ffcc00` (yellow) |
| Comment | `#646482` (gray) |
| Error | `#ff0066` (red) |

---

### Git Setup
Configura o Git globalmente:

```
user.name          → seu nome
user.email         → seu e-mail
init.defaultBranch → main
core.editor        → VS Code (code --wait)
pull.rebase        → true
core.autocrlf      → true
alias.lg           → log colorido com gráfico de branches
```

---

### SSH Manager
Gera e gerencia chaves SSH para o GitHub:

- Cria par de chaves **Ed25519** (mais segura que RSA)
- Inicia e configura o `ssh-agent` automaticamente
- Exibe a chave pública e oferece cópia para o clipboard

Após gerar: adicione a chave em **github.com → Settings → SSH Keys**.

---

### System Tweaks
Otimizações do Windows para devs:

| Tweak | Descrição |
|---|---|
| Extensões de arquivo | Exibe `.js`, `.ps1`, `.json` etc. no Explorer |
| Arquivos ocultos | Exibe pastas como `.git`, `.ssh` |
| Execution Policy | `RemoteSigned` para o usuário atual |
| WSL2 | Habilita o Linux integrado ao Windows |
| ANSI no console | Suporte a cores no terminal legado |

---

### Apps Opcionais
Menu de seleção múltipla — escolha apenas o que quiser:

| App | Categoria |
|---|---|
| Opera GX | Browser |
| Spotify | Música |
| Discord | Comunidade |
| Microsoft Teams | Trabalho |
| Notion | Produtividade |
| Obsidian | Produtividade |
| Google Drive | Produtividade |
| **Hoppscotch** | API Tools |
| Postman | API Tools (alternativo) |
| Steam | Games |
| Epic Games | Games |

---

### Instalar Tudo
Executa todos os módulos em sequência — ideal para configurar um PC novo do zero:

1. Dev Essentials
2. Terminal Theme (PowerShell + Git Bash)
3. PowerShell Setup
4. Git Setup
5. SSH Manager
6. System Tweaks
7. Apps Opcionais

---

## Estrutura do projeto

```
welldone-devkit/
├── welldone.ps1                    ← entrada principal
├── assets/
│   └── logo.txt                   ← ASCII art do header
├── themes/
│   └── welldone_neon.omp.json     ← tema Oh My Posh
└── scripts/
    ├── utils/
    │   ├── colors.ps1             ← paleta neon (true-color ANSI)
    │   ├── ansi.ps1               ← helpers de cursor e console
    │   ├── helpers.ps1            ← Run-Step, Install-Package, Confirm-Action
    │   └── ui.ps1                 ← menu numerado, header, boot screen
    └── modules/
        ├── install_dev_essentials.ps1
        ├── install_terminal_theme.ps1  ← Oh My Posh (PS + Git Bash)
        ├── setup_powershell.ps1        ← PS7 + PSReadLine + Terminal-Icons
        ├── setup_git.ps1
        ├── manage_ssh.ps1
        ├── system_tweaks.ps1
        └── install_optional_apps.ps1
```

---

## Navegação

| Input | Ação |
|---|---|
| `1`–`9` + Enter | Selecionar opção |
| `0` + Enter | Sair |
| `Q` + Enter | Sair |

---

## Contribuindo

1. Fork o repositório
2. Crie uma branch: `git checkout -b feat/novo-modulo`
3. Commit: `git commit -m "feat: adiciona módulo X"`
4. Push: `git push origin feat/novo-modulo`
5. Abra um Pull Request

---

## Licença

MIT © [WellytonSdJ](https://github.com/WellytonSdJ)
