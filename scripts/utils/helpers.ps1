# General-purpose helper functions

function Confirm-Action([string]$prompt = "Continuar?") {
    Write-Host "${BOLD}${CYAN}  ? ${NC}${WHITE}${prompt} ${GRAY}[s/n] ${NC}" -NoNewline
    $r = Read-Host
    return ($r -match '^[sySY]$')
}

function Run-Step {
    param(
        [string]$Label,
        [scriptblock]$Action
    )
    Write-Host "  ${CYAN}›${NC} ${WHITE}${Label}...${NC}" -NoNewline
    try {
        & $Action | Out-Null
        Write-Host " ${GREEN}OK${NC}"
        return $true
    } catch {
        Write-Host " ${RED}FALHOU${NC}"
        Write-Host "    ${GRAY}$($_.Exception.Message)${NC}"
        return $false
    }
}

function Show-Spinner {
    param([string]$Message, [scriptblock]$Action)
    $frames = @('⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏')
    $job = Start-Job -ScriptBlock $Action
    $i = 0
    while ($job.State -eq 'Running') {
        $f = $frames[$i % $frames.Count]
        Write-Host "`r  ${CYAN}${f}${NC} ${WHITE}${Message}${NC}   " -NoNewline
        Start-Sleep -Milliseconds 80
        $i++
    }
    $result = Receive-Job $job -Wait -AutoRemoveJob
    Write-Host "`r  ${GREEN}✓${NC} ${WHITE}${Message}${NC}   "
    return $result
}

function Pause-Prompt {
    Write-Host ""
    Write-Host "  ${GRAY}Pressione qualquer tecla para voltar ao menu...${NC}"
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}

function Test-Winget {
    return (Get-Command winget -ErrorAction SilentlyContinue) -ne $null
}

function Install-Package {
    param([string]$Id, [string]$Name)
    Run-Step "Instalando ${Name}" {
        winget install $Id --accept-source-agreements --accept-package-agreements --silent 2>&1
    }
}

function Center-Text([string]$text, [int]$width) {
    $pad = [Math]::Max(0, [Math]::Floor(($width - $text.Length) / 2))
    return (" " * $pad) + $text
}
