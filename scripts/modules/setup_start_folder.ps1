param([string]$Root, [switch]$Revert)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"
. "$Root\scripts\utils\state.ps1"
Init-StateDir $Root

$profileMarker = "# WellDone: startdir"

function Remove-StartFolderProfileBlock {
    $profilePath = $PROFILE.CurrentUserAllHosts
    if (-not (Test-Path $profilePath)) { return $false }
    $raw = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    if (-not $raw -or -not ($raw -match [regex]::Escape($profileMarker))) { return $false }
    $updated = $raw -replace ("(?m)\r?\n?" + [regex]::Escape($profileMarker) + "\r?\nSet-Location[^\r\n]*(\r?\n)?"), ""
    [System.IO.File]::WriteAllText($profilePath, $updated)
    return $true
}

# ═══════════════════════════════════════════════════════════════════════════
#  MODO REVERSÃO
# ═══════════════════════════════════════════════════════════════════════════
if ($Revert) {
    Show-ModuleHeader "REVERTER — PASTA INICIAL DO TERMINAL"
    Write-Host "  ${CYAN}O que esta reversão faz:${NC}"
    Write-Host "  ${GRAY}• Remove o 'Set-Location' para a pasta projects do perfil do PowerShell${NC}"
    Write-Host "  ${GRAY}• Restaura a pasta inicial do Windows Terminal para o valor de antes de rodar este módulo${NC}"
    Write-Host "  ${GRAY}• Não apaga a pasta 'projects' nem qualquer arquivo dentro dela${NC}"
    Write-Host ""

    $didProfile = Remove-StartFolderProfileBlock
    if ($didProfile) {
        Write-Host "  ${GREEN}✓${NC} Perfil do PowerShell restaurado"
    } else {
        Write-Host "  ${GRAY}—${NC} Perfil do PowerShell já não tinha essa configuração"
    }

    $state = Get-State "start_folder"
    $didWt = $false
    if ($state -and $state.WtPath -and (Test-Path $state.WtPath)) {
        try {
            $json = Get-Content $state.WtPath -Raw | ConvertFrom-Json
            if ($json.profiles -and $json.profiles.defaults) {
                if ($state.HadStartingDirectory) {
                    $json.profiles.defaults | Add-Member -NotePropertyName startingDirectory -NotePropertyValue $state.PreviousStartingDirectory -Force
                } elseif ($json.profiles.defaults.PSObject.Properties['startingDirectory']) {
                    $json.profiles.defaults.PSObject.Properties.Remove('startingDirectory')
                }
                [System.IO.File]::WriteAllText($state.WtPath, ($json | ConvertTo-Json -Depth 20))
                $didWt = $true
            }
        } catch {
            Write-Host "  ${YELLOW}⚠ Não foi possível atualizar o Windows Terminal: $($_.Exception.Message)${NC}"
        }
    }

    if ($didWt) {
        Write-Host "  ${GREEN}✓${NC} Windows Terminal restaurado"
        Remove-State "start_folder"
    } else {
        Write-Host "  ${GRAY}—${NC} Nada para restaurar no Windows Terminal"
    }

    Write-Host ""
    if ($didProfile -or $didWt) {
        Write-Host "  ${GREEN}✓ Reversão concluída!${NC}"
        Write-Host "  ${GRAY}Abra um novo terminal para ver o efeito.${NC}"
    } else {
        Write-Host "  ${GRAY}Nada para reverter — este módulo ainda não tinha sido configurado.${NC}"
    }
    Write-Host ""
    Pause-Prompt
    return
}

# ═══════════════════════════════════════════════════════════════════════════
#  MODO NORMAL — configura a pasta inicial
# ═══════════════════════════════════════════════════════════════════════════
Show-ModuleHeader "PASTA INICIAL DO TERMINAL"

$docsPath     = [Environment]::GetFolderPath("MyDocuments")
$projectsPath = $null

# ─── Detect or create the projects folder ────────────────────────────────────
if (Test-Path "$docsPath\PROJECTS") {
    $projectsPath = "$docsPath\PROJECTS"
    Write-Host "  ${GREEN}✓${NC} Pasta encontrada: ${CYAN}$projectsPath${NC}"
} elseif (Test-Path "$docsPath\PROJECT") {
    $projectsPath = "$docsPath\PROJECT"
    Write-Host "  ${GREEN}✓${NC} Pasta encontrada: ${CYAN}$projectsPath${NC}"
} else {
    $projectsPath = "$docsPath\PROJECTS"
    Write-Host "  ${CYAN}›${NC} Criando pasta: ${WHITE}$projectsPath${NC}" -NoNewline
    New-Item -ItemType Directory -Path $projectsPath -Force | Out-Null
    Write-Host " ${GREEN}OK${NC}"
}

Write-Host ""

# ─── Configure PowerShell profile (universal — works in any terminal) ─────────
$profilePath = $PROFILE.CurrentUserAllHosts
$profileDir  = Split-Path $profilePath -Parent

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}

$marker = $profileMarker
$raw    = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue

if ($raw -and ($raw -match [regex]::Escape($marker))) {
    $raw = $raw -replace ("(?m)" + [regex]::Escape($marker) + "\r?\nSet-Location[^\r\n]*(\r?\n)?"), ""
    [System.IO.File]::WriteAllText($profilePath, $raw)
}

Add-Content $profilePath "`n$marker`nSet-Location `"$projectsPath`""
Write-Host "  ${GREEN}✓${NC} Perfil PowerShell configurado"

# ─── Configure Windows Terminal if installed ──────────────────────────────────
$wtPaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
)

$wtFound = $false
foreach ($wtPath in $wtPaths) {
    if (-not (Test-Path $wtPath)) { continue }
    $wtFound = $true
    Write-Host "  ${CYAN}›${NC} Configurando Windows Terminal..." -NoNewline
    try {
        $json = Get-Content $wtPath -Raw | ConvertFrom-Json
        if (-not $json.profiles) {
            $json | Add-Member -NotePropertyName profiles -NotePropertyValue ([PSCustomObject]@{}) -Force
        }
        if (-not $json.profiles.defaults) {
            $json.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([PSCustomObject]@{}) -Force
        }

        # Guarda o valor original (ou a ausência dele) ANTES de sobrescrever —
        # só na primeira vez, para permitir reverter para o que sempre foi.
        $hadStartDir  = $null -ne $json.profiles.defaults.PSObject.Properties['startingDirectory']
        $prevStartDir = if ($hadStartDir) { $json.profiles.defaults.startingDirectory } else { $null }
        Save-StateOnce "start_folder" @{
            WtPath                    = $wtPath
            HadStartingDirectory      = $hadStartDir
            PreviousStartingDirectory = $prevStartDir
        }

        $json.profiles.defaults | Add-Member -NotePropertyName startingDirectory -NotePropertyValue $projectsPath -Force
        [System.IO.File]::WriteAllText($wtPath, ($json | ConvertTo-Json -Depth 20))
        Write-Host " ${GREEN}OK${NC}"
    } catch {
        Write-Host " ${YELLOW}⚠ $($_.Exception.Message)${NC}"
    }
    break
}

if (-not $wtFound) {
    Write-Host "  ${GRAY}Windows Terminal não encontrado — perfil PS configurado como fallback.${NC}"
}

Write-Host ""
Write-Host "  ${GREEN}✓ Configuração concluída!${NC}"
Write-Host "  ${GRAY}Abra um novo terminal para ver o efeito.${NC}"
Write-Host "  ${GRAY}💡 Para desfazer: menu principal → ${WHITE}Reverter Alterações${GRAY}.${NC}"
Write-Host ""
Pause-Prompt
