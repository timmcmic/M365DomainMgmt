function get-graphApplications
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName
    )

    $functionDomainName = "@"+$domainName

    out-logfile -string "Entering Get-GraphApplications"

    try
    {
        $returnApplications = get-mgApplication -all -property DisplayName,ID,AppID,IdentifierUris -errorAction STOP | where {$_.identifierURis -like "*$domainName*"}
    }
    catch
    {
        out-logfile -string $_
        out-logfile -string "ERROR:  Unable to obtain applications via graph." -isError:$TRUE
    }

    out-logfile -string ("Count of objects found: "+$returnApplications.count)

    out-logfile -string "Exiting Get-GraphApplications"

    return $returnApplications
}