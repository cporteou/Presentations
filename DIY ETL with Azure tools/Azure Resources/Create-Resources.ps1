
#! TODO Add splatting

#----------------------------------------------------------------------------
# Variables
#----------------------------------------------------------------------------

# The SubscriptionId in which to create these objects
$SubscriptionId = ''
# Set the resource group name and location for the server
$resourceGroupName = 'cpo-diyetl'
$region = 'UK South'
# Key vault
$kvName = 'kv-cpo-diyetl'
# ADF Name
$adfName = 'adf-cpo-diyetl'
#Blob storage
$blobName = 'cpodiyetl'
#ADLS 
$adlsName = 'adlscpodiyetl'
# Set server name - the logical server name has to be unique in the system
$serverName = 'sql-cpo-diyetl'
# Set the database name
$databaseName = 'db-cpo-diyetl'
# The ip address range that you want to allow to access your server. 
$startIp = $endIp = "82.32.38.68"

#----------------------------------------------------------------------------

Connect-AzAccount

Set-AzContext -SubscriptionId $SubscriptionId

#----------------------------------------------------------------------------
# Create a resource group
#----------------------------------------------------------------------------

New-AzResourceGroup -Name $resourceGroupName -Location $region -Tags @{"Project"="DIY ETL Presentation";"Created"="Feb 2020"}

#----------------------------------------------------------------------------
# Create Key vault for storing creds
#----------------------------------------------------------------------------

New-AzKeyVault -Name $kvName -ResourceGroupName $resourceGroupName -Location $region -Tag @{"Project"="DIY ETL Presentation";"Created"="Feb 2020"}

Set-AzKeyVaultAccessPolicy -VaultName $kvName -ResourceGroupName $resourceGroupName -UserPrincipalName 'craig@craigporteous.com' -PermissionsToKeys get, create, list  -PermissionsToSecrets get, list, set

Set-AzKeyVaultSecret -VaultName $kvName -Name 'sqladmin' # -SecretValue prompted

#----------------------------------------------------------------------------
# Create Resources - Resource Group / SQL Server / Firewall Rules / SQL Server DB
#----------------------------------------------------------------------------
# Create a server with a system wide unique server name
#----------------------------------------------------------------------------

New-AzSqlServer -ResourceGroupName $resourceGroupName `
    -ServerName $serverName `
    -Location $region `
    -Tags @{"Project"="DIY ETL Presentation";"Created"="Feb 2020"}

#----------------------------------------------------------------------------
# Create a server firewall rule that allows access from the specified IP range
# NOTE- If individual IP's are required rather than a range then individual firewall rules need to be created 
#----------------------------------------------------------------------------

New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName -ServerName $serverName -FirewallRuleName "Craig home" -StartIpAddress $startIp -EndIpAddress $endIp

#----------------------------------------------------------------------------
# Create a blank database with an S0 performance level
#----------------------------------------------------------------------------

New-AzSqlDatabase  -ResourceGroupName $resourceGroupName -ServerName $serverName `
    -DatabaseName $databaseName `
    -RequestedServiceObjectiveName "S0" `
    -Tags @{"Project"="DIY ETL Presentation";"Created"="Feb 2020"}

#----------------------------------------------------------------------------
# Create Data Factory with Git integration using existing resource group
#----------------------------------------------------------------------------

New-AzDataFactoryV2 -ResourceGroupName $resourceGroupName -Name $adfName -Location $region `
    -HostName 'https://github.com' -AccountName 'cporteou' -RepositoryName 'Presentations' -CollaborationBranch 'master' -RootFolder '/DIY ETL with Azure tools' -Tag @{"Project"="DIY ETL Presentation";"Created"="Feb 2020"}

#----------------------------------------------------------------------------
# Create blob storage
#----------------------------------------------------------------------------

New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $blobName -Location $region -SkuName Standard_LRS -Kind BlobStorage -AccessTier Hot -Tag @{"Project"="DIY ETL Presentation";"Created"="Feb 2020"}

#----------------------------------------------------------------------------
# Create data lake storage
#----------------------------------------------------------------------------

New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $adlsName -Location $region -SkuName Standard_LRS -Kind StorageV2 -EnableHierarchicalNamespace $True -Tags @{"Project"="DIY ETL Presentation";"Created"="Feb 2020"}

#----------------------------------------------------------------------------
# Create a logic app
#----------------------------------------------------------------------------

New-AzLogicApp -ResourceGroupName $resourceGroupName -Name $appName -Location $region 

#! TODO: add defintion file and reference in logic app command above.

#----------------------------------------------------------------------------
# Create a Function app
#----------------------------------------------------------------------------

New-AzFunctionApp

#----------------------------------------------------------------------------
# Create a Azure Automation account
#----------------------------------------------------------------------------

New-AzAutomationAccount