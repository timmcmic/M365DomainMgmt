function update-userUPN
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $userObjects,
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironmentName,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironments
    )

    $functionDomainName = "@"+$domainName

    out-logfile -string "Entering Update-UserUPN"

    out-logfile -string "Obtain the onmicrosoft.com domain name"

    $onMicrosoft = get-onMicrosoft -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments

    $onMicrosoft = "@"+$onMicrosoft

    $errorArray=@()

    $ProgressDelta = 100/($userObjects.count); $PercentComplete = 0; $MbxNumber = 0

    foreach ($user in $userObjects)
    {
        $MbxNumber++

        write-progress -activity "Processing Recipient" -status $user.Id -PercentComplete $PercentComplete

        $PercentComplete += $ProgressDelta

        out-logfile -string ("Processing ID: "+$user.id)

        $tempUPN = $user.userPrincipalName.replace($functionDomainName,$onMicrosoft)

        out-logfile -string $tempUPN

        try {
            update-mgUser -userID $user.id -UserPrincipalName $tempUPN -errorAction Stop

            out-logfile -string "UPN updated successfully."

            $functionObject = New-Object PSObject -Property @{
                ID = $user.id
                UPN = $user.userPrincipalName
                NewUPN = $tempUPN
                Name = $user.displayName    
                ObjectType = "User"
                ErrorMessage = "None"
            }

            $global:HTMLUPNRenameSuccess.add($functionObject)
        }
        catch {
            out-logfile -string "Assuming the current UPN is in use."

            $tempUser = $user.userPrincipalName.split("@")

            $tempPrefix = $tempUser[0]+"-"+(Get-Random -Minimum 100 -Maximum 5000).tostring()

            $tempUPN.replace($tempUser[0],$tempPrefix)

            try {
                update-mgUser -userID $user.id -UserPrincipalName $tempUPN -errorAction Stop
            }
            catch {
                out-logfile -string "Error must be something other than duplicate upn"

                $functionObject = New-Object PSObject -Property @{
                    ID = $user.id
                    UPN = $user.userPrincipalName
                    NewUPN = $tempUPN
                    Name = $user.displayName    
                    ObjectType = "User"
                    ErrorMessage = $_
                }

                $global:HTMLUPNRenameErrors.add($functionObject)
            }
        }
    }

    write-progress -activity "Processing Recipient" -completed

    out-logfile -string "Existing Update-UserUPN"
}