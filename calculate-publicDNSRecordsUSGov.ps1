function calculate-publicDNSRecordsUSGov
{
    Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironmentName,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironments
    )

    switch ($msGraphEnvironmentName) {
        $msGraphEnvironments.msGraphUSGov
        {  
            $functionAutoDiscover = "autodiscover.office365.us"
            $functionSIPTarget = "sipfed.online.gov.skypeforbusiness.us"
        }
        $msGraphEnvironments.msGraphUSGovDOD 
        {  
            $functionAutoDiscover = "autodiscover-dod.office365.us"
            $functionSIPTarget = "sipfed.online.dod.skypeforbusiness.us"
        }
    }

    $output = @()
    $onMicrosoft = $null
    $onMicrosoftSplit = $null
    $domainAutodiscover = "autodiscover"
    $domainNameAutoDiscover = $domainAutodiscover+"."+$domainName
    $enterpriseEnrollment = "EnterpriseEnrollment"
    $enterpriseEnrollmentDomainName = $enterpriseEnrollment+"."+$domainName
    $enterpriseRegistration = "EnterpriseRegistration"
    $enterpriseRegistrationDomainName = $enterpriseRegistration+"."+$domainName
    $functionMX = "MX"
    $functionRecordName = "@"
    $functionTTL = "3600"
    $functionMXEnd = "mail.protection.office365.us"
    $functionPriority = "0"
    $functionTXT = "TXT"
    $functionSPF = "v=spf1 include:spf.protection.office365.us -all"
    $functionCNAME = "CNAME"
    $functionSRV = "SRV"
    $functionSIPService = "_sipfederationtls"
    $functionSIPPort = "5061"
    $functionSIPPriority = "100"
    $functionSIPProtocol = "_tcp"
    $functionSIPWeight = "1"
    $functionEnterpriseEnrollment = "EnterpriseEnrollment-s.manage.microsoft.us"
    $functionEnterpriseRegistration = "EnterpriseRegistration.windows.net"

    out-logfile -string "Entering calculate-publicDNSRecordsUSGov"

    out-logfile -string $domainNameAutoDiscover

    out-logfile -string "Government records are based on the onmicrosoft.us domain within the tenant."

    $onMicrosoft = get-OnMicrosoft -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments

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

    $functionObject = New-Object PSObject -Property ([ordered]@{
        RecordType = $functionSRV
        RecordName = $functionRecordName
        TTL = $functionTTL
        Value = $functionSIPTarget
        Port = $functionSIPPort
        Priority = $functionSIPPriority
        Protocol = $functionSIPProtocol
        Service = $functionSIPService
        Weight = $functionSIPWeight
    })

    out-logfile -string $functionObject

    $output += $functionObject

    out-logfile -string "Calculate enterprise enrollment value."

     $functionObject = New-Object PSObject -Property ([ordered]@{
        RecordType = $functionCNAME
        RecordName = $enterpriseEnrollmentDomainName
        TTL = $functionTTL
        Value = $functionEnterpriseEnrollment
    })

    out-logfile -string $functionObject

    $output += $functionObject

    out-logfile -string "Calculate enterprise registration value."

     $functionObject = New-Object PSObject -Property ([ordered]@{
        RecordType = $functionCNAME
        RecordName = $enterpriseRegistrationDomainName
        TTL = $functionTTL
        Value = $functionEnterpriseRegistration
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