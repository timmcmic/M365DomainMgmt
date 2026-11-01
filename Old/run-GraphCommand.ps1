function run-graphCommand
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $url,
        [Parameter(Mandatory = $true)]
        $disable = $false,
        [Parameter(Mandatory = $true)]
        $get = $false,
        [Parameter(Mandatory = $true)]
        $patch = $false
    )

    if ($patch -eq $TRUE)
    {
        $body = @{}

        if ($disable -eq $TRUE)
        {
            $body = @{ isCloudManaged = $true}
        }
        else 
        {
            $body = @{ isCloudManaged = $false}
        }

        try {
            $body = $body | ConvertTo-Json -ErrorAction Stop
        }
        catch {
            out-logfile -string $_
            out-logfile -string "Unable to convert body paramters to json." -isError:$true
        }

        out-logfile -string "Entering Run-GraphCommand"

        Invoke-MgGraphRequest -Method "Patch" -Uri $url -body $body -errorAction STOP
    }
    else 
    {
        $returnData = Invoke-MgGraphRequest -Method "Get" -Uri $url -errorAction STOP
    }

    out-logfile -string "Exiting Run-GraphCommand"

    if ($get -eq $TRUE)
    {
        return $returnData.isCloudManaged
    }
}