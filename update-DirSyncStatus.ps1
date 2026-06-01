function update-DirSyncStatus
{
    param (
        [Parameter(Mandatory = $true)]
        $msGraphEnvironmentName,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironments,
        [Parameter(Mandatory = $true)]
        $objects,
        [Parameter(Mandatory = $true)]
        $userOrGroup,
        [Parameter(Mandatory = $false)]
        $enableOrDisable = "Disable"
    )
   
    out-logfile -string "Entering Update-UserDirSyncStatus"

    if ($userOrGroup -eq "User")
    {
        $ProgressDelta = 100/($objects.count); $PercentComplete = 0; $MbxNumber = 0

        foreach ($user in $objects)
        {
            $MbxNumber++

            write-progress -activity "Processing Recipient" -status $user.Id -PercentComplete $PercentComplete

            $PercentComplete += $ProgressDelta

            $functionObject = New-Object PSObject -Property @{
                    ID = $user.id
                    UPN = $user.userPrincipalName
                    Name = $user.displayName    
                    ObjectType = "User"
                    PreStatus = "None"
                    PostStatus = "None"
                    ErrorMessage = "None"
            }

            $url = get-GraphURL -id $user.id -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -userOrGroup $userOrGroup

            try {
                $status = run-graphCommand -url $url -disable:$false -get:$TRUE -patch:$false -errorAction STOP    
            }
            catch {
                out-logfile -string "Unable to get the pre-disablement status."
                out-logfile -string $_ -isError:$TRUE
            }

            $functionObject.PreStatus = $status

            try 
            {
                if ($enableOrDisable -eq "Disable")
                {
                    run-graphCommand -url $url -disable:$TRUE -patch:$TRUE -get:$false -errorAction STOP
                }
                else 
                {
                    run-graphCommand -url $url -disable:$false -patch:$TRUE -get:$false -errorAction STOP
                }

                try {
                    $status = run-graphCommand -url $url -disable:$false -get:$TRUE -patch:$false -errorAction STOP
                }
                catch {
                    out-logfile -string "Unable to get the pre-disablement status."
                    out-logfile -string $_ -isError:$TRUE
                }

                $functionObject.PostStatus = $status

                if ($enableOrDisable -eq "Disable")
                {
                    $global:HTMLDisableDirSyncSuccess.add($functionObject)
                }
                else 
                {
                    $global:HTMLEnabledDirSyncSuccess.add($functionObject)
                }
            }
            catch {
                out-logfile -string "Error updating dir sync status."

                $functionObject.errorMessage = $_

                if ($enableOrDisable -eq "Disable")
                {
                    $global:HTMLDisableDirSyncErrors.add($functionObject)

                }
                else 
                {
                    $global:HTMLEnabledDirSyncErrors.add($functionObject)
                }
            }
        }
    }

    if ($userOrGroup -eq "Group")
    {
        $ProgressDelta = 100/($objects.count); $PercentComplete = 0; $MbxNumber = 0

        foreach ($user in $objects)
        {
            $MbxNumber++

            write-progress -activity "Processing Recipient" -status $user.Id -PercentComplete $PercentComplete

            $PercentComplete += $ProgressDelta

            $functionObject = New-Object PSObject -Property @{
                    ID = $user.id
                    Name = $user.displayName    
                    ObjectType = "Group"
                    PreStatus = "None"
                    PostStatus = "None"
                    ErrorMessage = "None"
            }

            $url = get-GraphURL -id $user.id -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -userOrGroup $userOrGroup

            try {
                $status = run-graphCommand -url $url -disable:$false -get:$TRUE -patch:$false -errorAction STOP    
            }
            catch {
                out-logfile -string "Unable to get the pre-disablement status."
                out-logfile -string $_ -isError:$TRUE
            }

            $functionObject.PreStatus = $status

            try 
            {
                if ($enableOrDisable -eq "Disable")
                {
                    run-graphCommand -url $url -disable:$TRUE -patch:$TRUE -get:$false -errorAction STOP
                }
                else 
                {
                    run-graphCommand -url $url -disable:$false -patch:$TRUE -get:$false -errorAction STOP
                }

                try {
                    $status = run-graphCommand -url $url -disable:$false -get:$TRUE -patch:$false -errorAction STOP
                }
                catch {
                    out-logfile -string "Unable to get the pre-disablement status."
                    out-logfile -string $_ -isError:$TRUE
                }

                $functionObject.PostStatus = $status

                if ($enableOrDisable -eq "Disable")
                {
                    $global:HTMLDisableDirSyncSuccess.add($functionObject)
                }
                else 
                {
                    $global:HTMLEnabledDirSyncSuccess.add($functionObject)
                }
            }
            catch {
                out-logfile -string "Error updating dir sync status."

                $functionObject.errorMessage = $_

                if ($enableOrDisable -eq "Disable")
                {
                    $global:HTMLDisableDirSyncSuccess.add($functionObject)
                }
                else 
                {
                    $global:HTMLEnabledDirSyncSuccess.add($functionObject)
                }
            }
        }
    }

    write-progress -activity "Processing Recipient" -completed

    out-logfile -string "Exiting Update-UserDirSyncStatus"
}