function output-globalObjects
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $exportFiles
    )

    out-logfile -string "Entering Output-GlobalObjects"

    if ($global:HTMLDirSyncSuccess.count -gt 0)
    {
        out-xmlFile -itemNameToExport $exportFiles.DirSyncSuccess -itemToExport $global:HTMLDirSyncSuccess
    }

    if ($global:HTMLDirSyncErrors.count -gt 0)
    {
        out-xmlFile -itemNameToExport $exportFiles.DirSyncErrors -itemToExport $global:HTMLDirSyncErrors
    }

    if ($global:HTMLUPNRenameSuccess.count -gt 0)
    {
        out-xmlFile -itemNameToExport $exportFiles.UPNRenameSuccess -itemToExport $global:HTMLUPNRenameSuccess
    }

    if ($global:HTMLUPNRenameErrors.count -gt 0)
    {
        out-xmlFile -itemNameToExport $exportFiles.UPNRenameErrors -itemToExport $global:HTMLUPNRenameErrors
    }

    if ($global:HTMLPrimarySMTPRenameSuccess.count -gt 0)
    {
        out-xmlFile -itemNameToExport $exportFiles.PrimarySMTPRenameSuccess -itemToExport $global:HTMLPrimarySMTPRenameSuccess
    }

    if ($global:HTMLPrimarySMTPRenameErrors.count -gt 0)
    {
        out-xmlFile -itemNameToExport $exportFiles.PrimarySMTPRenameErrors -itemToExport $global:HTMLPrimarySMTPRenameErrors
    }

    if ($global:HTMLSecondarySMTPRemoveSuccess.count -gt 0)
    {
        out-xmlFile -itemNameToExport $exportFiles.SecondarySMTPRenameSuccess -itemToExport $global:HTMLSecondarySMTPRemoveSuccess
    }

    if ($global:HTMLSecondarySMTPRemoveErrors.count -gt 0)
    {
        out-xmlFile -itemNameToExport $exportFiles.SecondarySMTPRenameErrors -itemToExport $global:HTMLSecondarySMTPRemoveErrors
    }

    if ($global:HTMLDomainRemoved.count -gt 0)
    {
        out-xmlFile -itemNameToExport $exportFiles.DomainRemoved -itemToExport $global:HTMLDomainRemoved
    }

    out-logfile -string "Exiting Output-GlobalObjects"
}