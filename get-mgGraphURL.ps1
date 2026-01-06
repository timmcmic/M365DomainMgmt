function get-mggraphurl
{
    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$msGraphEnvironmentName
    )

    out-logfile -string "Entering Get-MGGraphURL"

    switch($domainOperation)
    {
        'Global' {
            out-logfile -string "Global"
            $url = "https://graph.microsoft.com"
        } 'USGov' {
            out-logfile -string "UsGov"
            $url = "https://graph.microsoft.us"
        } 'USDOD' {
            out-logfile -string "USDod"
            $url = "https://dod-graph.microsoft.us"
        } 'China' {
            out-logfile -string "China"
            $url = "https://microsoftgraph.chinacloudapi.cn"
        }
    }
    
    out-logfile -string "Existing Get-MGGraphURL"

    return $url
}