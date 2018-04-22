# --------------------------- Module Variables ----------------------------
#
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='')]
$intPrivLocalGroups = @(
    'Administrators',
    'Backup Operators',
    'Hyper-V Administrators',
    'Power Users',
    'Print Operators',
    'Remote Desktop Users',
    'Remote Management Users'
)

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='')]
$intLowPrivDomGroups = @(
    'Domain Users',
    'Authenticated Users',
    'Everyone'
)

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='')]
$intLowPrivLocalGroups = @(
    'Users',
    'Everyone',
    'Authenticated Users'
)

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='')]
$intLowPrivGroups = @(
    'Domain Users',
    'Authenticated Users',
    'Everyone',
    'Users'
)

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='')]
$intPrivDomGroups = @(
    'Domain Admins',
    'Administrators',
    'DNS Admins',
    'Backup Operators',
    'Enterprise Admins',
    'Schema Admins',
    'Server Operators',
    'Account Operators'
)

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='')]
$intRights = @(
    'SeTrustedCredManAccessPrivilege',
    'SeTcbPrivilege',
    'SeMachineAccountPrivilege',
    'SeBackupPrivilege',
    'SeCreateTokenPrivilege',
    'SeAssignPrimaryTokenPrivilege',
    'SeRestorePrivilege',
    'SeDebugPrivilege',
    'SeTakeOwnershipPrivilege',
    'SeCreateGlobalPrivilege',
    'SeLoadDriverPrivilege',
    'SeRemoteInteractiveLogonRight'
)

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '', Scope='*', Target='')]
$boringTrustees = @(
    'BUILTIN\Administrators',
    'NT AUTHORITY\SYSTEM'
)

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