<#
    .SYNOPSIS

    This function obtains the msGraphTenantID if not previously defined.

    .DESCRIPTION

    This function obtains the msGraphTenantID if not previously defined.

    .EXAMPLE

    get-msGraphTenantID 

    #>
    Function get-msGraphEnvironmentName
    {
        out-logfile -string "Entering get-MSGraphEnvironmentName"

        $global = "Global"
        $usGov = "USGov"
        $usDOD = "usDOD"
        $china = "China"

        write-host ""
        write-host "*********************************************"
        write-host "Select the grpah environment for your tenant:"
        write-host "1:  Global"
        write-host "2:  USGov"
        write-host "3:  USDoD"
        write-host "4:  China"

        $selection = read-host "Please make a environment selection: "

        out-logfile -string ("Graph environment selected = "+$selection)

        switch($selection)
        {
            '1' {
                $msGraphEnvironmentName = $global
            } '2' {
                $msGraphEnvironmentName = $usGov
            } '3' {
                $msGraphEnvironmentName = $usDOD
            } '4' {
                $msGraphEnvironmentName = $China
            } default {
                out-logfile -string "Invalid environment selection made." -isError:$TRUE
            }
        }

        write-host "*********************************************"
        write-host ""

        out-logfile -string "Exiting get-MSGraphEnvironmentName"

        return $msGraphEnvironmentName
    }