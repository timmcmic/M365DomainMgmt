function new-msGraphConnection
{
    Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $msGraphHashTable
    )

    out-logfile -string "Entering new-msGraphConnection"

    $msGraphInteractive = "Interactive"
    $msGraphCertificate = "Certificate"
    $msGraphClientSecret = "ClientSecret"

    switch ($msGraphhashTable.msGraphAuthenticationType) {
        $msGraphInteractive 
        {
            out-logfile -string "Graph interactive authentication specified." 
            new-msGraphInteractive -msGraphHashTable $msGraphHashTable
        }
        $msGraphCertificate 
        {  
            out-logfile -string "Graph certificate authentication specified."
        }
        $msGraphClientSecret 
        {  
            out-logfile -string "Graph client secret authentication specified."
        }
    }

    out-logfile -string "Exiting new-msGraphConnection"
}