Function Get-GPONetworkShares {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for Network Shares being created on hosts.
    # Level 3: TODO
    # Level 2: All Network Shares.
    # Level 1: All Network Shares.
    ######

    $GPOisinteresting = $false

	$settingsNetShares = ($polXml.Computer.ExtensionData.Extension.NetworkShares.Netshare | Sort-Object GPOSettingOrder)

    if ($settingsNetShares) {
	    foreach ($setting in $settingsNetShares) {
            if ($level -le 2) {
                $GPOisinteresting = $true
                $output = @{}
                $output.Add("Name", $setting.name)
                $output.Add("Action", $setting.Properties.action)
                $output.Add("PropName", $setting.Properties.name)
                $output.Add("Path", $setting.Properties.path)
                $output.Add("Comment", $setting.Properties.comment)
                Write-NoEmpties -output $output
                "`r`n"
            }
        }
    }

    if ($GPOisinteresting) {
        $Global:GPOsWithIntSettings += 1
    }

}