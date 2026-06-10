function new-ExchangeOnlineConnection
{
    param 
    (
        [Parameter(Mandatory = $false)]
        [string]$exchangeOnlineCertificateThumbPrint="",
        [Parameter(Mandatory = $false)]
        [string]$exchangeOnlineOrganizationName="",
        [Parameter(Mandatory = $false)]
        [string]$exchangeOnlineAppID="",
        [Parameter(Mandatory = $false)]
        [string]$msGraphEnvironmentName,
        [Parameter(Mandatory = $false)]
        [string]$exchangeOnlineEnvironments
    )

    out-logfile -string "Entering new-ExchangeOnlineConnection"

    out-logfile -string "Determining the method of Exchange Online connection."

    if (($exchangeOnlineCertificateThumbPrint -eq "") -and ($exchangeOnlineOrganizationName -ne "") -and ($exchangeOnlineAppID -ne ""))
    {
        out-logfile -string "An Exchange Certificate Thumbprint is required when using Exchange Online Organiation Name and Exchange Online App ID." -isError:$TRUE
    }
    elseif (($exchangeOnlineCertificateThumbPrint -ne "") -and ($exchangeOnlineOrganizationName -eq "") -and ($exchangeOnlineAppID -ne ""))
    {
        out-logfile -string "An Exchange Online Organization Name is required when using an Exchange Certificate Thumbprint and Exchange Online App ID" -isError:$TRUE
    }
    elseif (($exchangeOnlineCertificateThumbPrint -ne "") -and ($exchangeOnlineOrganizationName -ne "") -and ($exchangeOnlineAppID -eq ""))
    {
        out-logfile -string "An Exchange Online App ID is required when specifying an Exchange Certificate Thumbprint and Exchange Online Organization Name." -isError:$TRUE
    }
    elseif (($exchangeOnlineCertificateThumbPrint -ne "") -and ($exchangeOnlineOrganizationName -ne "") -and ($exchangeOnlineAppID -ne ""))
    {
        out-logfile -string "Starting Exchange Online Certificate Thumbprint connection"

        try {
            Connect-ExchangeOnline -Organization $exchangeOnlineOrganizationName -CertificateThumbprint $exchangeOnlineCertificateThumbPrint -AppId $exchangeOnlineAppID -ExchangeEnvironmentName $msGraphEnvironmentName -ErrorAction STOP
        }
        catch {
            out-logfile -string "Unable to make Exchange Online Connection"
            out-logfile -string $_ -isError:$TRUE
        }
    }
    else 
    {
        out-logfile -string "Starting Exchange Online Interactive Authentication"
        try {
            Connect-ExchangeOnline -ExchangeEnvironmentName $msGraphEnvironmentName -ErrorAction Stop
        }
        catch {
            out-logfile -string "Unable to make Exchange Online Connection"
            out-logfile -string $_ -isError:$TRUE
        }
    }

}