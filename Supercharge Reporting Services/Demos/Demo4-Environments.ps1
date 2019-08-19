##############################################################
# Supercharge your Reporting Services - An essential toolkit #
# @cporteous | craigporteous.com | github.com/cporteou       #
##############################################################
break
#------------------------------------------------------
# Connect to remote Azure VM using session created earlier (if disconnected)
Enter-PSSession -Name ssrsToolkitVM


# Migrate specific folders
#-----------------------------------------------------------------------------------------------------------------------------------------


$sourceUri, $destUri = 'http://localhost/ReportServer/ReportService2010.asmx?wsdl'
$sourceFolder = '/Internal Reporting' 
$destFolder = '/Copy of Internal Reporting' 
$tempFolder = (Resolve-Path .\).Path


$SourceProxy, $DestProxy = New-RsWebServiceProxy -ReportServerUri $sourceUri


if($Recurse){
    Out-RsFolderContent -Proxy $SourceProxy -RsFolder $sourceFolder -Destination $tempFolder -Recurse

    Write-RsFolderContent -Proxy $DestProxy -RsFolder $destFolder -Path $tempFolder -Recurse -Overwrite
}
else {
    Out-RsFolderContent -Proxy $SourceProxy -RsFolder $sourceFolder -Destination $tempFolder

    Write-RsFolderContent -Proxy $DestProxy -RsFolder $destFolder -Path $tempFolder -Overwrite
}


# Migrate entire environment
#-----------------------------------------------------------------------------------------------------------------------------------------

#Prerequisites
Install-Module -Name DBATools

#TODO
#Copy the database using DBATools
Copy-DbaDatabase -Source ssrstoolkit\MSSQLSERVER -Destination ssrstoolkit\MSSQLSERVER -Database ReportServer -NewName ReportServer2 -IncludeSupportDbs -WithReplace -BackupRestore -UseLastBackup

#TODO
Connect-RsReportServer -ReportServerInstance 'Instance2' -ReportServerUri $destUri
  
#TODO
Set-RsDatabase -DatabaseServerName $targetInstance -Name $targetDatabase -IsExistingDatabase -DatabaseCredentialType ServiceAccount -ReportServerVersion $SQLVersion.Value

