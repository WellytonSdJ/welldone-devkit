param([string]$Root, [switch]$Revert)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"
. "$Root\scripts\utils\state.ps1"
Init-StateDir $Root

# Chaves globais de git que este módulo configura.
$gitKeys = @("user.name", "user.email", "init.defaultBranch", "core.editor", `
             "merge.tool", "pull.rebase", "core.autocrlf", "alias.lg")

# ═══════════════════════════════════════════════════════════════════════════
#  MODO REVERSÃO
# ═══════════════════════════════════════════════════════════════════════════
if ($Revert) {
    Show-ModuleHeader "REVERTER — GIT SETUP"
    Write-Host "  ${CYAN}O que esta reversão faz:${NC}"
    Write-Host "  ${GRAY}• Restaura user.name, user.email e as demais configurações globais do Git${NC}"
    Write-Host "  ${GRAY}  para os valores que existiam antes de rodar este módulo${NC}"
    Write-Host "  ${GRAY}• Chaves que não existiam antes são removidas (git config --unset)${NC}"
    Write-Host "  ${GRAY}• NÃO desinstala o Git${NC}"
    Write-Host ""

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "  ${RED}✗ Git não encontrado — nada para reverter.${NC}"
        Pause-Prompt; return
    }

    $state = Get-State "git_setup"
    if (-not $state) {
        Write-Host "  ${GRAY}Nada para reverter — este módulo ainda não tinha sido configurado.${NC}"
        Write-Host ""
        Pause-Prompt
        return
    }

    foreach ($key in $gitKeys) {
        $prop = $state.($key -replace '\.', '_')
        if ($null -eq $prop) { continue }
        Write-Host "  ${CYAN}›${NC} ${WHITE}${key}${NC}..." -NoNewline
        if ($prop.Existed) {
            git config --global $key "$($prop.Value)" 2>&1 | Out-Null
            Write-Host " ${GREEN}restaurado para '$($prop.Value)'${NC}"
        } else {
            git config --global --unset $key 2>&1 | Out-Null
            Write-Host " ${GREEN}removido${NC}"
        }
    }

    Remove-State "git_setup"
    Write-Host ""
    Write-Host "  ${GREEN}✓ Reversão concluída!${NC}"
    Write-Host "  ${GRAY}O Git continua instalado — só a configuração global foi restaurada.${NC}"
    Write-Host ""
    Pause-Prompt
    return
}

# ═══════════════════════════════════════════════════════════════════════════
#  MODO NORMAL
# ═══════════════════════════════════════════════════════════════════════════
Show-ModuleHeader "CONFIGURAÇÃO DO GIT"

if (-not (Test-Winget)) {
    Write-Host "  ${RED}✗${NC} winget não encontrado. Instale o App Installer da Microsoft Store."
    Pause-Prompt; return
}

Run-Step "Instalando / atualizando Git" { winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements 2>&1 }
Write-Host ""

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  ${RED}✗ Git não encontrado após instalação. Reinicie o terminal e tente novamente.${NC}"
    Pause-Prompt; return
}

# Show current config if exists
$curName  = git config --global user.name  2>$null
$curEmail = git config --global user.email 2>$null

if ($curName) {
    Write-Host "  ${GRAY}Configuração atual:${NC}"
    Write-Host "  ${CYAN}Nome: ${WHITE}$curName${NC}"
    Write-Host "  ${CYAN}Email: ${WHITE}$curEmail${NC}"
    Write-Host ""
    if (-not (Confirm-Action "Deseja reconfigurar?")) {
        Pause-Prompt; return
    }
}

# ─── Snapshot dos valores originais (só na primeira vez) ──────────────────────
$snapshot = @{}
foreach ($key in $gitKeys) {
    $existingValue = git config --global $key 2>$null
    $existed = [bool]$existingValue
    $snapshot[$key -replace '\.', '_'] = @{ Existed = $existed; Value = $existingValue }
}
Save-StateOnce "git_setup" $snapshot

Write-Host ""
Write-Host "  ${CYAN}Nome completo (ex: Wellyston Souza): ${NC}" -NoNewline
$name = Read-Host

Write-Host "  ${CYAN}Email do GitHub: ${NC}" -NoNewline
$email = Read-Host

Write-Host ""
Run-Step "Configurando user.name"        { git config --global user.name  $name }
Run-Step "Configurando user.email"       { git config --global user.email $email }
Run-Step "Branch padrão → main"          { git config --global init.defaultBranch main }
Run-Step "Editor padrão → VS Code"       { git config --global core.editor "code --wait" }
Run-Step "Merge tool → VS Code"          { git config --global merge.tool vscode }
Run-Step "Pull → rebase"                 { git config --global pull.rebase true }
Run-Step "Autocrlf → true (Windows)"     { git config --global core.autocrlf true }
Run-Step "Alias: git lg (log bonito)"    {
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
}

Write-Host ""
Write-Host "  ${GREEN}✓ Git configurado com sucesso!${NC}"
Write-Host "  ${GRAY}Use ${WHITE}git lg${GRAY} para um log colorido e compacto.${NC}"
Write-Host "  ${GRAY}💡 Para desfazer: menu principal → ${WHITE}Reverter Alterações${GRAY}.${NC}"
Pause-Prompt
