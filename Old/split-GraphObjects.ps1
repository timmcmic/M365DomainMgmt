function split-graphObjects
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $objectArray,
        [Parameter(Mandatory = $true)]
        $isDirSync
    )

    out-logfile -string "Entering Split-GraphObjects"

    if ($isDirSync -eq $TRUE)
    {
        $returnArray = @($objectArray | where {$_.OnPremisesSyncEnabled -eq $TRUE})
    }
    else 
    {
        $returnArray = @($objectArray | where {$_.OnPremisesSyncEnabled -eq $NULL})
    }

    out-logfile -string ("Count of objects filtered: "+$returnArray.count)

    out-logfile -string "Exiting Split-GraphObjects"

    return $returnArray
}