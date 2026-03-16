function calculate-publicDNSRecords
{
    Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironmentName,
        [Parameter(Mandatory = $true)]
        $msGraphEnvironments
    )

    out-logfile -string "Entering calculate-publicDNSRecords"

    switch ($msGraphEnvironmentName) {
        $msGraphEnvironments.msGraphGlobal 
        {  
            out-logfile -string "Global envronment selected."

            calculate-publicDNSRecordsGlobal -domainName $domainName
        }
        $msGraphEnvironments.msGraphUSGov 
        {  
            out-logfile -string "USGov envronment selected."
        }
        $msGraphEnvironments.msGraphUSGovDOD
        {  
            out-logfile -string "USGovDOD envronment selected."
        }
        $msGraphEnvironments.msGraphChina
        {  
            out-logfile -string "China envronment selected."
        }
    }
}