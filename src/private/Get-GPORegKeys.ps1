Function Get-GPORegKeys {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for registry keys being set that may contain sensitive information.
    # Level 3: Any key that matches '$intKeys'.
    # Level 2: TODO Also show instances containing the strings 'pass', 'pwd', 'cred', or 'vnc'.
    # Level 1: All Registry Keys
    ######

    $GPOisinteresting = $false
    $GPOisvulnerable = $false

	$settingsRegKeys = ($polXml.ExtensionData.Extension.RegistrySettings.Registry | Sort-Object GPOSettingOrder)

    $vulnKeys = @()
    $vulnKeys += "Software\Network Associates\ePolicy Orchestrator"
    $vulnKeys += "SOFTWARE\FileZilla Server"
    $vulnKeys += "SOFTWARE\Wow6432Node\FileZilla Server"
    $vulnKeys += "Software\Wow6432Node\McAfee\DesktopProtection - McAfee VSE"
    $vulnKeys += "Software\McAfee\DesktopProtection - McAfee VSE"
    $vulnKeys += "Software\ORL\WinVNC3"
    $vulnKeys += "Software\ORL\WinVNC3\Default"
    $vulnKeys += "Software\ORL\WinVNC\Default"
    $vulnKeys += "Software\RealVNC\WinVNC4"
    $vulnKeys += "Software\RealVNC\Default"
    $vulnKeys += "Software\TightVNC\Server"
    $vulnKeys += "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

    $intWords = @()
    $intWords += "vnc"
    $intWords += "vpn"
    $intWords += "pwd"
    $intWords += "cred"
    $intWords += "key"
    $intWords += "pass"


    if ($settingsRegKeys) {
        foreach ($setting in $settingsRegKeys) {
            $settingkey = $setting.Properties.key
            $settingisInteresting = $false
            $settingIsVulnerable = $false

            if ($vulnKeys -Contains $settingkey) {
                $GPOisvulnerable = $true
                $settingIsVulnerable = $true
            }

            foreach ($intWord in $intWords) {
                # if either key or value include our interesting words as a substring, mark the setting as interesting
                if (($settingkey -match $intWord) -Or ($settingValue -match $intWord)) {
                    $GPOisinteresting = $true
                    $settingisInteresting = $true
                }
            }

            # if setting matches any of our criteria for printing (combined interest level + output level)
            if ((($settingisVulnerable) -And ($level -le 3)) -Or (($settingisInteresting) -And ($level -le 2)) -Or ($level -eq 1)) {
                $output = @{}
                $output.Add("Key", $settingkey)
                $output.Add("Action", $setting.Properties.action)
                $output.Add("Hive", $setting.Properties.hive)
                $output.Add("Name", $setting.Properties.name)
                $output.Add("Value", $setting.Properties.value)
                Write-NoEmpties -output $output
                "`r`n"
            }
        }
    }

    # update the global counters
    if ($GPOisivulnerable) {
        $Global:GPOsWithVulnSettings += 1
    }

    if ($GPOisinteresting) {
        $Global:GPOsWithIntSettings += 1
    }

}