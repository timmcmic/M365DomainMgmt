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
        [string]$msGraphCertificateThumbprint
    )

    #Define variables.

    $testString = "None"

    out-logfile -string "Entering Start-MSGraphConnection"

    out-logfile -string "Record or obaint an entra / graph tenant id."

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
}