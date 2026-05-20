param([string]$Root)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"

Show-ModuleHeader "GERENCIADOR SSH"

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

Pause-Prompt
