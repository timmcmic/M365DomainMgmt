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

    $dirSyncUsers
    $cloudUsers

    out-logfile -string "Entering Remove-ObjectDependencies"

    out-logfile -string "Obtaining all users that have this domain as a UPN."

    $users = get-GraphUsers -domainName $domainName -getUPN:$TRUE

    if ($users.count -gt 0)
    {
        out-logfile -string "Users were returned - split into dir sync and non dir synced users."

        $dirSyncUsers = @(split-GraphObjects -objectArray $users -isDirSync:$true)

        #$cloudUsers = @(split-GraphObjects -objectArray $users -isDirSync:$false)

        out-xmlFile -itemToExport $users -itemNameToExport $exportFiles.UsersUPN

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

        #update-userUPN -userObjects $users -domainName $domainName -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments

        out-logfile -string "If users are directory sync - change SOA to on premises."

        if ($dirSyncUsers.count -gt 0)
        {
            out-logfile -string "Directory sync users present - change SOA."

            update-DirSyncStatus -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -Objects $dirSyncUsers -userOrGroup "User" -enableOrDisable "Enable"
        }
        else 
        {
            out-logfile -string "All users were cloud only - proceed."
        }
    }
    else 
    {
        out-logfile -string "No users with an associated UPN found."
    }


    
    out-logfile -string "Exiting Remove-ObjectDependencies"

}