function validate-m365Domain
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $true)]
        $domainIsViral,
        [Parameter(Mandatory = $true)]
        $domainOperation,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironmentName,
        [Parameter(Mandatory = $true)]
        $exportFile
    )

    $graphEnvironmentNameTest = "Global"
    $domainOperationForceTakeover = "ForceTakeover"

    out-logfile -string "Entering validate-m365Domain"
    
    out-logfile "Test and anticipate success of viral domain takeover."

    if (($domainIsViral -eq $TRUE) -and ($msGraphEnvironmentName -ne $graphEnvironmentNameTest))
    {
        write-host "***WARNING***" -ForegroundColor Yellow
        write-host "The domain is unmanaged / viral and you are attempting to validate the domain in a non global / commercial tenant." -ForegroundColor Yellow
        write-host ""
        write-host "The operation will be tried but is expected to fail." -ForegroundColor Yellow
        write-host "If you have access to a commercial / global tenant the most efficient way is to add and remove the domain from this tenant." -ForegroundColor Yellow
        write-host "If you do not have access to a global tenant a support case will be required to assist in domain validation." -ForegroundColor Yellow

        Read-Host -Prompt "Press any key to continue..."

        out-logfile -string "***WARNING***"
        out-logfile -string "The domain is unmanaged / viral and you are attempting to validate the domain in a non global / commercial tenant."
        out-logfile -string "The operation will be tried but is expected to fail."
        out-logfile -string "If you have access to a commercial / global tenant the most efficient way is to add and remove the domain from this tenant."
        out-logfile -string "If you do not have access to a global tenant a support case will be required to assist in domain validation."
    }
    elseif($domainIsViral -eq $TRUE) 
    {
        out-logfile -string "The domain is viral but not being added to a non-global / commercial tenant - proceed as normal."
    }
    else 
    {
        Out-logfile -string "The domain is not viral - proceed as normal."
    }

    if (($domainIsViral -eq $TRUE) -or ($domainOperation -eq $domainOperationForceTakeover))
    {
        out-logfile -string "Using the graph beta endpoint to trigger domain validation due to viral status."

        $graphMethod = "Post"

        $body = @{}

        $body = @{ forceTakeover = $true}

        try {
            $body = $body | ConvertTo-Json -ErrorAction Stop
        }
        catch {
            out-logfile -string $_
            out-logfile -string "Unable to convert body paramters to json." -isError:$true
        }

        out-logfile -string $body

        out-logfile -string "Force takeover body paramters generated - attempt domain takeover."

        $functionURL = get-MSGraphCall -domainName $domainName -msGraphEnvironmentName $msGraphEnvironmentName

        try {
            Invoke-MgGraphRequest -Method $graphMethod -Uri $functionURL -Body $body -ErrorAction Stop
            out-logfile -string "The domain ForceTakeOver operation completed successfully."
        }
        catch {
            out-logfile -string $_
            out-logfile -string 'The domain ForceTakeOver operation FAILED.' -isError:$true
        }
    }
    else 
    {
        out-logfile -string "Using standard endpoint to trigger domain validation."
        try {
            confirm-mgDomain -DomainId $domainName -errorAction Stop
            out-logfile -string "The domain was successfully verified."
        }
        catch {
            out-logfile -string $_
            out-logfile -string "ERROR:  Domain was not successfully verified." -isError:$true
        }
    }

    $functionDomainInfo = Get-DomainName -domainName $domainName

    out-xmlFile -itemToExport $functionDomainInfo -itemNameToExport $exportFile

    out-logfile -string "Exiting validate-m365Domain"

    return $functionDomainInfo
}