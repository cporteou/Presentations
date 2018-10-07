#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 1: Licensing Data
#-------------------------------------------------------
break

#Install-Module AzureAD

#Connect to Azure with a Prompt
Connect-AzureAD

#-------------------------------------------------------------------------------

#Collect license info
$PBILicenses = Get-AzureADSubscribedSku | Where-Object{$_.SkuPartNumber -like '*POWER_BI*' -and $_.CapabilityStatus -eq 'Enabled'} | Select-Object SkuPartNumber, ConsumedUnits, SkuId

#Return global license count
$PBILicenses | Select-Object SkuPartNumber, ConsumedUnits, SkuId

#-------------------------------------------------------------------------------

$PBIUsers = @()
#Loop through each license and list all users
foreach($license in $PBILicenses)
{
    $PBIUsers += Get-AzureADUser -All 1 | Where-Object{($_.AssignedLicenses | Where-Object{$_.SkuId -eq $license.SkuId})} | Select-Object DisplayName, UserPrincipalName, @{l='License';e={$license.SkuPartNumber}}
}

#Check out the contents
$PBIUsers

#Output to a file
$PBIUsers | Out-File -FilePath .\PowerBI-Licenses.txt

#-------------------------------------------------------------------------------
# Output file location
Invoke-Item .\