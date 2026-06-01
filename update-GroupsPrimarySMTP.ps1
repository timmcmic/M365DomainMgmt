function update-groupsPrimarySMTP
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $userObjects,
        [Parameter(Mandatory = $true)]
        $domainName
    )

    $functionDomainName = "@"+$domainName

    out-logfile -string "Entering Update-GroupsPrimarySMTP"

    out-logfile -string "Obtain the onmicrosoft.com domain name"

    $onMicrosoft = get-onMicrosoft -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments

    $onMicrosoft = "@"+$onMicrosoft

    $errorArray=@()

    $ProgressDelta = 100/($userObjects.count); $PercentComplete = 0; $MbxNumber = 0

    foreach ($user in $userObjects)
    {
        $MbxNumber++

        write-progress -activity "Processing Recipient" -status $user.Id -PercentComplete $PercentComplete -id 1

        $PercentComplete += $ProgressDelta

        out-logfile -string "Testing for recipient type."

        try {
            $recipientType = (Get-Recipient -identity $user.id).recipientTypeDetails
            out-logfile -string ("Recipient Type: "+$recipientType)
        }
        catch {
            out-logfile -string "Unable to obtain the recipient type - unable to proceed." -isError:$TRUE
        }

        out-logfile -string "Test to determine if users primary proxy requires adjustment."

        out-logfile -string ("User mail address for evaluation: "+$user.Mail)

        if ($user.mail.contains($functionDomainName))
        {
            out-logfile -string "Users primary SMTP address must be changed."

            $tempSMTPAddress = $user.mail.replace($functionDomainName,$onMicrosoft)

            out-logfile -string ("Calculated Primary SMTP Address: "+$tempSMTPAddress)

            try {

                if ($recipientType -eq "GroupMailbox")
                {
                    set-UnifiedGroup -identity $user.id -primarySMTPAddress $tempSMTPAddress -errorAction STOP
                }
                else 
                {
                    set-DistributionGroup -identity $user.id -primarySMTPAddress $tempSMTPAddress -errorAction STOP -bypassSecurityGroupManagerCheck
                }

                $functionObject = New-Object PSObject -Property @{
                    ID = $user.id
                    Mail = $user.mail
                    NewMail = $tempSMTPAddress
                    Name = $user.displayName    
                    ObjectType = "Group"
                    ErrorMessage = "None"
                }

                $global:HTMLPrimarySMTPRenameGroupSuccess.add($functionObject)
            }
            catch {
                out-logfile -string "Assume that the SMTP set action failed becuase it matches another object."

                $tempSMTPAddress = $tempSMTPAddress.split("@")

                $tempSMTPAddress[0] = $tempSMTPAddress[0]+((Get-Random -Minimum 100 -Maximum 5000).tostring())

                $tempSMTPAddress = $tempSMTPAddress[0]+"@"+$tempSMTPAddress[1]

                try {
                    if ($recipientType -eq "GroupMailbox")
                    {
                        set-UnifiedGroup -identity $user.id -primarySMTPAddress $tempSMTPAddress -errorAction STOP
                    }
                    else 
                    {
                        set-DistributionGroup -identity $user.id -primarySMTPAddress $tempSMTPAddress -errorAction STOP -bypassSecurityGroupManagerCheck
                    }
                }
                catch {
                    out-logfile -string "Second error attempting to update primary SMTP address - fail user."

                    $functionObject = New-Object PSObject -Property @{
                        ID = $user.id
                        Mail = $user.mail
                        NewMail = $tempSMTPAddress
                        Name = $user.displayName    
                        ObjectType = "User"
                        ErrorMessage = $_
                    }

                    $global:HTMLPrimarySMTPRenameGroupErrors.add($functionObject)
                }
            }
        }
        else 
        {
            out-logfile -string "Users primary SMTP address does not require changing."
        }

        $ProgressDeltaAddresses = 100/($user.proxyaddresses.count); $PercentAddressesComplete = 0; $AddressNumber = 0

        foreach ($address in $user.proxyaddresses)
        {
            $addressNumber++

            write-progress -Activity "Processing Address" -Status $address -PercentComplete $PercentAddressesComplete -id 2 -ParentId 1

            $PercentAddressesComplete += $ProgressDeltaAddresses

            out-logfile -string ("Evaluation proxy address: "+$address)

            if ($address.contains($functionDomainName))
            {
                out-logfile -string "Remove secondary proxy address"

                try {
                    if ($recipientType -eq "GroupMailbox")
                    {
                        Set-UnifiedGroup -identity $user.id -emailAddresses @{remove=$address} -errorAction STOP
                    }
                    else 
                    {
                        Set-DistributionGroup -identity $user.id -emailAddresses @{remove=$address} -errorAction STOP -bypassSecurityGroupManagerCheck
                    }

                    $functionObject = New-Object PSObject -Property @{
                        ID = $user.id
                        AddressRemoved = $address
                        Name = $user.displayName    
                        ObjectType = "Group"
                        ErrorMessage = "None"
                    }

                    $global:HTMLSecondarySMTPRemoveGroupSuccess.add($functionObject)
                }
                catch {
                    out-logfile -string "Unable to remove the secondary proxy address."

                    $functionObject = New-Object PSObject -Property @{
                        ID = $user.id
                        AddressRemoved = $address
                        Name = $user.displayName    
                        ObjectType = "Group"
                        ErrorMessage = $_
                    }

                    $global:HTMLSecondarySMTPRemoveGroupErrors.add($functionObject)
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

    out-logfile -string "Existing Update-GroupsPrimarySMTP"
}