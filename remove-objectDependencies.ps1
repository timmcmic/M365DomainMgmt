function remove-objectDependencies
{
     Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $exportFiles,
        [Parameter(Mandatory = $true)]
        $domainName
    )

    out-logfile -string "Entering Remove-ObjectDependencies"

    

    out-logfile -string "Exiting Remove-ObjectDependencies"
}