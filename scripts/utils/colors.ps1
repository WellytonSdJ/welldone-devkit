# Neon color palette — ANSI true-color escape sequences
$Global:NC      = "`e[0m"
$Global:BOLD    = "`e[1m"
$Global:DIM     = "`e[2m"
$Global:ITALIC  = "`e[3m"
$Global:BLINK   = "`e[5m"

# Foreground — neon palette
$Global:CYAN    = "`e[38;2;0;234;255m"
$Global:PINK    = "`e[38;2;255;0;200m"
$Global:GREEN   = "`e[38;2;10;255;157m"
$Global:PURPLE  = "`e[38;2;160;0;255m"
$Global:YELLOW  = "`e[38;2;255;210;0m"
$Global:RED     = "`e[38;2;255;0;102m"
$Global:WHITE   = "`e[38;2;230;230;242m"
$Global:GRAY    = "`e[38;2;100;100;130m"
$Global:ORANGE  = "`e[38;2;255;140;0m"

# Background
$Global:BG_DARK      = "`e[48;2;10;8;18m"
$Global:BG_PANEL     = "`e[48;2;18;14;32m"
$Global:BG_SELECT    = "`e[48;2;59;0;110m"
$Global:BG_SUCCESS   = "`e[48;2;0;60;35m"
$Global:BG_ERROR     = "`e[48;2;80;0;20m"
$Global:BG_RESET     = "`e[49m"
