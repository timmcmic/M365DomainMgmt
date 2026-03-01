function verify-msGraphScopes
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $context,
        [Parameter(Mandatory = $true)]
        $scope
    )

    out-logfile -string "Entering verify-msGraphScopes"

    if ($context.scopes.contains($scope))
    {
        out-logfile -string "Required scopes are present."
    }
    else 
    {
        out-logfile -string "Directory.ReadWrite.All graph scope is required to proceed and not present."
        out-logfile -string "EXCEPTION:  Required graph scope not present." -isError:$true
    }

    out-logfile -string "Exiting verify-msGraphScopes"
}