function get-MSGraphCall
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironmentName,
        [Parameter(Mandatory = $false)]
        $verifyOrRemove = "Verify"
    )

    $functionmsGraphBetaVersion = "Beta"
    $global = "Global"
    $usGov = "USGov"
    $usDOD = "USGovDoD"
    $China = "China"
    $msGraphURLGlobal = "https://graph.microsoft.com"
    $msGraphURLUSGov = "https://graph.microsoft.us"
    $msGraphURLUSDoD = "https://dod-graph.microsoft.us"
    $msGraphURLChina = "https://microsoftgraph.chinacloudapi.cn"

    if ($verifyOrRemove -eq "Verify")
    {
        $functionDomainStringBeta = "/$functionmsGraphBetaVersion/domains/$domainName/verify"
    }
    else 
    {
        $functionDomainStringBeta = "/$functionmsGraphBetaVersion/domains/$domainName/forceDelete"
    }


    out-logfile -string "Entering get-MSGraphCall"

    if ($msGraphEnvironmentName -eq $global)
    {
        out-logfile -string "Graph envirnoment global"

        $functionURL = $msGraphURLGlobal+$functionDomainStringBeta
    }
    elseif ($msGraphEnvironmentName -eq $usGov)
    {
        out-logfile -string "Graph environment USGov"
        $functionURL = $msGraphURLUSGov+$functionDomainStringBeta
    }
    elseif ($msGraphEnvironmentName -eq $usDOD)
    {
        out-logfile -string "Graph environmet USDoD"
        $functionURL = $msGraphURLUSDoD+$functionDomainStringBeta
    }
    elseif ($msGraphEnvironmentName -eq $China)
    {
        out-logfile -string "Graph environment China"
        $functionURL = $msGraphURLChina+$functionDomainStringBeta
    }

    out-logfile -string ("Calculated graph URI: "+$functionURL)

    out-logfile -string "Exiting get-MSGraphCall"

    return $functionURL
}