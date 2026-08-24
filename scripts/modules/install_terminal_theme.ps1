param([string]$Root, [switch]$Revert)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"
. "$Root\scripts\utils\state.ps1"
Init-StateDir $Root

$profileMarker = "# WellDone DevKit — Oh My Posh"
$bashMarker    = "# WellDone DevKit — Oh My Posh (Git Bash)"

# ═══════════════════════════════════════════════════════════════════════════
#  MODO REVERSÃO
# ═══════════════════════════════════════════════════════════════════════════
if ($Revert) {
    Show-ModuleHeader "REVERTER — TERMINAL THEME (OH MY POSH)"
    Write-Host "  ${CYAN}O que esta reversão faz:${NC}"
    Write-Host "  ${GRAY}• Remove a inicialização do Oh My Posh do perfil do PowerShell${NC}"
    Write-Host "  ${GRAY}• Remove a inicialização do Oh My Posh do Git Bash (.bashrc)${NC}"
    Write-Host "  ${GRAY}• Remove a fonte configurada no Warp Terminal (se foi o WellDone quem configurou)${NC}"
    Write-Host "  ${GRAY}• NÃO desinstala a fonte JetBrainsMono Nerd Font nem o Oh My Posh${NC}"
    Write-Host ""

    $state     = Get-State "terminal_theme"
    $anyChange = $false

    # ─── PowerShell profile ────────────────────────────────────────────────
    $profile6 = $PROFILE.CurrentUserAllHosts
    $done = $false
    if ($state -and $state.Profile -and $state.Profile.Existed -and $state.Profile.PreviousLine) {
        $done = Restore-Line $profile6 "(?m)^oh-my-posh init.*$" $state.Profile.PreviousLine
    }
    if (-not $done) { $done = Remove-CommentedBlock $profile6 $profileMarker }
    if ($done) { Write-Host "  ${GREEN}✓${NC} Perfil do PowerShell restaurado"; $anyChange = $true }
    else { Write-Host "  ${GRAY}—${NC} Perfil do PowerShell já não tinha essa configuração" }

    # ─── Git Bash (.bashrc) ────────────────────────────────────────────────
    $gitBashRc = Join-Path $env:USERPROFILE ".bashrc"
    $done = $false
    if ($state -and $state.Bash -and $state.Bash.Existed -and $state.Bash.PreviousLine) {
        $done = Restore-Line $gitBashRc "(?m)^eval.*oh-my-posh init bash.*$" $state.Bash.PreviousLine
    }
    if (-not $done) { $done = Remove-CommentedBlock $gitBashRc $bashMarker }
    if ($done) { Write-Host "  ${GREEN}✓${NC} Git Bash (.bashrc) restaurado"; $anyChange = $true }
    else { Write-Host "  ${GRAY}—${NC} Git Bash já não tinha essa configuração" }

    # ─── Warp Terminal font ────────────────────────────────────────────────
    $warpPrefs = "$env:USERPROFILE\.warp\preferences.yaml"
    $done = $false
    if ($state -and $state.Warp) {
        if ($state.Warp.HadFontName -and $state.Warp.PreviousFontLine) {
            $done = Restore-Line $warpPrefs "(?m)^font_name:.*$" $state.Warp.PreviousFontLine
        } elseif (-not $state.Warp.HadFontName -and (Test-Path $warpPrefs)) {
            $raw = Get-Content $warpPrefs -Raw -ErrorAction SilentlyContinue
            if ($raw -and $raw -match "font_name") {
                $updated = [regex]::Replace($raw, "(?m)\r?\n?^font_name:.*(\r?\nfont_size:.*)?$", "")
                [System.IO.File]::WriteAllText($warpPrefs, $updated)
                $done = $true
            }
        }
    }
    if ($done) { Write-Host "  ${GREEN}✓${NC} Fonte do Warp Terminal restaurada"; $anyChange = $true }
    else { Write-Host "  ${GRAY}—${NC} Nada para restaurar no Warp Terminal" }

    if ($state) { Remove-State "terminal_theme" }

    Write-Host ""
    if ($anyChange) {
        Write-Host "  ${GREEN}✓ Reversão concluída!${NC}"
        Write-Host "  ${GRAY}Reinicie o terminal para ver o efeito. A fonte e o Oh My Posh continuam instalados.${NC}"
    } else {
        Write-Host "  ${GRAY}Nada para reverter — este módulo ainda não tinha sido configurado.${NC}"
    }
    Write-Host ""
    Pause-Prompt
    return
}

# ═══════════════════════════════════════════════════════════════════════════
#  MODO NORMAL — instala e configura o tema
# ═══════════════════════════════════════════════════════════════════════════
Show-ModuleHeader "TERMINAL THEME — OH MY POSH"

Write-Host "  ${CYAN}O que será configurado:${NC}"
Write-Host "  ${GRAY}• JetBrainsMono Nerd Font (fonte com ícones para o prompt)${NC}"
Write-Host "  ${GRAY}• Oh My Posh (motor de tema do terminal)${NC}"
Write-Host "  ${GRAY}• Tema WellDone Neon (tema cyberpunk personalizado)${NC}"
Write-Host "  ${GRAY}• Perfil PowerShell — oh-my-posh init pwsh${NC}"
Write-Host "  ${GRAY}• Git Bash .bashrc    — oh-my-posh init bash${NC}"
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
    $existing    = if (Test-Path $profile6) { Get-Content $profile6 -Raw } else { "" }
    $hadOhMyPosh = $existing -match "oh-my-posh"
    $prevLine    = $null
    if ($hadOhMyPosh) {
        $m = [regex]::Match($existing, "(?m)^oh-my-posh init.*$")
        if ($m.Success) { $prevLine = $m.Value }
    }
    $script:ttProfileState = @{ Existed = $hadOhMyPosh; PreviousLine = $prevLine }

    if (-not $hadOhMyPosh) {
        Add-Content -Path $profile6 -Value "`n$profileMarker`n$initLine"
    } else {
        $existing = $existing -replace "(?m)^oh-my-posh init.*$", $initLine
        Set-Content -Path $profile6 -Value $existing
    }
}

# Step 6 — write Git Bash profile (.bashrc)
$gitBashRc  = Join-Path $env:USERPROFILE ".bashrc"
$posixTheme = $activeTheme -replace "\\", "/"
if ($posixTheme -match "^([A-Za-z]):") {
    $posixTheme = "/" + $Matches[1].ToLower() + $posixTheme.Substring(2)
}
$bashLine = 'eval "$(oh-my-posh init bash --config ' + "'$posixTheme'" + ')"'

Run-Step "Configurando Git Bash (.bashrc)" {
    $existing    = if (Test-Path $gitBashRc) { Get-Content $gitBashRc -Raw } else { "" }
    $hadOhMyPosh = $existing -match "oh-my-posh"
    $prevLine    = $null
    if ($hadOhMyPosh) {
        $m = [regex]::Match($existing, "(?m)^eval.*oh-my-posh init bash.*$")
        if ($m.Success) { $prevLine = $m.Value }
    }
    $script:ttBashState = @{ Existed = $hadOhMyPosh; PreviousLine = $prevLine }

    if (-not $hadOhMyPosh) {
        Add-Content -Path $gitBashRc -Value "`n$bashMarker`n$bashLine"
    } else {
        $updated = $existing -replace "(?m)^eval.*oh-my-posh init bash.*$", $bashLine
        Set-Content -Path $gitBashRc -Value $updated
    }
}

# Step 7 — configure Warp font if Warp is installed
$warpExe = "$env:LOCALAPPDATA\Programs\Warp\Warp.exe"
if (Test-Path $warpExe) {
    $warpConfigDir = "$env:USERPROFILE\.warp"
    $warpPrefs     = "$warpConfigDir\preferences.yaml"

    Run-Step "Configurando fonte no Warp Terminal" {
        $fileExisted  = Test-Path $warpPrefs
        $hadFontName  = $false
        $prevFontLine = $null
        if ($fileExisted) {
            $raw = Get-Content $warpPrefs -Raw
            $hadFontName = $raw -match "font_name"
            if ($hadFontName) {
                $m = [regex]::Match($raw, "(?m)^font_name:.*$")
                if ($m.Success) { $prevFontLine = $m.Value }
            }
        }
        $script:ttWarpState = @{ FileExisted = $fileExisted; HadFontName = $hadFontName; PreviousFontLine = $prevFontLine }

        if (-not (Test-Path $warpConfigDir)) {
            New-Item -ItemType Directory -Force -Path $warpConfigDir | Out-Null
        }
        $fontBlock = "font_name: JetBrainsMono Nerd Font`nfont_size: 14"
        if ($fileExisted) {
            $raw = Get-Content $warpPrefs -Raw
            if (-not $hadFontName) {
                Add-Content -Path $warpPrefs -Value "`n$fontBlock"
            } else {
                $raw = $raw -replace "(?m)^font_name:.*$", "font_name: JetBrainsMono Nerd Font"
                Set-Content -Path $warpPrefs -Value $raw
            }
        } else {
            Set-Content -Path $warpPrefs -Value $fontBlock
        }
    }
    Write-Host "  ${GRAY}O Oh My Posh já está configurado no perfil do PowerShell — o Warp carregará automaticamente.${NC}"
} else {
    Write-Host "  ${GRAY}Dica Warp: instale via '${WHITE}Apps Opcionais${GRAY}' e configure a fonte ${WHITE}JetBrainsMono Nerd Font${GRAY} em${NC}"
    Write-Host "  ${GRAY}  Warp → Settings → Appearance → Font.${NC}"
}

# Guarda a snapshot "de antes" — só na primeira vez que este módulo roda.
Save-StateOnce "terminal_theme" @{
    Profile = $script:ttProfileState
    Bash    = $script:ttBashState
    Warp    = $script:ttWarpState
}

Write-Host ""
Write-Host "  ${GREEN}✓ Tema aplicado!${NC}"
Write-Host "  ${GRAY}Dica: configure a fonte '${WHITE}JetBrainsMono Nerd Font${GRAY}' no Windows Terminal e no Warp.${NC}"
Write-Host "  ${GRAY}Reinicie o terminal para ver as mudanças.${NC}"
Write-Host "  ${GRAY}💡 Para desfazer: menu principal → ${WHITE}Reverter Alterações${GRAY}.${NC}"
Pause-Prompt
