# ─── State snapshots — o que torna a reversão possível ────────────────────────
#
# Antes de QUALQUER módulo alterar uma configuração do sistema (perfil do
# PowerShell, Windows Terminal, git config, registro, serviço), ele salva
# aqui o valor ORIGINAL (o que já existia antes do WellDone mexer).
#
# Isso permite reverter cada ação de forma independente, restaurando
# exatamente o que havia antes — e não um "padrão" genérico chutado.
#
# Cada chave vira um arquivo .json em <Root>\.welldone-state\<chave>.json.
# Esses arquivos NÃO fazem parte do projeto (estão no .gitignore) — são
# dados locais da máquina onde o WellDone DevKit rodou.

$Global:WellDoneStateDir = $null

function Init-StateDir([string]$Root) {
    $Global:WellDoneStateDir = Join-Path $Root ".welldone-state"
    if (-not (Test-Path $Global:WellDoneStateDir)) {
        New-Item -ItemType Directory -Path $Global:WellDoneStateDir -Force | Out-Null
    }
}

function Get-StatePath([string]$Key) {
    return (Join-Path $Global:WellDoneStateDir "$Key.json")
}

# Retorna $true se já existe uma snapshot salva para essa chave.
function Test-State([string]$Key) {
    return Test-Path (Get-StatePath $Key)
}

# Lê a snapshot salva (ou $null se nunca foi salva).
function Get-State([string]$Key) {
    $path = Get-StatePath $Key
    if (-not (Test-Path $path)) { return $null }
    try {
        return (Get-Content $path -Raw | ConvertFrom-Json)
    } catch {
        return $null
    }
}

# Salva a snapshot original — mas só na PRIMEIRA vez. Se o módulo já rodou
# antes e já existe uma snapshot, não sobrescreve (senão perderíamos o
# valor "de antes do WellDone" e passaríamos a guardar só o valor anterior
# já modificado por nós mesmos).
function Save-StateOnce([string]$Key, $Value) {
    $path = Get-StatePath $Key
    if (Test-Path $path) { return }
    ($Value | ConvertTo-Json -Depth 10) | Set-Content -Path $path -Encoding UTF8
}

# Remove a snapshot — chamado depois de uma reversão bem-sucedida, para que
# o menu "Reverter Alterações" volte a mostrar "nada para reverter".
function Remove-State([string]$Key) {
    $path = Get-StatePath $Key
    if (Test-Path $path) { Remove-Item $path -Force }
}

# Remove um bloco de texto adicionado anteriormente por nós (marcado com um
# texto âncora exato) de dentro de um arquivo — usado para desfazer trechos
# que o WellDone anexou a perfis/rc files. Retorna $true se algo foi removido.
function Remove-TextBlock([string]$Path, [string]$Block) {
    if (-not (Test-Path $Path)) { return $false }
    $raw = Get-Content $Path -Raw -ErrorAction SilentlyContinue
    if (-not $raw -or -not $raw.Contains($Block)) { return $false }

    # Add-Content grava uma quebra de linha logo depois do bloco — remove ela
    # junto (senão sobra uma linha em branco no lugar), tentando CRLF e LF.
    $updated = $null
    foreach ($suffix in @("`r`n", "`n", "")) {
        if ($raw.Contains($Block + $suffix)) {
            $updated = $raw.Replace($Block + $suffix, "")
            break
        }
    }
    if ($null -eq $updated) { $updated = $raw.Replace($Block, "") }

    # Limita sequências de 3+ quebras de linha a no máximo 2 (uma linha em branco)
    $updated = $updated -replace "(\r?\n){3,}", "`n`n"
    [System.IO.File]::WriteAllText($Path, $updated)
    return $true
}

# Remove uma linha de comentário "âncora" (ex: "# WellDone DevKit — X") mais
# a linha logo em seguida (o conteúdo que ela introduziu). Usado quando o
# valor original não existia antes — não há nada para restaurar, só apagar
# o que o WellDone adicionou. Retorna $true se algo foi removido.
function Remove-CommentedBlock([string]$Path, [string]$Marker) {
    if (-not (Test-Path $Path)) { return $false }
    $raw = Get-Content $Path -Raw -ErrorAction SilentlyContinue
    if (-not $raw -or ($raw -notmatch [regex]::Escape($Marker))) { return $false }
    $pattern = "(?m)\r?\n?" + [regex]::Escape($Marker) + "\r?\n[^\r\n]*(\r?\n)?"
    $updated = [regex]::Replace($raw, $pattern, "")
    [System.IO.File]::WriteAllText($Path, $updated)
    return $true
}

# Restaura uma linha para o texto original salvo, localizando a linha atual
# por regex (ex: a linha que faz "oh-my-posh init ..."). Usado quando a
# configuração JÁ existia antes do WellDone mexer (não foi ele quem criou).
# Retorna $true se algo foi restaurado.
function Restore-Line([string]$Path, [string]$Pattern, [string]$OriginalLine) {
    if (-not (Test-Path $Path)) { return $false }
    $raw = Get-Content $Path -Raw -ErrorAction SilentlyContinue
    if (-not $raw -or ($raw -notmatch $Pattern)) { return $false }
    $safeReplacement = $OriginalLine.Replace('$', '$$')
    $updated = $raw -replace $Pattern, $safeReplacement
    [System.IO.File]::WriteAllText($Path, $updated)
    return $true
}
