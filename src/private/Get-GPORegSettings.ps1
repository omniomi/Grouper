Function Get-GPORegSettings {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for "Registry Settings" i.e. a bunch of Windows options that are defined via the registry.
    # Level 3: Shows settings that (if enabled) are going to severely impact the security of a host.
    # Level 2: Shows 'Interesting' settings, regardless of state.
    # Level 1: All Registry Settings.
    ######

    $settingsRegSettings = ($polXml.ExtensionData.Extension.RegistrySetting | Sort-Object GPOSettingOrder)

    if (($settingsRegSettings) -And ($level -eq 1)) {
        foreach ($setting in $settingsRegSettings) {
            $output = @{}
            $output.Add("KeyPath", $setting.KeyPath)
            $output.Add("AdmSetting", $setting.AdmSetting)
            $output.Add($setting.Value.Name, $setting.Value.Number)
            Write-NoEmpties -output $output
        }
    }

	$settingsPolicies = ($polXml.ExtensionData.Extension.Policy | Sort-Object GPOSettingOrder)

    if ($settingsPolicies) {

        $intRegPolicies = @(
            "Allow CredSSP authentication",
            "Allow Basic Authentication",
            "Set the default source path for Update-Help",
            "Default Source Path",
            "Allow remote server management through WinRM",
            "Specify intranet Microsoft update service location",
            "Set the intranet update service for detecting updates:",
            "Set the intranet statistics server:",
            "Allow Remote Shell Access",
            "Allow unencrypted traffic",
            "Sign-in last interactive user automatically after a system-initiated restart",
            "Intranet proxy servers for  apps",
            "Type a proxy server IP address for the intranet",
            "Internet proxy servers for apps",
            "Domain Proxies",
            "Restrict Unauthenticated RPC clients",
            "RPC Runtime Unauthenticated Client Restriction to Apply",
            "Enable RPC Endpoint Mapper Client Authentication",
            "Always install with elevated privileges",
            "Specify communities",
            "Communities",
            "Allow non-administrators to install drivers for these device setup classes",
            "Allow Users to install device drivers for these classes:",
            "Add-ons",
            "Add-on Management",
            "Allow background open of web pages",
            "Allow file extensions for OLE embedding",
            "Allow in-place activation of embedded OLE objects",
            "Allow scripts in one-off Outlook forms",
            "Allow storage of user passwords",
            "Allow Trusted Locations not on the computer",
            "Allow Trusted Locations on the network",
            "Apply macro security settings to macros, add-ins and additional actions",
            "Apply macro security settings to macros, add-ins, and SmartTags",
            "Authentication with Exchange Server",
            "Authentication with Exchange Server",
            "Authentication with Exchange Server",
            "Automatically download content for e-mail from people in Safe Senders and Safe Recipients Lists",
            "Block additional file extensions for OLE embedding",
            "Block all unmanaged add-ins",
            "Block application add-ins loading",
            "Block macros from running in Office files from the Internet",
            "Chart Templates Server Location",
            "Configure Add-In Trust Level",
            "Configure SIP security mode",
            "Disable 'Remember password' for Internet e-mail accounts",
            "Disable all application add-ins",
            "Disable user name and password",
            "Disable all trusted locations",
            "Disable Password Caching",
            "Disable e-mail forms from the Full Trust security zone",
            "Disable e-mail forms from the Internet security zone",
            "Disable e-mail forms from the Intranet security zone",
            "Disable e-mail forms running in restricted security level",
            "Disable fully trusted solutions full access to computer",
            "Disable hyperlink warnings",
            "Disable opening forms with managed code from the Internet security zone",
            "Disable VBA for Office applications",
            "Do not allow attachment previewing in Outlook",
            "Do not allow Outlook object model scripts to run for public folders",
            "Do not open files from the Internet zone in Protected View",
            "Do not open files in unsafe locations in Protected View",
            "Do not permit download of content from safe zones",
            "Embedded Files Blocked Extensions",
            "Excel add-in files",
            "File Previewing",
            "Hide warnings about suspicious names in e-mail addresses",
            "Include Internet in Safe Zones for Automatic Picture Download",
            "Include Intranet in Safe Zones for Automatic Picture Download",
            "Junk E-mail protection level",
            "List of managed add-ins",
            "Location of Backup Folder",
            "Local Machine Zone Lockdown Security",
            "Open files on local Intranet UNC in Protected View",
            "Path to DAV server",
            "Personal tempaltes path for Excel",
            "Personal templates path for Access",
            "Personal templates path for PowerPoint",
            "Personal templates path for Project",
            "Personal templates path for Publisher",
            "Personal templates path for Visio",
            "Personal templates path for Word",
            "Prevent saving credentials for Basic Authentication policy",
            "Prevent Word and Excel from loading managed code extensions",
            "Protection From Zone Elevation",
            "Require that application add-ins are signed by Trusted Publisher",
            "Require that application add-ins are signed by Trusted Publisher",
            "Require logon credentials",
            "Run Programs",
            "Scan encrypted macros in Excel Open XML workbooks",
            "Scan encrypted macros in PowerPoint Open XML presentations",
            "Scan encrypted macros in Word Open XML documents",
            "Security setting for macros",
            "Security setting for macros",
            "Specify server",
            "Start-up",
            "Templates",
            "Tools",
            "Trusted Domain List",
            "Trusted Location #1",
            "Trusted Location #10",
            "Trusted Location #11",
            "Trusted Location #12",
            "Trusted Location #13",
            "Trusted Location #14",
            "Trusted Location #15",
            "Trusted Location #16",
            "Trusted Location #17",
            "Trusted Location #18",
            "Trusted Location #19",
            "Trusted Location #2",
            "Trusted Location #20",
            "Trusted Location #3",
            "Trusted Location #4",
            "Trusted Location #5",
            "Trusted Location #6",
            "Trusted Location #7",
            "Trusted Location #8",
            "Trusted Location #9",
            "Turn off Protected View for attachments opened from Outlook",
            "Turn off Trusted Documents on the network",
            "Turn off Trusted Documents on the network",
            "Turn off trusted documents",
            "Turn off trusted documents",
            "Unblock automatic download of linked images",
            "User queries path",
            "User templates path",
            "User Templates",
            "User Templates",
            "VBA Macro Notification Settings",
            "VBA Macro Warning Settings",
            "Workgroup templates path"
        )

        $vulnRegPolicies = @(
            "Always install with elevated privileges",
            "Specify communities",
            "Communities",
            "Allow non-administrators to install drivers for these device setup classes",
            "Allow Users to install device drivers for these classes:"
        )

        # I hate this nested looping shit more than anything I've ever written.
        foreach ($setting in $settingsPolicies) {
            if ($true) {
                $output = @{}
                $output.Add("Setting Name", $setting.Name)
                $output.Add("State", $setting.State)
                $output.Add("Supported", $setting.Supported)
                $output.Add("Category", $setting.Category)
                $output.Add("Explain", $setting.Explain)

                if (($level -eq 1) -Or (($level -eq 2) -And ($intRegPolicies -Contains $setting.Name)) -Or (($level -eq 3) -And ($vulnRegPolicies -Contains $setting.Name))) {
                    Write-NoEmpties -output $output

                    foreach ($thing in $setting.EditText) {
                        $output = @{}
                        $output.Add("Name", $thing.Name)
                        $output.Add("Value", $thing.Value)
                        $output.Add("State", $thing.State)
                        Write-NoEmpties -output $output
                    }

                    foreach ($thing in $setting.DropDownList) {
                        $output = @{}
                        $output.Add("Name", $thing.Name)
                        $output.Add("Value", $thing.Value.Name)
                        $output.Add("State", $thing.State)
                        Write-NoEmpties -output $output
                    }

                    foreach ($thing in $setting.ListBox) {
                        $output = @{}
                        $output.Add("Name", $thing.Name)
                        $output.Add("ExplicitValue", $thing.ExplicitValue)
                        $output.Add("State", $thing.State)
                        $output.Add("Additive", $thing.Additive)
                        $output.Add("ValuePrefix", $thing.ValuePrefix)
                        $data = @(foreach ($subthing in $thing.Value) {
                            foreach ($subsubthing in $subthing.Element) {
                                $subsubthing.Data
                            }
                        })
                        $output.Add("Data", $data)
                        Write-NoEmpties -output $output
                    }

                    foreach ($thing in $setting.Checkbox) {
                        $output = @{}
                        $output.Add("Value", $thing.Name)
                        $output.Add("State", $thing.State)
                        Write-NoEmpties -output $output
                    }

                    foreach ($thing in $setting.Numeric) {
                        $output = @{}
                        $output.Add("Name", $thing.Name)
                        $output.Add("Value", $thing.Value)
                        $output.Add("State", $thing.State)
                        Write-NoEmpties -output $output
                    }
                    Write-Output "`r`n"
                }
            }
        }
    }
}