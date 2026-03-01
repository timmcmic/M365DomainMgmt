function new-msGraphConnection
{
    Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $msGraphHashTable
    )

    out-logfile -string "Entering new-msGraphConnection"

    $msGraphStatic=@{}
    $msGraphStatic['msGraphInteractive']="Interactive"
    $msGraphStatic['msGraphCertificate']="Certificate"
    $msGraphStatic['msGraphClientSecret']="ClientSecret"

    switch ($msGraphhashTable.msGraphAuthenticationType) {
        $msGraphStatic.msGraphInteractive 
        {
            out-logfile -string "Graph interactive authentication specified." 
            new-msGraphInteractive -msGraphHashTable $msGraphHashTable
        }
        $msGraphStatic.msGraphCertificate
        {  
            out-logfile -string "Graph certificate authentication specified."
            new-msGraphCertificate -msGraphHashTable $msGraphHashTable
        }
        $msGraphStatic.msGraphClientSecret  
        {  
            out-logfile -string "Graph client secret authentication specified."
            new-msGraphClientSecret -msGraphHashTable $msGraphHashTable
        }
    }

    out-logfile -string "Exiting new-msGraphConnection"
}