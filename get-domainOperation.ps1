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
        }
        $domainOperations.New 
        {  
            out-logfile -string "New operation specified."
        }
        $domainOperations.Confirm 
        {  
            out-logfile -string "Confirm operation specified."
        }
        $domainOperations.Remove 
        {  
            out-logfile -string "Remove operation specified."
        }
        $domainOperations.ForceTakeOver 
        {  
            out-logfile -string "ForceTakeOver operation specified."
        }
    }
}