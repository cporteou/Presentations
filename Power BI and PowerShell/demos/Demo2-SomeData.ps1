#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 2: Getting some data
#-------------------------------------------------------
break

Start-Process https://docs.microsoft.com/en-us/rest/api/power-bi/

    # This is a wrapper module
    # Install-Module MicrosoftPowerBIMgmt
    # Get-Module -Name MicrosoftPowerBIMgmt -ListAvailable

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

    #We'll use this workspace in all the demos
    $workspace = Get-PowerBIWorkspace -Name 'Power BI Loves PowerShell'

#-------------------------------------------------------
# Get all datasets in a specific workspace

    Get-PowerBIWorkspace -Name 'Power BI Loves PowerShell' | Get-PowerBIDataset

    #We'll use this dataset in all the demos
    $dataset = Get-PowerBIDataset -WorkspaceId $workspace.Id | Where-Object {$_.Name -eq 'Weather'}

#-------------------------------------------------------
# How about the users?


    #No "Get". Only Add/Remove
    Add-PowerBIWorkspaceUser -id $workspace.id -UserPrincipalName 'Aburton@craigporteous.com' -AccessRight Admin -Verbose

    Remove-PowerBIWorkspaceUser -id $workspace.id -UserPrincipalName 'Aburton@craigporteous.com' -Verbose

    Add-PowerBIWorkspaceUser -id $workspace.id -UserPrincipalName 'JHolden@craigporteous.com' -AccessRight Member




    # Didn't work. It is the same for Contributor permissions. This is actually a lack of functionality in the API despite showing in the documentation.
    # Results in "UnsupportedAccessRightError"

#-------------------------------------------------------
# The module can't handle the new Dataflows and App API calls yet.
# We can see Dataset refresh history by invoking the REST API manually
# Not currently a function in the module.

    $token = Get-PowerBIAccessToken

    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'= $token.Authorization
    }

#-------------------------------------------------------
#Workspace and datasets we defined above and their refresh history

    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.id)/datasets/$($dataset.id)/refreshes"

    $datasets = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

    $datasets.value

#-------------------------------------------------------
#Dataflows

$uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.id)/Dataflows"

$dataflows = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

$dataflows.value

#-------------------------------------------------------
#Reports

    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.id)/reports"

    $reports = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

    $reports.value

    Start-Process $reports.value[0].webUrl

#-------------------------------------------------------
#Let's export a report. Use this to backup content?
    $report = $reports.value | Where-Object{$_.name -eq 'Weather'}

    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/reports/$($report.id)/Export"

    $outputFile = (Resolve-Path .\).Path + "\$($report.name).pbix"

    Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET | Out-File -filepath $outputFile

#-------------------------------------------------------------------------------
# Output file location
Invoke-Item .\


