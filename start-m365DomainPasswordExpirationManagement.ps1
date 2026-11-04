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


Function start-m365DomainPasswordExpirationManagement
{
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
        [Parameter(Mandatory = $false)]        
        $domainsToModify=@(),
        [Parameter(Mandatory = $true)] 
        [ValidateSet("Enable","Disable")]
        [string]$enableOrDisable="",
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 2147483647)]        
        [int]$expirationDays=$NULL,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 2147483647)]        
        [int]$expirationNotificationDays=$NULL,
        [Parameter(Mandatory = $false)]        
        [boolean]$includeOnMicrosoftDomains=$false,
        [Parameter(Mandatory = $false)]        
        [boolean]$allDomains=$false,
        [Parameter(Mandatory =$FALSE)]
        [boolean]$allowTelemetryCollection=$TRUE
    )

    $disabledValue = "2147483647"
    $onMicrosoft = "onmicrosoft.com"

    #Create timeline hash table.

    $global:htmlTime = @{}
    $global:htmlTime['StartTime']=Get-Date

    #Create HTML items.

    $global:htmlData = @{}

    $telemetryStartTime = get-universalDateTime

    #Set the window title.

    $windowTitle = ("Start-M365DomainPasswordExpirationManagement")
    $host.ui.RawUI.WindowTitle = $windowTitle

    #Initialize telemetry collection.

    $appInsightAPIKey = "63d673af-33f4-401c-931e-f0b64a218d89"
    $traceModuleName = "M365DomainMgmt"

    if ($allowTelemetryCollection -eq $TRUE)
    {
        start-telemetryConfiguration -allowTelemetryCollection $allowTelemetryCollection -appInsightAPIKey $appInsightAPIKey -traceModuleName $traceModuleName
    }

    $global:ExpirationDomains=[System.Collections.Generic.List[PSObject]]::new()

    #Create telemetry values.

    $telemetryValues = @{}
    $telemetryValues['telemetryM365DomainMgmtVersion']="None"
    $telemetryValues['telemetryMSGraphAuthenticationVersion']="None"
    $telemetryValues['telemetryMSGraphDirectoryVersion']="None"
    $telemetryValues['telemetryEventName']="start-m365DomainPasswordExpirationManagement"

    #Create export table

    $exportNames = @{}
    $exportNames['DomainInfo']="DomainInfo"
    $exportNames['msGraphContext']="MSGraphContext"


    $moduleNames = @{}
    $moduleNames['M365DomainManagement']="M365DomainMGMT"
    $moduleNames['MsGraphAuthentication']="Microsoft.Graph.Authentication"
    $moduleNames['MSGraphDirectory']="Microsoft.Graph.Identity.DirectoryManagement"

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


    #Variables for logging and start log file.

    $global:logFile=$NULL
    $logFileName = "M365DomainMgmt_"+(Get-Date -Format FileDateTime)

    new-logfile -logFileName $logFileName -logFolderPath $logFolderPath

    out-logfile -string "*****************************************************"
    out-logfile -string "Entering Start-M365DomainPasswordExpirationManagement"
    out-logfile -string "*****************************************************"

    $global:htmlTime['PowerShellVersionTest']=Get-Date

    $telemetryValues['telemetryM365DomainMgmtVersion']=test-PowerShellModule -powershellModuleName $moduleNames.M365DomainManagement -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSGraphAuthenticationVersion']=test-PowerShellModule -powershellModuleName $moduleNames.MsGraphAuthentication -powershellVersionTest:$TRUE
    $telemetryValues['telemetryMSGraphDirectoryVersion']=test-PowerShellModule -powershellModuleName $moduleNames.MSGraphDirectory -powershellVersionTest:$TRUE

    $global:htmlTime['ParameterValidation']=Get-Date

    if ($enableOrDisable -eq "Enable")
    {
        out-logfile -string "Enable Password Expiration operation specified"
        out-logfile -string $expirationDays

        if ($expirationDays -eq 0)
        {
            out-logfile -string "ERROR:  Expiration days must be specified when enabling password expiration." -isError:$TRUE
        }

        if ($expirationNotificationDays -eq 0)
        {
            out-logfile -string "ERROR:  Expiration notification days must be specified when enabling password expiration." -isError:$TRUE
        }
    }
    elseif ($enableOrDisable -eq "Disable")
    {
        if ($expirationDays -gt 0)
        {
            out-logfile -string "ERROR:  Expiration days may not be specified when disabling password expiration." -isError:$TRUE
        }

        if ($expirationNotificationDays -gt 0)
        {
            out-logfile -string "ERROR:  Expiration notification days may not be specified when disabling password expiration." -isError:$TRUE
        }
    }
    else 
    {
        out-logfile -string "Disable Password Expiration operation specified"
    }

    out-logfile -string $domainsToModify.getType().name
    out-logfile -string $domainsToModify.getType().baseType.name


    if ($domainsToModify.getType().name -eq "String")
    {
        out-logfile -string "The domains to modify parameter is a string - convert to array."
        $domainsToModify = $domainsToModify -split ","
    }
    elseif ($domainsToModify.getType().BaseType.Name -eq "System.Array")
    {
        out-logfile -string "The domains to modify parameter is an array."
    }
    elseif ($domainsToModify.getType().BaseType.Name -eq "Array")
    {
        out-logfile -string "The domains to modify parameter is an array."
    }
    else 
    {
        out-logfile -string "ERROR:  The domains to modify parameter is not a string or array." -isError:$TRUE
    }

    if ($allDomains -eq $TRUE -and $domainsToModify.Count -gt 0)
    {
        out-logfile -string "ERROR:  The all domains parameter is set to true and the domains to modify parameter is not empty." -isError:$TRUE
    }
    else 
    {
        out-logfile -string "The following domains will be modified:  $($domainsToModify -join ', ')"
    }

    $global:htmlTime['MSGraphConnection']=Get-Date

    $msGraphValues.msGraphScopes += "Domain.ReadWrite.All"

    new-msGraphConnection -msGraphHashTable $msGraphValues -exportFile $exportNames.msGraphContext

    $global:htmlTime['GatherM365Domains']=Get-Date

    if ($allDomains -eq $TRUE)
    {
        out-logfile -string "All domains parameter is set to true - gather all M365 domains."

        try
        {
            $functionM365Domains = get-mgDomain -all -property ID,AuthenticationType,PasswordValidityPeriodInDays,PasswordNotificationWindowInDays,isRoot -errorAction Stop
        }
        catch 
        {
            out-logfile -string $_
            out-logfile -string "ERROR:  Unable to gather M365 domains." -isError:$TRUE
        }
    }
    elseif ($domainsToModify.Count -gt 0)
    {
        out-logfile -string "All domains parameter is set to false and the domains to modify parameter is not empty - gather specified M365 domains."

        $functionM365Domains = @()

        foreach ($domain in $domainsToModify)
        {
            try
            {
                $functionM365Domain = get-mgDomain -DomainId $domain -property ID,AuthenticationType,PasswordValidityPeriodInDays,PasswordNotificationWindowInDays,isRoot -errorAction Stop
                $functionM365Domains += $functionM365Domain
            }
            catch 
            {
                out-logfile -string $_
                out-logfile -string "ERROR:  Unable to gather M365 domain $domain." -isError:$TRUE
            }
        }
    }
    else 
    {
        out-logfile -string "All domains parameter is set to false and the domains to modify parameter is empty - no domains will be modified."
    }

    $global:htmlTime['ProcessCustomDomainObjects']=Get-Date

    foreach ($domain in $functionM365Domains)
    {
        out-logfile -string "Processing domain $($domain.id)"

        $functionObject = New-Object PSObject -Property ([ordered]@{
            ID = ""
            AuthenticationType = ""
            Current_PasswordValidityPeriodInDays = ""
            New_PasswordValidityPeriodInDays = ""
            Current_PasswordNotificationWindowInDays = ""
            New_PasswordNotificationWindowInDays = ""
            IsRootDomain = ""
            Error = ""
        })

        $functionObject.ID = $domain.id
        $functionObject.AuthenticationType = $domain.AuthenticationType
        $functionObject.Current_PasswordValidityPeriodInDays = $domain.PasswordValidityPeriodInDays
        $functionObject.Current_PasswordNotificationWindowInDays = $domain.PasswordNotificationWindowInDays
        $functionObject.IsRootDomain = $domain.IsRoot

        if ($functionObject.AuthenticationType -eq "Federated")
        {
            $functionObject.error = "FEDERATED_DOMAIN_EXCEPTION: Password validity cannot be set on domains federated for authentication."
        }
        elseif ($includeOnMicrosoftDomains -eq $FALSE)
        {
            if ($functionObject.ID.contains($onMicrosoft))
            {
                out-logfile -string "Domain $($functionObject.ID) is an onmicrosoft.com domain - will be skipped."
                $functionObject.error = "ONMICROSOFT_DOMAIN_EXCEPTION: Domain skipped by administrator specification."
            }
            else
            {
                out-logfile -string "Domain $($functionObject.ID) is not an onmicrosoft.com domain - will be processed."
            }
        }
        elseif ($functionObject.isRootDomain -eq $false)
        {
            out-logfile -string "Domain $($functionObject.ID) is not a root domain and will be skipped."
            $functionObject.error = "ROOT_DOMAIN_EXCEPTION: Expiration cannot be set on a subdomain."
        }
        else 
        {
            out-logfile -string "Domain $($functionObject.ID) is a root domain and can be processed."
        }

        $global:ExpirationDomains.add($functionObject)
    }

    $global:htmlTime['ProcessPasswordExpiration']=Get-Date

    foreach ($domain in $global:ExpirationDomains)
    {
        $setSuccess = $FALSE

        if ($domain.error -eq "")
        {
            if ($enableOrDisable -eq "Enable")
            {
                out-logfile -string "Enabling password expiration for domain $($domain.ID) with expiration days $expirationDays"

                try
                {
                    update-mgDomain -DomainId $domain.ID -PasswordValidityPeriodInDays $expirationDays -PasswordNotificationWindowInDays $expirationNotificationDays -errorAction Stop
                    $setSuccess = $TRUE
                }
                catch 
                {
                    out-logfile -string $_
                    out-logfile -string "ERROR:  Unable to enable password expiration for domain $($domain.ID)."
                    $domain.Error = $_.Exception.Message
                }
            }
            elseif ($enableOrDisable -eq "Disable")
            {
                out-logfile -string "Disabling password expiration for domain $($domain.ID)"

                try
                {
                    update-mgDomain -DomainId $domain.ID -PasswordValidityPeriodInDays $disabledValue -PasswordNotificationWindowInDays $disabledValue -errorAction Stop
                    $setSuccess = $TRUE
                }
                catch 
                {
                    out-logfile -string $_
                    out-logfile -string "ERROR:  Unable to disable password expiration for domain $($domain.ID)."
                    $domain.Error = $_.Exception.Message
                }
            }
        }
        else
        {
            out-logfile -string "Domain $($domain.ID) has an error - skipping password expiration operation."
        }

        if ($setSuccess -eq $TRUE)
        {
            try
            {
                $updatedDomain = get-mgDomain -DomainId $domain.ID -property ID,AuthenticationType,PasswordValidityPeriodInDays,PasswordNotificationWindowInDays -errorAction Stop
                $domain.New_PasswordValidityPeriodInDays = $updatedDomain.PasswordValidityPeriodInDays
                $domain.New_PasswordNotificationWindowInDays = $updatedDomain.PasswordNotificationWindowInDays
            }
            catch 
            {
                out-logfile -string $_
                out-logfile -string "ERROR:  Unable to gather updated M365 domain $($domain.ID)." -isError:$TRUE
            }
        }
        else 
        {
            out-logfile -string "Password expiration was not set for domain $($domain.ID) - skipping gathering updated domain information."
            $domain.New_PasswordValidityPeriodInDays = "ERROR"
            $domain.New_PasswordNotificationWindowInDays = "ERROR"
        }
    }

    $global:htmlTime['ExportDetails']=Get-Date

    out-xmlFile -itemToExport $global:ExpirationDomains -itemNameToExport $exportNames.DomainInfo

    $telemetryEndTime = get-universalDateTime

    [double]$telemetryElapsedSeconds = get-elapsedTime -startTime $telemetryStartTime -endTime $telemetryEndTime

    $telemetryEventProperties = @{
        M365DomainMGMT = $telemetryValues.telemetryEventName    
        M365DomainMGMTVersion = $telemetryValues.telemetryM365DomainMgmtVersion
        MSGraphAuthentication = $telemetryValues.telemetryMSGraphAuthenticationVersion
        MSGraphDirectory = $telemetryValues.telemetryMSGraphDirectoryVersion
    }

    $telemetryEventMetrics = @{
         TotalTime = $telemetryElapsedSeconds  
    }

    send-TelemetryEvent -traceModuleName $traceModuleName -eventName $telemetryValues.telemetryEventName -eventMetrics $telemetryEventMetrics -eventProperties $telemetryEventProperties

    generate-htmlReport 

    Disconnect-MgGraph
}