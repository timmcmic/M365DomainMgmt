function get-graphUsers
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $false)]
        $getUPN=$FALSE,
        [Parameter(Mandatory = $false)]
        $getPrimarySMTP=$FALSE,
        [Parameter(Mandatory = $false)]
        $getSecondaySMTP=$FALSE
    )

    $functionDomainName = "@"+$domainName


    out-logfile -string "Entering Get-GraphUsers"

    if ($getUPN -eq $TRUE)
    {
        out-logfile -string "Obtain users via UPN..."

        try {
            $returnUsers = @(get-mgUser -all -filter "endsWith(userprincipalName,'$functionDomainName')" -ConsistencyLevel eventual -property ID,UserPrincipalName,OnPremisesSyncEnabled -errorAction Stop)
        }
        catch {
            out-logfile -string "Error obtaining graph users."
            out-logfile -string $_ -isError:$true
        }
    }

    out-logfile -string ("Count of objects found: "+$returnUsers.count)

    out-logfile -string "Exiting Get-GraphUsers"

    return $returnUsers
}