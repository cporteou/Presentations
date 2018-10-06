#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 4: Automation setup
#-------------------------------------------------------
break

# Automate collection of licensing data. 2 methods to do this if you want this to run unattended or with prompted authentication
# Install-Module PowerBI-Metadata

#-------------------------------------------------------------------------------
# Get License data across all users

    Connect-AzureAD

    #Collect license info
    $pbiLicenses = Get-AzureADSubscribedSku | Where-Object{$_.SkuPartNumber -like '*POWER_BI*' -and $_.CapabilityStatus -eq 'Enabled'} | Select-Object SkuPartNumber, ConsumedUnits, SkuId

    $pbiUsers = @()
    #Loop through each license and list all users
    foreach($license in $pbiLicenses)
    {
        $pbiUsers += Get-AzureADUser -All 1 | Where-Object{($_.AssignedLicenses | Where-Object{$_.SkuId -eq $license.SkuId})} | Select-Object DisplayName, UserPrincipalName, @{l='License';e={$license.SkuPartNumber}}
    }

    $pbiUsersJson = $pbiUsers | ConvertTo-Json

#-------------------------------------------------------------------------------
# Connect to Power BI API using this Unattended auth function in the PowerBI-Metadata module
# This method uses the Active Directory Authentication Library (ADAL) to obtain an access token through the OAuth 2.0 protocol.

    #Ive set my email already and my ClientID and CLient Secret using an App created earlier
    #Here I'm using the secure password file method.
    $Splat = @{
        clientId       = '7fe7ce40-e0c9-418b-8a67-3332ff941d94'
        userName           = 'CPorteous@SQLGlasgow.co.uk'
        client_secret   = $client_Secret
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

    $dataset = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -Body $templateDataset


    Start-Process https://app.powerbi.com/groups/09205e39-5f7a-4daa-9b9c-4aaf6cb34cf9/list/datasets

#-------------------------------------------------------------------------------
# Push data to dataset

    #We can get a list of tables
    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/datasets/$($dataset.id)/tables"

    $tables = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

    $tables.value

    #Push JSON data to the dataset
    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/datasets/$($dataset.id)/tables/Licenses/rows"

    Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -Body $pbiUsersJson


#-------------------------------------------------------------------------------
# Dataset feeds into report

Start-Process https://app.powerbi.com/groups/09205e39-5f7a-4daa-9b9c-4aaf6cb34cf9/list/datasets

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