function calculate-publicDNSRecordsGlobal
{
    Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $domainName
    )

    $output = @()

    $recordIDs = @{}
    $recordIDs['m365MX']="2b672ab0-0bee-476f-b334-be436f2449bd"
    $recordIDs['m365SPF']="62bea837-a0d7-4466-b6d9-ff6bd1db8671"
    $recordIDs['m365AutoDiscover']="eea5ce9e-8deb-4ab7-a114-13ed6215774f"
    $recordIDs['m365SIPSrv']="2f9deed0-42e3-4f6d-ae82-495a7fde4da5"
    $recordIDs['m365SIPCname']="e9046b54-7d0d-422f-9e50-c731b2a8cbd5"
    $recordIDs['m365LyncCNAME']="a2a182ac-0b69-44c3-96c6-5d6bbbe9ee99"
    $recordIDs['m365SipFed']="b457cd8d-e1bb-4ea9-ae65-cb31c551e27a"
    $recordIDs['m365Sharepoint']="d9113a42-7876-4ff7-8bd6-e2596119517d"
    $recordIDs['m365MSOID']="16f3816b-1105-4764-a195-c249aae14401"
    $recordIDs['m365EntReg']="db0cde09-f798-4bd7-bbb2-1d19926ca807"
    $recordIDs['m365EntEnroll']="ef4f8e4c-f124-446d-8301-2586447cff67"

    out-logfile -string "Entering calculate-publicDNSRecordsGlobal"

    out-logfile -string "Capturing dns records for the domain."

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

    
}