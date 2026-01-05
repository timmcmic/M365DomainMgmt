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
        [string]$msGraphAuthenticationType,
        [Parameter(Mandatory = $true)]
        [string]$msGraphScopesRequired
    )

    #Define variables.

    $authenticationInteractive = "Interactive"
    $authenticationCertificate = "Certificate"
    $authenticationSecret = "Secret"
    $securedPasswordPassword = ""
    $clientSecretCredential = ""

    out-logfile -string "Entering New-msGraphConnection"

    if ($msGraphAuthenticationType -eq $authenticationInteractive)
    {
        out-logfile -string 'Graph Interactive Authentication'

        try {
            connect-MGGraph -scopes $msGraphScopesRequired -TenantId $msGraphTenantID -Environment $msGraphEnvironmentName -errorAction Stop
            out-logfile -string "Interactive graph connection established."
        }
        catch {
            out-logfile -string "Unable to connect with interactive authentication."
            out-logfile -string $_ -isError:$true
        }
    }
    elseif ($msGraphAuthenticationType -eq $authenticationCertificate)
    {
        out-logfile -string 'Graph Certificate Authentication'

        try {
            connect-MGGraph -TenantId $msGraphTenantID -CertificateThumbprint $msGraphCertificateThumbprint -AppId $msgraphApplicationID -Environment $msGraphEnvironmentName
            out-logfile -string "Interactive graph connection established."
        }
        catch {
            out-logfile -string "Unable to connect with certificate authentication."
            out-logfile -string $_ -isError:$true
        }
    }
    elseif ($msGraphAuthenticationType -eq $authenticationSecret)
    {
        out-logfile -string 'Graph Secret Authentication'

        out-logfile -string "Converting secret to secure password"

        $securedPasswordPassword = convertTo-SecureString -string $msGraphClientSecret -AsPlainText -Force

        out-logfile -string "Converting secure password and appID to client credential"

        $clientSecretCredential = new-object -typeName System.Management.Automation.PSCredential -argumentList $msGraphApplicationID,$securedPasswordPassword

        try {
            connect-MGGraph -TenantId $msGraphTenantID -Environment $msGraphEnvironmentName -ClientSecretCredential $clientSecretCredential -errorAction Stop
            out-logfile -string "Interactive graph connection established."
        }
        catch {
            out-logfile -string "Unable to connect with secret authentication."
            out-logfile -string $_ -isError:$true
        }
    }

    out-logfile -string "Exiting New-msGraphConnection"
}