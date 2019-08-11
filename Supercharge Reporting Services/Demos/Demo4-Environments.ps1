##############################################################
# Supercharge your Reporting Services - An essential toolkit #
# @cporteous | craigporteous.com | github.com/cporteou       #
##############################################################

#------------------------------------------------------
# Connect to remote Azure VM using session created earlier (if disconnected)
Enter-PSSession -Name ssrsToolkitVM





# Migrate specific folders
#-----------------------------------------------------------------------------------------------------------------------------------------

$SourceUri, $DestUri = 'http://localhost/ReportServer/ReportService2010.asmx?wsdl'
$RsFolder = '/Internal Reporting' 
$tempFolder = (Resolve-Path .\).Path

$SourceProxy = New-RsWebServiceProxy -ReportServerUri $SourceUri
$DestProxy = New-RsWebServiceProxy -ReportServerUri $DestUri

if($Recurse){
    Out-RsFolderContent -Proxy $SourceProxy -RsFolder $RsFolder -Destination $tempFolder -Recurse

    Write-RsFolderContent -Proxy $DestProxy -RsFolder $RsFolder -Path $tempFolder -Recurse -Overwrite
}
else {
    Out-RsFolderContent -Proxy $SourceProxy -RsFolder $RsFolder -Destination $tempFolder

    Write-RsFolderContent -Proxy $DestProxy -RsFolder $RsFolder -Path $tempFolder -Overwrite
}


# Migrate entire environment
#-----------------------------------------------------------------------------------------------------------------------------------------

#Copy the database using DBATools
Copy-DbaDatabase -Source DBSOURCE\Instance -Destination DBTARGET\Instance -Database ReportServer -IncludeSupportDbs -WithReplace -BackupRestore -NetworkShare \\Share\SSRS_Migration

Connect-RsReportServer -ComputerName $ssrsServer -ReportServerInstance 'MSSQLSERVER' -ReportServerUri $reportServer
    
Set-RsDatabase -DatabaseServerName $targetInstance -Name $targetDatabase -IsExistingDatabase -DatabaseCredentialType ServiceAccount -ReportServerVersion $SQLVersion.Value

