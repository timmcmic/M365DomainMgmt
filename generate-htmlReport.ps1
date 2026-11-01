function generate-HTMLReport
{
    $functionHTMLSuffix = "html"
    $global:functionHTMLFile = $global:LogFile.replace("log","$functionHTMLSuffix")

    out-logfile -string "Entering generate-HTMLReport"
    out-logfile -string $global:functionHTMLFile

    $headerString = "Domain Management Report"

     new-HTML -TitleText $domainName -FilePath $global:functionHTMLFile{
        New-HTMLHeader{
            New-HTMLText -Text $headerString -FontSize 24 -Color White -BackGroundColor Black -Alignment center
        }
        New-HTMLMain {
            New-HTMLTableOption -DataStore JavaScript

            foreach ($item in $global:htmlData.GetEnumerator())
            {
                new-htmlSection -headerText ("$($item.key)") {
                    new-htmlTable -DataTable ($item.value) -Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            $global:htmlTime = $global:HTMLTime.GetEnumerator() | Sort-Object -property Value

            new-htmlSection -HeaderText ("Timline of Events"){
                    new-HTMLTimeLIne {
                        foreach ($item in $htmlTime.GetEnumerator())
                        {
                            new-HTMLTimeLineItem -HeadingText $item.key -Date $item.value
                        }
                    }
            } -HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
        }
    } -online -ShowHTML

    out-logfile -string "Exiting generate-HTMLReport"
}