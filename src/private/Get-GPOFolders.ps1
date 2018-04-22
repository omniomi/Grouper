Function Get-GPOFolders {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for creation/renaming of local folders
    # Level 3: TODO
    # Level 2: TODO Need to generate a list of 'interesting' settings.
    # Level 1: All folders changes.
    ######

	$settingsFolders = ($polXml.ExtensionData.Extension.Folders.Folder | Sort-Object GPOSettingOrder)

    if ($settingsFolders) {
	    foreach ($setting in $settingsFolders) {
            if ($level -eq 1) {
                $output = @{}
                $output.Add("Name", $setting.name)
                $output.Add("Action", $setting.Properties.action)
                $output.Add("Path", $setting.Properties.path)
                Write-NoEmpties -output $output
                "`r`n"
            }
        }
    }
}