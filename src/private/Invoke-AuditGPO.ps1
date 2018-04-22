Function Invoke-AuditGPO {
    [cmdletbinding()]
    # Consumes <GPO> objects from a Get-GPOReport xml report and returns findings based on the $level filter.
    Param (
        [Parameter(Mandatory=$true)][System.Xml.XmlElement]$xmlgpo,
        [Parameter(Mandatory=$true)][ValidateSet(1,2,3)][int]$level
    )

    #check the GPO is even enabled
    $gpoisenabled = $xmlgpo.LinksTo.Enabled
    #and if it's not, increment our count of GPOs that don't do anything
    if (($gpoisenabled -ne "true") -And (!$Script:showdisabled)) {
        $Script:unlinkedPols += 1
        return $null
    }

    #check if it's linked somewhere
    $gpopath = $xmlgpo.LinksTo.SOMName
    #and if it's not, increment our count of GPOs that don't do anything
    if ((-Not $gpopath) -And (!$Script:showdisabled)) {
        $Script:unlinkedPols += 1
        return $null
    }

    # Define settings groups so we can send through both if the same type of policy settings can appear in either.
    $computerSettings = $xmlgpo.Computer
    $userSettings = $xmlgpo.User

    # Build an array of all our Get-GPO* check scriptblocks
    $polchecks = @(
        {Get-GPORegKeys -Level $level -polXML $computerSettings},
        {Get-GPORegKeys -Level $level -polXML $userSettings},
        {Get-GPOUsers -Level $level -polXML $userSettings},
        {Get-GPOUsers -Level $level -polXML $computerSettings},
        {Get-GPOGroups -Level $level -polXML $userSettings},
        {Get-GPOGroups -Level $level -polXML $computerSettings},
        {Get-GPOScripts -Level $level -polXML $userSettings},
        {Get-GPOScripts -Level $level -polXML $computerSettings},
        {Get-GPOFileUpdate -Level $level -polXML $userSettings},
        {Get-GPOFileUpdate -Level $level -polXML $computerSettings},
        {Get-GPOMSIInstallation -Level $level -polXML $userSettings},
        {Get-GPOMSIInstallation -Level $level -polXML $computerSettings},
        {Get-GPOUserRights -Level $level -polXML $xmlgpo},
        {Get-GPOSchedTasks -Level $level -polXML $computerSettings},
        {Get-GPOSchedTasks -Level $level -polXML $userSettings},
        {Get-GPOFolderRedirection -Level $level -polXML $xmlgpo},
        {Get-GPOFilePerms -Level $level -polXML $xmlgpo},
        {Get-GPOSecurityOptions -Level $level -polXML $xmlgpo},
        {Get-GPOAccountSettings -Level $level -polXML $xmlgpo},
        {Get-GPONetworkShares -Level $level -polXml $xmlgpo},
        {Get-GPOFolders -Level $level -polXML $userSettings},
        {Get-GPOFolders -Level $level -polXML $computerSettings},
        {Get-GPORegSettings -Level $level -polXML $computerSettings},
        {Get-GPORegSettings -Level $level -polXML $userSettings},
        {Get-GPOIniFiles -Level $level -polXML $computerSettings},
        {Get-GPOIniFiles -Level $level -polXML $userSettings},
        {Get-GPOEnvVars -Level $level -polXML $computerSettings},
        {Get-GPOEnvVars -Level $level -polXML $userSettings},
        {Get-GPOShortcuts -Level $level -polXml $userSettings},
        {Get-GPOShortcuts -Level $level -polXml $computerSettings},
        {Get-GPOFWSettings -Level $level -polXml $xmlgpo}
    )

    # Write a pretty green header with the report name and some other nice details
    $headers = @(
        {'==============================================================='},
        {'Policy UID: {0}' -f $xmlgpo.Identifier.Identifier.InnerText},
        {'Policy created on: {0:G}' -f ([DateTime]$xmlgpo.CreatedTime)},
        {'Policy last modified: {0:G}' -f ([DateTime]$xmlgpo.ModifiedTime)},
        {'Policy owner: {0}' -f $xmlgpo.SecurityDescriptor.Owner.Name.InnerText},
        {'Linked OU: {0}' -f $gpopath},
        {'Link enabled: {0}' -f $gpoisenabled},
        {'==============================================================='}
    )

    # In each GPO we parse, iterate through the list of checks to see if any of them return anything.
    $headerprinted = $false
    foreach ($polcheck in $polchecks) {
        $finding = & $polcheck # run the check and store the output
        if ($finding) {
            # the first time one of the checks returns something, show the user the header with the policy name and so on
            if (!$headerprinted) {
                # Increment the total counter of displayed policies.
                $Script:displayedPols += 1
                # Write the title of the GPO in nice green text
                Write-ColorText -Color "Green" -Text $xmlgpo.Name
                # Write the headers from above
                foreach ($header in $headers) {
                    & $header
                }

                # Parse and print out the GPO's Permissions
                $GPOPermissions = $xmlgpo.SecurityDescriptor.Permissions.TrusteePermissions
                # an array of permissions that aren't exciting
                $boringPerms = @(
                    "Read",
                    "Apply Group Policy"
                )

                # an array of users who have RW permissions on GPOs by default, so they're boring too.
                $boringTrustees = @(
                    "Domain Admins",
                    "Enterprise Admins",
                    "ENTERPRISE DOMAIN CONTROLLERS",
                    "SYSTEM"
                )

                $permOutput = @{}

                # iterate over each permission entry for the GPO
                foreach ($GPOACE in $GPOPermissions) {
                    $ACEType = $GPOACE.Standard.GPOGroupedAccessEnum # allow v deny
                    $trusteeName = $GPOACE.Trustee.Name.InnerText # who does it apply to
                    $trusteeSID = $GPOACE.Trustee.SID.InnerText # SID of the account/group it applies to
                    $ACEInteresting = $true # ACEs are default interesting unless proven boring.

                    # check if our trustee is a 'boring' default one
                    if ($trusteeName) {
                        foreach ($boringTrustee in $boringTrustees) {
                            if ($trusteeName -match $boringTrustee) {
                                $ACEInteresting = $false
                            }
                        }
                    }
                    # check if our permission is boring
                    if (($boringPerms -Contains $ACEType) -Or ($GPOACE.Type.PermissionType -eq "Deny")){
                        $ACEInteresting = $false
                    }

                    # if it's still interesting,
                    if ($ACEInteresting) {
                        #if we have a valid trustee name, add it to the output
                        if ($trusteeName) {
                            $permOutput.Add("Trustee",$trusteeName)
                        }
                        #if we have a SID, add it to the output
                        elseif ($trusteeSID) {
                            $permOutput.Add("Trustee SID", $trusteeSID)
                        }
                        #add our other stuff to the output
                        $permOutput.Add("Type", $GPOACE.Type.PermissionType)
                        $permOutput.Add("Access", $GPOACE.Standard.GPOGroupedAccessEnum)
                    }
                }
                # then print out the GPO's permissions
                if ($permOutput.Count -gt 0) {
                    Write-Title -DividerChar "#" -Color "Yellow" -Text "GPO Permissions"
                    Write-Output $permOutput "`r`n"
                }

                # then we set $headerprinted to 1 so we don't print it all again
                $headerprinted = 1
           }
            # Then for each actual finding we write the name of the check function that found something.
            $polcheckbits = ($polcheck.ToString()).split(' ')
            $polchecktitle = $polcheckbits[0]

            Switch ($polcheckbits[4])
            {
             '$computerSettings' { $polchecktype = 'Computer Policy'; break }
             '$userSettings' { $polchecktype = 'User Policy'; break }
             '$xmlgpo' { $polchecktype = 'All Policy'; break }
             default {''; break}
            }

            $polchecktitle = "$polchecktitle - $polchecktype"
            Write-Title -DividerChar "#" -Color "Yellow" -Text $polchecktitle
            # Write out the actual finding
            $finding
        }
    }
	[System.GC]::Collect()
}