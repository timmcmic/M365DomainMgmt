function promote-subDomain
{
    param(
        [Parameter(Mandatory=$true)]
        $domainInfo,
        [Parameter(Mandatory=$true)]
        $exportFile
    )

    out-logfile -string "Entering promote-subDomain"

    Out-logfile -string "Validate domain is verified in tenant."

    $global:htmlTime['ValidateVerifiedDomain']=Get-Date

    if ($domainInfo.isVerified -eq $TRUE)
    {
        out-logfile -string "The domain is validated in the tenant - proceed."
    }
    else 
    {
        out-logfile -string "The domain is not verified in the tenant." -isError:$true
    }

    out-logfile -string "Validate domain is a sub domain."

    $global:htmlTime['ValidateRootDomain']=Get-Date

    if ($domainInfo.isRoot -eq $False)
    {
        out-logfile -string "The domain is a sub domain - proceed."
    }
    else 
    {
        out-logfile -string "The domain is a root domain and cannot be promoted." -isError:$true
    }

    out-logfile -string "Ensure that the domain has no dependencies in M365."

    $global:htmlTime['GetDomainUsers']=Get-Date

    $domainDependencies = get-GraphUsers -domainName $domainInfo.id -getUPN:$TRUE

    if ($domainDependencies.count -gt 0)
    {
        out-logfile -string "The domain has dependencies in M365 (appears in users UPNs) and cannot be promoted." -isError:$true
    }
    else 
    {
        out-logfile -string "The domain has no dependencies in M365 and can be promoted."
    }

    $global:htmlTime['PromoteDomain']=Get-Date

    try {
        Invoke-MGPromoteDomain -DomainId $domainInfo.id -errorAction STOP
        out-logfile -string "The domain was successfully promoted to a root domain."
    }
    catch {
        out-logfile -string "The domain was not successfully promoted to a root domain."
        out-logfile -string $_ -isError:$TRUE
    }

    $global:htmlData['Promoted Domain Information'] = test-domainName -domainName $domainInfo.id

    out-xmlFile -itemToExport $domainInfo -itemNameToExport $exportFile.promotedSubDomain

    $global:htmlData['Domain Information'] = $domainInfo
}