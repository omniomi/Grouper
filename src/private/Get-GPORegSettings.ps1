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

        $intRegPolicies = @()
        $intRegPolicies += "Allow CredSSP authentication"
        $intRegPolicies += "Allow Basic Authentication"
        $intRegPolicies += "Set the default source path for Update-Help"
        $intRegPolicies += "Default Source Path"
        $intRegPolicies += "Allow remote server management through WinRM"
        $intRegPolicies += "Specify intranet Microsoft update service location"
        $intRegPolicies += "Set the intranet update service for detecting updates:"
        $intRegPolicies += "Set the intranet statistics server:"
        $intRegPolicies += "Allow Remote Shell Access"
        $intRegPolicies += "Allow unencrypted traffic"
        $intRegPolicies += "Sign-in last interactive user automatically after a system-initiated restart"
        $intRegPolicies += "Intranet proxy servers for  apps"
        $intRegPolicies += "Type a proxy server IP address for the intranet"
        $intRegPolicies += "Internet proxy servers for apps"
        $intRegPolicies += "Domain Proxies"
        $intRegPolicies += "Restrict Unauthenticated RPC clients"
        $intRegPolicies += "RPC Runtime Unauthenticated Client Restriction to Apply"
        $intRegPolicies += "Enable RPC Endpoint Mapper Client Authentication"
        $intRegPolicies += "Always install with elevated privileges"
        $intRegPolicies += "Specify communities"
        $intRegPolicies += "Communities"
        $intRegPolicies += "Allow non-administrators to install drivers for these device setup classes"
        $intRegPolicies += "Allow Users to install device drivers for these classes:"
        #MS Office settings starts here
        $intRegPolicies += "Add-ons"
        $intRegPolicies += "Add-on Management"
        $intRegPolicies += "Allow background open of web pages"
        $intRegPolicies += "Allow file extensions for OLE embedding"
        $intRegPolicies += "Allow in-place activation of embedded OLE objects"
        $intRegPolicies += "Allow scripts in one-off Outlook forms"
        $intRegPolicies += "Allow storage of user passwords"
        $intRegPolicies += "Allow Trusted Locations not on the computer"
        $intRegPolicies += "Allow Trusted Locations on the network"
        $intRegPolicies += "Apply macro security settings to macros, add-ins and additional actions"
        $intRegPolicies += "Apply macro security settings to macros, add-ins, and SmartTags"
        $intRegPolicies += "Authentication with Exchange Server"
        $intRegPolicies += "Authentication with Exchange Server"
        $intRegPolicies += "Authentication with Exchange Server"
        $intRegPolicies += "Automatically download content for e-mail from people in Safe Senders and Safe Recipients Lists"
        $intRegPolicies += "Block additional file extensions for OLE embedding"
        $intRegPolicies += "Block all unmanaged add-ins"
        $intRegPolicies += "Block application add-ins loading"
        $intRegPolicies += "Block macros from running in Office files from the Internet"
        $intRegPolicies += "Chart Templates Server Location"
        $intRegPolicies += "Configure Add-In Trust Level"
        $intRegPolicies += "Configure SIP security mode"
        $intRegPolicies += "Disable 'Remember password' for Internet e-mail accounts"
        $intRegPolicies += "Disable all application add-ins"
        $intRegPolicies += "Disable user name and password"
        $intRegPolicies += "Disable all trusted locations"
        $intRegPolicies += "Disable Password Caching"
        $intRegPolicies += "Disable e-mail forms from the Full Trust security zone"
        $intRegPolicies += "Disable e-mail forms from the Internet security zone"
        $intRegPolicies += "Disable e-mail forms from the Intranet security zone"
        $intRegPolicies += "Disable e-mail forms running in restricted security level"
        $intRegPolicies += "Disable fully trusted solutions full access to computer"
        $intRegPolicies += "Disable hyperlink warnings"
        $intRegPolicies += "Disable opening forms with managed code from the Internet security zone"
        $intRegPolicies += "Disable VBA for Office applications"
        $intRegPolicies += "Do not allow attachment previewing in Outlook"
        $intRegPolicies += "Do not allow Outlook object model scripts to run for public folders"
        $intRegPolicies += "Do not open files from the Internet zone in Protected View"
        $intRegPolicies += "Do not open files in unsafe locations in Protected View"
        $intRegPolicies += "Do not permit download of content from safe zones"
        $intRegPolicies += "Embedded Files Blocked Extensions"
        $intRegPolicies += "Excel add-in files"
        $intRegPolicies += "File Previewing"
        $intRegPolicies += "Hide warnings about suspicious names in e-mail addresses"
        $intRegPolicies += "Include Internet in Safe Zones for Automatic Picture Download"
        $intRegPolicies += "Include Intranet in Safe Zones for Automatic Picture Download"
        $intRegPolicies += "Junk E-mail protection level"
        $intRegPolicies += "List of managed add-ins"
        $intRegPolicies += "Location of Backup Folder"
        $intRegPolicies += "Local Machine Zone Lockdown Security"
        $intRegPolicies += "Open files on local Intranet UNC in Protected View"
        $intRegPolicies += "Path to DAV server"
        $intRegPolicies += "Personal tempaltes path for Excel"
        $intRegPolicies += "Personal templates path for Access"
        $intRegPolicies += "Personal templates path for PowerPoint"
        $intRegPolicies += "Personal templates path for Project"
        $intRegPolicies += "Personal templates path for Publisher"
        $intRegPolicies += "Personal templates path for Visio"
        $intRegPolicies += "Personal templates path for Word"
        $intRegPolicies += "Prevent saving credentials for Basic Authentication policy"
        $intRegPolicies += "Prevent Word and Excel from loading managed code extensions"
        $intRegPolicies += "Protection From Zone Elevation"
        $intRegPolicies += "Require that application add-ins are signed by Trusted Publisher"
        $intRegPolicies += "Require that application add-ins are signed by Trusted Publisher"
        $intRegPolicies += "Require logon credentials"
        $intRegPolicies += "Run Programs"
        $intRegPolicies += "Scan encrypted macros in Excel Open XML workbooks"
        $intRegPolicies += "Scan encrypted macros in PowerPoint Open XML presentations"
        $intRegPolicies += "Scan encrypted macros in Word Open XML documents"
        $intRegPolicies += "Security setting for macros"
        $intRegPolicies += "Security setting for macros"
        $intRegPolicies += "Specify server"
        $intRegPolicies += "Start-up"
        $intRegPolicies += "Templates"
        $intRegPolicies += "Tools"
        $intRegPolicies += "Trusted Domain List"
        $intRegPolicies += "Trusted Location #1"
        $intRegPolicies += "Trusted Location #10"
        $intRegPolicies += "Trusted Location #11"
        $intRegPolicies += "Trusted Location #12"
        $intRegPolicies += "Trusted Location #13"
        $intRegPolicies += "Trusted Location #14"
        $intRegPolicies += "Trusted Location #15"
        $intRegPolicies += "Trusted Location #16"
        $intRegPolicies += "Trusted Location #17"
        $intRegPolicies += "Trusted Location #18"
        $intRegPolicies += "Trusted Location #19"
        $intRegPolicies += "Trusted Location #2"
        $intRegPolicies += "Trusted Location #20"
        $intRegPolicies += "Trusted Location #3"
        $intRegPolicies += "Trusted Location #4"
        $intRegPolicies += "Trusted Location #5"
        $intRegPolicies += "Trusted Location #6"
        $intRegPolicies += "Trusted Location #7"
        $intRegPolicies += "Trusted Location #8"
        $intRegPolicies += "Trusted Location #9"
        $intRegPolicies += "Turn off Protected View for attachments opened from Outlook"
        $intRegPolicies += "Turn off Trusted Documents on the network"
        $intRegPolicies += "Turn off Trusted Documents on the network"
        $intRegPolicies += "Turn off trusted documents"
        $intRegPolicies += "Turn off trusted documents"
        $intRegPolicies += "Unblock automatic download of linked images"
        $intRegPolicies += "User queries path"
        $intRegPolicies += "User templates path"
        $intRegPolicies += "User Templates"
        $intRegPolicies += "User Templates"
        $intRegPolicies += "VBA Macro Notification Settings"
        $intRegPolicies += "VBA Macro Warning Settings"
        $intRegPolicies += "Workgroup templates path"
        #MS Office Settings End Here

        $vulnRegPolicies = @()
        $vulnRegPolicies += "Always install with elevated privileges"
        $vulnRegPolicies += "Specify communities"
        $vulnRegPolicies += "Communities"
        $vulnRegPolicies += "Allow non-administrators to install drivers for these device setup classes"
        $vulnRegPolicies += "Allow Users to install device drivers for these classes:"

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
                        $data = @()
                        foreach ($subthing in $thing.Value) {
                            foreach ($subsubthing in $subthing.Element) {
                                $data += $subsubthing.Data
                            }
                        }
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