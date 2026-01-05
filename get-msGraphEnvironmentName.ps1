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
        Param
        (
            [Parameter(Mandatory = $true)]
            [string]$msGraphEnvironmentName,
            [Parameter(Mandatory = $true)]
            [string]$testString
        )

        #Define variables.

        $global = "Global"
        $usGov = "USGov"
        $usDOD = "usDOD"
        $china = "China"

        out-logfile -string "Entering get-MSGraphEnvironmentName"

        if ($msGraphEnvironmentName -eq $testString)
        {
            out-logfile -string "An MSGraphEnvironment name was not defined."

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
        }
        else 
        {
            if (($msGraphEnvironmentName -eq $Global) -or ($msGraphEnvironmentName -eq $usGov) -or ($msGraphEnvironmentName -eq $usDOD) -or ($msGraphEnvironmentName -eq $China))
            {
                out-logfile -string "A msGraphEnvironnmentName was provied at runtime."
            }
            else 
            {
                out-logfile -string "ERROR:  Invalid environment passed at runtime." -isError:$TRUE
            }
        }

        write-host "*********************************************"
        write-host ""

        out-logfile -string "Exiting get-MSGraphEnvironmentName"

        return $msGraphEnvironmentName
    }