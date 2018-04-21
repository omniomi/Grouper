Function Get-GPOScripts {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for startup/shutdown/logon/logoff scripts.
    # Level 3: TODO Only show instances where the file is writable by the current user or 'Everyone' or 'Domain Users' or 'Authenticated Users'.
    # Level 2: All scripts.
    # Level 1: All scripts.
    ######

	$settingsScripts = ($polXml.ExtensionData.Extension.Script | Sort-Object GPOSettingOrder)

    if ($settingsScripts) {
        $GPOisinteresting = $true
        $GPOisvulnerable = $false

        foreach ($setting in $settingsScripts) {
            $commandPath = $setting.Command
            $output = @{}
            $output.Add("Command", $commandPath)
            $output.Add("Type", $setting.Type)
            $output.Add("Parameters", $setting.Parameters)
            $settingIsVulnerable = $false

            if ($Script:onlineChecks) {
                if ($commandPath.StartsWith("\\")) {
                    $ACLData = Find-IntACL -Path $commandPath
                    $output.Add("Owner",$ACLData["Owner"])
                    if ($ACLData["Vulnerable"] -eq "True") {
                        $settingIsVulnerable = $true
                        $GPOisvulnerable = $true
                        $output.Add("[!]", "Source file writable by current user!")
                    }
                    $commandPathAccess = $ACLData["Trustees"]
                }
            }

            if (($level -le 2) -Or (($level -le 3) -And ($settingisVulnerable))) {
                Write-NoEmpties -output $output
                ""
                if ($commandPathAccess) {
                    Write-Title -Text "Permissions on source file:" -DividerChar "-"
                    Write-Output $commandPathAccess
                    ""
                }
            }
        }
    }

    if ($GPOisinteresting) {
        $Script:GPOsWithIntSettings += 1
    }
    if ($GPOisvulnerable) {
        $Script:GPOsWithVulnSettings += 1
    }

}