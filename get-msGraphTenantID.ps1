<#
    .SYNOPSIS

    This function obtains the msGraphTenantID if not previously defined.

    .DESCRIPTION

    This function obtains the msGraphTenantID if not previously defined.

    .EXAMPLE

    get-msGraphTenantID 

    #>
    Function get-msGraphTenantID
    {
        Param
        (
            [Parameter(Mandatory = $true)]
            [string]$msGraphTenantID,
            [Parameter(Mandatory = $true)]
            [string]$testString
        )

        out-logfile -string "Entering get-msGraphTenantID"

        if ($msGraphTenantID -eq $testString)
        {
            write-host ""
            write-host "*********************************"
            $msGraphTenantID = read-host "Provide an Entra / Graph TenantID"
            write-host "*********************************"
            write-host ""
        }
        else 
        {
            out-logfile -string "A graph tenant ID was provied at runtime."
        }

        out-logfile -string "Exiting get-msGraphTenantID"

        return $msGraphTenantID
    }