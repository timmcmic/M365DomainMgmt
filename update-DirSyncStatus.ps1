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

    out-logfile -string "Exiting Update-UserDirSyncStatus"
}