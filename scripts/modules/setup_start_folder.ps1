param([string]$Root)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"

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

$marker = "# WellDone: startdir"
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
Write-Host ""
Pause-Prompt
