<#
    .SYNOPSIS

    This function creates the msGraph connection to support additional functions.

    .DESCRIPTION

    This function creates the msGraph connection to support additional functions.

    .PARAMETER msGraphEnvironmentName

    The graph environment that the work will be performed in.

    .OUTPUTS

    None

    .EXAMPLE

    validate-msGraphConnection -msGraphScopesRequired $msGraphScopesRequired

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