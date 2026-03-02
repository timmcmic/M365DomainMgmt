function get-domainName
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName
    )

    $noDomainName = "None"

    out-logfile -string "Entering get-DomainName"
    
    if ($domainName -eq $noDomainName)
    {
        out-logfile -string "No domain name specified - obtain."
        write-host "Enter domain name for operations:"

        $domainName = Read-Host
    }
    else 
    {
        out-logfile -string "Domain name specified - return."
    }

    out-logfile -string "Exiting get-DomainName"

    return $domainName
}