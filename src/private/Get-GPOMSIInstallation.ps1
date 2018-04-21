Function Get-GPOMSIInstallation {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for MSI installers being used to install software.
    # Level 3: TODO Only show instances where the file is writable by the current user or 'Everyone' or 'Domain Users' or 'Authenticated Users'.
    # Level 2: All MSI installations.
    # Level 1: All MSI installations.
    ######

	$MSIInstallation = ($polXml.ExtensionData.Extension.MsiApplication | Sort-Object GPOSettingOrder)

    if ($MSIInstallation) {
        $GPOisinteresting = $true
        $GPOisvulnerable = $false

 	    foreach ($setting in $MSIInstallation) {
            $output = @{}
            $MSIPath = $setting.Path
            $output.Add("Name", $setting.Name)
            $output.Add("Path", $MSIPath)

            if ($Global:onlineChecks) {
                if ($MSIPath.StartsWith("\\")) {
                    $ACLData = Find-IntACL -Path $MSIPath
                    $output.Add("Owner",$ACLData["Owner"])
                    if ($ACLData["Vulnerable"] -eq "True") {
                        $settingIsVulnerable = $true
                        $GPOisvulnerable = $true
                        $output.Add("[!]", "Source file writable by current user!")
                    }
                    $MSIPathAccess = $ACLData["Trustees"]
                }
            }

            if (($level -le 2) -Or (($level -le 3) -And ($settingisVulnerable))) {
                Write-NoEmpties -output $output
                ""
                if ($MSIPathAccess) {
                    Write-Title -Text "Permissions on source file:" -DividerChar "-"
                    Write-Output $MSIPathAccess
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