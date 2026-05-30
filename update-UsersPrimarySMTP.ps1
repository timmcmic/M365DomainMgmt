function update-UsersPrimarySMTP
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $userObjects,
    )

    $functionDomainName = "@"+$domainName

    out-logfile -string "Entering Update-UsersPrimarySMTP"

    out-logfile -string "Obtain the onmicrosoft.com domain name"

    $onMicrosoft = get-onMicrosoft -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments

    $onMicrosoft = "@"+$onMicrosoft

    $errorArray=@()

    foreach ($user in $userObjects)
    {
        out-logfile -string ("Processing ID: "+$user.id)

        $tempUPN = $user.userPrincipalName.replace($functionDomainName,$onMicrosoft)

        out-logfile -string $tempUPN

        try {
            update-mgUser -userID $user.id -UserPrincipalName $tempUPN -errorAction Stop

            out-logfile -string "UPN updated successfully."

            $functionObject = New-Object PSObject -Property @{
                ID = $user.id
                UPN = $user.UPN
                NewUPN = $tempUPN
                Name = $user.displayName    
                ObjectType = "User"
                ErrorMessage = "None"
            }

            $global:HTMLPrimarySMTPRenameSuccess.add($functionObject)
        }
        catch {
            out-logfile -string "Assuming the current UPN is in use."

            $tempUser = $user.mail.split("@")

            $tempPrefix = $tempUser[0]+"-"+(Get-Random -Minimum 100 -Maximum 5000).tostring()

            $tempSMTP.replace($tempUser[0],$tempPrefix)

            try {
                update-mgUser -userID $user.id -UserPrincipalName $tempUPN -errorAction Stop
            }
            catch {
                out-logfile -string "Error must be something other than duplicate upn"

                $functionObject = New-Object PSObject -Property @{
                    ID = $user.id
                    UPN = $user.UPN
                    NewUPN = $tempUPN
                    Name = $user.displayName    
                    ObjectType = "User"
                    ErrorMessage = $_
                }

                $global:HTMLUPNRenameErrors.add($functionObject)
            }
        }
    }

    out-logfile -string "Existing Update-UsersPrimarySMTP"
}