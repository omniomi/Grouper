Function Get-GPOIniFiles {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for changes to .INI files.
    # Level 3: TODO
    # Level 2: TODO Need to generate a list of 'interesting' settings.
    # Level 1: All .INI file changes.
    ######

    $settingsIniFiles = ($polXml.ExtensionData.Extension.IniFiles.Ini | Sort-Object GPOSettingOrder)

    if ($settingsIniFiles) {

	    foreach ($setting in $settingsIniFiles) {
            if ($level -eq 1) {
                $output = @{}
                $output.Add("Name", $setting.name)
                $output.Add("Path", $setting.Properties.path)
                $output.Add("Section", $setting.Properties.section)
                $output.Add("Value", $setting.Properties.value)
                $output.Add("Property", $setting.Properties.property)
                $output.Add("Action", $setting.Properties.action)
                Write-NoEmpties -output $output
                "`r`n"
            }
        }
    }
}