<#
    .SYNOPSIS

    This function creates the msGraph connection to support additional functions.

    .DESCRIPTION

    This function creates the msGraph connection to support additional functions.

    .PARAMETER msGraphEnvironmentName

    The graph environment that the work will be performed in.

    .OUTPUTS

    None

    .EXAMPLE

    validate-msGraphConnection -msGraphScopesRequired $msGraphScopesRequired

    #>
    Function start-DomainOperation
{
    [cmdletbinding()]

    Param
    (
        [Parameter(Mandatory = $true)]
        [string]$domainName,
        [Parameter(Mandatory = $true)]
        [string]$domainOperation
    )

    #Define local variables.

    $domainAdd = "Add"
    $domainRemove = "Remove"
    $domainConfirm = "Confirm"
    $domainForceDomainTakeOver = "ForceDomainTakeOver"
    $localDomainName = ""

    out-logfile -string "Entering Start-DomainOperation"

    if ($domainName -eq $global:testString)
    {
        out-logfile -string "Domain was not specified at runtime."
        
        write-host ""
        write-host "***************"
        $localDomainName = Read-Host "Enter Domain Name"
        write-host "***************"
        write-host ""
    }
    else 
    {
        out-logfile -string "Domain specified at runtime."
        $localDomainName = $domainName
    }

    out-logfile -string ("Domain specified: "+$localDomainName)

    out-logfile -string "Exiting Start-DomainOperation"
}