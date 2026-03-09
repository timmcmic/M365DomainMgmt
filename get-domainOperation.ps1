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
            write-host "1:  New / Add a Domain (Triggers Domain Confirmation)"
            write-host "2:  New / Add a Domain (Without Domain Confirmation)"
            write-host "3:  Confirm a Domain"
            write-host "4:  Remove a Domain"
            write-host "5:  Force Domain Takeover (External Takeover Method)"
            write-host "6:  Get Verification Records"

            $selection = Read-Host

            switch ($selection) {
                1 { $domainOperation = $domainOperations.New  }
                2 { $domainOperation - $domainOperations.NewWOConfirm}
                3 { $domainOperation = $domainOperations.Confirm }
                4 { $domainOperation = $domainOperations.remove }
                5 { $domainOperation = $domainOperations.ForceTakeOver }
                6 { $domainOperation = $domainOperations.GetVerificationRecords }
                7 { $domainOperation = $domainOperations.TestDNS}
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
        $domainOperations.NewWOConfirm
        {
            out-logfile -string "NewWOConfirm operation specified."
            $domainOperation = $domainOperations.NewWOConfirm 
        }
        $domainOperations.GetVerificationRecords
        {
            out-logfile -string "NewWOConfirm operation specified."
            $domainOperation = $domainOperations.GetVerificationRecords 
        }
        $domainOperations.TestDNS
        {
            out-logfile -string "TestDNS operation specified"
            $domainOperation = $domainOperations.TestDNS
        }
    }

    out-logfile -string "Exiting get-DomainOperation"

    return $domainOperation
}