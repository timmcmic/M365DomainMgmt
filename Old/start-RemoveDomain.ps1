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
    
    out-logfile -string "Entering Start-RemoveDomain"

    out-logfile -string "Obtain the removal URL."

    $url = get-MSGraphCall -domainName $domainName -msGraphEnvironmentName $msGraphEnvironmentName -verifyOrRemove "Remove"

    out-logfile -string ("Graph URL: "+$url)

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
        Invoke-MgGraphRequest -Method POST -Uri $url -Body $body -errorAction STOP

        $functionObject.removedStatus = "SUCCESS"

        $global:HTMLDomainRemoved.add($functionObject) 
    }
    catch {
        out-logfile -string "Unable to remove the domain."
        out-logfile -string $_

        $functionObject.removedStatus = "FAILED"
        $functionObject.errorMessage = $_

        $global:HTMLDomainRemoved.add($functionObject) 
    }
}

