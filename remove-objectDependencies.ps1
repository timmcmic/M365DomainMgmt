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

    out-logfile -string ("Count of users with UPN: "+$usersUPN.Count)

    out-logfile -string "Obtaining all users that have a proxy address with the domain."

    $usersProxy = @(get-GraphUsers -domainName $domainName -getSecondarySMTP:$TRUE)

    out-logfile -string ("Count of users with proxy address: "+$usersProxy.Count)

    out-logfile -string "Combine the two types of users to determine disable dir sync steps."

    $usersCombined = $usersUPN + $usersProxy

    out-logfile -string ("Count of users combined: "+$usersCombined.Count)

    out-logfile -string "Filter the users to unique IDs..."

    $usersCombined = $usersCombined | Sort-Object -Unique -Property Id

    out-logfile -string "Determine all objects that require directory sync disabled."

    if ($usersCombined.count -gt 0)
    {
        out-logfile -string "Users were returned - split into dir sync and non dir synced users."

        $dirSyncUsers = @(split-GraphObjects -objectArray $usersCombined -isDirSync:$true)

        if ($dirSyncUsers.count -gt 0)
        {
            out-xmlFile -itemToExport $dirSyncUsers -itemNameToExport $exportFiles.UsersDirectorySync

            out-logfile -string "Directory sync users present - change SOA."

            update-DirSyncStatus -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -Objects $dirSyncUsers -userOrGroup "User"

            start-sleepProgress -sleepString "Sleeping to allow dirsync status to propogate" -sleepSeconds 300
        }
        else 
        {
            out-logfile -string "All users were cloud only - proceed."
        }
    }
    else 
    {
       out-logfile -string "No objects meeting the domain criteria were discovered."
    }

    $usersCombined = @()

    if ($usersUPN.count -gt 0)
    {
        out-logfile -string "Proceed with UPN adjustments"

        out-xmlFile -itemToExport $usersUPN -itemNameToExport $exportFiles.UsersUPN

        update-userUPN -userObjects $usersUPN -domainNam $domainName -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments

        start-sleepProgress -sleepString "Sleeping to allow UPN changes to propogate" -sleepSeconds 300
    }
    else 
    {
        out-logfile -string "No users with an associated UPN found."
    }

    if ($usersProxy.count -gt 0)
    {
        out-logfile -string "Proceed with SMTP proxy address adjustments"

        out-xmlFile -itemToExport $usersProxy -itemNameToExport $exportFiles.UsersSMTP

        update-usersPrimarySMTP -userObjects $usersProxy -domainName $domainName
    }

    out-logfile -string "Start group processing..."

    $groupsProxy = @(get-GraphGroups -domainName $domainName)

    if ($groupsProxy.count -gt 0)
    {
        out-xmlFile -itemToExport $groupsProxy -itemNameToExport $exportFiles.GroupsProxy

        out-logfile -string "Groups were found that require processing - handle dir sync groups."

        $dirSyncGroups = @(split-GraphObjects -objectArray $groupsProxy -isDirSync:$true)
        
        if ($dirSyncGroups.count -gt 0)
        {
            out-xmlFile -itemToExport $dirSyncGroups -itemNameToExport $exportFiles.GroupsDirectorySync

            out-logfile -string "Directory sync groups present - change SOA."

            update-DirSyncStatus -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -Objects $dirSyncGroups -userOrGroup "Group"

            start-sleepProgress -sleepString "Sleeping to allow dirsync status to propogate" -sleepSeconds 300
        }
        else 
        {
            out-logfile -string "All users were cloud only - proceed."
        }

        out-logfile -string "Update proxy addresses on groups."

        update-groupsPrimarySMTP -userObjects $groupsProxy -domainName $domainName
    }

    start-removeDomain -domainName $domainName -msGraphEnvironmentName $msGraphEnvironmentName

    if ($dirSyncUsers.count -gt 0)
    {
        out-logfile -string "Directory sync users present - change SOA back."

        update-DirSyncStatus -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -Objects $dirSyncUsers -userOrGroup "User" -enableOrDisable "Enable"

        start-sleepProgress -sleepString "Sleeping to allow dirsync status to propogate" -sleepSeconds 300
    }
    else 
    {
        out-logfile -string "All users were cloud only - proceed."
    }

    if ($dirSyncGroups.count -gt 0)
    {
        out-logfile -string "Directory sync users present - change SOA back."

        update-DirSyncStatus -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -Objects $dirSyncGroups -userOrGroup "Group" -enableOrDisable "Enable"

        start-sleepProgress -sleepString "Sleeping to allow dirsync status to propogate" -sleepSeconds 300
    }
    else 
    {
        out-logfile -string "All groups were cloud only - proceed."
    }

    out-logfile -string "Exiting Remove-ObjectDependencies"
}