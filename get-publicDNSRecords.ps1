function get-publicDNSRecords
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $true)]
        $exportFile,
        [Parameter(Mandatory = $true)]
        $mxRecordType,
        [Parameter(Mandatory = $true)]
        $txtRecordType,
        [Parameter(Mandatory = $true)]
        $soaRecordType,
        [Parameter(Mandatory = $true)]
        $customDNSServer
    )

    out-logfile -string "Entering get-publicDNSRecords"

    $dnsRecords = @()
    $dnsRecordsReturn = @()
    $noDNSServer = "None"

    out-logfile -string "Locate public DNS records associated with the domain using default or custom DNS server."

    if ($customDNSServer -eq $noDNSServer)
    {
        out-logfile -string "Use the default DNS resolver."

        out-logfile -string "Obatin txt records."

        try {
            $dnsRecords += Resolve-DnsName -Name $domainName -type $txtRecordType -ErrorAction Stop
        }
        catch {
            out-logfile -string $_
            out-logfile -string "Unable to obtain DNS records." -isError:$TRUE
        }

        out-logfile -string "Obtain mx records."

        try {
            $dnsRecords += Resolve-DnsName -Name $domainName -type $mxRecordType -ErrorAction Stop
        }
        catch {
            out-logfile -string $_
            out-logfile -string "Unable to obtain DNS records." -isError:$TRUE
        }
    }
    else 
    {
        out-logfile -string "Use the customer DNS resolver."

        out-logfile -string "Obatin txt records."

        try {
            $dnsRecords += Resolve-DnsName -Name $domainName -type $txtRecordType -server $customDNSServer -ErrorAction Stop
        }
        catch {
            out-logfile -string $_
            out-logfile -string "Unable to obtain DNS records." -isError:$TRUE
        }

        out-logfile -string "Obtain mx records."

        try {
            $dnsRecords += Resolve-DnsName -Name $domainName -type $mxRecordType -server $customDNSServer -ErrorAction Stop
        }
        catch {
            out-logfile -string $_
            out-logfile -string "Unable to obtain DNS records." -isError:$TRUE
        }
    }

    out-logfile -string "Public DNS records obtained successfully for both TXT and MX."

    out-logfile -string "Exiting get-publicDNSRecords"
}