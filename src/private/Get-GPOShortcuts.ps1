Function Get-GPOShortcuts {
    [cmdletbinding()]
    # Consumes a single <GPO> object from a Get-GPOReport XML report.

    ######
    # Description: Checks for changes made to shortcuts or new shortcuts added.
    # Level 3: Only show instances where current user can write to target of shortcut.
    # Level 2: All shortcut settings that reference a network path.
    # Level 1: All shortcut settings.
    ######

    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    # Grab an array of the settings we're interested in from the GPO.
    $settingsShortcuts = ($polXml.ExtensionData.Extension.ShortcutSettings.Shortcut | Sort-Object GPOSettingOrder)
    # Check if there's actually anything in the array.
    if ($settingsShortcuts) {
        $GPOisinteresting = $false
        $GPOisvulnerable = $false
        # Iterate over array of settings, writing out only those we care about.
        foreach ($setting in $settingsShortcuts) {
            $settingisInteresting = $false
            $targetPath = $setting.properties.targetPath
            $output = @{}
            $output.Add("Name", $setting.name)
            $output.Add("Status", $setting.status)
            $output.Add("targetType", $setting.properties.targetType)
            $output.Add("Action", $setting.properties.Action)
            $output.Add("comment", $setting.properties.comment)
            $output.Add("startIn", $setting.properties.startIn)
            $output.Add("arguments", $setting.properties.arguments)
            $output.Add("targetPath", $setting.properties.targetPath)
            $output.Add("iconPath", $setting.properties.iconPath)
            $output.Add("shortcutPath", $setting.properties.shortcutPath)
            if ($Global:onlineChecks) {
                if ($targetPath.StartsWith("\\")) {
                    $settingisInteresting = $true
                    $GPOisinteresting = $true
                    $ACLData = Find-IntACL -Path $targetPath
                    $output.Add("Owner",$ACLData["Owner"])
                    if ($ACLData["Vulnerable"] -eq "True") {
                        $settingIsVulnerable = $true
                        $GPOisvulnerable = $true
                        $output.Add("[!]", "Source file writable by current user!")
                    }
                    $targetPathAccess = $ACLData["Trustees"]
                }
            }

            if (($level -eq 1) -Or (($level -le 2) -And ($settingisInteresting)) -Or (($level -le 3) -And ($settingisVulnerable))) {
                Write-NoEmpties -output $output
                ""
                if ($targetPathAccess) {
                    Write-Title -Text "Permissions on source file:" -DividerChar "-"
                    Write-Output $targetPathAccess
                    "`r`n"
                }
            }
        }
    }

    if ($GPOisinteresting) {
        $Global:GPOsWithIntSettings += 1
    }
    if ($GPOisvulnerable) {
        $Global:GPOsWithVulnSettings += 1
    }
}