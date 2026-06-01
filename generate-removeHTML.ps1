function generate-removeHTML
{
    $functionHTMLSuffix = "html"
    $global:functionHTMLFile = $global:LogFile.replace("log","$functionHTMLSuffix")

    out-logfile -string "Entering generate-DNSHtml"
    out-logfile -string $global:functionHTMLFile

    $headerString = "Domain Removal Summary"

    new-HTML -TitleText "Domain Removal Summary" -FilePath $global:functionHTMLFile{
        New-HTMLHeader{
            New-HTMLText -Text $headerString -FontSize 24 -Color White -BackGroundColor Black -Alignment center
        }
        New-HTMLMain {
            New-HTMLTableOption -DataStore JavaScript

            if ($global:HTMLDisableDirSyncSuccess.count -gt 0)
            {
                new-htmlSection -headerText ("Disable Dir Sync Success") {
                    new-htmlTable -DataTable ($global:HTMLDisableDirSyncSuccess | Select-Object ID,UPN,Name,ObjectType,PreStatus,PostStatus) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLDisableDirSyncErrors.count -gt 0)
            {
                new-htmlSection -headerText ("Disable Dir Sync ERRORS") {
                    new-htmlTable -DataTable ($global:HTMLDisableDirSyncErrors | Select-Object ID,UPN,Name,ObjectType,PreStatus,PostStatus,ErrorMessage) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "Red" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLEnabledDirSyncSuccess.count -gt 0)
            {
                new-htmlSection -headerText ("Enabled Dir Sync Success") {
                    new-htmlTable -DataTable ($global:HTMLEnabledDirSyncSuccess | Select-Object ID,UPN,Name,ObjectType,PreStatus,PostStatus) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLDisableDirSyncErrors.count -gt 0)
            {
                new-htmlSection -headerText ("Disable Dir Sync ERRORS") {
                    new-htmlTable -DataTable ($global:HTMLDisableDirSyncErrors | Select-Object ID,UPN,Name,ObjectType,PreStatus,PostStatus,ErrorMessage) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "Red" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLUPNRenameSuccess.count -gt 0)
            {
                new-htmlSection -headerText ("Rename UPN Success") {
                    new-htmlTable -DataTable ($global:HTMLUPNRenameSuccess | Select-Object ID,UPN,NewUPN,Name,ObjectType) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLUPNRenameErrors.count -gt 0)
            {
                new-htmlSection -headerText ("Rename UPN Failures") {
                    new-htmlTable -DataTable ($global:HTMLUPNRenameErrors | Select-Object ID,UPN,NewUPN,Name,ObjectType,ErrorMessage) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "Red" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLPrimarySMTPRenameSuccess.count -gt 0)
            {
                new-htmlSection -headerText ("Primary SMTP Rename Success") {
                    new-htmlTable -DataTable ($global:HTMLPrimarySMTPRenameSuccess | Select-Object ID,Mail,NewMail,Name,ObjectType) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLPrimarySMTPRenameErrors.count -gt 0)
            {
                new-htmlSection -headerText ("Primary SMTP Rename Failures") {
                    new-htmlTable -DataTable ($global:HTMLPrimarySMTPRenameErrors | Select-Object ID,Mail,NewMail,Name,ObjectType,ErrorMessage) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "Red" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

             if ($global:HTMLSecondarySMTPRemoveSuccess.count -gt 0)
            {
                new-htmlSection -headerText ("Secondary Address Removal Success") {
                    new-htmlTable -DataTable ($global:HTMLSecondarySMTPRemoveSuccess | Select-Object Id,AddressRemoved,Name,ObjectType) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLSecondarySMTPRemoveErrors.count -gt 0)
            {
                new-htmlSection -headerText ("Secondary Address Removal Failures") {
                    new-htmlTable -DataTable ($global:HTMLSecondarySMTPRemoveErrors | Select-Object Id,AddressRemoved,Name,ObjectType,ErrorMessage) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "Red" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

             if ($global:HTMLDisableDirSyncGroupSuccess.count -gt 0)
            {
                new-htmlSection -headerText ("Disable Dir Sync Success") {
                    new-htmlTable -DataTable ($global:HTMLDisableDirSyncGroupSuccess | Select-Object ID,Name,ObjectType,PreStatus,PostStatus) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLDisableDirSyncGroupErrors.count -gt 0)
            {
                new-htmlSection -headerText ("Disable Dir Sync ERRORS") {
                    new-htmlTable -DataTable ($global:HTMLDisableDirSyncGroupErrors | Select-Object ID,Name,ObjectType,PreStatus,PostStatus,ErrorMessage) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "Red" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLPrimarySMTPRenameGroupSuccess.count -gt 0)
            {
                new-htmlSection -headerText ("Primary SMTP Rename Success") {
                    new-htmlTable -DataTable ($global:HTMLPrimarySMTPRenameGroupSuccess | Select-Object ID,Mail,NewMail,Name,ObjectType) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLPrimarySMTPRenameGroupErrors.count -gt 0)
            {
                new-htmlSection -headerText ("Primary SMTP Rename Failures") {
                    new-htmlTable -DataTable ($global:HTMLPrimarySMTPRenameGroupErrors | Select-Object ID,Mail,NewMail,Name,ObjectType,ErrorMessage) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "Red" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

             if ($global:HTMLSecondarySMTPRemoveGroupSuccess.count -gt 0)
            {
                new-htmlSection -headerText ("Secondary Address Removal Success") {
                    new-htmlTable -DataTable ($global:HTMLSecondarySMTPRemoveGroupSuccess | Select-Object Id,AddressRemoved,Name,ObjectType) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLSecondarySMTPRemoveGroupErrors.count -gt 0)
            {
                new-htmlSection -headerText ("Secondary Address Removal Failures") {
                    new-htmlTable -DataTable ($global:HTMLSecondarySMTPRemoveGroupErrors | Select-Object Id,AddressRemoved,Name,ObjectType,ErrorMessage) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "Red" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }
        }
    } -online -ShowHTML

    out-logfile -string "Exiting generate-DNSHtml"
}
