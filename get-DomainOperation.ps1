function get-DomainOperation
{
    out-logfile -string "Entering Get-DomainOperation"

    write-host ""
    write-host "*********************************************"
    write-host "Select the domain operation to perform:"
    write-host "1:  New"
    write-host "2:  Remove"
    write-host "3:  Confirm"
    write-host "4:  ForceDomainTakeOver"
    write-host "5:  EXIT"

    $selection = read-host "Please make an operation selection: "

    out-logfile -string ("Operation Selected = "+$selection)

    switch($selection)
    {
        '1' {
            out-logfile -string "New"
            $domainOperation = "New"
        } '2' {
            out-logfile -string "Remove"
            $domainOperation = "Remove"
        } '3' {
            out-logfile -string "Confirm"
            $domainOperation = "Confirm"
        } '4' {
            out-logfile -string "ForceDomainTakeOver"
            $domainOperation = "ForceDomainTakeOver"
        } '5' {
            out-logfile -string "Exit"
            $domainOperation = "Exit"
        } default {
            out-logfile -string "Invalid operation selection made." -isError:$TRUE
        }
    }

    out-logfile -string $domainOperation
    out-logfile -string "Exiting Get-DomainOperation"

    return $domainOperation
}