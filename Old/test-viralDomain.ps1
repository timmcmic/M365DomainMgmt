function test-viralDomain
{
    param 
    (
        [Parameter(Mandatory = $true)]
        $domainName,
        [Parameter(Mandatory = $true)]
        $exportFile
    )

    $webInfo = $null
    $webURL = "https://login.microsoftonline.com/common/userrealm/"+$domainName+"?api-version=2.1"
    $jsonInfo = $null
    $unknownNamespace = "Unknown"
    $federatedNameSpace = "Federated"
    $domainIsViral = $false
    
    out-logfile -string "Entering test-viralInfo"
    
    out-logfile -string ("Testing URL: "+$webURL)

    try {
        $webInfo = Invoke-WebRequest -Uri $webURL -UseBasicParsing -ErrorAction Stop
        out-logfile -string "Successfully obtained viral domain information."
    }
    catch {
        out-logfile -string $_
        out-logfile -string "ERROR:  Unable to obtain viral domain information." -isError:$true
    }

    out-xmlfile -itemToExport $webInfo -itemNameToExport $exportFile.viralInfo

    try {
        out-logfile -string "Converting content payload from json format for evaluation."
        $jsonInfo = $webInfo.content | ConvertFrom-Json -ErrorAction Stop
        out-logfile -string "Content payload successfully converted from JSON for evaluation."
    }
    catch {
        out-logfile -string $_
        out-logfile -string 'ERROR:  Unable to convert content payload from JSON for evaluation.' -isError:$true
    }

    out-logfile -string $jsonInfo

    Out-logfile -string "Test to see if domain is already registered, tied to GoDaddy, or viral."

    if ($jsonInfo.NameSpaceType -eq $federatedNameSpace)
    {
        out-logfile -string "Domain is located and federated for authentication - test for Godaddy."

        if ($jsonInfo.authURL.contains("https://sso.godaddy.com"))
        {
            out-logfile -string "The domain is currently registered to another tenant through an Office 365 subscription purchased through GoDaddy."
            out-logfile -string "This implies that either the tenant was never removed or the domain currently has active Office 365 suscriptions through GoDaddy"
            out-logfile -string "Contact GoDaddy support and request information on the release of this domain."
            out-logfile -string $jsonInfo.authURL
            out-logfile -string "ERROR:  Godaddy support is required to assist with using this domain." -isError:$true
        }
        else 
        {
            out-logfile -string "Domain is not associated with GoDaddy - proceed."
        }
    }
    else 
    {
        out-logfile -string "Domain is not federated for authentication - proceed."
    }

    out-logfile -string "Test domain to see if it is viral or registered in another tenant."

    if ($jsonInfo.isViral -eq $TRUE)
    {
        out-logfile -string "The domain is reporting as viral - a force takeover may successfully confirm the domain."
        out-logfile -string $jsonInfo.isViral
        $domainIsViral = $true
    }
    elseif ($jsonInfo.namespacetype -ne $unknownNamespace)
    {
        out-logfile -string "The domain provided cannot be verified in this tenant."
        out-logfile -string "The domain is showing as currently verified on another tenant."
        out-logfile -string $jsonInfo.namespacetype
    }
    else 
    {
        out-logfile -string "Domain is not showing registered in another tenant or viral."
    }

    out-logfile -string "Exiting test-virualInfo"

    return $domainIsViral
}