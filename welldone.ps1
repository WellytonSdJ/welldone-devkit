#Requires -Version 5.1
<#
.SYNOPSIS
    WellDone DevKit — ambiente de desenvolvimento com TUI interativa
.DESCRIPTION
    Instalador e configurador cyberpunk-themed para ambiente de desenvolvimento Windows.
    Navegue com ↑↓ ou W/S, selecione com Enter, saia com Q.
.EXAMPLE
    .\welldone.ps1
#>

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

# ─── Load utilities ────────────────────────────────────────────────────────────
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"

Enable-VirtualTerminal
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "WellDone DevKit v2.0"

# ─── Menu definition ──────────────────────────────────────────────────────────
$menuItems = @(
    "  Dev Essentials"
    "  Terminal Theme"
    "  PowerShell Setup"
    "  Git Setup"
    "  SSH Manager"
    "  System Tweaks"
    "  Apps Opcionais"
    "  ─────────────────"
    "  Instalar Tudo"
    "  Sair"
)

$descriptions = @(
    @{  # 0 — Dev Essentials
        Title = "Dev Essentials"
        Body  = @"
Instala as ferramentas centrais de desenvolvimento:

  • Git — controle de versão
  • NVS — gerenciador de versões do Node.js
  • Node.js LTS — runtime JavaScript
  • VS Code — editor de código
  • Postman — testes de API

Todos os pacotes são instalados via winget com
flags --silent --accept-agreements.
"@
    }
    @{  # 1 — Terminal Theme
        Title = "Terminal Theme"
        Body  = @"
Configura um terminal cyberpunk neon:

  • JetBrainsMono Nerd Font — fonte com ícones
  • Oh My Posh — motor de temas do prompt
  • Tema WellDone Neon — visual personalizado
    (cyan, pink, purple em fundo escuro)

Aplica o tema em dois ambientes:
  • PowerShell — perfil CurrentUserAllHosts
  • Git Bash   — ~/.bashrc (init bash)

Após instalar, configure a fonte no
Windows Terminal → Configurações → Perfil.
"@
    }
    @{  # 2 — PowerShell Setup
        Title = "PowerShell Setup"
        Body  = @"
Instala e configura o PowerShell moderno:

  • PowerShell 7 (pwsh) — cross-platform,
    mais rápido que o Windows PowerShell 5.1

  • PSReadLine — syntax highlight em cores
    neon, predição por histórico (ListView),
    Tab completion avançado

  • Terminal-Icons — ícones de arquivo e
    pasta coloridos no terminal

As cores do PSReadLine seguem a paleta
WellDone Neon (cyan, green, yellow, pink).
"@
    }
    @{  # 3 — Git Setup  (index shifted)
        Title = "Git Setup"
        Body  = @"
Configura o Git globalmente no seu sistema:

  • user.name e user.email
  • Branch padrão → main
  • Editor → VS Code (code --wait)
  • pull.rebase → true
  • core.autocrlf → true (Windows)

Bonus — alias útil:
  git lg  →  log colorido e compacto
             com gráfico de branches
"@
    }
    @{  # 3 — SSH Manager
        Title = "SSH Manager"
        Body  = @"
Gera e gerencia chaves SSH para GitHub:

  • Cria chave Ed25519 (mais segura que RSA)
  • Inicia o ssh-agent automaticamente
  • Adiciona a chave ao agente
  • Exibe e copia a chave pública

Após gerar, adicione a chave em:
  github.com → Settings → SSH Keys
"@
    }
    @{  # 4 — System Tweaks
        Title = "System Tweaks"
        Body  = @"
Otimizações do Windows para devs:

  • Exibir extensões de arquivo no Explorer
  • Exibir arquivos e pastas ocultos
  • Execution Policy → RemoteSigned
  • Habilitar WSL2 (Linux no Windows)
  • Habilitar ANSI/VT no console legado
  • Desabilitar som de boot do Windows

Algumas mudanças exigem reiniciar o
Explorer ou fazer logoff/login.
"@
    }
    @{  # 6 — Apps Opcionais
        Title = "Apps Opcionais"
        Body  = @"
Selecione os apps que deseja instalar:

  Browser
    • Opera GX — navegador para gamers/devs

  Comunidade & Trabalho
    • Discord   • Microsoft Teams

  Produtividade
    • Notion   • Obsidian   • Google Drive

  Entretenimento
    • Spotify   • Steam   • Epic Games

Você escolhe quais instalar com um menu
de seleção múltipla antes de confirmar.
"@
    }
    @{  # 7 — separator (dummy)
        Title = ""
        Body  = ""
    }
    @{  # 8 — Instalar Tudo
        Title = "Instalar Tudo"
        Body  = @"
Executa todos os módulos em sequência:

  1. Dev Essentials
  2. Terminal Theme
  3. PowerShell Setup
  4. Git Setup
  5. SSH Manager
  6. System Tweaks
  7. Apps Opcionais

Cada módulo pede confirmação quando
necessário. O processo pode demorar
alguns minutos dependendo da conexão.

Ideal para configurar um PC novo do zero.
"@
    }
    @{  # 9 — Sair
        Title = "Sair"
        Body  = @"
Encerra o WellDone DevKit.

Volte sempre que precisar instalar mais
ferramentas ou reconfigurar o ambiente.

  welldone.ps1  —  sempre à mão em:
  Documentos\PROJECT\welldone-devkit\
"@
    }
)

# ─── Module dispatcher ────────────────────────────────────────────────────────
function Invoke-Module([string]$path) {
    & "$Root\scripts\modules\$path" -Root $Root
}

function Run-AllModules {
    Show-ModuleHeader "INSTALANDO TUDO"
    Write-Host "  ${CYAN}Executando todos os módulos em sequência...${NC}"
    Write-Host ""
    Pause-Prompt

    Invoke-Module "install_dev_essentials.ps1"
    Invoke-Module "install_terminal_theme.ps1"
    Invoke-Module "setup_powershell.ps1"
    Invoke-Module "setup_git.ps1"
    Invoke-Module "manage_ssh.ps1"
    Invoke-Module "system_tweaks.ps1"
    Invoke-Module "install_optional_apps.ps1"

    Clear-Screen
    Show-ModuleHeader "SETUP COMPLETO"
    Write-Host "  ${GREEN}✓ Tudo instalado e configurado!${NC}"
    Write-Host ""
    Write-Host "  ${GRAY}Próximos passos:${NC}"
    Write-Host "  ${CYAN}1.${NC} Feche e reabra o terminal"
    Write-Host "  ${CYAN}2.${NC} Configure a fonte JetBrainsMono Nerd Font no Windows Terminal"
    Write-Host "  ${CYAN}3.${NC} Adicione sua chave SSH no GitHub"
    Write-Host ""
    Pause-Prompt
}

# ─── Boot screen + main loop ──────────────────────────────────────────────────
Show-BootScreen

while ($true) {
    $choice = Show-Menu -Items $menuItems -Descriptions $descriptions `
              -Subtitle "v2.0  |  github.com/WellytonSdJ/welldone-devkit"

    switch ($choice) {
        0  { Invoke-Module "install_dev_essentials.ps1"  }
        1  { Invoke-Module "install_terminal_theme.ps1"  }
        2  { Invoke-Module "setup_powershell.ps1"        }
        3  { Invoke-Module "setup_git.ps1"               }
        4  { Invoke-Module "manage_ssh.ps1"              }
        5  { Invoke-Module "system_tweaks.ps1"           }
        6  { Invoke-Module "install_optional_apps.ps1"   }
        7  {}   # separator — do nothing
        8  { Run-AllModules                              }
        9  { break }
        -1 { break }
    }

    if ($choice -eq 9 -or $choice -eq -1) { break }
}

# ─── Goodbye ──────────────────────────────────────────────────────────────────
Clear-Screen
Write-Host ""
Write-Host "$(Center-Text '' (Get-TermWidth))"
Write-Host "${CYAN}$(Center-Text 'Até mais! WellDone DevKit encerrado.' (Get-TermWidth))${NC}"
Write-Host "${GRAY}$(Center-Text 'github.com/WellytonSdJ/welldone-devkit' (Get-TermWidth))${NC}"
Write-Host ""
