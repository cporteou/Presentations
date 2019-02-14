#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 4: Prompted setup
#-------------------------------------------------------
break

# If my demo broke earlier:
# $workspace.id = 'f213dfd6-9941-4ae1-887d-f1cb837dae1b'
# $dataset.id = '88e2f8e4-bbca-4366-b37c-fe36d047a2ae'

#-------------------------------------------------------------------------------
# Connect to Power BI API Using the Power BI Management Module

    Login-PowerBI

#-------------------------------------------------------
# Get the access token to invoke the REST API manually

    $token = Get-PowerBIAccessToken

    $authHeader = @{
        'Content-Type'='application/json'
        'Authorization'= $token.Authorization
    }

#-------------------------------------------------------------------------------
# Source our Weather data. This is the repeatable part.

    #Using the Workspace and datasets we defined in Demo 2 to get and store refresh history
    $uri = "https://api.powerbi.com/v1.0/myorg/groups/$($workspace.id)/datasets/$($dataset.id)/refreshes"

    $datasets = Invoke-RestMethod -Uri $uri -Headers $authHeader -Method GET

    #No need to convert to JSON when using the module.
    $refreshHistory = $datasets.value | ConvertTo-Json


#-------------------------------------------------------------------------------
# Create Push dataset in Workspace with the Management module function

    $col1 = New-PowerBIColumn -Name 'id' -DataType Int64
    $col2 = New-PowerBIColumn -Name 'refreshType' -DataType String
    $col3 = New-PowerBIColumn -Name 'startTime' -DataType DateTime
    $col4 = New-PowerBIColumn -Name 'endTime' -DataType DateTime
    $col5 = New-PowerBIColumn -Name 'status' -DataType string

    #Wrap columns in a table
    $table1 = New-PowerBITable -Name 'Weather dataset' -Columns $col1, $col2, $col3, $col4, $col5

    #Wrap table in a dataset
    $ds = New-PowerBIDataset -Name 'Dataset Refresh History' -Tables $table1

    #Add the dataset to the Workspace we created earlier
    $dataset = Add-PowerBIDataset -DataSet $ds -WorkspaceId $workspace.id


    Start-Process https://app.powerbi.com/groups/$($Workspace.id)/list/datasets

#-------------------------------------------------------------------------------
# Push data to this new dataset using the Power BI Management Module

    Add-PowerBIRow -DatasetId $dataset.Id -TableName 'Weather dataset' -Rows $refreshHistory -WorkspaceId $workspace.id

#-------------------------------------------------------------------------------
# Dataset feeds into report

    Start-Process https://app.powerbi.com/groups/$($Workspace.id)/list/datasets

