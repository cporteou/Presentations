#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 7: Automated collection of data
#-------------------------------------------------------


# Automate collection of licensing data
[CmdletBinding()]
param
(
    [string]
    $email,

    [string]
    $clientId,

    [string]
    $client_secret
)

    #Authentication
    try {
        #Authenticate to Azure AD using previously created CredentialManager entry
        $cred = Get-StoredCredential -Target 'Power BI Licenses'

        Connect-AzureAD -Credential $cred | Out-Null

        #Authenticate to Power BI API using app details
        $token = Get-PBIAuthTokenUnattended -userName $email -clientId $client_ID -client_secret $client_Secret

        $authHeader = @{
            'Content-Type'='application/json'
            'Authorization'='Bearer ' + $token
        }
    }
    catch {
        throw (New-Object System.Exception("Error authenticating to Power BI or Azure! $($_.Exception.Message)", $_.Exception))
    }


    try {
        #Return current License allocations for Power BI
        $pbiLicenses = Get-AzureADSubscribedSku | Where-Object{$_.SkuPartNumber -like '*POWER_BI*' -and $_.CapabilityStatus -eq 'Enabled'} | Select-Object SkuPartNumber, ConsumedUnits, SkuId

        #Loop through each license and list all users
        foreach($license in $pbiLicenses)
        {
            $pbiUsers += Get-AzureADUser -All 1 | Where-Object{($_.AssignedLicenses | Where-Object{$_.SkuId -eq $license.SkuId})} | Select-Object DisplayName, UserPrincipalName, @{l='License';e={$license.SkuPartNumber}}
        }

        #Convert to JSON to push into Power BI dataset
        $pbiUsersJson = $pbiUsers | ConvertTo-Json
    }
    catch {
        throw (New-Object System.Exception("Error collecting License data from Azure! $($_.Exception.Message)", $_.Exception))
    }

    try {
        #Get the dataset ID of our Push Dataset
        $uri = "https://api.powerbi.com/v1.0/myorg/datasets"

        $dataset = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET
    }
    catch {
        throw (New-Object System.Exception("Error retrieving dataset! $($_.Exception.Message)", $_.Exception))
    }

    try {
        #Clear data out of the Push Dataset
        $uri = "https://api.powerbi.com/v1.0/myorg/datasets/$($dataset.id)/tables/Licenses/rows"

        Invoke-RestMethod -Uri $uri -Headers $authHeader -Method DELETE

        #Push data to dataset
        $uri = "https://api.powerbi.com/v1.0/myorg/datasets/$($dataset.id)/tables/Licenses/rows"

        Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -Body $pbiUsersJson
    }
    catch {
        throw (New-Object System.Exception("Error updating dataset! $($_.Exception.Message)", $_.Exception))
    }


