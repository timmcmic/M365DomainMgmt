function add-mgGraphDomain
{
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$domainName,
        [Parameter(Mandatory = $true)]
        [string]$msGraphEnvironmentName
    )

    out-logfile -string "Entering add-MGGraphDomain"

    out-logfile -string "Locating graph url for operations."

    $mgGraphURL = get-msGraphURL -mgGrapEnvironmentName $mgGraphEnvironmentName

    out-logfile -string ("Graph URL: "+$mgGraphURL)
}