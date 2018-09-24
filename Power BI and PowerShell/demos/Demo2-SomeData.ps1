#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 4: Getting some data
#-------------------------------------------------------
break

# This is a wrapper module
    Install-Module MicrosoftPowerBIMgmt -Scope CurrentUser
    Update-Module MicrosoftPowerBIMgmt 
#-------------------------------------------------------
# List out the available commands

    Get-Command -Module MicrosoftPowerBIMgmt.Data
    Get-Command -Module MicrosoftPowerBIMgmt.Profile
    Get-Command -Module MicrosoftPowerBIMgmt.Reports
    Get-Command -Module MicrosoftPowerBIMgmt.Workspaces

#-------------------------------------------------------
# Authenticate to Power BI

    Login-PowerBI

#-------------------------------------------------------
# List out all of your workspaces

    Get-PowerBIGroup -Scope Individual

    # List out ALL workspaces in the Org - For Power BI Admins
    Get-PowerBIWorkspace -Scope Organization

    $workspace = Get-PowerBIWorkspace -Name 'PowerShell Demo'

#-------------------------------------------------------
# Get all datasets in a specific workspace

    Get-PowerBIWorkspace -Name 'PowerShell Demo' | Get-PowerBIDataset

    $dataset = Get-PowerBIDataset -WorkspaceId $workspace.Id | Where-Object {$_.Name -eq 'Weather'}

#-------------------------------------------------------
# How about the users?

    Get-PowerBIWorkspaceUser

    #Not yet. Only Add/Remove
    Add-PowerBIWorkspaceUser -id $workspace.id -UserPrincipalName 'Aburton@sqlglasgow.co.uk' -AccessRight Admin

    Remove-PowerBIWorkspaceUser -id $workspace.id -UserPrincipalName 'Aburton@sqlglasgow.co.uk'
    #Doesnt work for adding members!
    Add-PowerBIWorkspaceUser -id $workspace.id -UserPrincipalName 'Aburton@sqlglasgow.co.uk' -AccessRight Member

#-------------------------------------------------------
# We can see Dataset refresh history by invoking the REST API manually
# Not currently a function in the module.

    Login-PowerBIServiceAccount

    $token = Get-PowerBIAccessToken

    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'= $token.Authorization
    }

#-------------------------------------------------------
#Workspace datasets and refresh history

    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.id)/datasets/$($dataset.id)/refreshes"

    $datasets = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

    $datasets.value

    #Can only Add rows to datasets created by the API
    #Cant refresh directQuery datasets ie (usage metrics)

#-------------------------------------------------------
#Reports

    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.id)/reports"

    $reports = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

    $reports.value

#-------------------------------------------------------
#Let's export a report. Use this to backup content?
    $report = $reports.value | Where-Object{$_.name -eq 'Weather'}

    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/reports/$($report.id)/Export"

    $outputFile = (Resolve-Path .\).Path + "\$($report.name).pbix"

    Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET | Out-File -filepath $outputFile

