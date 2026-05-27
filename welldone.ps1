#Requires -Version 5.1
<#
.SYNOPSIS
    WellDone DevKit — ambiente de desenvolvimento
.DESCRIPTION
    Instalador e configurador cyberpunk-themed para ambiente de desenvolvimento Windows.
    Digite o número da opção desejada e pressione Enter.
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
$Host.UI.RawUI.WindowTitle = "WellDone DevKit v2.2"

# ─── Menu definition ──────────────────────────────────────────────────────────
$menuItems = @(
    @{ Label = "Dev Essentials";   Action = { Invoke-Module "install_dev_essentials.ps1"  } }
    @{ Label = "Terminal Theme";   Action = { Invoke-Module "install_terminal_theme.ps1"  } }
    @{ Label = "PowerShell Setup"; Action = { Invoke-Module "setup_powershell.ps1"        } }
    @{ Label = "Git Setup";        Action = { Invoke-Module "setup_git.ps1"               } }
    @{ Label = "SSH Manager";      Action = { Invoke-Module "manage_ssh.ps1"              } }
    @{ Label = "System Tweaks";    Action = { Invoke-Module "system_tweaks.ps1"           } }
    @{ Label = "Pasta Inicial";    Action = { Invoke-Module "setup_start_folder.ps1"      } }
    @{ Label = "Apps Opcionais";   Action = { Invoke-Module "install_optional_apps.ps1"   } }
    @{ Separator = $true }
    @{ Label = "Instalar Tudo";    Action = { Run-AllModules } }
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
    Invoke-Module "setup_start_folder.ps1"
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
    $choice = Show-Menu -Items $menuItems `
              -Subtitle "v2.2  |  github.com/WellytonSdJ/welldone-devkit"

    if ($null -eq $choice) { break }

    & $choice.Action

    # Run-AllModules já exibe seu próprio Pause-Prompt
    if ($choice.Label -ne "Instalar Tudo") { Pause-Prompt }
}

# ─── Goodbye ──────────────────────────────────────────────────────────────────
Clear-Screen
Write-Host ""
Write-Host "$(Center-Text '' (Get-TermWidth))"
Write-Host "${CYAN}$(Center-Text 'Até mais! WellDone DevKit encerrado.' (Get-TermWidth))${NC}"
Write-Host "${GRAY}$(Center-Text 'github.com/WellytonSdJ/welldone-devkit' (Get-TermWidth))${NC}"
Write-Host ""
