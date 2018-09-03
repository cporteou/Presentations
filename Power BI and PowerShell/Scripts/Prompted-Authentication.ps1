#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 3: Prompted Authentication
#-------------------------------------------------------
break

# Install-Module Microsoft.ADAL.PowerShell

# Client ID can be obtained from creating a Power BI app:
# https://dev.powerbi.com/apps
# App Type: Native
#-------------------------------------------------------

#Variables already defined
$clientId
$redirectUrl

#-------------------------------------------------------


$authority = "https://login.windows.net/common/oauth2/authorize"
$resourceAppID = "https://analysis.windows.net/powerbi/api"


#-------------------------------------------------------

#Load Active Directory Authentication Library (ADAL) Assemblies
Add-Type -Path "${env:ProgramFiles}\WindowsPowerShell\Modules\Microsoft.ADAL.PowerShell\1.12\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
Add-Type -Path "${env:ProgramFiles}\WindowsPowerShell\Modules\Microsoft.ADAL.PowerShell\1.12\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"

$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

#-------------------------------------------------------

        #Authentication will prompt for credentials'
        #$promptBehaviour = 'Always'

        #Authentication will only prompt for credentials if user is not already authenticated'
        $promptBehaviour = 'Auto'

#-------------------------------------------------------

$auth = $authContext.AcquireToken($resourceAppID, $clientId, $redirectUrl, $promptBehaviour)

$token = $auth.AccessToken

$token