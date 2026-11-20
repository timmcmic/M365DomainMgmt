function update-UsersPrimarySMTP
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $userObjects,
        [Parameter(Mandatory = $true)]
        $domainName
    )

    $functionDomainName = "@"+$domainName

    out-logfile -string "Entering Update-UsersPrimarySMTP"

    out-logfile -string "Obtain the onmicrosoft.com domain name"

    $onMicrosoft = get-onMicrosoft -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments

    $onMicrosoft = "@"+$onMicrosoft

    $errorArray=@()

    if ((Get-MGContext).authType -eq "Delegated")
    {
        out-logfile -string "Delegated authentication type utilized - create powershell timer and execute a synthetic graph comamnd to keep session alive."

        manage-graphTimer -start:$TRUE
    }
    else
    {
        out-logfile -string "Application authentication in effect - proceed without timer."
    }

    #Create a dictionary of the recipient types.

    out-logfile -string "Begin the process of auditing the recipient type."

    $recipientTypes = [System.Collections.Generic.Dictionary[string, string]]::new()

    $ProgressDelta = 100/($userObjects.count); $PercentComplete = 0; $MbxNumber = 0

    foreach ($user in $userObjects)
    {
        $MbxNumber++

        write-progress -activity "Processing Recipient" -status $user.Id -PercentComplete $PercentComplete -id 1

        $PercentComplete += $ProgressDelta

        out-logfile -string "Testing for recipient type."

        try {
            $recipientType = (Get-Recipient -identity $user.id).recipientType
            out-logfile -string ("Recipient Type: "+$recipientType)
        }
        catch {
            out-logfile -string "Unable to obtain the recipient type - unable to proceed." -isError:$TRUE
        }

        $recipientTypes.add($user.id,$recipientType)
    }

    write-progress -activity "Processing Recipient" -completed -id 1

    out-logfile -string "Update only the primary proxy address at this time - allow time for demotion to secondary address"

    $ProgressDelta = 100/($userObjects.count); $PercentComplete = 0; $MbxNumber = 0

    foreach ($user in $userObjects)
    {
        $functionObject = New-Object PSObject -Property @{
            ID = $user.id
            Mail = $user.mail
            NewMail = "None"
            Name = $user.displayName    
            ObjectType = $recipientTypes[$user.id]
            ErrorMessage = "None"
        }

        $MbxNumber++

        write-progress -activity "Processing Recipient" -status $user.Id -PercentComplete $PercentComplete -id 1

        $PercentComplete += $ProgressDelta

        out-logfile -string "Test to determine if users primary proxy requires adjustment."

        out-logfile -string ("User mail address for evaluation: "+$user.Mail)

        if ($user.mail.contains($functionDomainName))
        {
            out-logfile -string "Users primary SMTP address must be changed."

            $tempSMTPAddress = $user.mail.replace($functionDomainName,$onMicrosoft)

            out-logfile -string ("Calculated Primary SMTP Address: "+$tempSMTPAddress)

            try {

                if ($recipientTypes[$user.id] -eq "UserMailbox")
                {
                    set-mailbox -identity $user.id -windowsEmailAddress $tempSMTPAddress -errorAction STOP
                }
                else 
                {
                    set-mailUser -identity $user.id -primarySMTPAddress $tempSMTPAddress -errorAction STOP
                }

                $functionObject.newMail = $tempAddress

                $global:HTMLPrimarySMTPRenameSuccess.add($functionObject)
            }
            catch {
                out-logfile -string $_
                out-logfile -string "Assume that the SMTP set action failed becuase it matches another object."

                $tempSMTPAddress = $tempSMTPAddress.split("@")

                $tempSMTPAddress[0] = $tempSMTPAddress[0]+((Get-Random -Minimum 100 -Maximum 5000).tostring())

                $tempSMTPAddress = $tempSMTPAddress[0]+"@"+$tempSMTPAddress[1]

                out-logfile -string $tempSMTPAddress

                try {
                    if ($recipientTypes[$user.id] -eq "UserMailbox")
                    {
                        set-mailbox -identity $user.id -windowsEmailAddress $tempSMTPAddress -errorAction STOP
                    }
                    else 
                    {
                        set-mailUser -identity $user.id -primarySMTPAddress $tempSMTPAddress -errorAction STOP
                    }

                    $functionObject.newMail = $tempAddress
                }
                catch {
                    out-logfile -string "Second error attempting to update primary SMTP address - fail user."

                    out-logfile -string $_

                    $functionObject.newMail = $tempAddress
                    $functionObject.errorMessage = $_

                    $global:HTMLPrimarySMTPRenameErrors.add($functionObject)
                }
            }
        }
        else 
        {
            out-logfile -string "Users primary SMTP address does not require changing."
        }
    }
    
    write-progress -activity "Processing Recipient" -completed -id 1

    out-logfile -string "Update all users secondary proxy addresses if the address contains the domain to remove."

    $ProgressDelta = 100/($userObjects.count); $PercentComplete = 0; $MbxNumber = 0

    foreach ($user in $userObjects)
    {
        $MbxNumber++

        write-progress -activity "Processing Recipient" -status $user.Id -PercentComplete $PercentComplete -id 1

        $PercentComplete += $ProgressDelta

        $ProgressDeltaAddresses = 100/($user.proxyaddresses.count); $PercentAddressesComplete = 0; $AddressNumber = 0

        foreach ($address in $user.proxyaddresses)
        {
            $functionObject = New-Object PSObject -Property @{
                ID = $user.id
                AddressRemoved = "None"
                Name = $user.displayName    
                ObjectType = $recipientTypes[$user.id]
                ErrorMessage = "None"
            }

            $addressNumber++

            write-progress -Activity "Processing Address" -Status $address -PercentComplete $PercentAddressesComplete -id 2 -ParentId 1

            $PercentAddressesComplete += $ProgressDeltaAddresses

            out-logfile -string ("Evaluation proxy address: "+$address)

            if ($address.contains($functionDomainName))
            {
                out-logfile -string "Remove secondary proxy address"

                try {
                    if ($recipientTypes[$user.id] -eq "UserMailbox")
                    {
                        set-mailbox -identity $user.id -emailAddresses @{remove=$address} -errorAction STOP
                    }
                    else 
                    {
                        set-MailUser -identity $user.id -emailAddresses @{remove=$address} -errorAction STOP
                    }

                    $functionObject.AddressRemoved = $address

                    $global:HTMLSecondarySMTPRemoveSuccess.add($functionObject)
                }
                catch {
                    out-logfile -string "Unable to remove the secondary proxy address."

                    $functionObject.AddressRemoved = $address
                    $functionObject.ErrorMessage = $_

                    $global:HTMLSecondarySMTPRemoveErrors.add($functionObject)
                }
            }
            else 
            {
                out-logfile -string "Address removal not required."
            }
        }

        write-progress -activity "Processing Address" -completed -id 2 -ParentId 1
    }
    
    write-progress -activity "Processing Recipient" -completed -id 1

    if ((Get-MGContext).authType -eq "Delegated")
    {
        out-logfile -string "Delegated authentication type utilized - destroy the previously created timer and event."

        manage-graphTimer -start:$false
    }
    else
    {
        out-logfile -string "Application authentication utilized - no timer actions required."
    }

    out-logfile -string "Existing Update-UsersPrimarySMTP"
}