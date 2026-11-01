function test-DNSVerificationRecords
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $m365DNSRecords,
        [Parameter(Mandatory = $true)]
        $publicDNSRecords,
        [Parameter(Mandatory = $true)]
        $mxRecordType,
        [Parameter(Mandatory = $true)]
        $txtRecordType,
        [Parameter(Mandatory = $true)]
        $soaRecordType
    )

    $functionM365Txt = $null
    $functionM365MX = $null
    $functionPublicTxt = @($publicDNSRecords | where-object {$_.RecordType -eq $txtRecordType})
    $functionPublicMX = @($publicDNSRecords | where-object {$_.RecordType -eq $mxRecordType})
    $functionTXTPresent = $false
    $functionMXPresent = $false

    out-logfile -string "Entering test-DNSVerificationRecords"

    out-logfile -string "Extract the M365 verification values."

    foreach ($entry in $m365DNSRecords)
    {
        if ($entry.RecordType -eq $txtRecordType)
        {
            out-logfile -string "M365 text record type processed."
            $functionM365Txt = $entry.value
        }
        elseif ($entry.recordType -eq $mxRecordType)
        {
            out-logfile -string "M365 mx record type processed."
            $functionM365MX = $entry.value
        }
    }

    out-logfile -string ("M365 TXT Record: "+$functionM365Txt)
    out-logfile -string ("M365 MX Record: "+$functionM365mx)

    if ($functionPublicTxt.Count -gt 0)
    {
            out-logfile -string ("Public TXT Record Count: "+$functionPublicTxt.Count.toString())
    }
    else 
    {
        out-logfile -string "No public dns txt records."
    }

    if ($functionPublicMX.Count -gt 0)
    {
        out-logfile -string ("Public MX Record Count: "+$functionPublicMX.Count.toString())
    }
    else 
    {
        out-logfile -string ("No public dns mx records.")
    }

    out-logfile -string "Beginning public DNS text record evaluation."

    if ($functionPublicTxt.Count -gt 0)
    {
        foreach ($txt in $functionPublicTxt)
        {
            out-logfile -string ("Evaluating: "+$txt.value)

            if ($txt.value -eq $functionM365Txt)
            {
                out-logfile -string "Public TXT records matches M365 validation txt record."
                $functionTXTPresent = $true
            }
            else 
            {
                out-logfile -string "Public TXT record does not match M365 validation txt record."
            }
        }
    }
    else 
    {
        out-logfile -string "No TXT records to process."
    }

    if ($functionPublicMX.count -gt 0)
    {
         foreach ($mx in $functionPublicMX)
        {
            out-logfile -string ("Evaluating: "+$mx.value)

            if ($mx.value -eq $functionM365MX)
            {
                out-logfile -string "Public MX records matches M365 validation txt record."
                $functionMXPresent = $true
            }
            else 
            {
                out-logfile -string "Public MX record does not match M365 validation txt record."
            }
        }
    }

    if (($functionMXPresent -eq $FALSE) -and ($functionTXTPresent -eq $FALSE))
    {
        write-host "ERROR:  Microsoft 365 domain validation records not found in public DNS." -ForegroundColor Red
        write-host ""
        write-host "If the domain was just added during this operation please create one of the following records in public DNS:" -ForegroundColor Red

        foreach ($record in $m365DNSRecords)
        {
            write-host ("Record Type: "+$record.RecordType+"  Record Name: @  Record Value: "+$record.value) -ForegroundColor Red
        }
        write-host ""
        write-host "If the DNS records have already been added please verify with public lookup that they can be discovered." -ForegroundColor Red
        write-host ""

        read-host -Prompt "Press any key to continue..."

        out-logfile -string "ERROR:  Microsoft 365 domain validation records not found in public DNS."
        out-logfile -string "If the domain was just added during this operation please create one of the following records in public DNS:"

        foreach ($record in $m365DNSRecords)
        {
            out-logfile -string ("Record Type: "+$record.RecordType+"  Record Name: @  Record Value: "+$record.value)
        }
        out-logfile -string "If the DNS records have already been added please verify with public lookup that they can be discovered."

        out-logfile -string "ERROR: Microsoft 365 domain validation records not found in public DNS" -isError:$true
    }
    elseif (($functionMXPresent -eq $FALSE) -and ($functionTXTPresent -eq $true))
    {
        out-logfile -string "M365 TXT validation record found in public DNS."
    }
    elseif (($functionMXPresent -eq $true) -and ($functionTXTPresent -eq $false))
    {
        out-logfile -string "M365 MX validation record found in public DNS."
    }
        elseif (($functionMXPresent -eq $true) -and ($functionTXTPresent -eq $true))
    {
        out-logfile -string "M365 MX validation record and M365 TXT validation record found in public DNS."
    }

    out-logfile -string "Exiting test-DNSVerificationRecords"
}