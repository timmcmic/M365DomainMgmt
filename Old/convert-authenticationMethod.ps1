function convert-authenticationMethod
{
    Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $exportFile,
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $true)]
        $domainInfo
    )

    $functionAuthMethod = "Managed"

    out-logfile -string "Entering Convert-AuthenticationMethod"

    out-logfile -string ("Current domain authentication method: "+$domainInfo.AuthenticationType)

    try {
        Update-MgDomain -DomainId $domainName -AuthenticationType $functionAuthMethod -errorAction STOP
    }
    catch {
        out-logfile -string "Unable to change domain authentication method to managed authentication."
        out-logfile -string $_ -isError:$TRUE
    }

    $domainInfo = test-DomainName -domainName $domainName

    out-logfile -string ("Updated domain authentication method: "+$domainInfo.AuthenticationType)

    out-xmlfile -itemNameToExport $exportFile -itemToExport $domainInfo

    out-logfile -string "Exiting Convert-AuthenticationMethod"

    return $domainInfo
}