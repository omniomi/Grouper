<#
.SYNOPSIS
    Consumes a Get-GPOReport XML formatted report and outputs potentially vulnerable settings.
.DESCRIPTION
    GPP cpassword decryption function stolen shamelessly from @harmj0y
    Other small snippets and ideas stolen shamelessly from @sysop_host
.EXAMPLE
    So first you need to generate a report on a machine with the Group Policy PS module installed. Do that like this:

    "Get-GPOReport -All -ReportType XML -Path C:\temp\gporeport.xml"

    Then import this module and:

    "Invoke-AuditGPOReport -Path C:\temp\gporeport.xml"

    -showDisabled or else by default we just filter out policy objects that aren't enabled or linked anywhere.

    -Level (1, 2, or 3) - adjusts whether to show everything (1) or only interesting (2) or only definitely vulnerable (3) settings. Defaults to 2.

    -lazyMode (without -Path) will run the initial generation of the GPOReport for you but will need to be running as a domain user on a domain-joined machine.
#>
Function Invoke-AuditGPOReport {
    [cmdletbinding(DefaultParameterSetName='NoArgs')]
    param(
        [Parameter(ParameterSetName='WithFile', Mandatory=$true, HelpMessage="Path to XML GPO report")]
        [Parameter(ParameterSetName='OnlineDomain', Mandatory=$false, HelpMessage="Path to XML GPO report")]
        [ValidateScript({if(Test-Path $_ -PathType 'Leaf'){$true}else{Throw "Invalid path given: $_"}})]
        [ValidateScript({if($_ -Match '\.xml'){$true}else{Throw "Supplied file is not XML: $_"}})]
        [System.IO.FileInfo]$Path,

        [Parameter(ParameterSetName='WithFile', Mandatory=$false, HelpMessage="Toggle filtering GPOs that aren't linked anywhere")]
        [Parameter(ParameterSetName='WithoutFile', Mandatory=$false, HelpMessage="Toggle filtering GPOs that aren't linked anywhere")]
        [Parameter(ParameterSetName='OnlineDomain', Mandatory=$false, HelpMessage="Toggle filtering GPOs that aren't linked anywhere")]
        [switch]$showDisabled,

        [Parameter(ParameterSetName='WithFile', Mandatory=$false, HelpMessage="Set verbosity level (1 = most verbose, 3 = only show things that are definitely bad)")]
        [Parameter(ParameterSetName='WithoutFile', Mandatory=$false, HelpMessage="Set verbosity level (1 = most verbose, 3 = only show things that are definitely bad)")]
        [Parameter(ParameterSetName='OnlineDomain', Mandatory=$false, HelpMessage="Set verbosity level (1 = most verbose, 3 = only show things that are definitely bad)")]
        [ValidateSet(1,2,3)]
        [int]$level = 2,

        [Parameter(ParameterSetName='OnlineDomain', Mandatory=$true, HelpMessage="Perform online checks by actively contacting DCs within the target domain")]
        [switch]$online,

        [Parameter(ParameterSetName='OnlineDomain', Mandatory=$false, HelpMessage="FQDN for the domain to target for online checks")]
        [ValidateNotNullOrEmpty()]
        [string]$domain = $env:UserDomain
    )

    # This sucker actually consumes the file, does the stuff, this is the guy, you know?

    Write-Banner

    if ($PSVersionTable.PSVersion.Major -le 2) {
        Write-ColorText -Color "Red" -Text "[!] Sorry, Grouper is not yet compatible with PowerShell 2.0."
        break
    }

    #check if an xml report is specified, otherwise try to generate the report using Get-GPOReport
    if ($Path -eq $null) {
        $lazyMode = $true
    }

    # couple of counters for the stats at the end
    $Global:unlinkedPols = 0
    $Global:GPOsWithIntSettings = 0
    $Global:GPOsWithVulnSettings = 0
    $Global:displayedPols = 0

    #handle our arguments
    $Global:showDisabled = $false
    if ($showDisabled) {
        $Global:showDisabled = $true
    }

    # quick and dirty check to make sure that if the user said to do 'online' checks that we can actually reach the domain.
    $Global:onlineChecks = $false
    if ($online) {
        if ((Test-Path "\\$($domain)\SYSVOL") -eq $true) {
            Write-ColorText -Text "`r`n[i] Confirmed connectivity to AD domain $domain, including online-only checks.`r`n" -Color "Green"
            $Global:onlineChecks = $true
        }
        else {
            Write-ColorText -Text "`r`n[!] Couldn't talk to the domain $domain, falling back to offline mode.`r`n" -Color "Red"
            $Global:onlineChecks = $False
        }
    }

    # if the user set $lazyMode, confirm that the relevant module is available, then generate a gporeport using some default settings.
    if ($lazyMode) {
        $requiredModules = @('GroupPolicy')
        $requiredModules | Import-Module -Verbose:$false -ErrorAction SilentlyContinue
        if (($requiredModules | Get-Module) -eq $null) {
          Write-Warning ('[!] Could not import required modules, confirm the following modules exist on this host: {0}' -f $($requiredModules -join ', '))
          Break
        }

        if ($PSBoundParameters.Domain) {
          $reportPath = "$($pwd)\$($domain)_gporeport.xml"
          Get-GPOReport -All -ReportType xml -Path $reportPath -Domain $domain
        }
        else {
          $reportPath = "$($pwd)\gporeport.xml"
          Get-GPOReport -All -ReportType xml -Path $reportPath
        }
        [xml]$xmldoc = get-content $reportPath
    }
    # and if the user didn't set $lazyMode, get the contents of the report they asked us to look at
    elseif ($Path){
        # get the contents of the report file
        [xml]$xmldoc = get-content $Path
    }

    # get all the GPOs into an array
    $xmlgpos = $xmldoc.report.GPO

    # iterate over them running the selected checks
    foreach ($xmlgpo in $xmlgpos) {
        Invoke-AuditGPO -xmlgpo $xmlgpo -Level $level
    }

    $gpocount = ($xmlgpos.Count, 1 -ne $null)[0]

    Write-Title -Color "Green" -DividerChar "*" -Text "Stats"
    $stats = @()
    $stats += ('Display Level: {0}' -f $level)
    $stats += ('Online Checks Performed: {0}' -f $Global:onlineChecks)
    $stats += ('Displayed GPOs: {0}' -f $Global:displayedPols)
    $stats += ('Unlinked GPOs: {0}' -f $Global:unlinkedPols)
    #$stats += ('Interesting Settings: {0}' -f $Global:GPOsWithIntSettings)
    #$stats += ('Vulnerable Settings: {0}' -f $Global:GPOsWithVulnSettings)
    $stats += ('Total GPOs: {0}' -f $gpocount)
    Write-Output $stats
}