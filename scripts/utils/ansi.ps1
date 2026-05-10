# ANSI / console helpers

function Enable-VirtualTerminal {
    if ($env:OS -eq "Windows_NT") {
        $code = @'
using System;
using System.Runtime.InteropServices;
public class Console32 {
    [DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int h);
    [DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m);
    [DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);
}
'@
        try {
            Add-Type -TypeDefinition $code -ErrorAction Stop
            $handle = [Console32]::GetStdHandle(-11)
            $mode = 0
            [Console32]::GetConsoleMode($handle, [ref]$mode) | Out-Null
            [Console32]::SetConsoleMode($handle, $mode -bor 4) | Out-Null
        } catch {}
    }
}

function Move-Cursor($x, $y) { [Console]::SetCursorPosition($x, $y) }
function Hide-Cursor  { Write-Host "`e[?25l" -NoNewline }
function Show-Cursor  { Write-Host "`e[?25h" -NoNewline }
function Clear-Screen { [Console]::Clear() }

function Write-At($x, $y, $text) {
    [Console]::SetCursorPosition($x, $y)
    Write-Host $text -NoNewline
}

function Get-TermWidth  { [Math]::Max(80, [Console]::WindowWidth) }
function Get-TermHeight { [Math]::Max(24, [Console]::WindowHeight) }
