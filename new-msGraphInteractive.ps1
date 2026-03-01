function new-msGraphInteractive
{
    Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $msGraphHashTable
    )

    out-logfile -string "Entering new-msGraphInteractive"

    out-logfile -string "Creating interactive authentication to MS Graph."

    try {
        connect-mgGraph -tenantID $msGraphHashTable.msGraphTenantID -Environment $msGraphHashTable.msGraphEnvironmentName -Scopes $msGraphHashTable.msGraphScopes -errorAction Stop
        out-logfile -string "Interactive authentication to MS Graph successful."
    }
    catch {
        out-logfile -string $_
        out-logfile -string "Interactive authentication to MS Graph FAILED" -isError:$true
    }

    out-logfile -string "Exiting new-msGraphInteractive"
}