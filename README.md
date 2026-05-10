<div align="center">

```
 ██╗    ██╗███████╗██╗     ██╗     ██████╗  ██████╗ ███╗   ██╗███████╗
 ██║    ██║██╔════╝██║     ██║     ██╔══██╗██╔═══██╗████╗  ██║██╔════╝
 ██║ █╗ ██║█████╗  ██║     ██║     ██║  ██║██║   ██║██╔██╗ ██║█████╗
 ██║███╗██║██╔══╝  ██║     ██║     ██║  ██║██║   ██║██║╚██╗██║██╔══╝
 ╚███╔███╔╝███████╗███████╗███████╗██████╔╝╚██████╔╝██║ ╚████║███████╗
  ╚══╝╚══╝ ╚══════╝╚══════╝╚══════╝╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝
                    ░▒▓  D E V K I T  v 2 . 0  ▓▒░
```

**Instalador interativo de ambiente de desenvolvimento para Windows**

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue?style=flat-square&logo=powershell)
![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D4?style=flat-square&logo=windows)
![winget](https://img.shields.io/badge/winget-required-purple?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

</div>

---

## O que é?

**WellDone DevKit** é uma TUI (*Terminal User Interface*) interativa em PowerShell que automatiza a instalação e configuração de um ambiente de desenvolvimento completo no Windows — com visual cyberpunk neon, navegação por teclado e descrições detalhadas de cada opção.

> Configure um PC do zero em minutos, sem abrir navegador.

---

## Preview

```
╔══════════════════════════════════════════════════════════════════════════╗
║         [  ASCII art WELLDONE DEVKIT  ]                                  ║
╟─ v2.0  |  github.com/WellytonSdJ/welldone-devkit ──────────────────────╢
╠════════════════════╦═════════════════════════════════════════════════════╣
║  OPÇÕES            ║  DESCRIÇÃO                                          ║
║────────────────────║─────────────────────────────────────────────────────║
║ › Dev Essentials   ║  Dev Essentials                                     ║
║   Terminal Theme   ║                                                     ║
║   Git Setup        ║  Instala as ferramentas centrais de desenvolvimento:║
║   SSH Manager      ║  • Git — controle de versão                         ║
║   System Tweaks    ║  • NVS — gerenciador de versões do Node.js          ║
║   Apps Opcionais   ║  • Node.js LTS — runtime JavaScript                 ║
║   ─────────────    ║  • VS Code — editor de código                       ║
║   Instalar Tudo    ║  • Postman — testes de API                          ║
║   Sair             ║                                                     ║
╠════════════════════╩═════════════════════════════════════════════════════╣
║  [↑↓] Navegar   [Enter] Selecionar   [Q] Sair                           ║
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
| **Postman** | Testes de API |

---

### Terminal Theme — Oh My Posh
Configura um terminal com visual **cyberpunk neon**:

- **JetBrainsMono Nerd Font** — fonte com suporte a ícones
- **Oh My Posh** — motor de temas para o prompt
- **Tema WellDone Neon** — tema personalizado com:
  - Segmento de OS, caminho atual, branch git, versão do Node
  - Execution time e horário no prompt direito
  - Paleta: cyan `#00eaff` · pink `#ff00c8` · green `#0aff9d`

Após instalar, configure a fonte **JetBrainsMono Nerd Font** no Windows Terminal:
> `Settings → Profiles → Defaults → Appearance → Font face`

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
| Steam | Games |
| Epic Games | Games |

---

### Instalar Tudo
Executa todos os módulos em sequência — ideal para configurar um PC novo do zero.

---

## Estrutura do projeto

```
welldone-devkit/
├── welldone.ps1                    ← entrada principal (TUI)
├── assets/
│   └── logo.txt                   ← ASCII art do header
├── themes/
│   └── welldone_neon.omp.json     ← tema Oh My Posh
└── scripts/
    ├── utils/
    │   ├── colors.ps1             ← paleta neon (true-color ANSI)
    │   ├── ansi.ps1               ← helpers de cursor e console
    │   ├── helpers.ps1            ← Run-Step, Install-Package, Confirm-Action
    │   └── ui.ps1                 ← engine TUI (painéis, menu, boot screen)
    └── modules/
        ├── install_dev_essentials.ps1
        ├── install_terminal_theme.ps1
        ├── setup_git.ps1
        ├── manage_ssh.ps1
        ├── system_tweaks.ps1
        └── install_optional_apps.ps1
```

---

## Navegação da TUI

| Tecla | Ação |
|---|---|
| `↑` / `W` | Item anterior |
| `↓` / `S` | Próximo item |
| `Enter` | Selecionar |
| `Q` | Sair / voltar ao menu |

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
