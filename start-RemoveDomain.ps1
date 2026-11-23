function start-removeDomain
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironmentName
    )

    $functionObject = New-Object PSObject -Property @{
        Domain = $domainName
        RemovedStatus = ""
        ErrorMessage = "None"
    }

    $functionObject2 = New-Object PSObject -Property @{
        LastActionDateTime = ""
        Operation = ""
        Status = ""
    }
    
    out-logfile -string "Entering Start-RemoveDomain"

    #out-logfile -string "Obtain the removal URL."

    #$url = get-MSGraphCall -domainName $domainName -msGraphEnvironmentName $msGraphEnvironmentName -verifyOrRemove "Remove"

    #out-logfile -string ("Graph URL: "+$url)

    $body = @{ disableUserAccounts = $false}

    try {
        $body = $body | ConvertTo-Json -ErrorAction Stop
    }
    catch {
        out-logfile -string $_
        out-logfile -string "Unable to convert body paramters to json." -isError:$true
    }

    out-logfile -string "Post the domain removal to the cloud using the force option."

    try {
        #Invoke-MgGraphRequest -Method POST -Uri $url -Body $body -errorAction STOP
        Invoke-MGForceDomainDelete -domainID $domainName -bodyParameter $body -errorAction STOP
    }
    catch {
        out-logfile -string "Unable to remove the domain."
        out-logfile -string $_.Exception.Message

        $functionObject.removedStatus = "FAILED"
        $functionObject.errorMessage = $_.exception.message

        $global:HTMLDomainRemoved.add($functionObject) 
    }

    out-logfile -string "Forcefully removing a domain is an async operation - test for success of failure."

    $isFailure = $false

    do
    {
        try
        {
            out-logfile -string "Testing for status of domain."

            $test = get-mgDomain -domainID $domainName -errorAction Stop
        }
        catch
        {
            out-logfile -string "Domain was not found on query - domain should be successfully removed."
            out-logfile -string $_.exception.message
        }

        $functionObject2.lastActionDateTime = $test.lastActionDateTime
        $functionObject2.operation = $test.operation
        $functionObject2.status = $test.status

        out-logfile -string $test.status

        if ($functionObject2.status.contains("Failed"))
        {
            out-logfile -string "Domain operation failed."

            $global:htmlDomainRemovedFailedState.add($functionObject)

            $isFailure=$TRUE
        }
        else
        {
            start-sleepProgress -sleepString "Sleeping and retesting domain removal status..." -sleepSeconds 15
        }
    }
    until((!(Get-MgDomain -domainID $domainName)) -or ($isFailure -eq $TRUE))

    if ($isFailure -eq $FALSE)
    {
        $functionObject.removedStatus = "SUCCESS"

        $global:htmlDomainRemoved.add($functionObject)
    }
}

