function get-DomainOperation
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainOperation,
        [Parameter(Mandatory = $true)]
        $domainOperations
    )

    out-logfile -string "Entering get-DomainOperation"
    
    switch ($domainOperation) {
        $domainOperations.None 
        {  
            out-logfile -string "No operation specified."
            
            write-host "Select a domain operation from the list below:"
            write-host "1:  New / Add a Domain"
            write-host "2:  Confirm a Domain"
            write-host "3:  Remove a Domain"
            write-host "4:  Force Domain Takeover (External Takeover Method)"

            $selection = Read-Host

            switch ($selection) {
                $domainOperations.New { $domainOperation = $domainOperations.New  }
                $domainOperations.Confirm  {$domainOperation = $domainOperations.Confirm }
                $domainOperations.remove { $domainOperation = $domainOperations.remove }
                $domainOperations.ForceTakeOver { $domainOperation = $domainOperations.ForceTakeOver }
            }
        }
        $domainOperations.New 
        {  
            out-logfile -string "New operation specified."
            $domainOperation = $domainOperations.New 
        }
        $domainOperations.Confirm 
        {  
            out-logfile -string "Confirm operation specified."
            $domainOperation = $domainOperations.Confirm 
        }
        $domainOperations.Remove 
        {  
            out-logfile -string "Remove operation specified."
            $domainOperation = $domainOperations.remove 
        }
        $domainOperations.ForceTakeOver 
        {  
            out-logfile -string "ForceTakeOver operation specified."
            $domainOperation = $domainOperations.ForceTakeOver 
        }
    }

    out-logfile -string "Exiting get-DomainOperation"

    return $domainOperation
}