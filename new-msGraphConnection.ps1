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
    Function new-msGraphConnection
{
    [cmdletbinding()]

    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$msGraphTenantID,
        [Parameter(Mandatory = $true)]
        [string]$msgraphApplicationID,
        [Parameter(Mandatory = $true)]
        [string]$msGraphClientSecret,
        [Parameter(Mandatory = $true)]
        [string]$msGraphCertificateThumbprint,
        [Parameter(Mandatory = $true)]
        [string]$msGraphEnvironmentName,
        [Parameter(Mandatory = $true)]
        [string]$msGraphAuthenticationType
    )

    #Define variables.

    $authenticationInteractive = "Interactive"
    $authenticationCertificate = "Certificate"
    $authenticationSecret = "Secret"

    out-logfile -string "Entering New-msGraphConnection"

    if ($msGraphAuthenticationType -eq $authenticationInteractive)
    {
        out-logfile -string 'Graph Interactive Authentication'
    }
    elseif ($msGraphAuthenticationType -eq $authenticationCertificate)
    {
        out-logfile -string 'Graph Certificate Authentication'
    }
    elseif ($msGraphAuthenticationType -eq $authenticationSecret)
    {
        out-logfile -string 'Graph Secret Authentication'
    }

    out-logfile -string "Exiting New-msGraphConnection"
}