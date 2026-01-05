<#
    .SYNOPSIS

    This function creates the msGraph connection to support additional functions.

    .DESCRIPTION

    This function creates the msGraph connection to support additional functions.

    .PARAMETER msGraphRequiredScopes

    The scopes defined in the calling function required for ms graph work..

    .PARAMETER msGraphEnvironmentName

    The graph environment that the work will be performed in.

    .PARAMETER msGraphTenantID

    The tenant ID where the work will be performed.

    .PARAMETER msGraphCertificateThumbprint

    The certificate utilized for authentication.

    .PARAMETER msGraphClientSecret

    The secret utilized for the authentication session.

    .PARAMETER msGraphApplicationID

    The application that has the required permissions, client secret association, or certificate thumbprint associate.

	.OUTPUTS

    Ensure the directory exists.
    Establishes the logfile path/name for subsequent function calls.

    .EXAMPLE

    new-logfile -groupSMTPAddress ADDRESS -logFolderPath LOGFOLDERPATH

    #>
    Function start-msGraphConnection
{
    [cmdletbinding()]

    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$msGraphScopesRequired,
        [Parameter(Mandatory = $true)]
        [string]$msGraphTenantID,
        [Parameter(Mandatory = $true)]
        [string]$msgraphApplicationID,
        [Parameter(Mandatory = $true)]
        [string]$msGraphClientSecret,
        [Parameter(Mandatory = $true)]
        [string]$msGraphCertificateThumbprint,
        [Parameter(Mandatory = $true)]
        [string]$msGraphEnvironmentName
    )

    #Define variables.

    $testString = "None"
    $msGraphAuthenticationType = ""

    out-logfile -string "Entering Start-MSGraphConnection"

    out-logfile -string "Record or obtain an entra / graph tenant id."

    if ($msGraphTenantID -eq $testString)
    {
        out-logfile -string "A Entra / Graph TenantID was not defined."

        $msGraphTenantID = get-msGraphTenantID

        out-logfile -string ("MSGraphTenantID: "+$msGraphTenantID)
    }
    else 
    {
        out-logfile -string "A graph tenant ID was provied at runtime."
        out-logfile -string ("MSGraphTenantID: "+$msGraphTenantID)
    }

    out-logfile -string "Record or obtain an MSGraphEnvironmentName"

    if ($msGraphEnvironmentName -eq $testString)
    {
        out-logfile -string "An MSGraphEnvironment name was not defined."

        $msGraphEnvironmentName = get-msGraphEnvironmentName

        out-logfile -string ("MSGraphEnvironmentName: "+$msGraphEnvironmentName)
    }
    else 
    {
        out-logfile -string "A msGraphEnvironnmentName was provied at runtime."
        out-logfile -string ("MSGraphEnvironmentName: "+$msGraphEnvironmentName)
    }

    if (($msGraphCertificateThumbprint -ne $testString) -and ($msGraphClientSecret -ne $testString))
    {
        out-logfile -string "A certificate thumbprint and client secret were provided at the same time."
        out-logfile -string "Provide only one method of non-interactive authentication." -isError:$TRUE
    }
    else 
    {
        out-logfile -string "A client secret and certificate thumbprint were not provided together - proceed."
    }

    $msGraphAuthenticationType = get-msGraphAuthenticationMethod -msGraphApplicationID $msgraphApplicationID -msGraphCertificateThumbprint $msGraphCertificateThumbprint -msGraphClientSecret $msGraphClientSecret -testString $testString
}