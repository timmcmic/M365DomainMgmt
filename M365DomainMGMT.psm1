#############################################################################################
# DISCLAIMER:																				#
#																							#
# THE SAMPLE SCRIPTS ARE NOT SUPPORTED UNDER ANY MICROSOFT STANDARD SUPPORT					#
# PROGRAM OR SERVICE. THE SAMPLE SCRIPTS ARE PROVIDED AS IS WITHOUT WARRANTY				#
# OF ANY KIND. MICROSOFT FURTHER DISCLAIMS ALL IMPLIED WARRANTIES INCLUDING, WITHOUT		#
# LIMITATION, ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR OF FITNESS FOR A PARTICULAR		#
# PURPOSE. THE ENTIRE RISK ARISING OUT OF THE USE OR PERFORMANCE OF THE SAMPLE SCRIPTS		#
# AND DOCUMENTATION REMAINS WITH YOU. IN NO EVENT SHALL MICROSOFT, ITS AUTHORS, OR			#
# ANYONE ELSE INVOLVED IN THE CREATION, PRODUCTION, OR DELIVERY OF THE SCRIPTS BE LIABLE	#
# FOR ANY DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS	#
# PROFITS, BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER PECUNIARY LOSS)	#
# ARISING OUT OF THE USE OF OR INABILITY TO USE THE SAMPLE SCRIPTS OR DOCUMENTATION,		#
# EVEN IF MICROSOFT HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES						#
#############################################################################################


Function Start-M365DomainManagement
{
    
    <#
    .SYNOPSIS

    This module helps automate domain management in Microsoft 365.

    .DESCRIPTION

    This function triggers all sub functions..

    .PARAMETER LogFolderPath

    *REQUIRED*
    This provides the logging directory for the application.

    .PARAMETER msGraphTenantID

    This is the entra tenant ID where domain management should occur.

    .PARAMETER msGraphEnvironmentName

    This is the graph endpoint that will be utilized to manage the domain.

    .PARAMETER msGraphCertificateThumbprint

    This is the certificate thumbprint installed locally and associated with graph certificate authentication.

    .PARAMETER mmsGraphAppicationID

    This is the application GUID of the graph application created in entra.

    .PARAMETER msGraphClientSecret

    This is the client secret associated with the graph application.

    .PARAMETER domainName

    The domain name to perform the operation on.

    .PARAMETER domainOperation

    The operation to perform on the domain.

    .PARAMETER allowTelemetryCollection

    Specifies if telemetry collection is allowed.

    .OUTPUTS

    Logs all activities and backs up all original data to the log folder directory.
    Moves the distribution group from on premieses source of authority to office 365 source of authority.

    .NOTES

    The following blog posts maintain documentation regarding this module.

    https://timmcmic.wordpress.com.  

    Refer to the first pinned blog post that is the table of contents.

    
    .EXAMPLE

    Start-DistributionListMigration -groupSMTPAddress $groupSMTPAddress -globalCatalogServer server.domain.com -activeDirectoryCredential $cred -logfolderpath c:\temp -dnNoSyncOU "OU" -exchangeOnlineCredential $cred -azureADCredential $cred

    .EXAMPLE

    Start-DistributionListMigration -groupSMTPAddress $groupSMTPAddress -globalCatalogServer server.domain.com -activeDirectoryCredential $cred -logfolderpath c:\temp -dnNoSyncOU "OU" -exchangeOnlineCredential $cred -azureADCredential $cred -enableHybridMailFlow:$TRUE -triggerUpgradeToOffice365Group:$TRUE

    .EXAMPLE

    Start-DistributionListMigration -groupSMTPAddress $groupSMTPAddress -globalCatalogServer server.domain.com -activeDirectoryCredential $cred -logfolderpath c:\temp -dnNoSyncOU "OU" -exchangeOnlineCredential $cred -azureADCredential $cred -enableHybridMailFlow:$TRUE -triggerUpgradeToOffice365Group:$TRUE -useCollectedOnPremMailboxFolderPermissions:$TRUE -useCollectedOffice365MailboxFolderPermissions:$TRUE -useCollectedOnPremSendAs:$TRUE -useCollectedOnPremFullMailboxAccess:$TRUE -useCollectedOffice365FullMailboxAccess:$TRUE

    #>

    [cmdletbinding()]

    Param
    (
        #Define other mandatory parameters
        [Parameter(Mandatory = $true)]
        [string]$logFolderPath,
        #Define Microsoft Graph Parameters
        [Parameter(Mandatory = $true, ParameterSetName = "Interactive")]
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
        [ValidateSet("China","Global","USGov","USGovDod")]
        [string]$msGraphEnvironmentName,
        [Parameter(Mandatory = $true, ParameterSetName = "Interactive")]
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
        [string]$msGraphTenantID,
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [string]$msGraphCertificateThumbprint,
        [Parameter(Mandatory = $true, ParameterSetName = "Certificate")]
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]
        [string]$msGraphApplicationID,
        [Parameter(Mandatory = $true, ParameterSetName = "ClientSecret")]        
        [string]$msGraphClientSecret,
        [Parameter(Mandatory=$false)]
        [ValidateSet("Directory.ReadWrite.All","User.ReadWrite.All","User.EnableDisableAccount.All","User.ManageIdentities.All","User.ReadWrite","Group.Read.All","Group.ReadWrite.All","GroupMember.Read.All","Group-NestingSupport.ReadWrite.All")]
        [string]$msGraphUserPermissions="Directory.ReadWrite.All",
        [Parameter(Mandatory=$false)]
        [ValidateSet("Directory.ReadWrite.All","Directory.Read.All","Group-XTenantIdentitySync.Read.All","Group.ManageProtection.All")]
        [string]$msGraphGroupPermissions="Directory.ReadWrite.All",
        #Define Exchange Online connection information
        [Parameter(Mandatory = $false)]
        [string]$exchangeOnlineCertificateThumbPrint="",
        [Parameter(Mandatory = $false)]
        [string]$exchangeOnlineOrganizationName="",
         [Parameter(Mandatory = $false)]
        [string]$exchangeOnlineAppID="",
        #Define operation parameters
        [Parameter(Mandatory=$false)]
        [string]$domainName="None",
        [Parameter(Mandatory = $false)]
        [ValidateSet("None","New","NewWOConfirm","Remove","Confirm","ForceTakeOver","GetVerificationRecords","TestDNS","DisplayDNSRecords","PromoteSubDomain","PasswordExpiration")]
        [string]$domainOperation="None",
        [Parameter(Mandatory = $false)]
        [string]$customDNSServer="None",
        [Parameter(Mandatory =$FALSE)]
        [boolean]$allowTelemetryCollection=$TRUE
    )

    #Create timeline hash table.

    $global:htmlTime = @{}
    $global:htmlTime['StartTime']=Get-Date

    #Create HTML items.

    $global:htmlData = @{}

    $telemetryStartTime = get-universalDateTime

    #Set the window title.

    $windowTitle = ("Start-M365DomainManagement")
    $host.ui.RawUI.WindowTitle = $windowTitle

    #Initialize telemetry collection.

    $appInsightAPIKey = "63d673af-33f4-401c-931e-f0b64a218d89"
    $traceModuleName = "M365DomainMgmt"

    if ($allowTelemetryCollection -eq $TRUE)
    {
        start-telemetryConfiguration -allowTelemetryCollection $allowTelemetryCollection -appInsightAPIKey $appInsightAPIKey -traceModuleName $traceModuleName
    }

    #Create globals for reporting.

    $global:HTMLDirSyncSuccess=[System.Collections.Generic.List[PSObject]]::new()
    $global:HTMLDirSyncErrors=[System.Collections.Generic.List[PSObject]]::new()
    $global:HTMLUPNRenameSuccess=[System.Collections.Generic.List[PSObject]]::new()
    $global:HTMLUPNRenameErrors=[System.Collections.Generic.List[PSObject]]::new()
    $global:HTMLPrimarySMTPRenameSuccess=[System.Collections.Generic.List[PSObject]]::new()
    $global:HTMLPrimarySMTPRenameErrors=[System.Collections.Generic.List[PSObject]]::new()
    $global:HTMLSecondarySMTPRemoveSuccess=[System.Collections.Generic.List[PSObject]]::new()
    $global:HTMLSecondarySMTPRemoveErrors=[System.Collections.Generic.List[PSObject]]::new()
    $global:HTMLDomainRemoved = [System.Collections.Generic.List[PSObject]]::new()


    #Create telemetry values.

    $telemetryValues = @{}
    $telemetryValues['telemetryM365DomainMgmtVersion']="None"
    $telemetryValues['telemetryMSGraphAuthenticationVersion']="None"
    $telemetryValues['telemetryMSGraphDirectoryVersion']="None"
    $telemetryValues['telemetryMSGraphBetaDirectoryVersion']="None"
    $telemetryValues['telemetryMSGraphUsersVersion']="None"
    $telemetryValues['telemetryMSGraphGroupsVersion']="None"
    $telemetryValues['telemetryExchangeOnlineVersion']="None"
    $telemetryValues['telemetryEventName']="Start-M365DomainManagement"

    #Create MSGraphHashTable

    $msGraphScopesRequired = @()
    $msGraphScopeDomain = "Domain.ReadWrite.All"
    $msGraphGroupSync = "Group-OnPremisesSyncBehavior.ReadWrite.All"
    $msGraphUserSync = "User-OnPremisesSyncBehavior.ReadWrite.All"
    $msGraphValues = @{}
    $msGraphValues['msGraphEnvironmentName']=$msGraphEnvironmentName
    $msGraphValues['msGraphTenantID']=$msGraphTenantID
    $msGraphValues['msGraphApplicationID']=$msGraphApplicationID
    $msGraphValues['msGraphCertificateThumbprint']=$msGraphCertificateThumbprint
    $msGraphValues['msGraphClientSecret']=$msGraphClientSecret
    $msGraphValues['msGraphScopes']=$msGraphScopesRequired
    $msGraphValues['msGraphAuthenticationType']=$PSCmdlet.ParameterSetName

    #Define the msGraphEnvironments.

    $msGraphEnvironments = @{}
    $msGraphEnvironments['msGraphGlobal']="Global"
    $msGraphEnvironments['msGraphUSGov']="USGov"
    $msGraphEnvironments['msGraphUSGovDOD']="USGovDOD"
    $msGraphEnvironments['msGraphChina']="China"

    #Define the Exchange Online Environments.

    $exchangeOnlineEnvironments = @{}
    $exchangeOnlineEnvironments['Global']="O365Default"
    $exchangeOnlineEnvironments['USGov']="O365USGovGCCHigh"
    $exchangeOnlineEnvironments['USGovDOD']="O365USGovDoD"
    $exchangeOnlineEnvironments['Germany']="O365GermanyCloud"
    $exchangeOnlineEnvironments['China']="O365China"

    #Domain operations

    $domainOperations=@{}
    $domainOperations['None'] = "None"
    $domainOperations['New'] = "New"
    $domainOperations['NewWOConfirm'] = "NewWOConfirm"
    $domainOperations['Confirm'] = "Confirm"
    $domainOperations['Remove'] = "Remove"
    $domainOperations['ForceTakeOver'] = "ForceTakeOver"
    $domainOperations['GetVerificationRecords'] = "GetVerificationRecords"
    $domainOperations['TestDNS'] = "TestDNS"
    $domainOperations['DisplayDNSRecords'] = "DisplayDNSRecords"
    $domainOperations['PromoteSubDomain'] = "PromoteSubDomain"

    #Create export table

    $exportNames = @{}
    $exportNames['msGraphContext']="MSGraphContext"
    $exportNames['domainInfo']="DomainInfo"
    $exportNames['viralInfo']="ViralInfo"
    $exportNames['M365DNSRecords']="M365DNSRecords"
    $exportNames['PublicDNSRecords']="PublicDNSRecords"
    $exportNames['CalculatedPublicRecords']="CalculatedPublicRecords"
    $exportNames['DomainInfoPostValidation']="DomainInfoPostValidation"
    $exportNames['PostManagedChange']="PostManagedChange"
    $exportNames['UsersUPN']="UsersUPN"
    $exportNames['UsersSMTP']="UsersSMTP"
    $exportNames['UsersDirectorySync']="UsersDirectorySync"
    $exportNames['GroupsProxy']="GroupsProxy"
    $exportNames['GroupsDirectorySync']="GroupsDirectorySync"
    $exportNames['DirSyncSuccess']="DirSyncSuccess"
    $exportNames['DirSyncErrors']="DirSyncErrors"
    $exportNames['UPNRenameSuccess']="UPNRenameSuccess"
    $exportNames['UPNRenameErrors']="UPNRenameErrors"
    $exportNames['PrimarySMTPRenameSuccess']="PrimarySMTPRenameSuccess"
    $exportNames['PrimarySMTPRenameErrors']="PrimarySMTPRenameErrors"
    $exportNames['SecondarySMTPRenameSuccess']="SecondarySMTPRenameSuccess"
    $exportNames['SecondarySMTPRenameErrors']="SecondarySMTPRenameErrors"
    $exportNames['DomainRemoved']="DomainRemoved"
    $exportNames['PromotedSubDomain']="PromotedSubDomain"

    $moduleNames = @{}
    $moduleNames['M365DomainManagement']="M365DomainMGMT"
    $moduleNames['MsGraphAuthentication']="Microsoft.Graph.Authentication"
    $moduleNames['MSGraphDirectory']="Microsoft.Graph.Identity.DirectoryManagement"
    $moduleNames['MSGraphBetaDirectory']="Microsoft.Graph.Beta.Identity.DirectoryManagement"
    $moduleNames['MSGraphUsers']="Microsoft.Graph.Users"
    $moduleNames['MSGraphGroups']="Microsoft.Graph.Groups"
    $moduleNames['ExchangeOnline']="ExchangeOnlineManagement"

    #Variables for logging and start log file.

    $global:logFile=$NULL
    $logFileName = "M365DomainMgmt_"+(Get-Date -Format FileDateTime)

    #Misc variables.

    $domainIsViral = $false
    $domainInfo = $null
    $m365DNSRecords = $NULL
    $publicDNSRecords = $null
    $mxRecordType = "MX"
    $txtRecordType = "TXT"
    $soaRecordType = "SOA"

    new-logfile -logFileName $logFileName -logFolderPath $logFolderPath

    out-logfile -string "*****************************************************"
    out-logfile -string "Entering Start-M365DomainManagement"
    out-logfile -string "*****************************************************"

    switch ($msGraphEnvironmentName) {
        $msGraphEnvironmentName.msGraphGlobal { 
            $exchangeOnlineEnvironment = $exchangeOnlineEnvironments.global
         }
         $msGraphEnvironmentName.msGraphUSGov { 
            $exchangeOnlineEnvironment = $exchangeOnlineEnvironments.USGov
         }
          $msGraphEnvironmentName.msGraphUSGovDOD { 
            $exchangeOnlineEnvironment = $exchangeOnlineEnvironments.USGovDOD
         }
         $msGraphEnvironmentName.msGraphChina { 
            $exchangeOnlineEnvironment = $exchangeOnlineEnvironments.China
         }
        Default {
            $exchangeOnlineEnvironment = $exchangeOnlineEnvironments.Germany
        }
    }

    out-logfile -string $exchangeOnlineEnvironment

    out-logfile -string "Versions"

    $global:htmlTime['PowerShellVersionTest']=Get-Date

    $telemetryValues['telemetryM365DomainMgmtVersion']=test-PowerShellModule -powershellModuleName $moduleNames.M365DomainManagement -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSGraphAuthenticationVersion']=test-PowerShellModule -powershellModuleName $moduleNames.MsGraphAuthentication -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSGraphDirectoryVersion']=test-PowerShellModule -powershellModuleName $moduleNames.MSGraphDirectory -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSGraphBetaDirectoryVersion']=test-PowerShellModule -powershellModuleName $moduleNames.MSGraphBetaDirectory -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSGraphUsersVersion']=test-PowerShellModule -powershellModuleName $moduleNames.msGraphUsers -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSGraphGroupsVersion']=test-PowerShellModule -powershellModuleName $moduleNames.msGraphGroups -powershellVersionTest:$TRUE
    $telemetryValues['telemetryExchangeOnlineVersion']=test-PowerShellModule -powershellModuleName $moduleNames.ExchangeOnline -powershellVersionTest:$TRUE

    $global:htmlTime['GetDomainOperation']=Get-Date

    out-logfile -string "Operation"

    out-logfile -string ("The domain operation starting: "+$domainOperation)

    $domainOperation = get-DomainOperation -domainOperation $domainOperation -domainOperations $domainOperations

    out-logfile -string ("The domain operation returned: "+$domainOperation)

    out-logfile -string "Graph"

    if ($domainOperation -eq "Remove")
    {
        out-logfile -string "Domian operation is remove - adding enhanced graph scopes."

        $msGraphValues.msGraphScopes += $msGraphScopeDomain
        $msGraphValues.msGraphScopes += $msGraphGroupSync
        $msGraphValues.msGraphScopes += $msGraphUserSync
        $msGraphValues.msGraphScopes += $msGraphUserPermissions
        $msGraphValues.msGraphScopes += $msGraphGroupPermissions

        new-ExchangeOnlineConnection -msGraphEnvironmentName $exchangeOnlineEnvironment -exchangeOnlineCertificateThumbprint $exchangeOnlineCertificateThumbPrint -exchangeonlineAppID $exchangeOnlineAppID -exchangeOnlineOrganizationName $exchangeOnlineOrganizationName -exchangeOnlineEnvironments $exchangeOnlineEnvironments
    }
    else 
    {
        out-logfile -string "Domain operation is not remove, specifying minimum graph scopes required for domain operations."

        $msGraphValues.msGraphScopes += "Domain.ReadWrite.All"
    }

    $global:htmlTime['CreateGraphConnection']=Get-Date

    new-msGraphConnection -msGraphHashTable $msGraphValues -exportFile $exportNames.msGraphContext

    $global:htmlTime['GetDomainName']=Get-Date

    out-logfile -string "DomainName"

    out-logfile -string ("The domain name starting: " +$domainName)

    $domainName = get-domainName -domainName $domainName

    out-logfile -string ("The domain name ending: "+$domainName)

    $global:htmlTime['StartDomainOperation']=Get-Date


    switch ($domainOperation) {
        {($_ -eq $domainOperations.New) -or ($_ -eq $domainOperations.Confirm) -or ($_ -eq $domainOperations.ForceTakeOver)}  
        {  
            out-logfile -string "New/Confirm/ForceTakeOver"

            out-logfile -string "Add the domain if required."

            $global:htmlTime['ObtainDomainInfo']=Get-Date

            $domainInfo = add-domainOperation -domainName $domainName -exportFile $exportNames

            out-logfile -string "Ensure that the domain is not currently registered in the tenant."

            $global:htmlTime['TestDomainInfo']=Get-Date

            test-domainInfo -domainInfo $domainInfo

            out-logfile -string $domainInfo.isVerified
            out-logfile -string $domainInfo.isRoot

            if ($domainInfo.isVerified -eq $false)
            {
                out-logfile -string "Test the domain for viral or other tenant registrations."

                $global:htmlTime['TestDomainViral']=Get-Date

                $domainIsViral = test-viralDomain -domainName $domainName -exportFile $exportNames

                out-logfile -string "Gather DNS records required for domain verification."

                $global:htmlTime['GatherM365DNSRecords']=Get-Date

                $m365DNSRecords = get-DNSVerificationRecords -domainName $domainName -exportFile $exportNames -mxRecordType $mxRecordType -txtRecordType $txtRecordType

                write-host "Please place one of the following records in public DNS - it is not necessary to place both records in public DNS for domain verification." -ForegroundColor Green

                foreach ($record in $m365DNSRecords)
                {
                    write-host ("Record Type: "+$record.RecordType+"  Record Name: @  Record Value: "+$record.value) -ForegroundColor Green
                }

                Read-Host "Press any key to continue:"

                foreach ($record in $m365DNSRecords)
                {
                    out-logfile -string ("Record Type: "+$record.RecordType+"  Record Name: @  Record Value: "+$record.value)
                }

                $global:htmlTime['GatherPublicDNSRecords']=Get-Date

                $dnsResults = $FALSE
                $retryCounter = 0

                do
                {
                    $publicDNSRecords = get-publicDNSRecords -domainName $domainName -exportFile $exportNames -mxRecordType $mxRecordType -txtRecordType $txtRecordType -soaRecordType $soaRecordType -customDNSServer $customDNSServer

                    $global:htmlTime['TestPublicDNSRecords']=Get-Date

                    $dnsResults = test-DNSVerificationRecords -m365DNSRecords $m365DNSRecords -publicDNSRecords $publicDNSRecords -mxRecordType $mxRecordType -txtRecordType $txtRecordType -soaRecordType $soaRecordType

                    if ($retyCounter -lt 5 -and $dnsResults -eq $FALSE)
                    {
                        out-logfile -string ("DNS records are not yet present in public DNS.  Waiting 5 minutes before retrying.  Retry attempt: "+$retryCounter)
                        $retryCounter++

                        if ($retryCounter -lt 5)
                        {
                            start-sleepProgress -sleepseconds 300 -sleepString ("Waiting for DNS records to propagate in public DNS. Retry attempt: "+$retryCounter)
                        }
                    }
                    else
                    {
                        out-logfile -string ("DNS Records were found in public DNS or retry attempts exceeded.")
                    }
                }
                until ($retryCounter -eq 5 -or $dnsResults -eq $TRUE)

                if ($dnsResults -eq $FALSE)
                {
                    out-logfile -string "DNS records are not present in public DNS after 6 attempts.  Please verify that the DNS records have been added to public DNS and that they have propagated before continuing." -isError:$true

                    out-logfile -string "If the DNS records have already been added please verify with public lookup that they can be discovered."

                    out-logfile -string "ERROR: Microsoft 365 domain validation records not found in public DNS" -isError:$true

                    Read-Host "Press any key to continue:"
                }
                else
                {
                    out-logfile -string "DNS records are present in public DNS.  Proceeding with domain validation."
                }
                
                $global:htmlTime['ValidateDomain']=Get-Date

                $domainInfo = validate-m365Domain -domainName $domainName -domainIsViral $domainIsViral -domainOperation $domainOperation -msGraphEnvironmentName $msGraphEnvironmentName -exportFile $exportNames.DomainInfoPostValidation
            }
            else
            {
                out-logfile -string "The domain is either not verified or is a root domain in the tenant - skipping viral and DNS tests."
            }

            out-logfile -string "Claculating the public NS records necessary for your tenant to function."

            $global:htmlTime['CalculatePublicDNSRecords']=Get-Date

            calculate-publicDNSRecords -domainName $domainName -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments
        }
        $domainOperations.NewWOConfirm
        {
            out-logfile -string "NewNoConfirm"

            out-logfile -string "Add the domain if required."

            $global:htmlTime['AddDomain']=Get-Date

            $domainInfo = add-domainOperation -domainName $domainName -exportFile $exportNames

            out-logfile -string "Gather DNS records required for domain verification."

            $global:htmlTime['ObtainDNSVerificationRecords']=Get-Date

            $m365DNSRecords = get-DNSVerificationRecords -domainName $domainName -exportFile $exportNames -mxRecordType $mxRecordType -txtRecordType $txtRecordType

            foreach ($record in $m365DNSRecords)
            {
                write-host ("Record Type: "+$record.RecordType+"  Record Name: @  Record Value: "+$record.value) -ForegroundColor Green
            }

            Read-Host "Press any key to continue:"

            foreach ($record in $m365DNSRecords)
            {
                out-logfile -string ("Record Type: "+$record.RecordType+"  Record Name: @  Record Value: "+$record.value)
            }
        }
        $domainOperations.Remove 
        {
            out-logfile -string "Remove"

            $global:htmlTime['GetRemovalApproval']=Get-Date
            
            get-removalApproval

            $global:htmlTime['GetDomainInfo']=Get-Date

            $domainInfo = test-DomainName -domainName $domainName

            $global:htmlTime['ExportDomainInfo']=Get-Date

            out-xmlFile -itemToExport $domainInfo -itemNameToExport $exportNames.domainInfo

            $global:htmlTime['ConvertAuthenticationMethod']=Get-Date

            $domainInfo = convert-AuthenticationMethod -domainName $domainName -exportFile $exportNames.PostManagedChange -domainInfo $domainInfo

            $global:htmlTime['BeginDomainRemoval']=Get-Date

            remove-objectDependencies -exportFiles $exportNames -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments -domainName $domainName

            $global:htmlTime['EndTime']=Get-Date

            generate-removeHTML

            output-globalObjects -exportFiles $exportNames
        }
        $domainOperations.GetVerificationRecords
        {
            out-logfile -string "GetVerficiationRecords"

            out-logfile -string "Test to ensure that the domain is present."

            $global:htmlTime['ObtainDomain']=Get-Date

            try {
                $domainInfo = test-domainName -domainName $domainName -errorAction STOP
            }
            catch {
                out-logfile -string $_ 
                out-logfile -string "Domain is not present in tenant - unable to get verification records." -isError:$true
            }

            out-logfile -string "Ensure that the domain is not currently registered in the tenant."

            $global:htmlTime['TestDomainValidation']=Get-Date

            test-domainInfo -domainInfo $domainInfo

            out-logfile -string "Get the domain verification records."

            $global:htmlTime['GetVerificationRecords']=Get-Date

            $m365DNSRecords = get-DNSVerificationRecords -domainName $domainName -exportFile $exportNames -mxRecordType $mxRecordType -txtRecordType $txtRecordType

            foreach ($record in $m365DNSRecords)
            {
                write-host ("Record Type: "+$record.RecordType+"  Record Name: @  Record Value: "+$record.value) -ForegroundColor Green
            }

            Read-Host "Press any key to continue:"

            foreach ($record in $m365DNSRecords)
            {
                out-logfile -string ("Record Type: "+$record.RecordType+"  Record Name: @  Record Value: "+$record.value)
            }
        }
        $domainOperations.TestDNS
        {
            out-logfile -string "TestDNS"

            out-logfile -string "Test to ensure that the domain is present."

            $global:htmlTime['ObtainDomain']=Get-Date

            try {
                $domainInfo = test-domainName -domainName $domainName -errorAction STOP
            }
            catch {
                out-logfile -string $_ 
                out-logfile -string "Domain is not present in tenant - unable to test verification records." -isError:$true
            }

            out-logfile -string "Ensure that the domain is not currently registered in the tenant."

            $global:htmlTime['TestDomainValidation']=Get-Date

            test-domainInfo -domainInfo $domainInfo

            out-logfile -string "Test Verification and PublicDNS Records"

            $global:htmlTime['GetVerificationRecords']=Get-Date

            $m365DNSRecords = get-DNSVerificationRecords -domainName $domainName -exportFile $exportNames -mxRecordType $mxRecordType -txtRecordType $txtRecordType

            $global:htmlTime['GetPublicDNSRecords']=Get-Date

            $publicDNSRecords = get-publicDNSRecords -domainName $domainName -exportFile $exportNames -mxRecordType $mxRecordType -txtRecordType $txtRecordType -soaRecordType $soaRecordType -customDNSServer $customDNSServer

            $global:htmlTime['TestPublicDNSRecords']=Get-Date

            test-DNSVerificationRecords -m365DNSRecords $m365DNSRecords -publicDNSRecords $publicDNSRecords -mxRecordType $mxRecordType -txtRecordType $txtRecordType -soaRecordType $soaRecordType

            out-logfile -string "The DNS verification records were successfully located in public DNS."
        }
        $domainOperations.DisplayDNSRecords
        {
            out-logfile -string "DisplayDNSRecords"

            out-logfile -string "Test to ensure that the domain is present."

            $global:htmlTime['ObtainDomain']=Get-Date

            try {
                $domainInfo = test-domainName -domainName $domainName -errorAction STOP
            }
            catch {
                out-logfile -string $_ 
                out-logfile -string "Domain is not present in tenant - unable to provide DNS records for this domain." -isError:$true
            }

            out-logfile -string "Claculating the public DNS records necessary for your tenant to function."

            $global:htmlTime['CalculateDNSRecords']=Get-Date

            calculate-publicDNSRecords -domainName $domainName -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments
        }
        $domainOperations.PromoteSubDomain
        {
            out-logfile -string "PromoteSubDomain"

            out-logfile -string "Test to ensure that the domain is present."

            $global:htmlTime['ObtainDomain']=Get-Date

            try {
                $domainInfo = test-domainName -domainName $domainName -errorAction STOP
            }
            catch {
                out-logfile -string $_ 
                out-logfile -string "Domain is not present in tenant - unable to promote sub domain." -isError:$true
            }

            if ($domainInfo.isRoot -eq $TRUE)
            {
                out-logfile -string "The domain is already a root domain and cannot be promoted." -isError:$true
            }
            else
            {   
                out-logfile -string "The domain is a sub domain and can be promoted to a root domain."
            }

            $global:htmlTime['StartDomainPromotion']=Get-Date

            promote-subDomain -domainInfo $domainInfo -exportFile $exportNames
        }
        $domainOperations.PasswordExpiration
        {
            out-logfile -string "PasswordExpiration"

            out-logfile -string "Test to ensure that the domain is present."

            $global:htmlTime['StartPasswordExpiration']=Get-Date

            start-ManagePasswordExpiration -exportFile $exportNames
        }
    }

    $telemetryEndTime = get-universalDateTime

    [double]$telemetryElapsedSeconds = get-elapsedTime -startTime $telemetryStartTime -endTime $telemetryEndTime

    $telemetryEventProperties = @{
        M365DomainMGMT = "Start-M365DomainManagement"
        M365DomainMGMTVersion = $telemetryValues.telemetryM365DomainMgmtVersion
        MSGraphAuthentication = $telemetryValues.telemetryMSGraphAuthenticationVersion
        MSGraphDirectory = $telemetryValues.telemetryMSGraphDirectoryVersion
        MSGraphBetaDirectory = $telemetryValues.telemetryMSGraphBetaDirectoryVersion
        MSGraphUsers = $telemetryValues.telemetryMSGraphUsersVersion
        MSGraphGroups = $telemetryValues.telemetryMSGraphGroupsVersion
        ExchangeOnline = $telemetryValues.telemetryExchangeOnlineVersion
        OperationSelected = $domainOperation
    }

    $telemetryEventMetrics = @{
         TotalTime = $telemetryElapsedSeconds  
    }

    send-TelemetryEvent -traceModuleName $traceModuleName -eventName $telemetryValues.telemetryEventName -eventMetrics $telemetryEventMetrics -eventProperties $telemetryEventProperties

    Disconnect-MgGraph

    Disconnect-ExchangeOnline -confirm:$FALSE

    out-logfile -string "Completed domain operations using M365DomainMGMT"

    generate-HTMLReport
}