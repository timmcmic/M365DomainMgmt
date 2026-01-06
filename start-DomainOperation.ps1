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

    #Declare variables

    $isSingleOperation = $FALSE

    if ($domainName -eq $global:testString)
    {
        out-logfile -string "Domain was not specified at runtime."

        $domainName = get-domainName
    }
    else
    {
        out-logfile -string "Domain was specified at runtime - proceed."
    }

    if ($domainOperation -eq $global:testString)
    {
        out-logfile -string "Operation not specified - determine next action."
        $domainOperation = get-DomainOperation
    }
    else
    {
        out-logfile -string "Operation is specified - single operation action."
        $isSingleOperation = $TRUE
    }

    out-logfile -string ("Domain Name: "+$domainName)
    out-logfile -string ("Domain Operation: "+$domaionOperation)

    out-logfile -string "Exiting Start-DomainOperation"
}