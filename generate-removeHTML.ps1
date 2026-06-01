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

            if ($global:HTMLDomainRemoved.count -gt 0)
            {
                if ($global:HTMLDomainRemoved[0].errorMessages -ne "None")
                {
                    new-htmlSection -headerText ("Domain Remove ERROR") {
                        new-htmlTable -DataTable ($global:HTMLDomainRemoved | Select-Object Domain,RemovedStatus,ErrorMessage) -Filtering {
                        } -AutoSize
                    }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "Red" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
                }
                else 
                {
                    new-htmlSection -headerText ("Domain Remove SUCCESS") {
                        new-htmlTable -DataTable ($global:HTMLDomainRemoved | Select-Object Domain,RemovedStatus) -Filtering {
                        } -AutoSize
                    }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
                }
            }

            if ($global:HTMLDirSyncSuccess.count -gt 0)
            {
                new-htmlSection -headerText ("Disable Dir Sync Success") {
                    new-htmlTable -DataTable ($global:HTMLDirSyncSuccess | Select-Object ID,UPN,Name,ObjectType,PreStatus,PostStatus) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLDirSyncErrors.count -gt 0)
            {
                new-htmlSection -headerText ("Disable Dir Sync ERRORS") {
                    new-htmlTable -DataTable ($global:HTMLDirSyncErrors | Select-Object ID,UPN,Name,ObjectType,PreStatus,PostStatus,ErrorMessage) -Filtering {
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
        }
    } -online -ShowHTML

    out-logfile -string "Exiting generate-DNSHtml"
}
