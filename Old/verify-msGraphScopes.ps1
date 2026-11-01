function verify-msGraphScopes
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $context,
        [Parameter(Mandatory = $true)]
        $scopes
    )

    $missingScopes = @()

    out-logfile -string "Entering verify-msGraphScopes"

    out-logfile -string "Log all scopes found in the graph context."

    foreach ($test in $context.scopes)
    {
        out-logfile -string $test
    }

    out-logfile -string "Log all scopes required for the specified domain operation."

    foreach ($test in $scopes)
    {
        out-logfile -string $test
    }

    foreach ($test in $scopes)
    {
        if ($context.scopes.contains($test))
        {
            out-logfile -string "Required scopes are present."
            out-logfile -string $test
        }
        else 
        {
            out-logfile -string "Scope missing..."
            $missingScopes += $test
        }
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