param([string]$Root)
. "$Root\scripts\utils\colors.ps1"
. "$Root\scripts\utils\ansi.ps1"
. "$Root\scripts\utils\helpers.ps1"
. "$Root\scripts\utils\ui.ps1"

Show-ModuleHeader "APPS OPCIONAIS"

$apps = @(
    @{ Id='Opera.OperaGX';                 Name='Opera GX';        Cat='Browser'       }
    @{ Id='Spotify.Spotify';               Name='Spotify';         Cat='Música'        }
    @{ Id='Discord.Discord';               Name='Discord';         Cat='Comunidade'    }
    @{ Id='XP8BT8DW290MPQ';               Name='Microsoft Teams'; Cat='Trabalho'      }
    @{ Id='XPDBVSS44R0L9H';               Name='Notion';          Cat='Produtividade' }
    @{ Id='Valve.Steam';                   Name='Steam';           Cat='Games'         }
    @{ Id='EpicGames.EpicGamesLauncher';   Name='Epic Games';      Cat='Games'         }
)

Write-Host "  ${CYAN}Selecione os apps para instalar:${NC}"
Write-Host "  ${GRAY}(pressione número + Enter para alternar, ou 'a' para todos, 'Enter' para instalar)${NC}"
Write-Host ""

$selected = @($false) * $apps.Count

# Selection loop
while ($true) {
    for ($i = 0; $i -lt $apps.Count; $i++) {
        $check = if ($selected[$i]) { "${GREEN}[✓]${NC}" } else { "${GRAY}[ ]${NC}" }
        $cat   = "${GRAY}($($apps[$i].Cat))${NC}"
        Write-Host "  $check ${WHITE}$($i+1).${NC} $($apps[$i].Name) $cat"
    }
    Write-Host ""
    Write-Host "  ${CYAN}›${NC} ${WHITE}Número, 'a' (todos), ou Enter para instalar: ${NC}" -NoNewline
    $input = Read-Host

    if ($input -eq "") { break }
    if ($input -eq "a" -or $input -eq "A") {
        $selected = @($true) * $apps.Count
        Clear-Host
        Show-ModuleHeader "APPS OPCIONAIS"
        continue
    }
    $n = 0
    if ([int]::TryParse($input, [ref]$n) -and $n -ge 1 -and $n -le $apps.Count) {
        $selected[$n - 1] = -not $selected[$n - 1]
    }
    Clear-Host
    Show-ModuleHeader "APPS OPCIONAIS"
}

$toInstall = @()
for ($i = 0; $i -lt $apps.Count; $i++) {
    if ($selected[$i]) { $toInstall += $apps[$i] }
}

if ($toInstall.Count -eq 0) {
    Write-Host "  ${YELLOW}Nenhum app selecionado.${NC}"
    Pause-Prompt; return
}

Write-Host ""
Write-Host "  ${CYAN}Instalando $($toInstall.Count) app(s)...${NC}"
Write-Host ""

$ok = $true
foreach ($app in $toInstall) {
    if (-not (Install-Package $app.Id $app.Name)) { $ok = $false }
}

Write-Host ""
if ($ok) {
    Write-Host "  ${GREEN}✓ Todos os apps instalados!${NC}"
} else {
    Write-Host "  ${YELLOW}⚠ Concluído com alguns erros.${NC}"
}
Pause-Prompt
