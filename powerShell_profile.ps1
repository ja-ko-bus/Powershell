Set-PSReadLineKeyHandler -Key Tab `
    -BriefDescription ForwardCharAndAcceptNextSuggestionWord `
    -LongDescription "Move cursor one character to the right in the current editing line and accept the next word in suggestion when it's at the end of the current editing 

line" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -lt $line.Length) {
        [Microsoft.PowerShell.PSConsoleReadLine]::ForwardChar($key, $arg)
    } else {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion($key, $arg)
    }
}

$themeDir = "$env:USERPROFILE\Documents\PowerShell\Themes"
$lastThemeFile = "$env:USERPROFILE\.last_theme"

function setTheme {
    param (
        [string]$theme
    )

    $themePath = "$themeDir\$theme.omp.json"

    if (Test-Path $themePath) {
        oh-my-posh init pwsh --config $themePath | Invoke-Expression
        $theme | Out-File -FilePath $lastThemeFile -Encoding utf8
        Write-Host "Switched to theme: $theme" -ForegroundColor Green
    }
    else {
        Write-Host "Theme '$theme' not found!" -ForegroundColor Red
    }
}

function listThemes {
    $themes = Get-ChildItem -Path $themeDir -Filter "*.omp.json" | ForEach-Object { $_.BaseName }
    if ($themes) {
        Write-Host "Available themes:" -ForegroundColor Cyan
        $themes | ForEach-Object { Write-Host " - $_" }
    }
    else {
        Write-Host "No themes found in '$themeDir'!" -ForegroundColor Red
    }
}

if (Test-Path $lastThemeFile) {
    $lastTheme = Get-Content $lastThemeFile -Raw | ForEach-Object { $_.Trim() }
    if ($lastTheme) {
        oh-my-posh init pwsh --config "$themeDir\$lastTheme.omp.json" | Invoke-Expression
        Write-Host "Loaded last theme: $lastTheme" -ForegroundColor Yellow
    }
    else {
        Write-Host "No valid last theme found!" -ForegroundColor Red
    }
} else {
    Write-Host "No last theme found, please set one using 'setTheme'!" -ForegroundColor Red
}
