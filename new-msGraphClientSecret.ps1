function new-msGraphClientSecret
{
    Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $msGraphHashTable
    )

    out-logfile -string "Entering new-msGraphClientSecret"

    out-logfile -string "Convert the client secret to a secure password."

    try {
        $securedPasswordPassword = ConvertTo-SecureString -String $msGraphHashTable.msGraphClientSecret -AsPlainText -Force -ErrorAction Stop
        out-logfile -string "Conversion of the client secret to secure string completed."
    }
    catch {
        out-logfile -string $_
        out-logfile -string "Unable to convert the client secret to a secure password." -isError:$true
    }

    out-logfile -string "Create the client secret credential."

    try {
        $clientSecretCredential = New-Object -TypeName System.Management.Automation.PSCredential -argumentList $msGraphHashTable.msGraphApplicationID,$securedPasswordPassword -errorAction Stop
        out-logfile -string "Client secret credential created successfully."
    }
    catch {
        out-logfile -string $_
        out-logfile -string "Unable to create the client secret credential." -isError:$true
    }

    out-logfile -string "Creating client secret authentication to MS Graph."

    try {
        connect-mgGraph -tenantID $msGraphHashTable.msGraphTenantID -Environment $msGraphHashTable.msGraphEnvironmentName -clientSecretCredential $clientSecretCredential -errorAction Stop
        out-logfile -string "Client secret authentication to MS Graph successful."
    }
    catch {
        out-logfile -string $_
        out-logfile -string "Client secret authentication to MS Graph FAILED" -isError:$true
    }

    out-logfile -string "Exiting new-msGraphClientSecret"
}