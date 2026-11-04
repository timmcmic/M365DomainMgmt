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
            write-host "1:  New / Add a Domain (Triggers Domain Verfification)"
            write-host "2:  New / Add a Domain (No Domain Verification)"
            write-host "3:  Verify Domain a Domain"
            write-host "4:  Remove Domain"
            write-host "5:  Remove Domain"
            write-host "6:  Force Domain Takeover (External Takeover Method)"
            write-host "7:  Get Domain DNS Verification Records"
            write-host "8:  Test Domain Verification Records in Public DNS"
            write-host "9:  Display M365 DNS Records for Public DNS"
            write-host "10: Promote Sub Domain"

            $selection = Read-Host

            switch ($selection) {
                1 { $domainOperation = $domainOperations.New  }
                2 { $domainOperation = $domainOperations.NewWOConfirm}
                3 { $domainOperation = $domainOperations.Confirm }
                4 { $domainOperation = $domainOperations.remove }
                5 { $domainOperation = $domainOperations.removeDelete }
                6 { $domainOperation = $domainOperations.GetVerificationRecords }
                7 { $domainOperation = $domainOperations.TestDNS}
                8 { $domainOperation = $domainOperations.DisplayDNSRecords}
                9 { $domainOperation = $domainOperations.PromoteSubDomain}
                10 { $domainOperation = $domainOperations.PromoteSubDomain}
                default {out-logfile -string "Please select a valid option from the list on next run." -isError:$TRUE}
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
        $domainOperations.DisplayDNSRecords
        {
            out-logfile -string "Display DNS Records operations specified"
            $domainOperation = $domainOperations.DisplayDNSRecords
        }
        $domainOperations.PromoteSubDomain
        {
            out-logfile -string "Promote Sub Domain operation specified"
            $domainOperation = $domainOperations.PromoteSubDomain
        }
        $domainOperation.removeDelete
        {
            out-logfile -string "Remove delete operation specified"
            $domainOperation = $domainOperations.removeDelete
        }
    }

    out-logfile -string "Exiting get-DomainOperation"

    return $domainOperation
}