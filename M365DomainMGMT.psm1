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
        #Define variables to allow administrator to provide grpah connectivity.
         #Define Microsoft Graph Parameters
        [Parameter(Mandatory = $false)]
        [ValidateSet("None","China","Global","USGov","USGovDod")]
        [string]$msGraphEnvironmentName="None",
        [Parameter(Mandatory=$false)]
        [string]$msGraphTenantID="None",
        [Parameter(Mandatory=$false)]
        [string]$msGraphCertificateThumbprint="None",
        [Parameter(Mandatory=$false)]
        [string]$msGraphApplicationID="None",
        [Parameter(Mandatory=$false)]
        [string]$msGraphClientSecret="None"
    )

    #Variables for logging.

    $global:msGraphGlobal:logFile=$NULL
    $logFileName = "M365DomainMgmt_"+(Get-Date -Format FileDateTime)

    #Variables for graph.

    $msGraphRequiredScopes = "Domain.ReadWrite.All"
    $msGraphURL = ""

    #Define globals

    $global:msGraphGlobal = "Global"
    $global:msGraphUSGov = "USGov"
    $global:msGraphUSDOD = "usDOD"
    $global:msGraphChina = "China"
    $global:authenticationInteractive = "Interactive"
    $global:authenticationCertificate = "Certificate"
    $global:authenticationSecret = "Secret"

    #Start the log file.

    new-logfile -logFileName $logFileName -logFolderPath $logFolderPath

    out-logfile -string "*****************************************************"
    out-logfile -string "Starting M365 Domain Management"
    out-logfile -string "*****************************************************"

    out-logfile -string "Obtain and prepare MS Graph Connection."

    $msGraphURL = start-msGraphConnection -msGraphScopesRequired $msGraphRequiredScopes -msGraphEnvironmentName $msGraphEnvironmentName -msGraphTenantID $msGraphTenantID -msGraphCertificateThumbprint $msGraphCertificateThumbprint -msGraphApplicationID $msGraphApplicationID -msGraphClientSecret $msGraphClientSecret
}

