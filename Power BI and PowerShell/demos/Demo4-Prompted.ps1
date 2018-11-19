#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 4: Prompted setup
#-------------------------------------------------------
break

# Automate collection of licensing data. 2 methods to do this if you want this to run unattended or with prompted authentication

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
# Connect to Power BI API Using the Power BI Management Module

    Login-PowerBI

#-------------------------------------------------------------------------------
# Create Push dataset in Workspace with the Management module function

    $col1 = New-PowerBIColumn -Name 'DisplayName' -DataType String
    $col2 = New-PowerBIColumn -Name 'UserPrincipalName' -DataType String
    $col3 = New-PowerBIColumn -Name 'License' -DataType String

    #Wrap columns in a table
    $table1 = New-PowerBITable -Name 'Licenses' -Columns $col1, $col2, $col3

    #Wrap table in a dataset
    $ds = New-PowerBIDataset -Name 'Power BI Licenses' -Tables $table1

    #Add the dataset to the Workspace we created earlier
    $dataset = Add-PowerBIDataset -DataSet $ds -WorkspaceId $workspace.id


    Start-Process https://app.powerbi.com/groups/$($Workspace.id)/list/datasets

#-------------------------------------------------------------------------------
# Push data to dataset using the Power BI Management Module

    # Needs the data to be in an array, not JSON
    $pbiUsersArray = ConvertFrom-Json $pbiUsersJson

    Add-PowerBIRow -DatasetId $dataset.Id -TableName 'Licenses' -Rows $pbiUsersArray -WorkspaceId $workspace.id

#-------------------------------------------------------------------------------
# Dataset feeds into report


    Start-Process https://app.powerbi.com/groups/$($Workspace.id)/list/datasets

