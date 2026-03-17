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

    out-logfile -string "Entering calculate-publicDNSRecordsUSGov"

    out-logfile -string "Government records are based on the onmicrosoft.us domain within the tenant."

    $onMicrosoft = get-OnMicrosoft

    out-logfile -string $onMicrosoft

    Read-Host "Test"

    try {
        $records = Get-MgDomainServiceConfigurationRecord -DomainId $domainName -errorAction STOP
    }
    catch {
        out-logfile -string $_
        out-logfile -string "Unable to obtain the DNS records for the domain." -isError:$true
    }

    foreach ($record in $records)
    {
        switch ($record.id) {
            $recordIDs.m365MX 
            {  
                out-logfile -string "MX"
                $functionObject = New-Object PSObject -Property ([ordered]@{
                    RecordType = $record.RecordType
                    RecordName = "@"
                    TTL = $record.TTL
                    Value = $record.additionalProperties.mailExchange
                    Preference = $record.additionalproperties.preference
                })

                out-logfile -string $functionObject

                $output += $functionObject
            }
            $recordIDs.m365SPF
            {  
                out-logfile -string "SPF"
                $functionObject = New-Object PSObject -Property ([ordered]@{
                    RecordType = $record.RecordType
                    RecordName = "@"
                    TTL = $record.TTL
                    Value = $record.additionalProperties.text
                })

                out-logfile -string $functionObject

                $output += $functionObject
            }
            $recordIDs.m365AutoDiscover 
            {  
                out-logfile -string "Autodiscover"

                $functionObject = New-Object PSObject -Property ([ordered]@{
                    RecordType = $record.RecordType
                    RecordName = $record.Label
                    TTL = $record.TTL
                    Value = $record.additionalProperties.canonicalName
                })

                out-logfile -string $functionObject

                $output += $functionObject
            }
            $recordIDs.m365SIPSrv 
            {  
                out-logfile -string "SIP SRV"
                <#
                $functionObject = New-Object PSObject -Property ([ordered]@{
                    RecordType = $record.RecordType
                    RecordName = $record.Label
                    TTL = $record.TTL
                    Value = $record.additionalProperties.nameTarget
                    Port = $record.additionalProperties.port
                    Priority = $record.additionalProperties.priority
                    Protocol = $record.additionalProperties.protocol
                    Service = $record.additionalProperties.service
                    Weight = $record.additionalProperties.weight
                })

                out-logfile -string $functionObject

                $output += $functionObject
                #>
            }
            $recordIDs.m365SIPCname 
            {  
                out-logfile -string "SIP Cname"
                <#
                $functionObject = New-Object PSObject -Property ([ordered]@{
                    RecordType = $record.RecordType
                    RecordName = $record.Label
                    TTL = $record.TTL
                    Value = $record.additionalProperties.canonicalName
                })

                out-logfile -string $functionObject

                $output += $functionObject
                #>
            }
            $recordIDs.m365LyncCNAME 
            {  
                <#
                out-logfile -string "Lync CNAME"
                $functionObject = New-Object PSObject -Property ([ordered]@{
                    RecordType = $record.RecordType
                    RecordName = $record.Label
                    TTL = $record.TTL
                    Value = $record.additionalProperties.canonicalName
                })

                out-logfile -string $functionObject

                $output += $functionObject
                #>
            }
            $recordIDs.m365SipFed 
            {  
                out-logfile -string "Sip Fed"
                $functionObject = New-Object PSObject -Property ([ordered]@{
                    RecordType = $record.RecordType
                    RecordName = $record.Label
                    TTL = $record.TTL
                    Value = $record.additionalProperties.nameTarget
                    Port = $record.additionalProperties.port
                    Priority = $record.additionalProperties.priority
                    Protocol = $record.additionalProperties.protocol
                    Service = $record.additionalProperties.service
                    Weight = $record.additionalProperties.weight
                })

                out-logfile -string $functionObject

                $output += $functionObject
            }
            $recordIDs.m365Sharepoint 
            {  
                out-logfile -string "Sharepoint - NOT USED"
                <#
                $functionObject = New-Object PSObject -Property ([ordered]@{
                    RecordType = $record.RecordType
                    TTL = $record.TTL
                    Value = $record.additionalProperties.canonicalName
                })

                out-logfile -string $functionObject

                $output += $functionObject
                #>
            }
            $recordIDs.m365MSOID 
            {  
                out-logfile -string "NOT USED"

            }
            $recordIDs.m365EntReg 
            {  
                out-logfile -string "Enterprise Registration"
                $functionObject = New-Object PSObject -Property ([ordered]@{
                    RecordType = $record.RecordType
                    RecordName = $record.Label
                    TTL = $record.TTL
                    Value = $record.additionalProperties.canonicalName
                })

                out-logfile -string $functionObject

                $output += $functionObject


            }
            $recordIDs.m365EntEnroll 
            {  
                out-logfile -string "Enterprise Enrollment"
                $functionObject = New-Object PSObject -Property ([ordered]@{
                    RecordType = $record.RecordType
                    RecordName = $record.Label
                    TTL = $record.TTL
                    Value = $record.additionalProperties.canonicalName
                })

                out-logfile -string $functionObject

                $output += $functionObject
            }
            Default {out-logfile -string "Unknown ID - contact author - failure" -isError:$true} 
        }
    }

    <#

    out-logfile -string "Sample DMARC"
    $functionObject = New-Object PSObject -Property ([ordered]@{
        RecordType = "TXT"
        RecordName = "@"
        TTL = "3600"
        Value = "v=DMARC1; p=reject; pct=100; rua=mailto:rua@$domainName; ruf=mailto:ruf@$domainName"
    })

    out-logfile -string $functionObject

    $output += $functionObject

    $domainNameDashes = $domainname.replace(".","-")
    $domainSplit = $domainName.split(".")
    for ($i = 0 ; $i -lt $domainSplit.count - 1 ; $i ++)
    {
        $domainNameNoSpaces = $domainNameNoSpaces + $domainSplit[$i]
    }
    
    out-logfile -string "Sample DKIM"
    $functionObject = New-Object PSObject -Property ([ordered]@{
        RecordType = "CNAME"
        RecordName = "selector1._domainkey"
        TTL = "3600"
        Value = "selector1-$domainNameDashes._domainKey.$domainNameNoSpaces.n-v1.dkim.mail.microsoft"
    })

    out-logfile -string $functionObject

    $output += $functionObject

    out-logfile -string "Sample DKIM"
    $functionObject = New-Object PSObject -Property ([ordered]@{
        RecordType = "CNAME"
        RecordName = "selector2._domainkey"
        TTL = "3600"
        Value = "selector2-$domainNameDashes._domainKey.$domainNameNoSpaces.n-v1.dkim.mail.microsoft"
    })

    out-logfile -string $functionObject

    $output += $functionObject

    #>

    try {
        generate-DNSHtml -output $output -domainName $domainName -errorAction STOP
    }
    catch {
        out-logfile -string $_
        out-logfile -string "Unable to generate the DNS HTML record." -isError:$true
    }

    out-logfile -string "Exiting calculate-publicDNSRecordsUSGov"
}