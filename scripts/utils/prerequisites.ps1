function Show-Prerequisites {
    $w     = Get-TermWidth
    $inner = $w - 2

    $wingetOk = (Get-Command winget -ErrorAction SilentlyContinue) -ne $null
    $sshOk    = (Get-Command ssh-keygen -ErrorAction SilentlyContinue) -ne $null

    if ($wingetOk -and $sshOk) { return $true }

    Clear-Screen
    Show-ModuleHeader "VERIFICAÇÃO DE PRÉ-REQUISITOS"

    Write-Host "  ${CYAN}Status dos componentes necessários:${NC}"
    Write-Host ""

    if ($wingetOk) {
        Write-Host "  ${GREEN}[✓]${NC} winget (App Installer)"
    } else {
        Write-Host "  ${RED}[✗]${NC} winget (App Installer) — ${YELLOW}necessário para instalar apps${NC}"
    }

    if ($sshOk) {
        Write-Host "  ${GREEN}[✓]${NC} OpenSSH (ssh-keygen)"
    } else {
        Write-Host "  ${YELLOW}[!]${NC} OpenSSH (ssh-keygen) — ${GRAY}necessário apenas para o módulo SSH${NC}"
    }

    Write-Host ""

    if (-not $wingetOk) {
        Write-Host "  ${YELLOW}──────────────────────────────────────────${NC}"
        Write-Host "  ${BOLD}${WHITE}Como instalar o winget:${NC}"
        Write-Host ""
        Write-Host "  ${CYAN}Opção 1 — Microsoft Store (recomendado)${NC}"
        Write-Host "  ${GRAY}Procure por 'App Installer' ou acesse a loja pela opção abaixo.${NC}"
        Write-Host ""
        Write-Host "  ${CYAN}Opção 2 — GitHub (sem Store)${NC}"
        Write-Host "  ${GRAY}Baixe o .msixbundle em:${NC}"
        Write-Host "  ${WHITE}  github.com/microsoft/winget-cli/releases/latest${NC}"
        Write-Host ""

        if (Confirm-Action "Abrir a Microsoft Store no App Installer agora?") {
            Start-Process "ms-windows-store://pdp/?productid=9NBLGGH4NNS1"
            Write-Host ""
            Write-Host "  ${GREEN}✓${NC} Microsoft Store aberta."
            Write-Host "  ${GRAY}Instale o App Installer, depois feche e reabra este script.${NC}"
            Write-Host ""
            Pause-Prompt
            return $false
        }

        Write-Host ""
        Write-Host "  ${YELLOW}⚠ Sem winget, a maioria dos módulos não funcionará.${NC}"

        if (-not (Confirm-Action "Continuar mesmo assim?")) {
            return $false
        }
    }

    if (-not $sshOk) {
        Write-Host ""
        Write-Host "  ${YELLOW}──────────────────────────────────────────${NC}"
        Write-Host "  ${BOLD}${WHITE}Como instalar o OpenSSH:${NC}"
        Write-Host ""
        Write-Host "  ${GRAY}Configurações → Apps → Recursos Opcionais → Adicionar recurso${NC}"
        Write-Host "  ${GRAY}Procure por '${WHITE}Cliente OpenSSH${GRAY}' e instale.${NC}"
        Write-Host ""
        Write-Host "  ${GRAY}Ou via PowerShell (como Administrador):${NC}"
        Write-Host "  ${WHITE}  Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0${NC}"
        Write-Host ""
        Write-Host "  ${GRAY}O módulo SSH Manager ficará indisponível até a instalação.${NC}"
        Write-Host ""
        Pause-Prompt
    }

    return $true
}
