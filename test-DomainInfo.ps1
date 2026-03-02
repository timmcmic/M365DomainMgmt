function test-domainInfo
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainInfo
    )

    out-logfile -string "Entering test-DomainInfo"
    
    if ($domainInfo.isVerified -eq $TRUE)
    {
        out-logfile -string "The domain is already added and verified in the existing tenant."
        out-logfile -string $domainInfo.isVerified
        out-logfile -string "ERROR:  Domain already verified in tenant." -isError:$true
    }
    else 
    {
        out-logfile -string "The domain is not currently verified in the tenant."
    }

    out-logfile -string "Exiting test-DomainInfo"
}