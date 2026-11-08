function get-graphApplications
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName
    )

    $functionDomainName = "@"+$domainName

    out-logfile -string "Entering Get-GraphApplications"

    $returnApplications = get-mgApplication -all -property AppID,IdentifierUris | where {$_.identifierURis -like "*$domainName*"}

    out-logfile -string ("Count of objects found: "+$returnApplications.count)

    out-logfile -string "Exiting Get-GraphApplications"

    return $returnApplications
}