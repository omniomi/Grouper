Function Find-IntACL {
    Param (
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Path
    )
    # Consumes a file path, returns a hash table containing the owner, a hash table of trustees, and a value for
    # "Vulnerable" to show if current user can write the target file, determined by attempting to open the target
    # file for writing, then immediately closing it.
    $ACLData = @{}
    try {
        $targetPathACL = Get-ACL $Path -ErrorAction Stop
        $targetPathOwner = $targetPathACL.Owner
        $targetPathAccess = $targetPathACL.Access | Where-Object {-Not ($boringTrustees -Contains $_.IdentityReference)} | select FileSystemRights,AccessControlType,IdentityReference
        $ACLData.Add("Owner", $targetPathOwner)
        $ACLData.Add("Trustees", $targetPathAccess)
        Try {
            [io.file]::OpenWrite($targetPath).close()
            $ACLData.Add("Vulnerable","True")
        }
        Catch {
            $ACLData.Add("Vulnerable","False")
        }
    }
    catch [System.Exception] {
        $ACLData.Add("Vulnerable","Error")
    }
    return $ACLData
}