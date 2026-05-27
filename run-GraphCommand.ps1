function run-graphCommand
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $url,
        [Parameter(Mandatory = $true)]
        $disable = $false
    )

    if ($disable -eq $TRUE)
    {
        $body = @{}

        $body = @{ isCloudManaged = $true}

        try {
            $body = $body | ConvertTo-Json -ErrorAction Stop
        }
        catch {
            out-logfile -string $_
            out-logfile -string "Unable to convert body paramters to json." -isError:$true
        }
    }

    out-logfile -string "Entering Run-GraphCommand"

    Invoke-MgGraphRequest -Method "Patch" -Uri $url -body $body -errorAction STOP

    out-logfile -string "Exiting Run-GraphCommand"
}