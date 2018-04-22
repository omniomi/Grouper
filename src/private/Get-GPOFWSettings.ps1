Function Get-GPOFWSettings {
    [cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][System.Xml.XmlElement]$polXML,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    ######
    # Description: Checks for changes to Firewall Rules.
    # Level 3: TODO
    # Level 2: TODO
    # Level 1: Show all Firewall settings
    ######
    if ($level -le 2) {
        if ($polXml.Computer.ExtensionData.Extension.PrivateProfile.EnableFirewall -ne $null) {
            $output = [ordered]@{}
            $output.Add("Firewall Profile","PrivateProfile")
            $output.Add("DefaultInboundAction",$polXml.Computer.ExtensionData.Extension.PrivateProfile.DefaultInboundAction.Value)
            $output.Add("DefaultOutboundAction",$polXml.Computer.ExtensionData.Extension.PrivateProfile.DefaultOutboundAction.Value)
            $output.Add("EnableFirewall",$polXml.Computer.ExtensionData.Extension.PrivateProfile.EnableFirewall.Value)
            Write-NoEmpties -output $output
            ""
        }

        if ($polXml.Computer.ExtensionData.Extension.PublicProfile.EnableFirewall -ne $null) {
            $output = [ordered]@{}
            $output.Add("Firewall Profile","PublicProfile")
            $output.Add("DefaultInboundAction",$polXml.Computer.ExtensionData.Extension.PublicProfile.DefaultInboundAction.Value)
            $output.Add("DefaultOutboundAction",$polXml.Computer.ExtensionData.Extension.PublicProfile.DefaultOutboundAction.Value)
            $output.Add("EnableFirewall",$polXml.Computer.ExtensionData.Extension.PublicProfile.EnableFirewall.Value)
            Write-NoEmpties -output $output
            ""
        }

        if ($polXml.Computer.ExtensionData.Extension.DomainProfile.EnableFirewall -ne $null) {
            $output = [ordered]@{}
            $output.Add("Firewall Profile","DomainProfile")
            $output.Add("DefaultInboundAction",$polXml.Computer.ExtensionData.Extension.DomainProfile.DefaultInboundAction.Value)
            $output.Add("DefaultOutboundAction",$polXml.Computer.ExtensionData.Extension.DomainProfile.DefaultOutboundAction.Value)
            $output.Add("EnableFirewall",$polXml.Computer.ExtensionData.Extension.DomainProfile.EnableFirewall.Value)
            Write-NoEmpties -output $output
            ""
        }

        if ($level -eq 1) {
            $settingsInbound = $polXml.Computer.ExtensionData.Extension.InboundFirewallRules
             $settingsInbound = ($settingsInbound | ? {$_})
            if ($settingsInbound -ne $null) {
                foreach ($setting in $settingsInbound) {
                    $output = [ordered]@{}
                    $output.Add("Inbound Rule Name",$setting.Name)
                    $output.Add("Action",$setting.Action)
                    $output.Add("Dir",$setting.Dir)
                    $output.Add("Profile",$setting.Profile)
                    $output.Add("Lport",$setting.Lport)
                    $output.Add("Protocol",$setting.Protocol)
                    $output.Add("Active",$setting.Active)
                    $output.Add("App",$setting.App)
                    $output.Add("Svc",$setting.Svc)
                    $output.Add("EmbedCtxt",$setting.EmbedCtxt)
                    Write-NoEmpties -output $output
                    ""
                    }
            }

            $settingsOutbound = $polXml.Computer.ExtensionData.Extension.OutboundFirewallRules
            $settingsOutbound = ($settingsOutbound | ? {$_})
            if ($settingsOutbound -ne $null) {
                foreach ($setting in $settingsOutbound) {
                    $output = [ordered]@{}
                    $output.Add("Outbound Rule Name",$setting.Name)
                    $output.Add("Action",$setting.Action)
                    $output.Add("Dir",$setting.Dir)
                    $output.Add("Profile",$setting.Profile)
                    $output.Add("Lport",$setting.Rport)
                    $output.Add("Protocol",$setting.Protocol)
                    $output.Add("Active",$setting.Active)
                    $output.Add("App",$setting.App)
                    $output.Add("Svc",$setting.Svc)
                    $output.Add("EmbedCtxt",$setting.EmbedCtxt)
                    Write-NoEmpties -output $output
                    ""
                }
            }
        }
    }
}