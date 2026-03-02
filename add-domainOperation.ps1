function add-domainOperation
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $true)]
        $exportFile
    )

    $domainInfo = $null
    $addDomain = $false

    out-logfile -string "Entering add-domainOperation"
    
    out-logfile -string "Test to see if domain is present."

    try {
        $domainInfo = test-domainName -domainName $domainName errorAction STOP
        out-logfile -string "The domain has already been added to the tenant - add operation skipped proceeding."
    }
    catch {
        out-logfile -string "The domain has not been added to the tenant - proceeding with testing."
        $addDomain = $true
    }

    out-logfile -string "Exiting add-domainOperation"
}