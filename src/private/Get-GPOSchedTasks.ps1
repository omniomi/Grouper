Function Get-GPOSchedTasks {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for scheduled tasks being configured on a host.
    # Level 3: Only show instances where a password has been set.
    # Level 2: TODO If a password has been set or the thing being run is non-local or there are arguments set.
    # Level 1: All scheduled tasks.
    ######

    $GPOisinteresting = $false
    $GPOisvulnerable = $false

    $tasktypes = @()
    $tasktypes += $polXml.ExtensionData.Extension.ScheduledTasks.Task
    $tasktypes += $polXml.ExtensionData.Extension.ScheduledTasks.ImmediateTask
    $tasktypes += $polXml.ExtensionData.Extension.ScheduledTasks.TaskV2

    $settingsSchedTasks = $tasktypes | Sort-Object GPOSettingOrder

    if ($settingsSchedTasks) {
        foreach ($setting in $settingsSchedTasks) {
            #see if we have any stored encrypted passwords
            $cpasswordcrypt = $setting.properties.cpassword
            if ($cpasswordcrypt) {
                $GPOisvulnerable = $true
                $GPOisinteresting = $true

                # decrypt it with harmj0y's function
                $cpasswordclear = Get-DecryptedCpassword -Cpassword $cpasswordcrypt
            }
            #see if any arguments have been set
            $taskArgs = $setting.Properties.args
            if ($taskArgs) {
                $GPOisinteresting = $true
            }

            #if so, or if we're showing everything, or if there are args and we're at level 2, show the setting.
            if ((($cpasswordcrypt) -And ($level -le 3)) -Or ($level -le 2)) {
                $output = @{}
                $output.Add("Name", $setting.Properties.name)
                $output.Add("runAs", $setting.Properties.runAs)
                $output.Add("Password", $($cpasswordclear, "Password Not Set" -ne $null)[0])
                $output.Add("Action", $setting.Properties.action)
                $output.Add("appName", $setting.Properties.appName)
                $output.Add("args", $setting.Properties.args)
                $output.Add("startIn", $setting.Properties.startIn)
                Write-NoEmpties -output $output

                if ($setting.Properties.Triggers) {
                    foreach ($trigger in $setting.Properties.Triggers) {
                        $output = @{}
                        $output.Add("type", $trigger.Trigger.type)
                        $output.Add("startHour", $trigger.Trigger.startHour)
                        $output.Add("startMinutes", $trigger.Trigger.startMinutes)
                        Write-NoEmpties -output $output
                        "`r`n"
                    }
                }
            }
        }
    }

    if ($GPOisinteresting) {
        $Global:GPOsWithIntSettings += 1
    }

    if ($GPOisvulnerable) {
        $Global:GPOsWithVulnSettings += 1
    }
}