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
        $userOrGroup
    )
   
    $errorUsers = @()

    out-logfile -string "Entering Update-UserDirSyncStatus"

    if ($userOrGroup = "User")
    {
         foreach ($user in $objects)
        {
            $url = get-GraphURL -id $user.id -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -userOrGroup $userOrGroup

            try {
                run-graphCommand -url $url -disable:$TRUE -errorAction STOP
            }
            catch {
                out-logfile -string "Error updating dir sync status."
                out-logfile -string $_
                $errorArray += $user.id
                $errorArray += $user.userprincipalName
            }
        }
    }

    if ($errorArray.count -gt 0)
    {
        out-logfile -string "************************"
        out-logfile -string "ERRORS ENCOUTERED - THE FOLLOWING USERS COULD NOT HAVE DIRSYNC DISABLED"

        foreach ($errorUser in $errorArray)
        {
            out-logfile -string $errorUser
        }

        out-logfile -string "************************"

        out-logfile -string "Dirsync users could not be disabled - unable to proceed" -isError:$TRUE
    }
    else 
    {
        out-logfile -string "No errors encoutered."
    }

    out-logfile -string "Exiting Update-UserDirSyncStatus"
}