Function Get-GPOEnvVars {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for environment variables being set.
    # Level 3: TODO
    # Level 2: TODO Need to generate a list of 'interesting' settings.
    # Level 1: All environment variables.
    ######

	$settingsEnvVars = ($polXml.ExtensionData.Extension.EnvironmentVariables.EnvironmentVariable | Sort-Object GPOSettingOrder)

    if ($settingsEnvVars) {
	    foreach ($setting in $settingsEnvvars) {
            if ($level -eq 1) {
                $output = @{}
                $output.Add("Name", $setting.name)
                $output.Add("Status", $setting.status)
                $output.Add("Value", $setting.properties.value)
                $output.Add("Action", $setting.properties.action)
                Write-NoEmpties -output $output
                "`r`n"
            }
        }
    }
}