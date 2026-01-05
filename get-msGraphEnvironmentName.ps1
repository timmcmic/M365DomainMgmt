<#
    .SYNOPSIS

    This function obtains the msGraphTenantID if not previously defined.

    .DESCRIPTION

    This function obtains the msGraphEnvironmentName if not previously defined.

    .EXAMPLE

    get-msGraphTenantID -msGraphEnvironmentName $msGraphEnvironmentName -testString $testString

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
                    $msGraphEnvironmentName = $global:msGraphGlobal
                } '2' {
                    $msGraphEnvironmentName = $global:msGraphUSGov
                } '3' {
                    $msGraphEnvironmentName = $global:msGraphUSDOD
                } '4' {
                    $msGraphEnvironmentName = $global:msGraphChina
                } default {
                    out-logfile -string "Invalid environment selection made." -isError:$TRUE
                }
            }

            write-host "*********************************************"
            write-host ""
        }
        else 
        {
            if (($msGraphEnvironmentName -eq $global:msGraphGlobal) -or ($msGraphEnvironmentName -eq $global:msGraphUSGov) -or ($msGraphEnvironmentName -eq $global:msGraphUSDOD) -or ($msGraphEnvironmentName -eq $global:msGraphChina))
            {
                out-logfile -string "A msGraphEnvironnmentName was provied at runtime."
            }
            else 
            {
                out-logfile -string "ERROR:  Invalid environment passed at runtime." -isError:$TRUE
            }
        }

        out-logfile -string "Exiting get-MSGraphEnvironmentName"

        return $msGraphEnvironmentName
    }