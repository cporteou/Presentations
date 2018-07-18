#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 6: Automation setup
#-------------------------------------------------------
break

# Automate collection of licensing data

#* Get License data across all users
#-------------------------------------------------------------------------------
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


#* Connect to Power BI API
#-------------------------------------------------------------------------------
    $token = Get-PBIAuthTokenUnattended -userName $email -clientId $client_ID -client_secret $client_Secret

    # Build the API Header with the auth token
    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'='Bearer ' + $token
    }


#* Create Push dataset in Workspace
#-------------------------------------------------------------------------------

    #Import JSON template for Dataset (and table)
    $templateDataset = Get-Content .\PUSHDataset.json

    $workspace = Get-PBMWorkspace -authToken $token -workspaceName $workspaceName
    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/datasets"

    $dataset = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -Body $templateDataset

    https://app.powerbi.com/groups/


#* Push data to dataset
#-------------------------------------------------------------------------------

    #We can get a list of tables
    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/datasets/$($dataset.id)/tables"

    $tables = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

    $tables.value

    #Push JSON data to the dataset
    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($Workspace.id)/datasets/$($dataset.id)/tables/Licenses/rows"

    Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -Body $pbiUsersJson


#* Dataset feeds into report
#-------------------------------------------------------------------------------

    https://app.powerbi.com/groups/me

