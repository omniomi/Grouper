Function Get-GPOFileUpdate {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for files being copied/updated/whatever.
    # Level 3: TODO Only show instances where the 'fromPath' file is writable by the current user or 'Everyone' or 'Domain Users' or 'Authenticated Users'.
    # Level 2: All File Updates where FromPath is a network share
    # Level 1: All File Updates.
    ######

	$settingsFiles = ($polXml.ExtensionData.Extension.FilesSettings | Sort-Object GPOSettingOrder)

    if ($settingsFiles) {
        $GPOisinteresting = $true
        $GPOisvulnerable = $false
 	    foreach ($setting in $settingsFiles.File) {
            $fromPath = $setting.Properties.fromPath
            $targetPath = $setting.Properties.targetPath
            $output = @{}
            $output.Add("Name", $setting.name)
            $output.Add("Action", $setting.Properties.action)
            $output.Add("fromPath", $fromPath)
            $output.Add("targetPath", $targetPath)
            $settingIsVulnerable = $false

            if ($Global:onlineChecks) {
                if ($fromPath.StartsWith("\\")) {
                    $ACLData = Find-IntACL -Path $fromPath
                    $output.Add("Owner",$ACLData["Owner"])
                    if ($ACLData["Vulnerable"] -eq "True") {
                        $settingIsVulnerable = $true
                        $GPOisvulnerable = $true
                        $output.Add("[!]", "Source file writable by current user!")
                    }
                    $fromPathAccess = $ACLData["Trustees"]
                }
            }

            if (($level -le 2) -Or (($level -le 3) -And ($settingisVulnerable))) {
                Write-NoEmpties -output $output
                ""
                if ($fromPathAccess) {
                    Write-Title -Text "Permissions on source file:" -DividerChar "-"
                    Write-Output $fromPathAccess
                    ""
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