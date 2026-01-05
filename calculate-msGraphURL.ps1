<#
    .SYNOPSIS

    This function calculates the graph URL that will be utilized in function calls.

    .DESCRIPTION

    This function calculates the graph URL that will be utilized in function calls.

    .PARAMETER msGraphEnvironmentName

    The graph environment that the work will be performed in.

	.OUTPUTS

    Ensure the directory exists.
    Establishes the logfile path/name for subsequent function calls.

    .EXAMPLE

    new-logfile -groupSMTPAddress ADDRESS -logFolderPath LOGFOLDERPATH

    #>
    Function calculate-msGraphURL
{
    [cmdletbinding()]

    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$msGraphEnvironmentName
    )

    #Define local variables.

    $msGraphURL = ""
    $msGraphURLGlobal = "https://graph.microsoft.com"
    $msGraphURLUSGov = "https://graph.microsoft.us"
    $msGraphURLUSDoD = "https://dod-graph.microsoft.us"
    $msGraphURLChina = "https://microsoftgraph.chinacloudapi.cn"

    out-logfile -string "Entering Calculate-MSGraphURL"

    

    out-logfile -string "Exiting Calculate-MSGraphURL"

    return $msGraphURL
}