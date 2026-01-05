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

    .PARAMETER msGraphAuthenticationType

    The type of authentication that will be utilized with graph.

	.OUTPUTS

    Ensure the directory exists.
    Establishes the logfile path/name for subsequent function calls.

    .EXAMPLE

    new-logfile -groupSMTPAddress ADDRESS -logFolderPath LOGFOLDERPATH

    #>
    Function validate-msGraphConnection
{
    [cmdletbinding()]

    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$msGraphScopesRequired
    )

    out-logfile -string "Entering Validate-MSGraphConnection"

    $graphContext = Get-MgContext

    out-logfile -string ("TenantID: "+$graphContext.tenantID)
    out-logfile -string ("ClientID: "+$graphContext.clientID)
    out-logfile -string ("AuthType: "+$graphContext.authType)
    out-logfile -string ("TokeCredentialType: "+$graphContext.tokenCredentialType)
    out-logfile -string ("AppName: "+$graphContext.AppName)
    out-logfile -string ("Environment: "+$graphContext.environment)

    foreach ($scope in $graphContext.scopes)
    {
        out-logfile -string ("Scope: "+$scope)
    }

    if ($graphContext.scopes -contains $msGraphScopesRequired)
    {
        out-logfile -string "The scopes required are available - proceed."
    }
    else 
    {
        out-logfile -string "ERROR:  Missing Domain.ReadWrite.All scope in graph connection"
    }

    out-logfile -string "Exiting Validate-MSGraphConnection"
}