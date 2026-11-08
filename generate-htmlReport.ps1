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
                    {$_ -eq 'Converted Domain Information' -or $_ -eq "Promoted Domain Information" -or $_ -eq "Domain Information" -or $_ -eq "Converted Domain Information" -or $_ -eq "Verified Domain Information"} {
                        New-HTMLSection -HeaderText $item.key  {
                            New-HTMLList{
                                new-htmlListItem -text ("Domain ID: "+$item.value.id) -FontSize 14
                                New-HTMLListItem -text ("Authentication Type: "+$item.value.AuthenticationType) -FontSize 14
                                New-HTMLListItem -text ("Default Domain: "+$item.value.IsDefault) -FontSize 14
                                New-HTMLListItem -text ("Root Domain: "+$item.value.IsRoot) -FontSize 14 -nestedListItems {
                                    if ($item.value.isRoot -eq $false -and $item.value.isVerified -eq $true)
                                    {
                                        new-htmlList {
                                            New-HTMLListItem -text ("Root Domain ID: "+$item.value.RootDomain.id) -FontSize 14
                                            New-HTMLListItem -text ("Root Domain Authentication Type: "+$item.value.RootDomain.AuthenticationType) -FontSize 14
                                            New-HTMLListItem -text ("Root Domain Default Domain: "+$item.value.RootDomain.IsDefault) -FontSize 14
                                            New-HTMLListItem -text ("Root Domain: "+$item.value.RootDomain.IsRoot) -FontSize 14
                                            New-HTMLListItem -text ("Root Domain Verified Domain: "+$item.value.RootDomain.IsVerified) -FontSize 14
                                        }-color Black -BackGroundColor White -fontSize 14
                                    }
                                }
                                New-HTMLListItem -text ("Verified Domain: "+$item.value.IsVerified) -FontSize 14
                            }-color Black -BackGroundColor White -fontSize 14
                        }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
                        Break
                    }
                    "Viral Domain Information" {
                        New-HTMLSection -HeaderText $item.key  {
                            New-HTMLList{
                                new-htmlListItem -text ("Domain: "+$item.value.domainname) -FontSize 14
                                new-htmlListItem -text ("Namespace: "+$item.value.namespacetype) -FontSize 14

                                if ($item.value.AuthURL)
                                {
                                    new-htmlListItem -text ("AuthURL: "+$item.value.AuthURL) -FontSize 14 -nestedListItems {

                                        if ($item.value.AuthURL.contains("https://sso.godaddy.com"))
                                        {
                                            new-htmlList {
                                                New-HTMLListItem -text "The domain is currently registered to another tenant through an Office 365 subscription purchased through GoDaddy" -color Red -FontSize 14
                                                New-HTMLListItem -text "This implies that either the tenant was never removed or the domain currently has active Office 365 suscriptions through GoDaddy" -color Red -FontSize 14
                                                New-HTMLListItem -text "Contact GoDaddy support and request information on the release of this domain." -color Red -FontSize 14
                                            }-color Black -BackGroundColor White -fontSize 14
                                        }
                                    }
                                }

                                if ($item.value.isViral)
                                {
                                    new-htmlListItem -text ("Is Unmanaged Tenant: "+$item.value.isViral) -FontSize 14 -nestedListItems {
                                        new-htmlList {
                                                New-HTMLListItem -text "The domain is reporting as viral - a force takeover may successfully confirm the domain." -color Red -FontSize 14
                                                New-HTMLListItem -text "https://learn.microsoft.com/en-us/entra/identity/users/domains-admin-takeover" -color Red -FontSize 14
                                                New-HTMLListItem -text "The above link provides information on how to perform a force takeover of the domain." -color Red -FontSize 14
                                                New-HTMLListItem -text "The internal admin takeover may be used to takeover the existing unamanged tenant." -color Red -FontSize 14
                                                New-HTMLListItem -text "The external admin takeover may be used to forcefully remove the domain into any other COMMERCIAL tenant." -color Red -FontSize 14
                                                New-HTMLListItem -text "If you are adding the domain to a GCC High or DOD tenant - extenrnal takeover will not work unless you first use a COMMERCIAL tenant." -color Red -FontSize 14
                                                New-HTMLListItem -text "This module automatically attempts a force takeover in this scenario regardless of the tenant type." -color Red -FontSize 14
                                            }-color Black -BackGroundColor White -fontSize 14
                                    }
                                }
                            }-color Black -BackGroundColor White -fontSize 14
                        }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
                        Break
                    }
                    "DNS Records" {
                        New-HTMLSection -HeaderText $item.key  {
                            new-htmlTable -DataTable ($item.value | Select-Object RecordType,RecordName,TTL,Value,Preferece,Port,Priority,Protocol,Service,Weight) -Filtering {
                            } -AutoSize
                        }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
                        Break
                    }
                    "DNS Verfiication Records" {
                        New-HTMLSection -HeaderText $item.key  {
                            new-htmlTable -DataTable ($item.value | Select-Object RecordType,Value) -Filtering {
                            } -AutoSize
                        }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
                        Break
                    }
                    "Public DNS Records" {
                        New-HTMLSection -HeaderText $item.key  {
                            new-htmlTable -DataTable ($item.value | Select-Object RecordType,Value) -Filtering {
                            } -AutoSize
                        }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
                        Break
                    }
                }
            }

            if ($global:expirationDomains.Count -gt 0)
            {
                New-HTMLSection -HeaderText "Password Expiration Management" {
                    new-htmlTable -DataTable ($global:expirationDomains)-Filtering {
                    } -AutoSize
                }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed
            }

            if ($global:HTMLDomainRemoved.count -gt 0)
            {
                if ($global:HTMLDomainRemoved[0].errorMessage -ne "None")
                {
                    new-htmlSection -headerText ("Domain Remove ERROR") {
                        new-htmlTable -DataTable ($global:HTMLDomainRemoved | Select-Object Domain,RemovedStatus,ErrorMessage) -Filtering {
                        } -AutoSize
                    }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "Red" -HeaderBackGroundColor "Black"  -CanCollapse -BorderRadius 10px -collapsed

                    if ($global:HTMLDirSyncSuccess.count -gt 0)
                    {
                        New-HTMLSection -HeaderText "NOTES:  PLEASE REVIEW" {
                            New-HTMLList{
                                new-htmlListItem -text "The domain was not removed successfully." -FontSize 14
                                New-HTMLListItem -text "Users or groups had their SOA changed to cloud only - this was not reverted." -FontSize 14
                                New-HTMLListItem -text "If you will be retrying the remove operation after correcting failures no actions are required." -FontSize 14
                                New-HTMLListItem -text "If the domain will not be removed now the SOA may need to be adjusted to Active Directory to restore these users." -FontSize 14
                            }
                        }-HeaderTextAlignment "Left" -HeaderTextSize "16" -HeaderTextColor "White" -HeaderBackGroundColor "Red" -BorderRadius 10px -collapsed
                    }
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