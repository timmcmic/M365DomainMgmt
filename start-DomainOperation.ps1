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
        [string]$domainOperation,
        [Parameter(Mandatory = $true)]
        [string]$msGraphEnvironmentName
    )

    function domainOperation
    {
        out-logfile -string "HERE"
    }

    #Define local variables.

    $domainAdd = "Add"
    $domainRemove = "Remove"
    $domainConfirm = "Confirm"
    $domainForceDomainTakeOver = "ForceDomainTakeOver"
    $localDomainName = ""
    $isSingleOperation = $false

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
        $isSingleOperation = $TRUE
    }

    out-logfile -string ("Domain specified: "+$localDomainName)

    do {
        if ($isSingleOperation -eq $false)
        {
            out-logfile -string "A domain operation was not provided.."

            write-host ""
            write-host "*********************************************"
            write-host "Select the domain operation to perform:"
            write-host "1:  Add"
            write-host "2:  Remove"
            write-host "3:  Confirm"
            write-host "4:  ForceDomainTakeOver"
            write-host "5:  EXIT"

            $selection = read-host "Please make an operation selection: "

            out-logfile -string ("Operation Selected = "+$selection)

            switch($selection)
            {
                '1' {
                    out-logfile -string "Add"
                    domainOperation
                } '2' {
                    out-logfile -string "Remove"
                } '3' {
                    out-logfile -string "Confirm"
                } '4' {
                    out-logfile -string "ForceDomainTakeOver"
                } '5' {
                    out-logfile -string "Exit"
                } default {
                    out-logfile -string "Invalid operation selection made." -isError:$TRUE
                }
            }
        }
        else 
        {
            out-logfile -string "A valid domain operation was specified at runtime."
            $selection = 5
        }
    } until (
        $selection = 5
    )

    out-logfile -string "Exiting Start-DomainOperation"
}