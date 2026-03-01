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
        [ValidateSet("None","New","Remove","Confirm","ForceTakeOver")]
        [string]$domainOperation="None",
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

    #Create export table

    $exportNames = @{}
    $exportNames['usersXML']="-UsersXML"
    $exportNames['domainsCSV']="-DomainsCSV"
    $exportNames['addressesToTextXML']="-AddressToTestXML"
    $exportNames['consumerAccountsXML']="-ConsumerAccounts"

    #Variables for logging and start log file.

    $global:logFile=$NULL
    $logFileName = "M365DomainMgmt_"+(Get-Date -Format FileDateTime)

    new-logfile -logFileName $logFileName -logFolderPath $logFolderPath

    out-logfile -string "*****************************************************"
    out-logfile -string "Entering Start-M365DomainManagement"
    out-logfile -string "*****************************************************"

    new-msGraphConnection -msGraphHashTable $msGraphValues
}
