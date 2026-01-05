<#
    .SYNOPSIS

    This function obtains the msGraphTenantID if not previously defined.

    .DESCRIPTION

    This function obtains the msGraphTenantID if not previously defined.

    .EXAMPLE

    get-msGraphAuthenticationMethod -msGraphApplicationID $msGraphApplicationID -msGRaphClientSecret $msGraphClientSecret -msGraphCertificateThumbprint $msGraphCertificateThumbprint

    .OUTPUTS

    Returns the authentication method.

    #>
    Function get-msGraphAuthenticationMethod
    {
        Param
        (
            [Parameter(Mandatory = $true)]
            [string]$msgraphApplicationID,
            [Parameter(Mandatory = $true)]
            [string]$msGraphClientSecret,
            [Parameter(Mandatory = $true)]
            [string]$msGraphCertificateThumbprint
        )

        #Define variables.

        $authenticationType = ""
        
        out-logfile -string "Entering get-msGraphAuthenticationMethod"

        if (($msGraphCertificateThumbprint -ne $global:testString) -and ($msGraphClientSecret -ne $global:testString))
        {
            out-logfile -string "A certificate thumbprint and client secret were provided at the same time."
            out-logfile -string "Provide only one method of non-interactive authentication." -isError:$TRUE
        }
        else 
        {
            out-logfile -string "A client secret and certificate thumbprint were not provided together - proceed."
        }

        if ($msGraphCertificateThumbprint -ne $global:testString)
        {
            if ($msgraphApplicationID -ne $global:testString)
            {
                $authenticationType = $global:authenticationCertificate
                out-logfile -string "Authentication Method = CertificateAuthentication"
            }
            else 
            {
                out-logfile -string "When specifying a certificateThumbprint an application ID must also be specified."
                out-logfile -string "ERROR:  Missing application ID" -isError:$TRUE
            }
        }
        elseif ($msGraphClientSecret -ne $global:testString)
        {
            if ($msgraphApplicationID -ne $global:testString)
            {
                $authenticationType = $global:authenticationSecret
                out-logfile -string "Authentication Method = ClientSecret"
            }
            else 
            {
                out-logfile -string "When specifying a certificateThumbprint an application ID must also be specified."
                out-logfile -string "ERROR:  Missing application ID" -isError:$TRUE
            }
        }
        else 
        {
            $authenticationType = $global:authenticationInteractive
            out-logfile -string "Authentication Method = Interactive"
        }

        if ($msgraphApplicationID -ne $global:testString -and ($msGraphClientSecret -eq $global:testString -and $msGraphCertificateThumbprint -eq $global:testString))
        {
            out-logfile -string "A certificate thumbprint or client secret is required when specifying an application id."
            out-logfile -string "ERROR:  Missing certificate thumbprint or client secret" -isError:$TRUE
        }

        out-logfile -string "Exiting get-msGraphAuthenticationMethod"

        return $authenticationType
    }