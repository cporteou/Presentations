#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 4: Getting some data
#-------------------------------------------------------
break

#Use the Token we created earlier
$token

# Build the API Header with the auth token
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token
}

#-------------------------------------------------------

#Let's return all Workspaces
$uri = "https://api.powerbi.com/v1.0/myorg/groups"

$workspace = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

#-------------------------------------------------------

#What about a specific workspace
$workspace.value[3]


#-------------------------------------------------------
#Workspace users
$WorkspaceID = $workspace.value[3].id

$uri = "https://api.powerbi.com/v1.0/myorg/groups/$($WorkspaceID)/users"

$workspaceUsers = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

$workspaceUsers.value

#-------------------------------------------------------
#Workspace datasets and refresh history

$uri = "https://api.powerbi.com/v1.0/myorg/groups/$($WorkspaceID)/datasets"

$datasets = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

$datasets.value
#Can only Add rows to datasets created by the API
#Cant refresh directQuery datasets ie (usage metrics)

#-------------------------------------------------------
#Reports

$uri = "https://api.powerbi.com/v1.0/myorg/groups/$($WorkspaceID)/reports"

$reports = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

$reports.value

#-------------------------------------------------------
#Let's export a report. Use this to backup content?
$reportID = $reports.value[1].id

$uri = "https://api.powerbi.com/v1.0/myorg/groups/$($WorkspaceID)/reports/$($reportID)/Export"

$outputFile = (Resolve-Path .\).Path + "\$($reports.value[1].name).pbix"
Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET | Out-File -filepath $outputFile

