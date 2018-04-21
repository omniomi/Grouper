Function Write-ColorText {
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Text,
        [Parameter(Mandatory=$false)][ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White', ignorecase=$true)] [string]$Color = $host.ui.RawUI.ForegroundColor
    )
    # does what it says on the tin - writes text in colour.
    $DefForegroundColor = $host.ui.RawUI.ForegroundColor
    $host.ui.RawUI.ForegroundColor = $Color
    Write-Output $Text
    $host.ui.RawUI.ForegroundColor = $DefForegroundColor
}