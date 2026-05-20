# TUI rendering engine — two-panel layout with full-screen redraw

$Script:MENU_COL_WIDTH = 28   # width of left panel (menu)

# ─── Box characters ───────────────────────────────────────────────────────────
$B = @{
    TL='╔'; TR='╗'; BL='╚'; BR='╝'
    H='═';  V='║'
    TLs='╟'; TRs='╢'; Hs='─'
    ML='╠'; MR='╣'; MT='╦'; MB='╩'; MX='╬'
}

# ─── Draw a horizontal rule of $len chars ────────────────────────────────────
function Draw-HRule([string]$char, [int]$len, [string]$color) {
    Write-Host "${color}$($char * $len)${NC}" -NoNewline
}

# ─── Full-width bordered row ──────────────────────────────────────────────────
function Draw-Row([string]$content, [string]$borderColor, [int]$innerWidth) {
    $padded = $content.PadRight($innerWidth).Substring(0, $innerWidth)
    Write-Host "${borderColor}$($B.V)${NC}${padded}${borderColor}$($B.V)${NC}"
}

# ─── Header with ASCII logo ───────────────────────────────────────────────────
function Show-Header {
    $w = Get-TermWidth
    $inner = $w - 2

    $logoPath = Join-Path $PSScriptRoot "..\..\assets\logo.txt"
    $lines = if (Test-Path $logoPath) { Get-Content $logoPath } else { @("  WELLDONE DEVKIT  v2.0") }

    # Top border
    Write-Host "${PINK}$($B.TL)$(Draw-HRule $B.H ($inner) '' 2>&1)$($B.TR)${NC}"

    foreach ($line in $lines) {
        $centered = Center-Text $line $inner
        $padded = $centered.PadRight($inner).Substring(0, $inner)
        Write-Host "${PINK}$($B.V)${NC}${CYAN}${padded}${NC}${PINK}$($B.V)${NC}"
    }
}

# ─── Draw the divider row between header and body ────────────────────────────
function Show-PanelDivider {
    $w      = Get-TermWidth
    $inner  = $w - 2
    $left   = $Script:MENU_COL_WIDTH
    $right  = $inner - $left - 1

    $line  = "${PINK}$($B.ML)"
    $line += "$($B.H * $left)"
    $line += "$($B.MT)"
    $line += "$($B.H * $right)"
    $line += "$($B.MR)${NC}"
    Write-Host $line
}

# ─── Draw the row that splits menu and description columns ───────────────────
function Show-BodyRow([string]$leftContent, [string]$rightContent) {
    $w     = Get-TermWidth
    $inner = $w - 2
    $left  = $Script:MENU_COL_WIDTH
    $right = $inner - $left - 1

    $lPad = $leftContent.PadRight($left).Substring(0, $left)
    $rPad = $rightContent.PadRight($right).Substring(0, $right)
    Write-Host "${PINK}$($B.V)${NC}${lPad}${PINK}$($B.V)${NC}${rPad}${PINK}$($B.V)${NC}"
}

# ─── Draw the bottom merger row ───────────────────────────────────────────────
function Show-PanelMerger {
    $w     = Get-TermWidth
    $inner = $w - 2
    $left  = $Script:MENU_COL_WIDTH
    $right = $inner - $left - 1

    $line  = "${PINK}$($B.ML)"
    $line += "$($B.H * $left)"
    $line += "$($B.MB)"
    $line += "$($B.H * $right)"
    $line += "$($B.MR)${NC}"
    Write-Host $line
}

# ─── Footer with keybinding hints ────────────────────────────────────────────
function Show-Footer {
    $w     = Get-TermWidth
    $inner = $w - 2

    $hints = "  ${GRAY}[${NC}${CYAN}↑↓${NC}${GRAY}]${NC} Navegar   ${GRAY}[${NC}${GREEN}Enter${NC}${GRAY}]${NC} Selecionar   ${GRAY}[${NC}${RED}Q${NC}${GRAY}]${NC} Sair"
    $visLen = 52   # approximate visible length without ANSI codes
    $padded = $hints + (" " * [Math]::Max(0, $inner - $visLen))

    Write-Host "${PINK}$($B.V)${NC}${padded}${PINK}$($B.V)${NC}"
    Write-Host "${PINK}$($B.BL)$($B.H * $inner)$($B.BR)${NC}"
}

# ─── Render a single menu item row ───────────────────────────────────────────
function Format-MenuItem([string]$label, [int]$idx, [int]$selected) {
    $left = $Script:MENU_COL_WIDTH
    if ($idx -eq $selected) {
        $arrow = "${BG_SELECT}${GREEN}${BOLD} › ${NC}"
        $text  = "${BG_SELECT}${WHITE}${BOLD}$label${NC}"
        $pad   = " " * [Math]::Max(0, $left - 3 - $label.Length - 1)
        return "${arrow}${text}${BG_SELECT}${pad}${NC}"
    } else {
        return "${GRAY}   $label${NC}"
    }
}

# ─── Render description lines wrapped to right-panel width ───────────────────
function Format-DescLines([string[]]$lines, [int]$rightWidth) {
    $result = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $lines) {
        if ($line.Length -eq 0) { $result.Add(""); continue }
        $words = $line -split ' '
        $current = ""
        foreach ($w in $words) {
            if (($current.Length + $w.Length + 1) -le ($rightWidth - 2)) {
                $current += if ($current) { " $w" } else { $w }
            } else {
                if ($current) { $result.Add($current) }
                $current = $w
            }
        }
        if ($current) { $result.Add($current) }
    }
    return $result
}

# ─── Main interactive menu ────────────────────────────────────────────────────
function Show-Menu {
    param(
        [string[]]$Items,
        [hashtable[]]$Descriptions,
        [string]$Subtitle = ""
    )

    $w        = Get-TermWidth
    $inner    = $w - 2
    $left     = $Script:MENU_COL_WIDTH
    $right    = $inner - $left - 1
    $selected = 0
    $count    = $Items.Count

    Hide-Cursor

    try {
        while ($true) {
            Clear-Screen

            Show-Header

            # Subtitle bar
            $sub = " $Subtitle"
            $subPad = $sub.PadRight($inner).Substring(0, $inner)
            Write-Host "${PINK}$($B.TLs)${NC}${PURPLE}${DIM}${subPad}${NC}${PINK}$($B.TRs)${NC}"

            Show-PanelDivider

            # Column headers
            $lHeader = " ${BOLD}${CYAN}OPÇÕES${NC}"
            $rHeader = " ${BOLD}${CYAN}DESCRIÇÃO${NC}"
            Show-BodyRow $lHeader $rHeader

            # Thin separator under column headers
            $lSep = "${GRAY}$($B.Hs * $left)${NC}"
            $rSep = "${GRAY}$($B.Hs * $right)${NC}"
            Show-BodyRow $lSep $rSep

            # Build description lines for selected item
            $desc = $Descriptions[$selected]
            $descTitle = " ${BOLD}${PINK}$($desc.Title)${NC}"
            $descRaw   = $desc.Body -split "`n"
            $descLines = [System.Collections.Generic.List[string]]@(Format-DescLines $descRaw ($right))
            $descLines.Insert(0, $descTitle)
            $descLines.Insert(1, "")

            # Render menu rows alongside description
            $totalRows = [Math]::Max($count + 2, $descLines.Count + 2)
            for ($r = 0; $r -lt $totalRows; $r++) {
                # Left: menu item or blank
                if ($r -lt $count) {
                    $itemText = $Items[$r]
                    $lCell = Format-MenuItem $itemText $r $selected
                } else {
                    $lCell = ""
                }

                # Right: description line or blank
                if ($r -lt $descLines.Count) {
                    $dLine = $descLines[$r]
                    $rCell = if ($r -eq 0) { $dLine } else { " ${WHITE}${dLine}${NC}" }
                } else {
                    $rCell = ""
                }

                Show-BodyRow $lCell $rCell
            }

            # Empty spacer row
            Show-BodyRow "" ""
            Show-PanelMerger
            Show-Footer

            # Key input
            $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            $vk  = $key.VirtualKeyCode
            $ch  = $key.Character

            switch ($vk) {
                38 { $selected = ($selected - 1 + $count) % $count }   # Up
                40 { $selected = ($selected + 1) % $count }             # Down
                87 { $selected = ($selected - 1 + $count) % $count }   # W
                83 { $selected = ($selected + 1) % $count }             # S
                13 { Show-Cursor; return $selected }                     # Enter
                81 { Show-Cursor; return -1 }                            # Q
                default {
                    if ($ch -eq 'q' -or $ch -eq 'Q') { Show-Cursor; return -1 }
                }
            }
        }
    } finally {
        Show-Cursor
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
