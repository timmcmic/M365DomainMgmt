function calculate-publicDNSRecordsUSGov
{
    Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $domainName
    )

    $output = @()
    $onMicrosoft = $null
    $onMicrosoftSplit = $null
    $domainSplit = $domainName.split(".")
    $domainAutodiscover = "autodiscover"
    $domainNameAutoDiscover = $domainname.replace($domainSplit[0],$domainAutodiscover)
    $functionMX = "MX"
    $functionRecordName = "@"
    $functionTTL = "3600"
    $functionMXEnd = "mail.protection.office365.us"
    $functionPriority = "0"
    $functionTXT = "TXT"
    $functionSPF = "v=spf1 include:spf.protection.office365.us -all"
    $functionCNAME = "CNAME"
    $functionAutoDiscover = "autodiscover.office365.us"

    out-logfile -string "Entering calculate-publicDNSRecordsUSGov"

    foreach ($entry in $domainSplit)
    {
        out-logfile -string $entry
    }
    out-logfile -string $domainNameAutoDiscover

    out-logfile -string "Government records are based on the onmicrosoft.us domain within the tenant."

    $onMicrosoft = get-OnMicrosoft

    out-logfile -string $onMicrosoft

    $onMicrosoftSplit = $onMicrosoft.split(".")

    foreach ($entry in $onMicrosoftSplit)
    {
        out-logfile -string $entry
    }

    out-logfile -string "Calculate the MX record."

    $functionObject = New-Object PSObject -Property ([ordered]@{
        RecordType = $functionMX
        RecordName = $functionRecordName
        TTL = $functionTTL
        Value = $onMicrosoftSplit[0]+"."+$functionMXEnd
        Priority = $functionPriority
    })

    out-logfile -string $functionObject

    $output += $functionObject

    out-logfile -string "Calculate TXT Record"

    $functionObject = New-Object PSObject -Property ([ordered]@{
        RecordType = $functionTXT
        RecordName = $functionRecordName
        TTL = $functionTTL
        Value = $functionSPF
    })

    out-logfile -string $functionObject

    $output += $functionObject

    out-logfile -string "Calculate autodiscover record"

    $functionObject = New-Object PSObject -Property ([ordered]@{
        RecordType = $functionCNAME
        RecordName = $domainNameAutoDiscover
        TTL = $functionTTL
        Value = $functionAutoDiscover
    })

    out-logfile -string $functionObject

    $output += $functionObject

    try {
        generate-DNSHtml -output $output -domainName $domainName -errorAction STOP
    }
    catch {
        out-logfile -string $_
        out-logfile -string "Unable to generate the DNS HTML record." -isError:$true
    }

    out-logfile -string "Exiting calculate-publicDNSRecordsUSGov"
}