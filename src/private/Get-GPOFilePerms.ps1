Function Get-GPOFilePerms {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for changes to local file permissions.
    # Level 3: TODO Only show instances where the file is writable by the current user or 'Everyone' or 'Domain Users' or 'Authenticated Users'.
    # Level 2: TODO Also show instances where any user/group other than the usual default Domain/Enterprise Admins has 'Full Control'.
    # Level 1: All file permission changes.
    ######

	$settingsFilePerms = ($polXml.Computer.ExtensionData.Extension.File | Sort-Object GPOSettingOrder)

    if ($settingsFilePerms) {
 	    foreach ($setting in $settingsFilePerms) {
            if ($level -eq 1) {
                $output = @{}
                $output.Add("Path", $setting.Path)
                $output.Add("SDDL", $setting.SecurityDescriptor.SDDL.innertext)
                Write-NoEmpties -output $output
                "`r`n"
            }
        }
    }
}