function get-removalApproval
{
    write-host "**********************"
    write-host "Removing a domain requires the following actions:"
    write-host "1)  Domain authentication converted from federated to managed if applicable."
    write-host "2)  All user UPNs will be updated to the onmicrosoft.com domain name."
    write-host "3)  All group and user proxy addresses that contain the domain will be removed and the onmicrosoft.com set as primary."
    write-host "4)  Any EntraID app registrations URLs that utilize the domain will be replaced with the onmicrosoft.com domain."
    write-host "**********************"
    
    do {
        $result = Read-Host "Prees Y to continue N to stop"
    } until (
        $result -eq "Y" -or $result -eq "N"
    )

    if ($result -eq "N")
    {
        out-logfile -string "Administrator has choosen not to continue the removal process..." -isError:$TRUE
    }
    else 
    {
        out-logfile -string "Administrator has choosen to continue with the removal process..."
    }
}
