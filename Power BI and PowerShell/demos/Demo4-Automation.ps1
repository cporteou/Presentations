#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 4: Automation setup
#-------------------------------------------------------
break

# If my demo broke earlier:
# $workspace.id = 'f213dfd6-9941-4ae1-887d-f1cb837dae1b'
# $dataset.id = '88e2f8e4-bbca-4366-b37c-fe36d047a2ae'

# Automate collection of dataset refresh data. 2 methods to do this if you want this to run unattended or with prompted authentication
# Install-Module PowerBI-Metadata
#-------------------------------------------------------------------------------
# Connect to Power BI API using this Unattended auth function in the PowerBI-Metadata module
# This method uses the Active Directory Authentication Library (ADAL) to obtain an access token through the OAuth 2.0 protocol.

    #Ive set my email already and my ClientID and CLient Secret using an App created earlier
    #Here I'm using the secure password file method.
    $Splat = @{
        clientId       = '4b606914-a276-4482-9304-4c0f965a80c9'
        userName       = 'Craig@craigporteous.com'
        client_secret  = $client_Secret
    }

    $token = Get-PBIAuthTokenUnattended @Splat

    # Build the API Header with the auth token
    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'='Bearer ' + $token
    }

#-------------------------------------------------------------------------------
# Create Push dataset in Workspace from template

    #Import JSON template for Dataset (and table)
    $templateDataset = Get-Content .\PUSHDataset.json

    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/datasets"

    $pushDataset = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -Body $templateDataset


    Start-Process https://app.powerbi.com/groups/$($Workspace.id)/list/datasets

#-------------------------------------------------------------------------------
# Source our Weather data. This is the repeatable part.

    #Using the Workspace and datasets we defined in Demo 2 to get and store refresh history
    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.id)/datasets/$($dataset.id)/refreshes"

    $datasets = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

    #Body has to be in JSON format
    $refreshHistory = $datasets.value | Select-Object id, refreshtype, starttime, endtime, status | ConvertTo-Json


#-------------------------------------------------------------------------------
# Push data to dataset

    #We can get a list of tables
    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/datasets/$($pushDataset.id)/tables"

    $tables = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

    $tables[0].value.name

    #Push JSON data to the dataset
    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/datasets/$($pushDataset.id)/tables/$($tables[0].value.name)/rows"

    Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -Body $refreshHistory


#-------------------------------------------------------------------------------
# Dataset feeds into report

Start-Process https://app.powerbi.com/groups/$($Workspace.id)/list/datasets

#Here's one I made earlier:
Start-Process https://app.powerbi.com/groups/f213dfd6-9941-4ae1-887d-f1cb837dae1b/reports/65017520-8acd-4380-a62e-82929483a153/ReportSection







break
#-------------------------------------------------------
#* OPTION 1 - Use Credential Manager module - Thanks Josh King (@WindosNZ)

$Splat = @{
    Target   = 'Power BI Auth Demo'
    Password = Read-Host -Prompt "Please enter Password for $email"
    Comment  = 'This helps remind my why I created this'
    Persist  = 'LocalMachine'
}
New-StoredCredential @Splat

$cred = Get-StoredCredential -Target 'Power BI Licenses'
$pass = $cred.Password

# This should be a secure string
$pass

#-------------------------------------------------------
#* OPTION 2 - Use an encrypted text file

$path = (Resolve-Path .\).Path
$user = $env:UserName
$file = ($email + "_cred_by_$($user).txt")

# Encrypted Credential file not found. Creating new file
Read-Host -Prompt "Please enter Password for $email" -AsSecureString | ConvertFrom-SecureString | Out-File "$($path)\$($email)_cred_by_$($user).txt"

# Retrieve file
$pass = Get-Content ($path + '\' + $file) | ConvertTo-SecureString

# This should be a secure string
$pass

#-------------------------------------------------------