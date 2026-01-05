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
        $msGraphTenantID = read-host "Provied an Entra / Graph TenantID: "

        return $msGraphTenantID
    }