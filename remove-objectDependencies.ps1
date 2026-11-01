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

    $global:htmlTime['GetAllUsersUPN']=Get-Date

    $usersUPN = @(get-GraphUsers -domainName $domainName -getUPN:$TRUE)

    out-logfile -string ("Count of users with UPN: "+$usersUPN.Count)
    
    #read-host "Press enter to continue..."

    out-logfile -string "Obtaining all users that have a proxy address with the domain."

    $global:htmlTime['GetAllUsersProxy']=Get-Date

    $usersProxy = @(get-GraphUsers -domainName $domainName -getSecondarySMTP:$TRUE)

    out-logfile -string ("Count of users with proxy address: "+$usersProxy.Count)

   #read-host "Press enter to continue..."

    out-logfile -string "Combine the two types of users to determine disable dir sync steps."

    $global:htmlTime['CombineUsersAndProxy']=Get-Date

    $usersCombined = $usersUPN + $usersProxy

    out-logfile -string ("Count of users combined: "+$usersCombined.Count)

    #read-host "Press enter to continue..."

    out-logfile -string "Filter the users to unique IDs..."

    $global:htmlTime['SortCombinedList']=Get-Date

    $usersCombined = $usersCombined | Sort-Object -Unique -Property Id

    out-logfile -string ("Users combined filtered by id count: "+$usersCombined.Count)

    #read-host "Press enter to continue..."

    out-logfile -string "Determine all objects that require directory sync disabled."

    if ($usersCombined.count -gt 0)
    {
        out-logfile -string "Users were returned - split into dir sync and non dir synced users."

        $global:htmlTime['SplitDirSyncUsers']=Get-Date

        $dirSyncUsers = @(split-GraphObjects -objectArray $usersCombined -isDirSync:$true)

        out-logfile -string ("Directory synced users: "+$dirSyncUsers.count)

        #read-host "Press enter to continue..."

        if ($dirSyncUsers.count -gt 0)
        {
            $global:htmlTime['BeginProcessDirSyncUsers']=Get-Date

            $global:htmlTime['ExportDirSyncUsers']=Get-Date

            out-xmlFile -itemToExport $dirSyncUsers -itemNameToExport $exportFiles.UsersDirectorySync

            out-logfile -string "Directory sync users present - change SOA."

            $global:htmlTime['ChangeSOAtoCloud']=Get-Date

            update-DirSyncStatus -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -Objects $dirSyncUsers -userOrGroup "User"

            start-sleepProgress -sleepString "Sleeping to allow dirsync status to propogate" -sleepSeconds 300

            $global:htmlTime['EndProcessDirSyncUsers']=Get-Date

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
        $global:htmlTime['BeginProcessUserUPN']=Get-Date

        out-logfile -string "Proceed with UPN adjustments"

        $global:htmlTime['ExportUserUPN']=Get-Date

        out-xmlFile -itemToExport $usersUPN -itemNameToExport $exportFiles.UsersUPN

        $global:htmlTime['UpdateUserUPN']=Get-Date

        update-userUPN -userObjects $usersUPN -domainNam $domainName -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments

        start-sleepProgress -sleepString "Sleeping to allow UPN changes to propogate" -sleepSeconds 300

        $global:htmlTime['EndProcessUserUPN']=Get-Date
    }
    else 
    {
        out-logfile -string "No users with an associated UPN found."
    }

    if ($usersProxy.count -gt 0)
    {
        $global:htmlTime['BeginProcessUserSMTPAddresses']=Get-Date

        out-logfile -string "Proceed with SMTP proxy address adjustments"

        $global:htmlTime['ExportUserProxyAddresses']=Get-Date

        out-xmlFile -itemToExport $usersProxy -itemNameToExport $exportFiles.UsersSMTP

        $global:htmlTime['UpdateProxyAddresses']=Get-Date

        update-usersPrimarySMTP -userObjects $usersProxy -domainName $domainName

        start-sleepProgress -sleepString "Sleeping to allow user proxy address changes to propogate..." -sleepSeconds 300
                    
        $global:htmlTime['EndProcessProxyAddresses']=Get-Date
    }

    out-logfile -string "Start group processing..."

    $global:htmlTime['GetAllGroupsSMTP']=Get-Date

    $groupsProxy = @(get-GraphGroups -domainName $domainName)

    out-logfile -string ("Count of groups with proxy address: "+$groupsProxy.count)

    #read-host "Press enter to continue..."

    if ($groupsProxy.count -gt 0)
    {
        $global:htmlTime['StartProcessGroupsProxy']=Get-Date

        $global:htmlTime['ExportGroupsProxy']=Get-Date

        out-xmlFile -itemToExport $groupsProxy -itemNameToExport $exportFiles.GroupsProxy

        out-logfile -string "Groups were found that require processing - handle dir sync groups."

        $global:htmlTime['SplitDirSyncGroups']=Get-Date

        $dirSyncGroups = @(split-GraphObjects -objectArray $groupsProxy -isDirSync:$true)

        out-logfile -string ("Count of groups directory synced: "+$dirSyncGroups.count)

        #read-host "Press enter to continue..."
        
        if ($dirSyncGroups.count -gt 0)
        {
            $global:htmlTime['StartProcessDirSyncGroups']=Get-Date

            $global:htmlTime['ExportDirSyncGroups']=Get-Date

            out-xmlFile -itemToExport $dirSyncGroups -itemNameToExport $exportFiles.GroupsDirectorySync

            out-logfile -string "Directory sync groups present - change SOA."

            $global:htmlTime['ChangeGroupSOAToCloud']=Get-Date

            update-DirSyncStatus -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -Objects $dirSyncGroups -userOrGroup "Group"

            start-sleepProgress -sleepString "Sleeping to allow dirsync status to propogate" -sleepSeconds 300

            $global:htmlTime['EndProcessDirSyncGroups']=Get-Date
        }
        else 
        {
            out-logfile -string "All users were cloud only - proceed."
        }

        out-logfile -string "Update proxy addresses on groups."

        $global:htmlTime['ProcessGroupsSMTP']=Get-Date

        update-groupsPrimarySMTP -userObjects $groupsProxy -domainName $domainName

        start-sleepProgress -sleepString "Sleeping to allow group SMTP proxy address changes to propogate..." -sleepSeconds 300

        $global:htmlTime['EndProcessGroupsProxy']=Get-Date

    }

    $global:htmlTime['StartDomainRemovalActivity']=Get-Date

    start-removeDomain -domainName $domainName -msGraphEnvironmentName $msGraphEnvironmentName

    $global:htmlTime['EndDomainRemovalActivity']=Get-Date

    if ($global:HTMLDomainRemoved[0].errorMessage -eq "None" -and ($dirSyncUsers.count -gt 0) -or ($dirSyncGroups.count -gt 0))
    {
        if ($dirSyncUsers.count -gt 0)
        {
            out-logfile -string "Directory sync users present - change SOA back."

            $global:htmlTime['BeginRevertSOAUsers']=Get-Date

            update-DirSyncStatus -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -Objects $dirSyncUsers -userOrGroup "User" -enableOrDisable "Enable"
        }
        else 
        {
            out-logfile -string "All users were cloud only - proceed."
        }

        if ($dirSyncGroups.count -gt 0)
        {
            out-logfile -string "Directory sync users present - change SOA back."

            $global:htmlTime['BeginRevertSOACloud']=Get-Date

            update-DirSyncStatus -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -Objects $dirSyncGroups -userOrGroup "Group" -enableOrDisable "Enable"
        }
        else 
        {
            out-logfile -string "All groups were cloud only - proceed."
        }
    }
    elseif ($global:HTMLDomainRemoved[0].errorMessage -ne "None" -and ($dirSyncUsers.count -gt 0) -or ($dirSyncGroups.count -gt 0))
    {
        out-logfile -string '++++++++++++++++++++++++++++++++++'
        out-logfile -string "Multiple users or groups dir sync status changed to cloud only."
        out-logfile -string "Domain was not removed successfully."
        out-logfile -string "Rerun script and select restore dir sync status if you will not be fixing errors and removing domain."
        out-logfile -string '++++++++++++++++++++++++++++++++++'
    }
    else 
    {
        out-logfile -string "No dir sync users or groups were modified."
    }

    
    out-logfile -string "Exiting Remove-ObjectDependencies"
}