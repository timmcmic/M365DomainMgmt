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

    out-xmlfile -itemNameToExport $exportFile.PublicDNSRecords -itemToExport $dnsRecords

    out-logfile -string "Creating custom objects for DNS evaluation."

    foreach ($entry in $dnsRecords)
    {
        if ($entry.type -eq $soaRecordType)
        {
            out-logfile -string "Entry is type SOA."

            $functionObject = New-Object PSObject -Property @{
                RecordType = $soaRecordType
                Value = "NotApplicable"
            }
        }
        elseif ($entry.type -eq $txtRecordType)
        {
            out-logfile -string "Entry type is TXT."

            foreach ($value in $entry.strings)
            {
                $functionObject = New-Object PSObject -Property @{
                RecordType = $txtRecordType
                Value = $value
                }
            }
        }
        elseif ($entry.type -eq $mxRecordType)
        {
            out-logfile -string "Entry type is MX."
            
            $functionObject = New-Object PSObject -Property @{
                RecordType = $mxRecordType
                Value = $entry.NameExchange  
            }
        }

        $dnsRecordsReturn += $functionObject
    }

    foreach ($entry in $dnsRecordsReturn)
    {
        out-logfile -string ("Record Type: "+$entry.recordType)
        out-logfile -string ("Value : "+$entry.value)
    }

    out-xmlFile -itemToExport $dnsRecordsReturn -itemNameToExport $exportFile.CalculatedPublicRecords

    out-logfile -string "Exiting get-publicDNSRecords"

    return $dnsRecordsReturn
}