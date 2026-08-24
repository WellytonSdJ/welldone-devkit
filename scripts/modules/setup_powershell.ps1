param([string]$Root, [switch]$Revert)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"
. "$Root\scripts\utils\state.ps1"
Init-StateDir $Root

# Bloco fixo gravado no perfil — usado tanto para adicionar (modo normal)
# quanto para remover com precisão (modo reversão), já que é sempre o
# mesmo texto literal.
$psConfig = @"

# WellDone DevKit — PowerShell Setup
Import-Module Terminal-Icons
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -Colors @{
    Command   = '#0aff9d'
    Parameter = '#00eaff'
    String    = '#ffcc00'
    Comment   = '#646482'
    Error     = '#ff0066'
}
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
"@

# ═══════════════════════════════════════════════════════════════════════════
#  MODO REVERSÃO
# ═══════════════════════════════════════════════════════════════════════════
if ($Revert) {
    Show-ModuleHeader "REVERTER — POWERSHELL SETUP"
    Write-Host "  ${CYAN}O que esta reversão faz:${NC}"
    Write-Host "  ${GRAY}• Remove o bloco de configuração (PSReadLine, Terminal-Icons, cores) do perfil PowerShell${NC}"
    Write-Host "  ${GRAY}• NÃO desinstala o PowerShell 7 nem os módulos PSReadLine / Terminal-Icons${NC}"
    Write-Host ""

    $profile6 = $PROFILE.CurrentUserAllHosts
    $done = Remove-TextBlock $profile6 $psConfig

    if ($done) {
        Write-Host "  ${GREEN}✓${NC} Perfil do PowerShell restaurado"
        Remove-State "powershell_setup"
        Write-Host ""
        Write-Host "  ${GREEN}✓ Reversão concluída!${NC}"
        Write-Host "  ${GRAY}Reinicie o terminal para ver o efeito. PowerShell 7 e os módulos continuam instalados.${NC}"
    } else {
        Write-Host "  ${GRAY}—${NC} Nada para reverter — este módulo ainda não tinha sido configurado."
    }
    Write-Host ""
    Pause-Prompt
    return
}

# ═══════════════════════════════════════════════════════════════════════════
#  MODO NORMAL
# ═══════════════════════════════════════════════════════════════════════════
Show-ModuleHeader "POWERSHELL SETUP"

Write-Host "  ${CYAN}O que será instalado e configurado:${NC}"
Write-Host "  ${GRAY}• PowerShell 7   — versão moderna e multiplataforma${NC}"
Write-Host "  ${GRAY}• PSReadLine     — syntax highlight e predição por histórico${NC}"
Write-Host "  ${GRAY}• Terminal-Icons — ícones de arquivo coloridos no terminal${NC}"
Write-Host ""

if (-not (Test-Winget)) {
    Write-Host "  ${RED}✗ winget não encontrado.${NC}"; Pause-Prompt; return
}

# Step 1 — PowerShell 7
Install-Package "Microsoft.PowerShell" "PowerShell 7" | Out-Null

# Step 2 — PSReadLine (enhanced autocomplete + syntax highlight)
Run-Step "Instalando PSReadLine" {
    Install-Module PSReadLine -AllowPrerelease -Force -SkipPublisherCheck `
        -ErrorAction SilentlyContinue
}

# Step 3 — Terminal-Icons (file/folder icons in terminal)
Run-Step "Instalando Terminal-Icons" {
    Install-Module Terminal-Icons -Repository PSGallery -Force `
        -ErrorAction SilentlyContinue
}

# Step 4 — Write config block to PowerShell profile
$profile6 = $PROFILE.CurrentUserAllHosts

Run-Step "Gravando configuração no perfil PowerShell" {
    $profileDir = Split-Path $profile6 -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
    }
    $existing = if (Test-Path $profile6) { Get-Content $profile6 -Raw } else { "" }
    if ($existing -notmatch "Terminal-Icons") {
        Add-Content -Path $profile6 -Value $psConfig
        Save-StateOnce "powershell_setup" @{ Added = $true }
    }
}

Write-Host ""
Write-Host "  ${GREEN}✓ PowerShell configurado!${NC}"
Write-Host "  ${GRAY}Reinicie o terminal (ou rode pwsh) para ativar.${NC}"
Write-Host "  ${GRAY}Dica: abra com '${WHITE}pwsh${GRAY}' para usar o PowerShell 7.${NC}"
Write-Host "  ${GRAY}💡 Para desfazer o bloco do perfil: menu principal → ${WHITE}Reverter Alterações${GRAY}.${NC}"
Pause-Prompt
