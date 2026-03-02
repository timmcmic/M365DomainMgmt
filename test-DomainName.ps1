function test-DomainName
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName
    )

    out-logfile -string "Entering test-DomainName"
    
    out-logfile -string "Test to see if domain is present."

    $domain = get-MGDomain -domainid $domainName -errorAction STOP

    out-logfile -string "Exiting test-DomainName"

    return $domain
}