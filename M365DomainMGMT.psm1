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
        #Define operation parameters
        [Parameter(Mandatory=$false)]
        [string]$domainName="None",
        [Parameter(Mandatory = $false)]
        [ValidateSet("None","New","NewWOConfirm","Remove","Confirm","ForceTakeOver","GetVerificationRecords","TestDNS","DisplayDNSRecords")]
        [string]$domainOperation="None",
        [Parameter(Mandatory = $false)]
        [string]$customDNSServer="None",
        [Parameter(Mandatory =$FALSE)]
        [boolean]$allowTelemetryCollection=$TRUE
    )

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

    #Create telemetry values.

    $telemetryValues = @{}
    $telemetryValues['telemetryM365DomainMgmtVersion']="None"
    $telemetryValues['telemetryMSGraphAuthenticationVersion']="None"
    $telemetryValues['telemetryMSGraphDirectoryVersion']="None"
    $telemetryValues['telemetryMSGraphBetaDirectoryVersion']="None"

    #Create MSGraphHashTable

    $msGraphScopesRequired = "Domain.ReadWrite.All"
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

    #Create export table

    $exportNames = @{}
    $exportNames['msGraphContext']="MSGraphContext"
    $exportNames['domainInfo']="DomainInfo"
    $exportNames['viralInfo']="ViralInfo"
    $exportNames['M365DNSRecords']="M365DNSRecords"
    $exportNames['PublicDNSRecords']="PublicDNSRecords"
    $exportNames['CalculatedPublicRecords']="CalculatedPublicRecords"
    $exportNames['DomainInfoPostValidation']="DomainInfoPostValidation"

    #Variables for logging and start log file.

    $global:logFile=$NULL
    $logFileName = "M365DomainMgmt_"+(Get-Date -Format FileDateTime)

    #Misc variables.

    $domainIsViral = $false
    $msGraphGlobalEnvironment = "Global"
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

    out-logfile -string "Graph"

    new-msGraphConnection -msGraphHashTable $msGraphValues -exportFile $exportNames.msGraphContext

    out-logfile -string "Operation"

    out-logfile -string ("The domain operation starting: "+$domainOperation)

    $domainOperation = get-DomainOperation -domainOperation $domainOperation -domainOperations $domainOperations

    out-logfile -string ("The domain operation returned: "+$domainOperation)

    out-logfile -string "DomainName"

    out-logfile -string ("The domain name starting: " +$domainName)

    $domainName = get-domainName -domainName $domainName

    out-logfile -string ("The domain name ending: "+$domainName)

    switch ($domainOperation) {
        {($_ -eq $domainOperations.New) -or ($_ -eq $domainOperations.Confirm) -or ($_ -eq $domainOperations.ForceTakeOver)}  
        {  
            out-logfile -string "New/Confirm/ForceTakeOver"

            out-logfile -string "Add the domain if required."

            $domainInfo = add-domainOperation -domainName $domainName -exportFile $exportNames

            out-logfile -string "Ensure that the domain is not currently registered in the tenant."

            test-domainInfo -domainInfo $domainInfo

            out-logfile -string "Test the domain for viral or other tenant registrations."

            $domainIsViral = test-viralDomain -domainName $domainName -exportFile $exportNames

            out-logfile -string "Gather DNS records required for domain verification."

            $m365DNSRecords = get-DNSVerificationRecords -domainName $domainName -exportFile $exportNames -mxRecordType $mxRecordType -txtRecordType $txtRecordType

            $publicDNSRecords = get-publicDNSRecords -domainName $domainName -exportFile $exportNames -mxRecordType $mxRecordType -txtRecordType $txtRecordType -soaRecordType $soaRecordType -customDNSServer $customDNSServer

            test-DNSVerificationRecords -m365DNSRecords $m365DNSRecords -publicDNSRecords $publicDNSRecords -mxRecordType $mxRecordType -txtRecordType $txtRecordType -soaRecordType $soaRecordType

            $domainInfo = validate-m365Domain -domainName $domainName -domainIsViral $domainIsViral -domainOperation $domainOperation -msGraphEnvironmentName $msGraphEnvironmentName -exportFile $exportNames.DomainInfoPostValidation
        }
        $domainOperations.NewWOConfirm
        {
            out-logfile -string "NewNoConfirm"

            out-logfile -string "Add the domain if required."

            $domainInfo = add-domainOperation -domainName $domainName -exportFile $exportNames
        }
        $domainOperations.Remove 
        {  
        }
        $domainOperations.GetVerificationRecords
        {
            out-logfile -string "GetVerficiationRecords"

            out-logfile -string "Test to ensure that the domain is present."

            try {
                $domainInfo = test-domainName -domainName $domainName -errorAction STOP
            }
            catch {
                out-logfile -string $_ 
                out-logfile -string "Domain is not present in tenant - unable to get verification records." -isError:$true
            }

            out-logfile -string "Ensure that the domain is not currently registered in the tenant."

            test-domainInfo -domainInfo $domainInfo

            out-logfile -string "Get the domain verification records."

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

            try {
                $domainInfo = test-domainName -domainName $domainName -errorAction STOP
            }
            catch {
                out-logfile -string $_ 
                out-logfile -string "Domain is not present in tenant - unable to test verification records." -isError:$true
            }

            out-logfile -string "Ensure that the domain is not currently registered in the tenant."

            test-domainInfo -domainInfo $domainInfo

            out-logfile -string "Test Verification and PublicDNS Records"

            $m365DNSRecords = get-DNSVerificationRecords -domainName $domainName -exportFile $exportNames -mxRecordType $mxRecordType -txtRecordType $txtRecordType

            $publicDNSRecords = get-publicDNSRecords -domainName $domainName -exportFile $exportNames -mxRecordType $mxRecordType -txtRecordType $txtRecordType -soaRecordType $soaRecordType -customDNSServer $customDNSServer

            test-DNSVerificationRecords -m365DNSRecords $m365DNSRecords -publicDNSRecords $publicDNSRecords -mxRecordType $mxRecordType -txtRecordType $txtRecordType -soaRecordType $soaRecordType

            out-logfile -string "The DNS verification records were successfully located in public DNS."
        }
        $domainOperations.DisplayDNSRecords
        {
            out-logfile -string "DisplayDNSRecords"

            out-logfile -string "Test to ensure that the domain is present."

            try {
                $domainInfo = test-domainName -domainName $domainName -errorAction STOP
            }
            catch {
                out-logfile -string $_ 
                out-logfile -string "Domain is not present in tenant - unable to provide DNS records for this domain." -isError:$true
            }

            out-logfile -string "Claculating the public DNS records necessary for your tenant to function."

            calculate-publicDNSRecords -domainName $domainName -msGraphEnvironmentName $msGraphEnvironmentName -msGraphEnvironments $msGraphEnvironments

            read-host "Press"
        }
    }

    Disconnect-MgGraph

    out-logfile -string "Completed domain operations using M365DomainMGMT"
}