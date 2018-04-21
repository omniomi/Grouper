Function Get-GPOGroups {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for changes made to local groups.
    # Level 3: If Domain Users, Everyone, Authenticated Users get added to 'interesting groups'.
    # Level 2: Show changes to groups that grant meaningful security-relevant access.
    # Level 1: All groups and all changes.
    ######

    $GPOIsInteresting = $false
    $GPOIsVulnerable = $false

    $settingsGroups = ($polXml.ExtensionData.Extension.LocalUsersAndGroups.Group | Sort-Object GPOSettingOrder)

    if ($settingsGroups) {
	    foreach ($setting in $settingsGroups) {
            $settingIsInteresting = $false
            $settingIsVulnerable = $false
            $groupIsInteresting = $false

            # check if the group being modified is one of the high-priv local groups array,
            $groupName = $setting.properties.groupName
            if ($intPrivLocalGroups -Contains $groupName) {
                $GPOIsInteresting = $true
                $settingIsInteresting = $true
                $groupIsInteresting = $true
            }

            # if it's in that array AND a member being modified is a low-priv domain group, we flag the setting as vulnerable.
            $groupmembers = $setting.properties.members.member
            foreach ($groupmember in $groupmembers) {
                $groupMemberName = $groupmember.name
                foreach ($lowPrivDomGroup in $intLowPrivDomGroups) {
                    if (($groupMemberName -match $lowPrivDomGroup) -And ($groupIsInteresting)){
                        $settingIsVulnerable = $true
                        $GPOIsVulnerable = $true
                    }
                }
            }

            if ((($settingIsVulnerable) -And ($level -le 3)) -Or (($settingIsInteresting) -And ($level -le 2)) -Or ($level -eq 1)) {
                $output = @{}
                $output.Add("Name", $setting.Name)
                $output.Add("NewName", $setting.properties.NewName)
                $output.Add("Description", $setting.properties.Description)
                $output.Add("Group Name", $groupName)
                Write-NoEmpties -output $output

                foreach ($member in $setting.properties.members.member) {
                    $output = @{}
                    $output.Add("Name", $member.name)
                    $output.Add("Action", $member.action)
                    $output.Add("UserName", $member.userName)
                    Write-NoEmpties -output $output
                }
                "`r`n"
            }
        }
    }

    if ($GPOisinteresting) {
        $Global:GPOsWithIntSettings += 1
    }
    if ($GPOIsVulnerable) {
        $Global:GPOsWithVulnSettings += 1
    }
}