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

             if ($global:HTMLEnabledDirSyncSuccess.count -gt 0)
            {
                new-htmlSection -headerText ("Enable Dir Sync Success") {
                    new-htmlTable -DataTable ($global:HTMLDisableDirSyncSuccess | Select-Object ID,UPN,Name,ObjectType,PreStatus,PostStatus) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLEnabledDirSyncErrors.count -gt 0)
            {
                new-htmlSection -headerText ("Enable Dir Sync Failures") {
                    new-htmlTable -DataTable ($global:HTMLDisableDirSyncErrors | Select-Object ID,UPN,Name,ObjectType,PreStatus,PostStatus,ErrorMessage) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "Red" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }
        }
    } -online -ShowHTML

    out-logfile -string "Exiting generate-DNSHtml"
}
