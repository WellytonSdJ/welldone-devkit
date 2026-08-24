param([string]$Root, [switch]$Revert)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"
. "$Root\scripts\utils\state.ps1"
Init-StateDir $Root

# ═══════════════════════════════════════════════════════════════════════════
#  MODO REVERSÃO
# ═══════════════════════════════════════════════════════════════════════════
if ($Revert) {
    Show-ModuleHeader "REVERTER — SSH MANAGER"
    Write-Host "  ${CYAN}O que esta reversão faz:${NC}"
    Write-Host "  ${GRAY}• Restaura o tipo de inicialização do serviço ssh-agent para o valor de antes${NC}"
    Write-Host "  ${GRAY}• NÃO apaga a chave SSH gerada (arquivo local em ~\.ssh)${NC}"
    Write-Host "  ${GRAY}• NÃO remove a chave do GitHub — isso só pode ser feito lá manualmente${NC}"
    Write-Host ""

    $state = Get-State "ssh_manager"
    if (-not $state) {
        Write-Host "  ${GRAY}Nada para reverter — este módulo ainda não tinha sido configurado.${NC}"
        Write-Host ""
        Pause-Prompt
        return
    }

    if (-not (Get-Command Set-Service -ErrorAction SilentlyContinue) -or -not (Get-Service ssh-agent -ErrorAction SilentlyContinue)) {
        Write-Host "  ${GRAY}Serviço ssh-agent não encontrado — nada a restaurar.${NC}"
        Remove-State "ssh_manager"
        Pause-Prompt
        return
    }

    Run-Step "Restaurando tipo de inicialização do ssh-agent" {
        Set-Service ssh-agent -StartupType $state.StartType -ErrorAction SilentlyContinue
    }

    Remove-State "ssh_manager"
    Write-Host ""
    Write-Host "  ${GREEN}✓ Reversão concluída!${NC}"
    Write-Host "  ${GRAY}Sua chave SSH continua no lugar — só o serviço voltou ao estado anterior.${NC}"
    Write-Host ""
    Pause-Prompt
    return
}

# ═══════════════════════════════════════════════════════════════════════════
#  MODO NORMAL
# ═══════════════════════════════════════════════════════════════════════════
Show-ModuleHeader "GERENCIADOR SSH"

if (-not (Get-Command ssh-keygen -ErrorAction SilentlyContinue)) {
    Write-Host "  ${RED}✗${NC} OpenSSH não encontrado."
    Write-Host "  ${GRAY}Ative em: Configurações → Apps → Recursos Opcionais → Cliente OpenSSH${NC}"
    Pause-Prompt; return
}

$sshDir    = "$env:USERPROFILE\.ssh"
$keyFile   = "$sshDir\id_ed25519"
$pubFile   = "$keyFile.pub"

# Show existing key if any
if (Test-Path $pubFile) {
    Write-Host "  ${GREEN}✓ Chave SSH existente encontrada:${NC}"
    Write-Host ""
    Write-Host "  ${CYAN}Chave pública:${NC}"
    $pub = Get-Content $pubFile
    Write-Host "  ${GRAY}$pub${NC}"
    Write-Host ""
    Write-Host "  ${YELLOW}Copie a chave acima e adicione em:${NC}"
    Write-Host "  ${WHITE}https://github.com/settings/ssh/new${NC}"
    Write-Host ""

    if (-not (Confirm-Action "Deseja gerar uma nova chave (sobrescreve a atual)?")) {
        # offer to copy to clipboard
        if (Confirm-Action "Copiar chave para o clipboard?") {
            $pub | Set-Clipboard
            Write-Host "  ${GREEN}✓ Chave copiada para o clipboard!${NC}"
        }
        Pause-Prompt; return
    }
}

Write-Host "  ${CYAN}Email para a chave SSH (ex: seu@email.com): ${NC}" -NoNewline
$email = Read-Host

if (-not $email) {
    Write-Host "  ${RED}Email não pode ser vazio.${NC}"; Pause-Prompt; return
}

New-Item -ItemType Directory -Force -Path $sshDir | Out-Null

Run-Step "Gerando chave Ed25519" {
    ssh-keygen -t ed25519 -C $email -f $keyFile -N '""' 2>&1
}

# Guarda o tipo de inicialização original do serviço — só na primeira vez.
$svc = Get-Service ssh-agent -ErrorAction SilentlyContinue
if ($svc) {
    Save-StateOnce "ssh_manager" @{ StartType = [string]$svc.StartType }
}

Run-Step "Iniciando ssh-agent" {
    Start-Service ssh-agent -ErrorAction SilentlyContinue
    Set-Service  ssh-agent -StartupType Automatic -ErrorAction SilentlyContinue
}

Run-Step "Adicionando chave ao agente" {
    ssh-add $keyFile 2>&1
}

Write-Host ""
Write-Host "  ${GREEN}✓ Chave SSH gerada!${NC}"
Write-Host ""
Write-Host "  ${CYAN}Sua chave pública:${NC}"
$pub = Get-Content $pubFile
Write-Host "  ${GRAY}$pub${NC}"
Write-Host ""

if (Confirm-Action "Copiar chave para o clipboard?") {
    $pub | Set-Clipboard
    Write-Host "  ${GREEN}✓ Copiado! Cole em: ${WHITE}https://github.com/settings/ssh/new${NC}"
}

Write-Host "  ${GRAY}💡 O tipo de inicialização do serviço ssh-agent pode ser desfeito em: menu principal → ${WHITE}Reverter Alterações${GRAY}.${NC}"
Write-Host "  ${GRAY}   (a chave gerada em si não é apagada por essa opção)${NC}"
Pause-Prompt
