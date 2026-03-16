function test-DomainName
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName
    )

    $errorString = "Request_ResourceNotFound"

    out-logfile -string "Entering test-DomainName"
    
    out-logfile -string "Test to see if domain is present."

    try {
        $domain = get-MGDomain -domainid $domainName -errorAction STOP

        out-logfile -string "Successfully captured domain information."
    }
    catch {
        out-logfile -string "Determine if this is a domain not found error - if so proceed."

        if ($error[0].exception.message.contains($errorString))
        {
            out-logfile -string "Domain is not found error."
        }
        else 
        {
            out-logfile -string $_
            out-logfile -string "Unable to obtain domain information error." -isError:$true
        }
    }

    out-logfile -string "Exiting test-DomainName"

    return $domain
}