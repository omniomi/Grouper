Function Get-GPOUserRights {
    [cmdletbinding()]

    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for user rights granted to users and groups.
    # Level 3: Only show "Interesting" rights, i.e. those that can be used for local privilege escalation or remote access,
    #             and only if they've been assigned to Domain Users, Authenticated Users, or Everyone.
    # Level 2: Only show "Interesting" rights, i.e. those that can be used for local privilege escalation or remote access.
    # Level 1: All non-default.
    ######

    $GPOIsInteresting = $false
    $GPOIsVulnerable = $false

    $uraSettings = ($polXml.Computer.ExtensionData.Extension.UserRightsAssignment)

    $uraSettings = ($uraSettings | ? {$_}) #Strips null elements from array - nfi why I was getting so many of these.

    if ($uraSettings) {
        foreach ($setting in $uraSettings) {
            $settingIsInteresting = $false
            $settingIsVulnerable = $false
            $rightIsInteresting = $false

            $userRight = $setting.Name

            $members = @(foreach ($member in $setting.Member) {
                ($member.Name.Innertext)
            })

            # if the right being assigned is in our array of interesting rights, the setting is interesting.
            if ($intRights -contains $userRight) {
                $GPOisinteresting = $true
                $settingIsInteresting = $true
                $rightIsInteresting = $true
            }

            # then we construct an array of trustees being granted the right, so we can see if they are in any of our interesting low priv groups.
            if ($rightIsInteresting) {
                foreach ($lowPrivGroup in $intLowPrivGroups) {
                    foreach ($member in $members) {
                        if ($member -match $lowPrivGroup) {
                            $GPOIsVulnerable = $true
                            $settingIsVulnerable = $true
                        }
                    }
                }
            }

            if ((($settingIsVulnerable) -And ($level -le 3)) -Or (($settingIsInteresting) -And ($level -le 2)) -Or ($level -eq 1)) {
                $output = @{}
                $output.Add("Right", $userRight)
                $output.Add("Members", $members -join ',')
                Write-NoEmpties -output $output
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