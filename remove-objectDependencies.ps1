function remove-objectDependencies
{
     Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $exportFiles,
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironmentName,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironments
    )

    $dirSyncTracking = @()

    out-logfile -string "Entering Remove-ObjectDependencies"

    out-logfile -string "Obtaining all users that have this domain as a UPN."

    $usersUPN = @(get-GraphUsers -domainName $domainName -getUPN:$TRUE)

    if ($usersUPN.count -gt 0)
    {
        out-logfile -string "Users were returned - split into dir sync and non dir synced users."

        $dirSyncUsers = @(split-GraphObjects -objectArray $usersUPN -isDirSync:$true)
        $dirSyncTracking += $dirSyncUsers

        #$cloudUsers = @(split-GraphObjects -objectArray $users -isDirSync:$false)

        out-xmlFile -itemToExport $usersUPN -itemNameToExport $exportFiles.UsersUPN

        out-logfile -string "If users are directory sync - change SOA to cloud."

        if ($dirSyncUsers.count -gt 0)
        {
            out-logfile -string "Directory sync users present - change SOA."

            update-DirSyncStatus -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -Objects $dirSyncUsers -userOrGroup "User"
        }
        else 
        {
            out-logfile -string "All users were cloud only - proceed."
        }

        out-logfile -string "Proceed with UPN adjustments"

        update-userUPN -userObjects $usersUPN -domainName $domainName -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments
    }
    else 
    {
        out-logfile -string "No users with an associated UPN found."
    }

    out-logfile -string "Obtain all users who have a primary SMTP address at the domain to be removed."

    $usersPrimary = @(get-GraphUsers -domainName $domainName -getPrimarySMTP:$true)

    if ($usersPrimary.count -gt 0)
    {
        out-logfile -string "Users were returned - split into dir sync and non dir synced users."

        $dirSyncUsers = @(split-GraphObjects -objectArray $usersPrimary -isDirSync:$true)
        $dirSyncTracking += $dirSyncUsers

        #$cloudUsers = @(split-GraphObjects -objectArray $users -isDirSync:$false)

        out-xmlFile -itemToExport $usersPrimary -itemNameToExport $exportFiles.UsersPrimarySMTP

        out-logfile -string "If users are directory sync - change SOA to cloud."

        if ($dirSyncUsers.count -gt 0)
        {
            out-logfile -string "Directory sync users present - change SOA."

            update-DirSyncStatus -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -Objects $dirSyncUsers -userOrGroup "User"
        }
        else 
        {
            out-logfile -string "All users were cloud only - proceed."
        }

        out-logfile -string "Proceed with UPN adjustments"

        update-userPrimarySMTP -userObjects $usersPrimary
    }
    else 
    {
        out-logfile -string "No users with an associated UPN found."
    }
    
    out-logfile -string "Exiting Remove-ObjectDependencies"

}