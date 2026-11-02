function test-domainInfo
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainInfo
    )

    out-logfile -string "Entering test-DomainInfo"
    
    if ($domainInfo.isVerified -eq $TRUE -and $domainInfo.isRoot -eq $TRUE)
    {
        out-logfile -string "The domain is already added and verified in the existing tenant."
        out-logfile -string $domainInfo.isVerified
        out-logfile -string "ERROR:  Domain already verified in tenant." -isError:$true
    }
    elseif ($domainInfo.isVerified -eq $TRUE -and $domainInfo.isRoot -eq $false)
    {
        out-logfile -string "The domain is a sub domain in the tenant.."
        out-logfile -string $domainInfo.isRoot  
    }
    else 
    {
        out-logfile -string "The domain is not currently verified in the tenant."
    }

    out-logfile -string "Exiting test-DomainInfo"
}