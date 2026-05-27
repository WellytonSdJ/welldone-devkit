# UI rendering — static numbered menu + frame helpers

# ─── Box characters ───────────────────────────────────────────────────────────
$B = @{
    TL='╔'; TR='╗'; BL='╚'; BR='╝'
    H='═';  V='║'
    TLs='╟'; TRs='╢'; Hs='─'
    ML='╠'; MR='╣'; MT='╦'; MB='╩'; MX='╬'
}

# ─── Visible-length helpers (strip ANSI codes for accurate padding) ───────────
function Get-VisibleLength([string]$s) {
    return ([regex]::Replace($s, '\x1b\[[0-9;]*[a-zA-Z]', '')).Length
}

function Pad-Visible([string]$s, [int]$width) {
    return $s + (' ' * [Math]::Max(0, $width - (Get-VisibleLength $s)))
}

# ─── Full-width bordered row ──────────────────────────────────────────────────
function Draw-FullRow([string]$content) {
    $w     = Get-TermWidth
    $inner = $w - 2
    $padded = Pad-Visible $content $inner
    Write-Host "${PINK}$($B.V)${NC}${padded}${PINK}$($B.V)${NC}"
}

# ─── Header with ASCII logo ───────────────────────────────────────────────────
function Show-Header {
    $w     = Get-TermWidth
    $inner = $w - 2

    $logoPath = Join-Path $PSScriptRoot "..\..\assets\logo.txt"
    $lines = if (Test-Path $logoPath) { Get-Content $logoPath } else { @("  WELLDONE DEVKIT  v2.2") }

    Write-Host "${PINK}$($B.TL)$($B.H * $inner)$($B.TR)${NC}"

    foreach ($line in $lines) {
        $centered = Center-Text $line $inner
        $padded   = Pad-Visible $centered $inner
        Write-Host "${PINK}$($B.V)${NC}${CYAN}${padded}${NC}${PINK}$($B.V)${NC}"
    }
}

# ─── Footer ───────────────────────────────────────────────────────────────────
function Show-Footer([string]$hint) {
    $w     = Get-TermWidth
    $inner = $w - 2

    Write-Host "${PINK}$($B.ML)$($B.H * $inner)$($B.MR)${NC}"
    $hintPad = Pad-Visible "  $hint" $inner
    Write-Host "${PINK}$($B.V)${NC}${hintPad}${PINK}$($B.V)${NC}"
    Write-Host "${PINK}$($B.BL)$($B.H * $inner)$($B.BR)${NC}"
}

# ─── Static numbered menu ─────────────────────────────────────────────────────
function Show-Menu {
    param(
        [hashtable[]]$Items,   # each: @{ Label; Action }
        [string]$Subtitle = ""
    )

    $w     = Get-TermWidth
    $inner = $w - 2

    Clear-Screen
    Show-Header

    # Subtitle bar
    $subPad = Pad-Visible " $Subtitle" $inner
    Write-Host "${PINK}$($B.TLs)${NC}${PURPLE}${DIM}${subPad}${NC}${PINK}$($B.TRs)${NC}"
    Write-Host "${PINK}$($B.ML)$($B.H * $inner)$($B.MR)${NC}"

    # Numbered items
    $num = 1
    foreach ($item in $Items) {
        if ($item.Separator) {
            $sepLine = Pad-Visible "  ${GRAY}$($B.Hs * 28)${NC}" $inner
            Write-Host "${PINK}$($B.V)${NC}${sepLine}${PINK}$($B.V)${NC}"
        } else {
            $numTag  = "${GRAY}[${NC}${CYAN}${num}${NC}${GRAY}]${NC}"
            $label   = " ${WHITE}$($item.Label)${NC}"
            $row     = Pad-Visible "  ${numTag}${label}" $inner
            Write-Host "${PINK}$($B.V)${NC}${row}${PINK}$($B.V)${NC}"
            $num++
        }
    }

    Show-Footer "${GRAY}Digite o número e pressione ${NC}${GREEN}Enter${NC}${GRAY}. [${NC}${RED}0${NC}${GRAY}] Sair${NC}"

    # Input loop
    while ($true) {
        Write-Host ""
        Write-Host -NoNewline "  ${CYAN}›${NC} ${WHITE}Opção: ${NC}"
        $input = Read-Host

        if ($input -eq '0' -or $input -eq 'q' -or $input -eq 'Q') {
            return $null
        }

        $n = 0
        if ([int]::TryParse($input, [ref]$n)) {
            $selectableItems = $Items | Where-Object { -not $_.Separator }
            if ($n -ge 1 -and $n -le $selectableItems.Count) {
                return $selectableItems[$n - 1]
            }
        }

        Write-Host "  ${RED}Opção inválida.${NC} Digite um número entre ${CYAN}1${NC} e ${CYAN}$($selectableItems.Count)${NC} ou ${RED}0${NC} para sair."
    }
}

# ─── Boot animation ───────────────────────────────────────────────────────────
function Show-BootScreen {
    Clear-Screen
    $w = Get-TermWidth

    $logoPath = Join-Path $PSScriptRoot "..\..\assets\logo.txt"
    if (Test-Path $logoPath) {
        $lines = Get-Content $logoPath
        Write-Host ""
        foreach ($line in $lines) {
            Write-Host "$(Center-Text $line $w)" -ForegroundColor Cyan
        }
    }

    Write-Host ""
    $msgs = @(
        @{ text=" Inicializando WellDone DevKit..."; color=$CYAN   }
        @{ text=" Carregando módulos neon...";        color=$PURPLE }
        @{ text=" Sistema pronto.";                   color=$GREEN  }
    )
    foreach ($m in $msgs) {
        Start-Sleep -Milliseconds 420
        Write-Host "  $($m.color)›${NC} ${WHITE}$($m.text)${NC}"
    }
    Start-Sleep -Milliseconds 600
}

# ─── Module section header ────────────────────────────────────────────────────
function Show-ModuleHeader([string]$title) {
    Clear-Screen
    $w = Get-TermWidth
    Write-Host ""
    Write-Host "${PINK}  ╔$('═' * ($w-4))╗${NC}"
    $t = Center-Text "  $title  " ($w - 4)
    Write-Host "${PINK}  ║${NC}${BOLD}${CYAN}$($t.PadRight($w-4).Substring(0,$w-4))${NC}${PINK}║${NC}"
    Write-Host "${PINK}  ╚$('═' * ($w-4))╝${NC}"
    Write-Host ""
}
