function get-GraphURL
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $msGraphEnvironmentName,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironments,
        [Parameter(Mandatory = $true)]
        $id,
        [Parameter(Mandatory = $true)]
        $userOrGroup
    )

    out-logfile -string "Entering Get-GraphURL"

    $msGraphBaseURLs = @{}
    $msGraphBaseURLs['msGraphGlobal']="graph.microsoft.com"
    $msGraphBaseURLs['msGraphUSGov']="graph.microsoft.us"
    $msGraphBaseURLs['msGraphUSGovDOD']="dod-graph.microsoft.us"
    $msGraphBaseURLs['msGraphChina']="microsoftgraph.chinacloudapi.cn"
    $baseURL = ""
    $returnURL = ""

    out-logfile -string ("Processing id: "+$id)

    switch ($msGraphEnvironmentName) {
        $msGraphEnvironments.msGraphGlobal
        {  
            $baseURL = $msGraphBaseURLs.msGraphGlobal
        }
        $msGraphEnvironments.msGraphUSGov 
        {
            $baseURL = $msGraphBaseURLs.msGraphUSGov

        }
        $msGraphEnvironments.msGraphUSGovDOD 
        {
            $baseURL = $msGraphBaseURLs.msGraphUSGovDOD
        }
        $msGraphEnvironments.msGraphChina 
        {
            $baseURL = $msGraphBaseURLs.msGraphChina
        }
        Default 
        {
            out-logfile -string "You should have never gotten here - contact author." -isError:$TRUE
        }
    }

    out-logfile -string ("Base URL for request: "+$baseURL)

    if ($userOrGroup -eq "User")
    {
        $returnURL = "https://"+$baseURL+"/beta/user/"+$id+"/onPremisesSyncBehavior"
    }

    out-logfile -string $returnURL

    out-logfile -string "Exiting Get-GraphURL"

    return $returnURL
}