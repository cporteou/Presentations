using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# # Write to the Azure Functions log stream.
# Write-Host "PowerShell HTTP trigger function processed a request."

# # Interact with query parameters or the body of the request.
 $name = $Request.Query.blobname
if (-not $name) {
    $name = $Request.Body.Name
}

# $body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

# if ($name) {
#     $body = "Hello, $name. This HTTP triggered function executed successfully."
# }

#----------------------------------------
# Author: 	Craig Porteous
# Date:		09/09/2020
# This script is for retrieving all PBI
# workspace security members using Service
# principal authentication
#----------------------------------------



# Build authentication components
$client_Id = $env:kv_powerbi_clientid
$client_Secret = $env:kv_powerbi_clientsecret
$tenantID = ""
$authority = "https://login.windows.net/$tenantID/oauth2/token"
$resourceAppID = "https://analysis.windows.net/powerbi/api"

#-------------------------------------------------------
# Get Authentication token

    $authBody = @{
        'resource'=$resourceAppID
        'client_id'=$client_Id
        'grant_type'="client_credentials"
        'client_secret'=$client_Secret
    }

#-------------------------------------------------------
# Authentiate to Power BI

    $auth = Invoke-RestMethod -Uri $authority -Body $authBody -Method POST -Verbose

    $token = $auth.access_token

    # Build the API Header with the auth token
    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'='Bearer ' + $token
    }

#-------------------------------------------------------------------------------
# List out all of our workspaces.

    $uri = "https://api.powerbi.com/v1.0/myorg/groups/"

    $workspaces = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

#Declare final Array
$PBI_Security = @()

#-------------------------------------------------------------------------------
# Loop through all workspaces.

foreach($workspace in $workspaces.value)
{
        
    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.id)/users"

    $users = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET # -Verbose

    foreach($user in $users.value)
    {
        $PBI_Security += New-Object PsObject -Property @{
            "GroupName"="$($workspace.name)";
            "GroupID"="$($workspace.id)";
            "UserName"="$($user.displayName)";
            "UserEmail"="$($user.emailAddress)";
            "UserRole"="$($user.GroupUserAccessRight)";
            "userType"="$($user.principalType)"
            "AuditDate"="$(get-date -f yyyy-MM-dd)";
        }
    }
    $users = $null
    $uri = $null
}

$jsonBody = ConvertTo-Json $PBI_Security

Push-OutputBinding -Name outputBlob -Value $jsonBody

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $blobname
})
