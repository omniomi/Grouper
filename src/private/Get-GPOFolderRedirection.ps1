Function Get-GPOFolderRedirection {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for user Folder redirections.
    # Level 3: TODO Only show instances where DestPath is writable by the current user or 'Everyone' or 'Domain Users' or 'Authenticated Users'.
    # Level 2: TODO Also show instances where any user/group other than the usual default Domain/Enterprise Admins has 'Full Control'.
    # Level 1: All Folder Redirection.
    ######

	$settingsFolderRedirection = ($polXml.User.ExtensionData.Extension.Folder | Sort-Object GPOSettingOrder)

    if ($settingsFolderRedirection) {
 	    foreach ($setting in $settingsFolderRedirection) {
            if ($level -eq 1) {
                $output = @{}
                $output.Add("DestPath", $setting.Location.DestinationPath)
                $output.Add("Target Group", $setting.Location.SecurityGroup.Name.innertext)
                $output.Add("Target SID", $setting.Location.SecurityGroup.SID.innertext)
                $output.Add("ID", $setting.Id)
                Write-NoEmpties -output $output
                "`r`n"
            }
        }
    }
}