param([string]$Root, [switch]$Revert)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"
. "$Root\scripts\utils\state.ps1"
Init-StateDir $Root

$explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$soundPath    = "HKCU:\AppEvents\Schemes\Apps\.Default\SystemStart\.Current"
$consolePath  = "HKCU:\Console"

function Get-RegValueOrNull([string]$Path, [string]$Name) {
    if (-not (Test-Path $Path)) { return $null }
    $item = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    return $item.$Name
}

function Get-RegDefaultOrNull([string]$Path) {
    if (-not (Test-Path $Path)) { return $null }
    try { return (Get-Item -LiteralPath $Path).GetValue("") } catch { return $null }
}

# ═══════════════════════════════════════════════════════════════════════════
#  MODO REVERSÃO
# ═══════════════════════════════════════════════════════════════════════════
if ($Revert) {
    Show-ModuleHeader "REVERTER — SYSTEM TWEAKS"
    Write-Host "  ${CYAN}O que esta reversão faz:${NC}"
    Write-Host "  ${GRAY}• Restaura extensões de arquivo e arquivos ocultos no Explorer${NC}"
    Write-Host "  ${GRAY}• Restaura o som de inicialização do Windows${NC}"
    Write-Host "  ${GRAY}• Restaura a PowerShell Execution Policy (usuário atual)${NC}"
    Write-Host "  ${GRAY}• Restaura o suporte a ANSI no console legado${NC}"
    Write-Host "  ${GRAY}• NÃO desabilita o WSL2 — é um recurso do Windows, não apenas uma preferência${NC}"
    Write-Host ""

    $state = Get-State "system_tweaks"
    if (-not $state) {
        Write-Host "  ${GRAY}Nada para reverter — este módulo ainda não tinha sido configurado.${NC}"
        Write-Host ""
        Pause-Prompt
        return
    }

    Run-Step "Restaurando extensões de arquivo" {
        if ($null -ne $state.HideFileExt) {
            Set-ItemProperty -Path $explorerPath -Name HideFileExt -Value $state.HideFileExt
        } else {
            Remove-ItemProperty -Path $explorerPath -Name HideFileExt -ErrorAction SilentlyContinue
        }
    }

    Run-Step "Restaurando arquivos ocultos" {
        if ($null -ne $state.Hidden) {
            Set-ItemProperty -Path $explorerPath -Name Hidden -Value $state.Hidden
        } else {
            Remove-ItemProperty -Path $explorerPath -Name Hidden -ErrorAction SilentlyContinue
        }
    }

    Run-Step "Restaurando som de inicialização" {
        if (Test-Path $soundPath) {
            Set-ItemProperty -Path $soundPath -Name "(Default)" -Value $state.SoundDefault -ErrorAction SilentlyContinue
        }
    }

    Run-Step "Restaurando Execution Policy" {
        Set-ExecutionPolicy $state.ExecutionPolicy -Scope CurrentUser -Force
    }

    Run-Step "Restaurando suporte ANSI no console legado" {
        if ($state.HadAnsiValue -and $null -ne $state.AnsiValue) {
            Set-ItemProperty -Path $consolePath -Name VirtualTerminalLevel -Value $state.AnsiValue
        } else {
            Remove-ItemProperty -Path $consolePath -Name VirtualTerminalLevel -ErrorAction SilentlyContinue
        }
    }

    Remove-State "system_tweaks"
    Write-Host ""
    Write-Host "  ${GREEN}✓ Reversão concluída!${NC}"
    Write-Host "  ${YELLOW}⚠ Algumas mudanças exigem reiniciar o Explorer ou o Windows.${NC}"
    Write-Host ""
    Pause-Prompt
    return
}

# ═══════════════════════════════════════════════════════════════════════════
#  MODO NORMAL
# ═══════════════════════════════════════════════════════════════════════════
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
Write-Host "  ${GRAY}(exceto o WSL2, tudo acima pode ser desfeito depois em 'Reverter Alterações')${NC}"
Write-Host ""

if (-not (Confirm-Action "Aplicar todos os tweaks?")) {
    Pause-Prompt; return
}
Write-Host ""

# ─── Snapshot dos valores originais (só na primeira vez) ──────────────────────
$hadAnsiValue = ($null -ne (Get-RegValueOrNull $consolePath "VirtualTerminalLevel"))
Save-StateOnce "system_tweaks" @{
    HideFileExt      = Get-RegValueOrNull $explorerPath "HideFileExt"
    Hidden           = Get-RegValueOrNull $explorerPath "Hidden"
    SoundDefault     = Get-RegDefaultOrNull $soundPath
    ExecutionPolicy  = [string](Get-ExecutionPolicy -Scope CurrentUser)
    HadAnsiValue     = $hadAnsiValue
    AnsiValue        = Get-RegValueOrNull $consolePath "VirtualTerminalLevel"
}

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
Write-Host "  ${GRAY}💡 Para desfazer (exceto o WSL2): menu principal → ${WHITE}Reverter Alterações${GRAY}.${NC}"
Pause-Prompt
