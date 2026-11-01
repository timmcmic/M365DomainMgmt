function new-msGraphCertificate
{
    Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $msGraphHashTable
    )

    out-logfile -string "Entering new-msGraphCertificate"

    out-logfile -string "Creating certificate authentication to MS Graph."

    try {
        connect-mgGraph -tenantID $msGraphHashTable.msGraphTenantID -Environment $msGraphHashTable.msGraphEnvironmentName -CertificateThumbprint $msGraphHashTable.msGraphCertificateThumbprint -ClientId $msGraphHashTable.msGraphApplicationID -errorAction Stop
        out-logfile -string "Certificate authentication to MS Graph successful."
    }
    catch {
        out-logfile -string $_
        out-logfile -string "Certificate authentication to MS Graph FAILED" -isError:$true
    }

    out-logfile -string "Exiting new-msGraphCertificate"
}