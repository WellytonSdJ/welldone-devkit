param([string]$Root)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"

Show-ModuleHeader "SYSTEM TWEAKS"

Write-Host "  ${CYAN}Otimizações que serão aplicadas:${NC}"
Write-Host ""

$tweaks = @(
    @{ Label="Mostrar extensões de arquivo no Explorer";        Key="Enabled" }
    @{ Label="Mostrar arquivos ocultos no Explorer";            Key="Hidden" }
    @{ Label="Desabilitar som de inicialização do Windows";     Key="Sound" }
    @{ Label="Ativar PowerShell Execution Policy RemoteSigned"; Key="PSPolicy" }
    @{ Label="Habilitar WSL2 (Windows Subsystem for Linux)";    Key="WSL" }
    @{ Label="Habilitar Terminal Virtual (ANSI) no console";    Key="ANSI" }
)

foreach ($t in $tweaks) {
    Write-Host "  ${GRAY}•${NC} $($t.Label)"
}
Write-Host ""

if (-not (Confirm-Action "Aplicar todos os tweaks?")) {
    Pause-Prompt; return
}
Write-Host ""

# File extensions
Run-Step "Mostrar extensões de arquivo" {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name HideFileExt -Value 0
}

# Hidden files
Run-Step "Mostrar arquivos ocultos" {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name Hidden -Value 1
}

# Startup sound off
Run-Step "Desabilitar som de inicialização" {
    Set-ItemProperty -Path "HKCU:\AppEvents\Schemes\Apps\.Default\SystemStart\.Current" `
        -Name "(Default)" -Value "" -ErrorAction SilentlyContinue
}

# PS Execution Policy
Run-Step "Execution Policy → RemoteSigned" {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

# WSL2
Run-Step "Habilitando WSL2" {
    wsl --install --no-distribution 2>&1
}

# ANSI via registry
Run-Step "Habilitando ANSI no console legado" {
    $regPath = "HKCU:\Console"
    if (-not (Test-Path $regPath)) { New-Item $regPath -Force | Out-Null }
    Set-ItemProperty -Path $regPath -Name VirtualTerminalLevel -Value 1
}

Write-Host ""
Write-Host "  ${GREEN}✓ Tweaks aplicados!${NC}"
Write-Host "  ${YELLOW}⚠ Algumas mudanças exigem reiniciar o Explorer ou o Windows.${NC}"
Pause-Prompt
