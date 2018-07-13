#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 3: Prompted Authentication
#-------------------------------------------------------
break

# Install-Module Microsoft.ADAL.PowerShell
#-------------------------------------------------------
# Prompted Authentication
#-------------------------------------------------------

# Client ID can be obtained from creating a Power BI app:
# https://dev.powerbi.com/apps
# App Type: Native

$clientId = '0bb5a25b-9f95-4091-8c48-de56248c9d24'
$redirectUrl = 'https://incrementalgroup.co.uk'

#-------------------------------------------------------


$authority = "https://login.windows.net/common/oauth2/authorize"
$resourceAppID = "https://analysis.windows.net/powerbi/api"


#-------------------------------------------------------

$authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority

#-------------------------------------------------------

        #Authentication will prompt for credentials'
        $promptBehaviour = 'Always'

        #Authentication will only prompt for credentials if user is not already authenticated'
        #$promptBehaviour = 'Auto'

#-------------------------------------------------------


$auth = $authContext.AcquireToken($resourceAppID, $clientId, $redirectUrl, $promptBehaviour)

$token = $auth.AccessToken
$auth.AccessToken