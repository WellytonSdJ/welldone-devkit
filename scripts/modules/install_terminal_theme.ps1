param([string]$Root)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"

Show-ModuleHeader "TERMINAL THEME — OH MY POSH"

Write-Host "  ${CYAN}O que será configurado:${NC}"
Write-Host "  ${GRAY}• FiraCode Nerd Font (fonte com ícones para o prompt)${NC}"
Write-Host "  ${GRAY}• Oh My Posh (motor de tema do terminal)${NC}"
Write-Host "  ${GRAY}• Tema WellDone Neon (tema cyberpunk personalizado)${NC}"
Write-Host ""

if (-not (Test-Winget)) {
    Write-Host "  ${RED}✗ winget não encontrado.${NC}"; Pause-Prompt; return
}

# Step 1 — font
Install-Package "DEVCOM.JetBrainsMonoNerdFont" "JetBrainsMono Nerd Font" | Out-Null

# Step 2 — oh-my-posh
Install-Package "JanDeDobbeleer.OhMyPosh" "Oh My Posh" | Out-Null

# Step 3 — refresh PATH so oh-my-posh is available
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")

# Step 4 — copy welldone theme
$themeDir  = "$Root\themes"
$ompThemes = $env:POSH_THEMES_PATH
$themeSrc  = Join-Path $themeDir "welldone_neon.omp.json"

if ($ompThemes -and (Test-Path $ompThemes) -and (Test-Path $themeSrc)) {
    Run-Step "Copiando tema WellDone Neon" {
        Copy-Item $themeSrc -Destination "$ompThemes\welldone_neon.omp.json" -Force
    }
    $activeTheme = "$ompThemes\welldone_neon.omp.json"
} elseif (Test-Path $themeSrc) {
    $activeTheme = $themeSrc
    Write-Host "  ${YELLOW}⚠ POSH_THEMES_PATH não definido — usando caminho direto.${NC}"
} else {
    Write-Host "  ${YELLOW}⚠ Arquivo de tema não encontrado em: $themeSrc${NC}"
    $activeTheme = "jandedobbeleer"   # built-in fallback
}

# Step 5 — write PowerShell profile
$initLine = "oh-my-posh init pwsh --config `"$activeTheme`" | Invoke-Expression"
$profile6 = $PROFILE.CurrentUserAllHosts

Run-Step "Gravando perfil PowerShell" {
    $profileDir = Split-Path $profile6 -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
    }
    $existing = if (Test-Path $profile6) { Get-Content $profile6 -Raw } else { "" }
    if ($existing -notmatch "oh-my-posh") {
        Add-Content -Path $profile6 -Value "`n# WellDone DevKit — Oh My Posh`n$initLine"
    } else {
        $existing = $existing -replace "(?m)^oh-my-posh init.*$", $initLine
        Set-Content -Path $profile6 -Value $existing
    }
}

Write-Host ""
Write-Host "  ${GREEN}✓ Tema aplicado!${NC}"
Write-Host "  ${GRAY}Dica: configure a fonte '${WHITE}JetBrainsMono Nerd Font${GRAY}' no Windows Terminal.${NC}"
Write-Host "  ${GRAY}Reinicie o terminal para ver as mudanças.${NC}"
Pause-Prompt
