Function Get-GPOUsers {
    [cmdletbinding()]
    # Consumes a single <GPO> object from a Get-GPOReport XML report.

    ######
    # Description: Checks for changes made to local users.
    # Level 3: Only show instances where a password has been set, i.e. GPP Passwords.
    # Level 2: All users and all changes.
    # Level 1: All users and all changes.
    ######

    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    $GPOisinteresting = $false
    $GPOisvulnerable = $false

    # Grab an array of the settings we're interested in from the GPO.
    $settingsUsers = ($polXml.ExtensionData.Extension.LocalUsersAndGroups.User | Sort-Object GPOSettingOrder)

    # Check if there's actually anything in the array.
    if ($settingsUsers) {
        $output = @{}

        # Iterate over array of settings, writing out only those we care about.
        foreach ($setting in $settingsUsers) {

            #see if we have any stored encrypted passwords
            $cpasswordcrypt = $setting.properties.cpassword
            if ($cpasswordcrypt) {
                $GPOisvulnerable = $true

                # decrypt it with harmj0y's function
                $cpasswordclear = Get-DecryptedCpassword -Cpassword $cpasswordcrypt
            }
            #if so, or if we're showing boring, show the rest of the setting
            if (($cpasswordcrypt) -Or ($level -le 2)) {
                $GPOisinteresting = $true
                $output = @{}
                $output.Add("Name", $setting.Name)
                $output.Add("New Name", $setting.properties.NewName)
                $output.Add("Description", $setting.properties.Description)
                $output.Add("changeLogon", $setting.properties.changeLogon)
                $output.Add("noChange", $setting.properties.noChange)
                $output.Add("neverExpires", $setting.properties.neverExpires)
                $output.Add("Disabled", $setting.properties.acctDisabled)
                $output.Add("UserName", $setting.properties.userName)
                $output.Add("Password", $($cpasswordclear, "Password Not Set" -ne $null)[0])
                Write-NoEmpties -output $output
                "`r`n"
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