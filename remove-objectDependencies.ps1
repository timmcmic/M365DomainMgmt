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

    out-logfile -string "Get all users that are directory synced and have the domain as a UPN."

    $users = get-GraphUsers -domainName $domainName -getUPN:$TRUE

    if ($users.count -gt 0)
    {
        out-logfile -string "Users were returned - split into dir sync and non dir synced users."

        $dirSyncUsers = @(split-GraphObjects -objectArray $users -isDirSync:$true)

        $cloudUsers = @(split-GraphObjects -objectArray $users -isDirSync:$false)

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

        out-logfile -string "Proceed "
    }
    else 
    {
        out-logfile -string "No users with an associated UPN found."
    }


    
    out-logfile -string "Exiting Remove-ObjectDependencies"
}