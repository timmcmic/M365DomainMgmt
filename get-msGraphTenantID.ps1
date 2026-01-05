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
        out-logfile -string "Entering get-msGraphTenantID"
        
        write-host ""
        write-host "*********************************"
        $msGraphTenantID = read-host "Provide an Entra / Graph TenantID"
        write-host "*********************************"
        write-host ""

        out-logfile -string "Exiting get-msGraphTenantID"

        return $msGraphTenantID
    }