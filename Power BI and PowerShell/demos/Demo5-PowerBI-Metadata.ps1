

Install-Module PowerBI-Metadata

#TODO Authenticate to Power BI - stuff to talk about
$auth = Get-PBIAuthTokenPrompt -clientId "0bb5a25b-9f95-4091-8c48-de56248c9d24" -redirectUrl "https://incrementalgroup.co.uk"

#Return datasets for a specific Workspace (we only know the name)
Get-PBMDataset -authToken $auth -workspaceName 'SSSC Data Migration' | Get-PBMDatasetRefreshHistory -authToken $auth -workspaceID $_.workspaceID -DatasetID $_.datasetId

Get-PBMDatasetRefreshHistory -authToken $auth -workspaceID 1530055f-XXXX-XXXX-XXXX-ee8c87e4a648  -DatasetID ffac73aa-XXXX-XXXX-XXXX-643f36b11a68