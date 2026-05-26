function verify-msGraphScopes
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $context,
        [Parameter(Mandatory = $true)]
        $scope
    )

    $missingScopes = @()

    out-logfile -string "Entering verify-msGraphScopes"

    foreach ($scope in $context.scopes)
    {
        out-logfile -string $scope
    }

    foreach ($test in $scope)
    {
        if ($context.scopes.contains($scope))
    {
        out-logfile -string "Required scopes are present."
    }
    else 
    {
        out-logfile -string "Scope missing..."
        $missingScopes += $test
    }

    if ($missingScopes.count -gt 0)
    {
        foreach ($test in $missingScopes)
        {
            out-logfile -string ("Mandatory graph scope missing: "+$test)
        }

        out-logfile -string "Mandatory graph scopes missing to proceed - review errors above for missing scopes." -isError:$TRUE
    }
    out-logfile -string "Exiting verify-msGraphScopes"
}