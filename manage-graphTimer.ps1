function manage-graphTimer
{
    Param
    (
        [Parameter(Mandatory = $true)]
        [boolean]$start
    )

    if ($start -eq $TRUE)
    {
        $global:timer = [System.Timers.Timer]::new(900000)

        $timer.AutoReset = $true

        $action = {
            # Retrieve the log path passed via -MessageData
            $logPath = $Event.MessageData

            try
            {
                Get-MgUser -UserId (Get-MgContext).Account -errorAction STOP
                $success = "Successful"
            }
            catch
            {
                $success = $_
            }
            
            # Extract event details
            $timeStamp  = $Event.TimeGenerated.ToString("yyyy-MM-dd HH:mm:ss")
            $eventString = "Processed timer action..."
            
            # Format and write to the log file
            $logEntry = "[$timeStamp] [$eventstring] [$success]"
            Add-Content -Path $logPath -Value $logEntry

            write-host $logEntry -foregroundColor Blue
        }

        $eventLog = $global:logFile.replace(".log",".txt")

        $global:event = Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action $action -messageData $eventLog 

        $timer.Start()
    }
    else
    {
        $global:timer.Stop()
        Unregister-Event -SourceIdentifier $global:event.Name
        $global:timer.Dispose()
    }
}