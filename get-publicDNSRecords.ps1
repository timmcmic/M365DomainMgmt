function get-publicDNSRecords
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $true)]
        $exportFile,
        [Parameter(Mandatory = $true)]
        $dnsType,
        [Parameter(Mandatory = $true)]
        $customDNSServer
    )

    $dnsRecords = @()
    $dnsRecordsReturn = @()
    $functionNoDNSServer = "None"

    out-logfile -string "Entering get-publicDNSRecords"

    out-logfile -string "Capture public DNS records."

    if ($customDNSServer -eq $functionNoDNSServer)
    {
        out-logfile -string "Using the DNS resolver assigned to this machine."

        try {
            $dnsRecords += Resolve-DnsName -name $domainName -type $dnsType -errorAction Stop

            out-logfile -string "Public DNS records captured successfully."
        }
        catch {
            out-logfile -string $_
            out-logfile -string "ERROR:  Public DNS records not captured successfully." -isError:$true
        }
    }
    else 
    {
        out-logfile -string "Using the custom DNS resolver specified."

        try {
            $dnsRecords += Resolve-DnsName -name $domainName -type $dnsType -errorAction Stop -server $customDNSServer

            out-logfile -string "Public DNS records captured successfully."
        }
        catch {
            out-logfile -string $_
            out-logfile -string "ERROR:  Public DNS records not captured successfully." -isError:$true
        }
    }

    out-xmlFile -itemToExport $dnsRecords -itemNameToExport $exportFile
    
    out-logfile -string "Exiting get-publicDNSRecords"

    return $dnsRecordsREturn
}