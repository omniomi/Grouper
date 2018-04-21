Function Get-GPOSecurityOptions {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for potentially vulnerable "Security Options" settings.
    # Level 3: TODO.
    # Level 2: Show everything that matches $intKeyNames or $intSysAccPolName.
    # Level 1: All settings.
    ######

    $GPOisinteresting = $false
	$settingsSecurityOptions = ($polXml.Computer.ExtensionData.Extension.SecurityOptions | Sort-Object GPOSettingOrder)

    if ($settingsSecurityOptions) {
        if ($level -le 2) {
            $intKeyNameBools = @{}
            $intKeyNameBools.Add("MACHINE\System\CurrentControlSet\Control\Lsa\DisableDomainCreds", "false")
            $intKeyNameBools.Add("MACHINE\System\CurrentControlSet\Control\Lsa\EveryoneIncludesAnonymous", "true")
            $intKeyNameBools.Add("MACHINE\System\CurrentControlSet\Control\Lsa\LimitBlankPasswordUse", "false")
            $intKeyNameBools.Add("MACHINE\System\CurrentControlSet\Control\Lsa\NoLMHash", "false")
            $intKeyNameBools.Add("MACHINE\System\CurrentControlSet\Control\Lsa\RestrictAnonymous", "false")
            $intKeyNameBools.Add("MACHINE\System\CurrentControlSet\Control\Lsa\RestrictAnonymousSAM", "false")
            $intKeyNameBools.Add("MACHINE\System\CurrentControlSet\Control\Lsa\SubmitControl", "true")
            $intKeyNameBools.Add("MACHINE\System\CurrentControlSet\Control\Lsa\UseMachineId", "true")
            $intKeyNameBools.Add("MACHINE\System\CurrentControlSet\Control\Print\Providers\LanMan Print Services\Servers\AddPrinterDrivers", "false")

            $intKeyNameLists = @()
            $intKeyNameLists += "MACHINE\System\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedExactPaths\Machine"
            $intKeyNameLists += "MACHINE\System\CurrentControlSet\Control\SecurePipeServers\Winreg\AllowedPaths\Machine"
            $intKeyNameLists += "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\NullSessionPipes"
            $intKeyNameLists += "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\NullSessionShares"
            $intKeyNameLists += "MACHINE\System\CurrentControlSet\Services\LanManServer\Parameters\RestrictNullSessAccess"

            $intSysAccPolBools = @{}
            $intSysAccPolBools.Add("EnableGuestAccount", 1)
            $intSysAccPolBools.Add("EnableAdminAccount", 1)
            $intSysAccPolBools.Add("LSAAnonymousNameLookup", 1)

            $intSysAccPolStrings = @{}
            $intSysAccPolStrings.Add("NewAdministratorName", "")
            $intSysAccPolStrings.Add("NewGuestName", "")

     	    foreach ($setting in $settingsSecurityOptions) {
            #Check if it's a registry based option
                if ($setting.KeyName) {
                    $keyname = $setting.KeyName
                    $output = @{}
                    $values = @{}
                    $foundit = 0
                    if ($foundit -eq 0) {
                        if ($intKeyNameLists -contains $keyname) {
                            $GPOisinteresting = $true
                            $foundit = 1
                            $output.Add("Name", $setting.Display.Name)
                            $output.Add("KeyName", $setting.KeyName)
                            $dispstrings = $setting.Display.DisplayStrings.Value
                            #here we have to iterate over the list of values
                            $i = 0
                            foreach ($dispstring in $dispstrings) {
                                $values.Add("Path/Pipe$i", $dispstring)
                                $i += 1
                            }
                            Write-NoEmpties -output $output
                            Write-NoEmpties -output $values
                            "`r`n"
                        }
                    }
                    if ($foundit -eq 0) {
                        foreach ($intKeyNameBool in $intKeyNamesBools) {
                            if (($keyNameBool.ContainsKey($keyname)) -And ($keyNameBool.ContainsValue($setting.Display.DisplayBoolean))) {
                                $GPOIsInteresting =1
                                $foundit = 1
                                $output.Add("Name", $setting.Display.Name)
                                $output.Add("KeyName", $setting.KeyName)
                                $values.Add("DisplayBoolean", $setting.Display.Displayboolean)
                                Write-NoEmpties -output $output
                                Write-NoEmpties -output $values
                                "`r`n"
                            }
                        }
                    }
                }
                # or a 'system access policy name'
                elseif ($setting.SystemAccessPolicyName) {
                    $output = @{}
                    foreach ($SAP in $intSysAccPolBools) {
                        if (($SAP.ContainsKey($setting.SystemAccessPolicyName)) -And ($SAP.ContainsValue($setting.SettingNumber))) {
                            $output.Add("Name", $setting.SystemAccessPolicyName)
                            $output.Add("SettingNumber",$setting.SettingNumber)
                            $GPOisinteresting = $true
                            Write-NoEmpties -output $output
                            "`r`n"
                        }
                    }
                    foreach ($SAP in $intSysAccPolStrings) {
                        if ($SAP.ContainsKey($setting.SystemAccessPolicyName)) {
                            $output.Add("Name", $setting.SystemAccessPolicyName)
                            $output.Add("SettingString",$setting.SettingString)
                            $GPOisinteresting = $true
                            Write-NoEmpties -output $output
                            "`r`n"
                        }
                    }
                }
            }
        }
    }

    if ($GPOisinteresting) {
        $Global:GPOsWithIntSettings += 1
    }
}