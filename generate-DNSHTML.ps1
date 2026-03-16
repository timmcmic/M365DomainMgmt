function generate-DNSHtml
{
    Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        $output,
        [Parameter(Mandatory = $true)]
        $domainName
    )

    $functionHTMLSuffix = "html"
    $global:functionHTMLFile = $global:LogFile.replace("log","$functionHTMLSuffix")

    out-logfile -string "Entering generate-DNSHtml"
    out-logfile -string $global:functionHTMLFile

    $headerString = "Microsoft 365 Public DNS Records"

    new-HTML -TitleText $domainName -FilePath $global:functionHTMLFile{
        New-HTMLHeader{
            New-HTMLText -Text $headerString -FontSize 24 -Color White -BackGroundColor Black -Alignment center
        }
        New-HTMLMain {
            New-HTMLTableOption -DataStore JavaScript

            new-htmlSection -headerText ("CNAME Records") {
                new-htmlTable -DataTable ($output | where {$_.recordType -eq "CNAME"} | Select-Object RecordType,RecordName,TTL,Value) -Filtering {
                } -AutoSize
            }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed

            New-htmlSection -headerText ("TXT Records") {
                new-htmlTable -DataTable ($output | where {$_.recordType -eq "TXT"} | Select-Object RecordType,RecordName,TTL,Value) -Filtering {
                } -AutoSize
            }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed

            New-htmlSection -headerText ("MX Records") {
                new-htmlTable -DataTable ($output | where {$_.recordType -eq "MX"} | Select-Object RecordType,RecordName,TTL,Value,Preferece) -Filtering {
                } -AutoSize
            }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed

            New-htmlSection -headerText ("MX Records") {
                new-htmlTable -DataTable ($output | where {$_.recordType -eq "SRV"} | Select-Object RecordType,RecordName,TTL,Value,Port,Priority,Protocol,Service,Weight) -Filtering {
                } -AutoSize
            }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
        }
    } -online -ShowHTML
}
