#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 5: Power BI Metadata Module
#-------------------------------------------------------
break


#Install-Module PowerBI-Metadata
#-------------------------------------------------------

    Get-Command -Module PowerBI-Metadata

#-------------------------------------------------------
# Authenticate to Power BI

    $token = Get-PBIAuthTokenPrompt -clientId $clientid -redirectUrl $redirectUrl

#-------------------------------------------------------
#Return datasets for a specific Workspace (we only know the name)

    $datasets = Get-PBMDataset -authToken $token -workspaceName $workspaceName

    #Take a look at the refresh history
    #TODO Find a dataset that has a refresh history
    Get-PBMDatasetRefreshHistory -authToken $token -workspaceID $datasets[0].workspaceID -DatasetID $datasets[0].id
