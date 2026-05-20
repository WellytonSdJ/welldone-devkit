param([string]$Root)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"

Show-ModuleHeader "DEV ESSENTIALS"

if (-not (Test-Winget)) {
    Write-Host "  ${RED}✗${NC} winget não encontrado. Instale o App Installer da Microsoft Store."
    Pause-Prompt; return
}

Write-Host "  ${CYAN}Ferramentas que serão instaladas:${NC}"
Write-Host "  ${GRAY}• Git   • NVS   • Node.js LTS   • VS Code   • Hoppscotch${NC}"
Write-Host ""

$packages = @(
    @{ Id='Git.Git';                     Name='Git'          }
    @{ Id='jasongin.nvs';                Name='NVS'          }
    @{ Id='Microsoft.VisualStudioCode';  Name='VS Code'      }
    @{ Id='Hoppscotch.Hoppscotch';       Name='Hoppscotch'   }
)

$ok = $true
foreach ($p in $packages) {
    if (-not (Install-Package $p.Id $p.Name)) { $ok = $false }
}

# After NVS, add LTS Node via nvs
Write-Host ""
if (Run-Step "Configurando Node.js LTS via NVS" {
    $env:NVS_HOME = "$env:LOCALAPPDATA\nvs"
    $nvsCmd = "$env:NVS_HOME\nvs.cmd"
    if (Test-Path $nvsCmd) {
        & $nvsCmd add lts 2>&1
        & $nvsCmd use lts 2>&1
        & $nvsCmd link lts 2>&1
    }
}) {} else { $ok = $false }

Write-Host ""
if ($ok) {
    Write-Host "  ${GREEN}✓ Dev Essentials instalados com sucesso!${NC}"
} else {
    Write-Host "  ${YELLOW}⚠ Concluído com alguns erros. Verifique acima.${NC}"
}
Pause-Prompt
