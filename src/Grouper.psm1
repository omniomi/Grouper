# --------------------------- Module Variables ----------------------------
#
$intPrivLocalGroups = @()
$intPrivLocalGroups += "Administrators"
$intPrivLocalGroups += "Backup Operators"
$intPrivLocalGroups += "Hyper-V Administrators"
$intPrivLocalGroups += "Power Users"
$intPrivLocalGroups += "Print Operators"
$intPrivLocalGroups += "Remote Desktop Users"
$intPrivLocalGroups += "Remote Management Users"

$intLowPrivDomGroups = @()
$intLowPrivDomGroups += "Domain Users"
$intLowPrivDomGroups += "Authenticated Users"
$intLowPrivDomGroups += "Everyone"

$intLowPrivLocalGroups = @()
$intLowPrivLocalGroups += "Users"
$intLowPrivLocalGroups += "Everyone"
$intLowPrivLocalGroups += "Authenticated Users"

$intLowPrivGroups = @()
$intLowPrivGroups += "Domain Users"
$intLowPrivGroups += "Authenticated Users"
$intLowPrivGroups += "Everyone"
$intLowPrivGroups += "Users"

$intPrivDomGroups = @()
$intPrivDomGroups += "Domain Admins"
$intPrivDomGroups += "Administrators"
$intPrivDomGroups += "DNS Admins"
$intPrivDomGroups += "Backup Operators"
$intPrivDomGroups += "Enterprise Admins"
$intPrivDomGroups += "Schema Admins"
$intPrivDomGroups += "Server Operators"
$intPrivDomGroups += "Account Operators"

$intRights = @()
$intRights += "SeTrustedCredManAccessPrivilege"
$intRights += "SeTcbPrivilege"
$intRights += "SeMachineAccountPrivilege"
$intRights += "SeBackupPrivilege"
$intRights += "SeCreateTokenPrivilege"
$intRights += "SeAssignPrimaryTokenPrivilege"
$intRights += "SeRestorePrivilege"
$intRights += "SeDebugPrivilege"
$intRights += "SeTakeOwnershipPrivilege"
$intRights += "SeCreateGlobalPrivilege"
$intRights += "SeLoadDriverPrivilege"
$intRights += "SeRemoteInteractiveLogonRight"

$boringTrustees = @()
$boringTrustees += "BUILTIN\Administrators"
$boringTrustees += "NT AUTHORITY\SYSTEM"

# --------------------------- Load Loose Files ----------------------------
#
$ModuleScriptFiles = @(Get-ChildItem -Path $PSScriptRoot -Filter *.ps1 -Recurse  | Where-Object { $_.Name -notlike "*.ps1xml" } )

foreach ($ScriptFile in $ModuleScriptFiles) {
    try {
       Write-Verbose "Loading script file $($ScriptFile.Name)"
        . $ScriptFile.FullName
    }
    catch {
       Write-Error "Error loading script file $($ScriptFile.FullName)"
    }
}