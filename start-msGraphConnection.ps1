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

    $msGraphTenantID = get-msGraphTenantID -msGraphTEnantID $msGraphTenantID -testString $testString

    out-logfile -string ("MSGraphTenantID: "+$msGraphTenantID)

    out-logfile -string "Record or obtain an MSGraphEnvironmentName"

    $msGraphEnvironmentName = get-msGraphEnvironmentName -msGraphEnvironmentName $msGraphEnvironmentName -testString $testString

    out-logfile -string ("MSGraphEnvironmentName: "+$msGraphEnvironmentName)

    out-logfile -string "Obtain the graph authentication type"

    $msGraphAuthenticationType = get-msGraphAuthenticationMethod -msGraphApplicationID $msgraphApplicationID -msGraphCertificateThumbprint $msGraphCertificateThumbprint -msGraphClientSecret $msGraphClientSecret -testString $testString

    out-logfile -string ("msGraphAuthenticationType: "+$msGraphAuthenticationType)

    out-logfile -string "Create the graph connection."

    new-msGraphConnection -msGraphAuthenticationType $msGraphAuthenticationType -msGraphClientSecret $msGraphClientSecret -msGraphCertificateThumbprint $msGraphCertificateThumbprint -msGraphTenantID $msGraphTenantID -msGraphEnvironmentName $msGraphEnvironmentName
}