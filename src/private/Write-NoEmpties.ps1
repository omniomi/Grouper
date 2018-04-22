Function Write-NoEmpties {
    Param (
        $output
    )
    # this function literally just prints hash tables but skips any with an empty value.
    Foreach ($outpair in $output.GetEnumerator()) {
                    if (-Not (("", $null) -Contains $outpair.Value)) {
                        Write-Output ($outpair)
                    }
                }
}