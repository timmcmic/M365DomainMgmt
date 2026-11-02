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
                switch ($item.key)
                {
                    {"Domain Information" -or "Converted Domain Information" -or "Verified Domain Information"} {
                        New-HTMLSection -HeaderText "NOTES:  PLEASE REVIEW" {
                            New-HTMLList{
                                new-htmlListItem -text ("Domain ID: $item.value.id") -FontSize 14
                                New-HTMLListItem -text ("Authentication Type: $item.value.AuthenticationType") -FontSize 14
                                New-HTMLListItem -text ("Default Domain: $item.value.IsDefault") -FontSize 14
                                New-HTMLListItem -text ("Root Domain: $item.value.IsRoot") -FontSize 14

                                if ($item.value.isRoot -eq $true)
                                {
                                    New-HTMLListItem -text ("Root Domain ID: $item.value.RootDomain.id") -FontSize 14
                                }
                                else
                                {
                                    New-HTMLListItem -text ("Sub Domain: $item.value.IsSubDomain") -FontSize 14
                                    New-HTMLListItem -text ("Parent Domain: $item.value.ParentDomainName") -FontSize 14
                                }

                                New-HTMLListItem -text ("Verified Domain: $item.value.IsVerified") -FontSize 14
                                New-HTMLListItem -text "If the domain will not be removed now the SOA may need to be adjusted to Active Directory to restore these users." -FontSize 14
                            }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
                        }
                    }
                }
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