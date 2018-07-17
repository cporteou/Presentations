#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 7: Automated collection of data
#-------------------------------------------------------



<#
.SYNOPSIS

.DESCRIPTION
#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 7: Automated collection of data
#-------------------------------------------------------

.PARAMETER email

.PARAMETER clientId

..PARAMETER client_Secret
#>

#Requires -Modules PowerBI-Metadata, Microsoft.ADAL.PowerShell, CredentialManager, AzureAD

[CmdletBinding()]
param
(
    [Parameter(Mandatory)]
    [string]
    $Email,
    [Parameter(Mandatory, HelpMessage = "Client ID for Power BI Server-side Web app")]
    [string]
    $ClientId,
    [Parameter(Mandatory, HelpMessage = "Client Secret for Power BI Server-side Web app")]
    [string]
    $Client_Secret
)

Begin{
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
}
Process{
    try {
        Write-Verbose "Return tenant's currently enabled licenses for all Power BI License types"
        $pbiLicenses = Get-AzureADSubscribedSku | Where-Object{$_.SkuPartNumber -like '*POWER_BI*' -and $_.CapabilityStatus -eq 'Enabled'} | Select-Object SkuPartNumber, ConsumedUnits, SkuId

        #Loop through each license and list all users
        foreach($license in $pbiLicenses)
        {
            Write-Verbose "Return users currently holding a $($license.SkuPartNumber) license"
            $pbiUsers += Get-AzureADUser -All 1 | Where-Object{($_.AssignedLicenses | Where-Object{$_.SkuId -eq $license.SkuId})} | Select-Object DisplayName, UserPrincipalName, @{l='License';e={$license.SkuPartNumber}}
        }

        #Convert to JSON to push into Power BI dataset
        $pbiUsersJson = $pbiUsers | ConvertTo-Json
    }
    catch {
        throw (New-Object System.Exception("Error collecting License data from Azure! $($_.Exception.Message)", $_.Exception))
    }

    try {
        Write-Verbose "Get the dataset ID of our Push Dataset"
        $dataset = Get-PBMDataset -authToken $token -datasetName 'SSSC Registrations'
    }
    catch {
        throw (New-Object System.Exception("Error retrieving dataset! $($_.Exception.Message)", $_.Exception))
    }

    try {
        if(!$dataset) {
            Write-Verbose "Dataset does not exist. Creating in MyWorkspace from local JSON template 'PUSHDataset.json'"
            $templateDataset = Get-Content .\PUSHDataset.json

            $uri = "https://api.powerbi.com/v1.0/myorg/datasets"

            $dataset = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -Body $templateDataset
        }
        else {
            Write-Verbose "Clearing data out of the Push Dataset"
            $uri = "https://api.powerbi.com/v1.0/myorg/datasets/$($dataset.id)/tables/Licenses/rows"

            Invoke-RestMethod -Uri $uri -Headers $authHeader -Method DELETE
        }

        Write-Verbose "Pushing data into dataset"
        $uri = "https://api.powerbi.com/v1.0/myorg/datasets/$($dataset.id)/tables/Licenses/rows"

        Invoke-RestMethod -Uri $uri -Headers $authHeader -Method POST -Body $pbiUsersJson

        Write-Verbose "Data Push complete"
    }
    catch {
        throw (New-Object System.Exception("Error updating dataset! $($_.Exception.Message)", $_.Exception))
    }
}


