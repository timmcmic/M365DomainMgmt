function update-applicationURI
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $applications,
        [Parameter(Mandatory = $true)]
        $domainName
    )

    out-logfile -string "Entering Update-applicationURI"

    out-logfile -string "Obtain the onmicrosoft.com domain name"

    $onMicrosoft = get-onMicrosoft -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments

    $errorArray=@()

    $ProgressDelta = 100/($applications.count); $PercentComplete = 0; $MbxNumber = 0

    foreach ($application in $applications)
    {
        $MbxNumber++

        write-progress -activity "Processing application" -status $application.appId -PercentComplete $PercentComplete

        $PercentComplete += $ProgressDelta

        out-logfile -string ("Processing ID: "+$application.appid)
        out-logfile -string ("Processing URI: "+$application.identifierURIs)

        $newURI = $application.identifierURIs.replace($domainName,$onMicrosoft)

        out-logfile -string $newURI

        try {
            update-mgApplication -applicationID $application.id -IdentifierURIs $newURI -errorAction STOP

            out-logfile -string "Updated URI successfully."

            $functionObject = New-Object PSObject -Property @{
                ID = $application.ID
                AppID = $application.appID
                OriginalURI = $application.identifierURIs
                NewURI = $newURI
                Name = $application.displayName    
                ObjectType = "Application"
                ErrorMessage = "None"
            }

            $global:HTMLApplications.add($functionObject)
        }
        catch {
            out-logfile -string "Error"
            out-logfile -string $_

           $functionObject = New-Object PSObject -Property @{
                ID = $application.ID
                AppID = $application.appID
                OriginalURI = $application.identifierURIs
                NewURI = $newURI
                Name = $application.displayName    
                ObjectType = "Application"
                ErrorMessage = $_
            }

            $global:HTMLApplications.add($functionObject)
        }
    }

    write-progress -activity "Processing Application" -completed

    out-logfile -string "Exiting Update-ApplicationURI"
}