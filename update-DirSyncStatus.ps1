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

    if ($userOrGroup = "User")
    {
        foreach ($user in $objects)
        {
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

    out-logfile -string "Exiting Update-UserDirSyncStatus"
}