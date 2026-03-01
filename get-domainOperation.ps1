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
            $domainOperation = $domainOperations.None 
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