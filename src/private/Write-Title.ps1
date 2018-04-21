Function Write-Title {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Text,
        [Parameter(Mandatory=$false)][ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White', ignorecase=$true)] [string]$Color = $host.ui.RawUI.ForegroundColor,
        [Parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][string]$DividerChar = "-"
    )
    Write-ColorText -Text $Text -Color $Color
    $divider = $DividerChar * $Text.Length
    Write-ColorText -Text $divider -Color $Color
}