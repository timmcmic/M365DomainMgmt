function get-domainName
{   
    out-logfile -string "Enter Get-DomainName"

    write-host ""
    write-host "***************"
    $localDomainName = Read-Host "Enter Domain Name"
    write-host "***************"
    write-host ""

    out-logfile -string "Exit Get-DomainName"

    return $localDomainName    
}