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
    out-logfile -string ("Current root domain setting: " +$domainInfo.isRoot)

    if ($domainInfo.isRoot -eq $TRUE)
    {
        
        try {
            Update-MgDomain -DomainId $domainName -AuthenticationType $functionAuthMethod -errorAction STOP
        }
        catch {
            out-logfile -string "Unable to change domain authentication method to managed authentication."
            out-logfile -string $_ -isError:$TRUE
        }
    }
    else
    {
        out-logfile -string "Skipping authentiction conversion - domain is a subdomain and inherits settings from the parent domain."
    }

    $domainInfo = test-DomainName -domainName $domainName

    out-logfile -string ("Updated domain authentication method: "+$domainInfo.AuthenticationType)

    out-xmlfile -itemNameToExport $exportFile -itemToExport $domainInfo

    out-logfile -string "Exiting Convert-AuthenticationMethod"

    $global:htmlData['Converted Domain Information'] = $output

    return $domainInfo
}