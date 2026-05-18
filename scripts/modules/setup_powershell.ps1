param([string]$Root)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"

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

$profile6 = $PROFILE.CurrentUserAllHosts

Run-Step "Gravando configuração no perfil PowerShell" {
    $profileDir = Split-Path $profile6 -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
    }
    $existing = if (Test-Path $profile6) { Get-Content $profile6 -Raw } else { "" }
    if ($existing -notmatch "Terminal-Icons") {
        Add-Content -Path $profile6 -Value $psConfig
    }
}

Write-Host ""
Write-Host "  ${GREEN}✓ PowerShell configurado!${NC}"
Write-Host "  ${GRAY}Reinicie o terminal (ou rode pwsh) para ativar.${NC}"
Write-Host "  ${GRAY}Dica: abra com '${WHITE}pwsh${GRAY}' para usar o PowerShell 7.${NC}"
Pause-Prompt
