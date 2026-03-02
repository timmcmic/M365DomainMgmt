function get-DNSVerificationRecords
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
        $txtRecordType
    )

    $dnsRecords = $null
    $dnsRecordsObject=@()

    out-logfile -string "Entering get-DNSVerificationRecords"

    out-logfile -string "Obtaining the M365 DNS verification records."

    try {
        $dnsRecords = @(Get-MgDomainVerificationDnsRecord -DomainID $domainName -errorAction STOP)
        out-logfile -string "M365 DNS verification records obtained successfully."
    }
    catch {
        out-logfile -string $_
        out-logfile -string "ERROR:  Unable to obtain the M365 DNS verification records." -isError:$true
    }

    Out-XMLFile -itemToExport $dnsRecords -itemNameToExport $exportFile.M365DNSRecords

    out-logfile -string "Creating a custom object for the DNS records."

    foreach ($entry in $dnsRecords)
    {
    if ($entry.recordType -eq $txtRecordType)
        {
            $functionObject = New-Object PSObject -Property @{
                RecordType = $entry.recordType
                Value = $entry.AdditionalProperties.text
            }
        }
        elseif ($entry.recordType -eq $mxRecordType)
        {
           $functionObject = New-Object PSObject -Property @{
                RecordType = $entry.recordType
                Value = $entry.AdditionalProperties.mailExchange
            }
        }

        $dnsRecordsObject += $functionObject
    }

    foreach ($object in $dnsRecordsObject)
    {
        out-logfile -string $object.recordType
        out-logfile -string $object.value
    }
    
    out-logfile -string "Exiting get-DNSVerificationRecords"

    return $dnsRecordsObject
}