function get-onMicrosoft
{
    $onMicrosoft = "onmicrosoft.us"
    $mailFilter = "mail.onmicrosoft.us"
    $domains = @()

    out-logfile -string "Entering get-onMicrosoft"

    out-logfile -string "Getting all domains that contain onmicrosoft.us"

    try {
        $domains = @(get-mgDomain -all -errorAction STOP | where {$_.id.EndsWith($onMicrosoft)})
    }
    catch {
        out-logfile $_
        out-logfile -string "Unable to obtain onmicrosoft.us domains." -isError:$true
    }

    foreach ($domain in $domains)
    {
        out-logfile -string $domain.Id
    }

    out-logfile -string "Filter the domains to obtain only those that are domain.onmicrosoft.us"

    $domains = @($domains | where {$_.id -notmatch $mailFilter})

    foreach ($domain in $domains)
    {
        out-logfile -string $domain.id
    }

    out-logfile -string "It is possible that there are multiple onmicrosoft.com domains - locating the current failback domain."

    if ($domains.count -gt 1)
    {
        out-logfile -string "Domain count > 1."
        $domain = $domains | where {$_.isInitial -eq $true}
    }
    else 
    {
        $domain = $domains[0]
    }

    out-logfile -string "The domain that will be returned:"
    out-logfile -string $domain.Id

    return $domain.Id
}