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

    $msGraphEnvironmentName = "USGov"

    switch ($msGraphEnvironmentName) {
        $msGraphEnvironments.msGraphGlobal 
        {  
            out-logfile -string "Global envronment selected."

            calculate-publicDNSRecordsGlobal -domainName $domainName
        }
        $msGraphEnvironments.msGraphUSGov 
        {  
            out-logfile -string "USGovDOD environment selected."
            calculate-publicDNSRecordsUSGov -domainName $domainName
        }
        $msGraphEnvironments.msGraphUSGovDOD
        {  
            out-logfile -string "USGovDOD envronment selected."
            calculate-publicDNSRecordsOther -domainName $domainName -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments
        }
        $msGraphEnvironments.msGraphChina
        {  
            out-logfile -string "China envronment selected."
        }
    }
}