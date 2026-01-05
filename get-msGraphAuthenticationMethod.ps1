<#
    .SYNOPSIS

    This function obtains the msGraphTenantID if not previously defined.

    .DESCRIPTION

    This function obtains the msGraphTenantID if not previously defined.

    .EXAMPLE

    get-msGraphTenantID 

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
            [string]$msGraphCertificateThumbprint,
            [Parameter(Mandatory = $true)]
            [string]$testString
        )

        #Define variables.

        $authenticationType = ""
        $authenticationInteractive = "Interactive"
        $authenticationCertificate = "Certificate"
        $authenticationSecret = "Secret"

        out-logfile -string "Entering get-msGraphAuthenticationMethod"

        if ($msGraphCertificateThumbprint -ne $testString)
        {
            if ($msgraphApplicationID -ne $testString)
            {
                $authenticationType = $authenticationCertificate
                out-logfile -string "Authentication Method = CertificateAuthentication"
            }
            else 
            {
                out-logfile -string "When specifying a certificateThumbprint an application ID must also be specified."
                out-logfile -string "ERROR:  Missing application ID" -isError:$TRUE
            }
        }
        elseif ($msGraphClientSecret -ne $testString)
        {
            if ($msgraphApplicationID -ne $testString)
            {
                $authenticationType = $authenticationSecret
                out-logfile -string "Authentication Method = CertificateAuthentication"
            }
            else 
            {
                out-logfile -string "When specifying a certificateThumbprint an application ID must also be specified."
                out-logfile -string "ERROR:  Missing application ID" -isError:$TRUE
            }
        }
        else 
        {
            $authenticationType = $authenticationInteractive
            out-logfile -string "Authentication Method = Interactive"
        }

        if ($msgraphApplicationID -ne $testString -and ($msGraphClientSecret -eq $testString -or $msGraphCertificateThumbprint -eq $testString))
        {
            out-logfile -string "A certificate thumbprint or client secret is required when specifying an application id."
            out-logfile -string "ERROR:  Missing certificate thumbprint or client secret" -isError:$TRUE
        }

        out-logfile -string "Exiting get-msGraphAuthenticationMethod"

        return $authenticationType
    }