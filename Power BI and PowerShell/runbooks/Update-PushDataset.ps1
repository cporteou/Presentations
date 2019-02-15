#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Script: Azure Automation runbook script to update push dataset
#-------------------------------------------------------
# Prerequisites
# Module: PowerBI-Metadata
# The following variables need to be set up in Azure Automation account:
# client_id - Set from the Power BI App created in the Developer portal
# client_secret - Set from the Power BI App created in the Developer portal
# workspace_id - Target & source workspace for datasets
# dataset_id - Source dataset we're pulling history from
# pushDataset_id - Target push dataset we're putting data into.
#-------------------------------------------------------
# set variables and retrieve automation credentials

# Credentials
$myCredential = Get-AutomationPSCredential -Name 'Power BI Login'
$userName = $myCredential.UserName
$password = $myCredential.GetNetworkCredential().Password

#Variables
$client_Id = Get-AutomationVariable -Name 'client_id'
$client_Secret = Get-AutomationVariable -Name 'client_secret'
$workspace_id = Get-AutomationVariable -Name 'workspace_id'
$dataset_id = Get-AutomationVariable -Name 'dataset_id'
$pushDataset_id = Get-AutomationVariable -Name 'pushDataset_id'

# Build authentication components
$tenantID = Get-AzureTenantID -Email $userName
$authority = "https://login.windows.net/$tenantID/oauth2/token"
$resourceAppID = "https://analysis.windows.net/powerbi/api"

#-------------------------------------------------------
# Get Authentication token

    $authBody = @{
        'resource'=$resourceAppID
        'client_id'=$client_Id
        'grant_type'="password"
        'username'=$userName
        'password'= $password #! THIS IS IN PLAIN TEXT!
        'scope'="openid"
        'client_secret'=$client_Secret
    }

    #! Clear password variable immediately after use
    $password = $null

#-------------------------------------------------------
#Authentiate to Power BI

    $auth = Invoke-RestMethod -Uri $authority -Body $authBody -Method POST -Verbose

    #! Clear auth array immediately after use
    $authBody = $null

    $token = $auth.access_token

    # Build the API Header with the auth token
    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'='Bearer ' + $token
    }

#-------------------------------------------------------------------------------
# Source our Weather dataset's refresh history.

    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace_id)/datasets/$($dataset_id)/refreshes"

    $datasets = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

    #Body has to be in JSON format
    $refreshHistory = $datasets.value | ConvertTo-Json

#-------------------------------------------------------------------------------
# Push data to dataset

    #We can get a list of tables
    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace_id)/datasets/$($pushDataset_id)/tables"

    $tables = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

    $tables[0].value.name

    #Push JSON data to the dataset
    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace_id)/datasets/$($pushDataset_id)/tables/$($tables.value.name)/rows"

    Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -Body $refreshHistory

