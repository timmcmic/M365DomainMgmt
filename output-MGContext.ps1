function output-MGContext
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $exportFile
    )

    out-logfile -string "Entering output-MGContext"

    out-logfile -string "Gathering MGContext"

    try {
        $context = Get-MgContext -ErrorAction Stop
        out-logfile -string "MGContext gathered successfully."
    }
    catch {
        out-logfile -string $_
        out-logfile -string "Unable to gather MGContext." -isError:$true
    }

    out-xmlFile -itemToExport $context -itemNameToExport $exportFile
}