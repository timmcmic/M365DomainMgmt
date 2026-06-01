function get-graphGroups
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName
    )

    out-logfile -string "Entering Get-GraphGroups"

    $functionDomainName = "@"+$domainName

    out-logfile -string "Obtain users via primary SMTP Address..."

    try {
        $returnGroups = @(get-mgGroup -all -filter "proxyaddresses/any(p:endswith(p,'$functionDomainName'))" -ConsistencyLevel eventual -property ID,DisplayName,GroupTypes,OnPremisesSyncEnabled,ProxyAddresses,Mail -errorAction Stop)
    }
    catch {
        out-logfile -string "Error obtaining graph users."
        out-logfile -string $_ -isError:$true
    }

    out-logfile -string ("Count of objects found: "+$returnGroups.count)

    out-logfile -string "Exiting Get-GraphGroups"

    return $returnGroups
}