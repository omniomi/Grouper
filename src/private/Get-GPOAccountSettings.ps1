Function Get-GPOAccountSettings {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for Account Settings.
    # Level 3: TODO
    # Level 2: If it matches our list of interesting settings - undecided if i want to include weak password policy here.
    # Level 1: All Account Settings.
    ######

	$settingsAccount = ($polXml.Computer.ExtensionData.Extension.Account | Sort-Object GPOSettingOrder)

    $GPOisinteresting = $false

    $intAccSettingBools = @{}
    $intAccSettingBools.Add("ClearTextPassword","true")

    if ($settingsAccount) {
	    foreach ($setting in $settingsAccount) {
            $settingName = $setting.Name
            $settingisInteresting = $false

            foreach ($intAccSetting in $intAccSettingBools) {
                if (($intAccSetting.ContainsKey($settingName)) -And ($intAccSetting.containsValue($setting.SettingBoolean))) {
                    $settingisInteresting = $true
                    $GPOisinteresting = $true
                }
            }

            if (($level -eq 1) -Or (($settingisInteresting) -And ($level -le 2))) {
                $output = @{}
                $output.Add("Name", $settingName)
                if ($setting.SettingBoolean) {
                    $output.Add("SettingBoolean", $setting.SettingBoolean)
                }
                if ($setting.SettingNumber) {
                    $output.Add("SettingNumber", $setting.SettingNumber)
                }
                $output.Add("Type", $setting.Type)
                Write-NoEmpties -output $output
                "`r`n"
            }
        }
    }

    # update the global counters
    if ($GPOisinteresting) {
        $Global:GPOsWithIntSettings += 1
    }
}
