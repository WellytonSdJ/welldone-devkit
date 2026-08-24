param([string]$Root, [switch]$Revert)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"
. "$Root\scripts\utils\state.ps1"
Init-StateDir $Root

# ─── Catálogo de reversões disponíveis ─────────────────────────────────────────
# Cada item aqui corresponde a UM módulo que sabe reverter a si mesmo (rodando
# com -Revert). Nada nesta lista desinstala programas — só desfaz pointers e
# configurações (pasta inicial, perfis, git config, tweaks do registro, etc.).
$items = @(
    @{
        Key    = "start_folder"
        Module = "setup_start_folder.ps1"
        Label  = "Pasta Inicial do Terminal"
        Desc   = "Remove a pasta 'projects' como diretório padrão do terminal (perfil PowerShell e Windows Terminal) e restaura a pasta que era usada antes."
    }
    @{
        Key    = "terminal_theme"
        Module = "install_terminal_theme.ps1"
        Label  = "Terminal Theme (Oh My Posh)"
        Desc   = "Remove a inicialização do tema Oh My Posh do perfil PowerShell, do Git Bash e a fonte do Warp. NÃO desinstala a fonte nem o Oh My Posh."
    }
    @{
        Key    = "powershell_setup"
        Module = "setup_powershell.ps1"
        Label  = "PowerShell Setup"
        Desc   = "Remove o bloco de configuração (PSReadLine, Terminal-Icons, cores) do perfil PowerShell. NÃO desinstala o PowerShell 7 nem os módulos."
    }
    @{
        Key    = "git_setup"
        Module = "setup_git.ps1"
        Label  = "Git Setup"
        Desc   = "Restaura user.name, user.email e as demais configurações globais do Git para os valores de antes. NÃO desinstala o Git."
    }
    @{
        Key    = "system_tweaks"
        Module = "system_tweaks.ps1"
        Label  = "System Tweaks"
        Desc   = "Restaura Explorer, som de inicialização, Execution Policy e suporte ANSI para os valores de antes. NÃO desabilita o WSL2 (recurso do Windows, não é uma preferência)."
    }
    @{
        Key    = "ssh_manager"
        Module = "manage_ssh.ps1"
        Label  = "SSH Manager (serviço)"
        Desc   = "Restaura o tipo de inicialização do serviço ssh-agent. NÃO apaga a chave SSH gerada nem a remove do GitHub."
    }
)

Show-ModuleHeader "REVERTER ALTERAÇÕES"

Write-Host "  ${CYAN}O que é isso?${NC}"
Write-Host "  ${GRAY}Cada opção abaixo desfaz, de forma independente, uma configuração aplicada${NC}"
Write-Host "  ${GRAY}por um módulo do WellDone DevKit — devolvendo o valor que existia antes.${NC}"
Write-Host "  ${GRAY}${BOLD}Nada aqui desinstala programas.${NC}${GRAY} Só ajusta pointers e preferências.${NC}"
Write-Host ""

# ─── Detecta o que tem alteração pendente ──────────────────────────────────────
foreach ($i in $items) {
    $i.HasChanges = Test-State $i.Key
}

$anyPending = @($items | Where-Object { $_.HasChanges }).Count -gt 0

if (-not $anyPending) {
    Write-Host "  ${GREEN}✓${NC} Nenhuma alteração para reverter no momento."
    Write-Host "  ${GRAY}(as opções aparecem aqui depois que você roda os módulos correspondentes)${NC}"
    Write-Host ""
    Pause-Prompt
    return
}

$selected = @($false) * $items.Count

function Draw-Items {
    Clear-Host
    Show-ModuleHeader "REVERTER ALTERAÇÕES"
    Write-Host "  ${GRAY}(pressione número + Enter para marcar/desmarcar, ou Enter para reverter os marcados)${NC}"
    Write-Host ""
    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        if ($item.HasChanges) {
            $check = if ($selected[$i]) { "${CYAN}[✓]${NC}" } else { "${GRAY}[ ]${NC}" }
            $label = "${WHITE}$($item.Label)${NC}"
            $status = "${YELLOW}(alterações detectadas)${NC}"
        } else {
            $check = "${GRAY}[ ]${NC}"
            $label = "${GRAY}$($item.Label)${NC}"
            $status = "${GRAY}(nada para reverter)${NC}"
        }
        Write-Host "  $check ${WHITE}$($i+1).${NC} $label $status"
        Write-Host "       ${GRAY}$($item.Desc)${NC}"
        Write-Host ""
    }
}

while ($true) {
    Draw-Items
    Write-Host "  ${CYAN}›${NC} ${WHITE}Número, ou Enter para reverter os marcados: ${NC}" -NoNewline
    $choice = Read-Host

    if ($choice -eq "") { break }

    $n = 0
    if ([int]::TryParse($choice, [ref]$n) -and $n -ge 1 -and $n -le $items.Count) {
        $idx = $n - 1
        if ($items[$idx].HasChanges) {
            $selected[$idx] = -not $selected[$idx]
        }
    }
}

$toRevert = @()
for ($i = 0; $i -lt $items.Count; $i++) {
    if ($selected[$i]) { $toRevert += $items[$i] }
}

if ($toRevert.Count -eq 0) {
    Write-Host "  ${YELLOW}Nada foi marcado — nenhuma reversão executada.${NC}"
    Pause-Prompt
    return
}

Write-Host ""
if (-not (Confirm-Action "Reverter $($toRevert.Count) item(ns) selecionado(s)?")) {
    Pause-Prompt; return
}

foreach ($item in $toRevert) {
    Write-Host ""
    & "$Root\scripts\modules\$($item.Module)" -Root $Root -Revert
}
