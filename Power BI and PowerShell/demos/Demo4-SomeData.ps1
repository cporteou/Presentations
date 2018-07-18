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

$workspace.value

#-------------------------------------------------------

#What about a specific workspace
$demoWorkspace = $workspace.value | Where-Object {$_.name -eq 'PowerShell Demo'}

$demoWorkspace

#-------------------------------------------------------
#Workspace users

$uri = "https://api.powerbi.com/v1.0/myorg/groups/$($demoWorkspace.id)/users"

$workspaceUsers = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

$workspaceUsers.value

#-------------------------------------------------------
#Workspace datasets and refresh history

$uri = "https://api.powerbi.com/v1.0/myorg/groups/$($demoWorkspace.id)/datasets"

$datasets = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

$datasets.value
#Can only Add rows to datasets created by the API
#Cant refresh directQuery datasets ie (usage metrics)

#-------------------------------------------------------
#Reports

$uri = "https://api.powerbi.com/v1.0/myorg/groups/$($demoWorkspace.id)/reports"

$reports = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

$reports.value

#-------------------------------------------------------
#Let's export a report. Use this to backup content?
$report = $reports.value | Where-Object{$_.name -eq 'Weather'}

$uri = "https://api.powerbi.com/v1.0/myorg/groups/$($demoWorkspace.id)/reports/$($report.id)/Export"

$outputFile = (Resolve-Path .\).Path + "\$($report.name).pbix"

Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET | Out-File -filepath $outputFile

