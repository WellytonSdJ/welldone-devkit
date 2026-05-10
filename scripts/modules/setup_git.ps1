param([string]$Root)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"

Show-ModuleHeader "CONFIGURAÇÃO DO GIT"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  ${RED}✗ Git não encontrado. Execute 'Dev Essentials' primeiro.${NC}"
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
Pause-Prompt
