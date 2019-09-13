##############################################################
# Supercharge your Reporting Services - An essential toolkit #
# @cporteous | craigporteous.com | github.com/cporteou       #
##############################################################
break

#------------------------------------------------------
# Connect to remote Azure VM using session created earlier (if disconnected)
    Enter-PSSession -Name ssrsToolkitVM


#Connect to SSRS (if not already connected from Demo 1)
    Connect-RsReportServer -ReportServerUri 'http://ssrstoolkit/ReportServer/ReportService2010.asmx?wsdl'


# Migrate specific folders
#-----------------------------------------------------------------------------------------------------------------------------------------


    $sourceUri = 'http://localhost/ReportServer/ReportService2010.asmx?wsdl'
    $destUri = 'http://ssrstoolkit2/ReportServer/ReportService2010.asmx?wsdl'
    $sourceFolder, $destFolder = '/Internal Reporting' 
    $tempFolder = (Resolve-Path .\).Path


    $SourceProxy = New-RsWebServiceProxy -ReportServerUri $sourceUri

    $DestProxy = New-RsWebServiceProxy -ReportServerUri $destUri

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

#Connect to destination server
    Enter-PSSession -Name ssrsToolkitVM2


#Prerequisites
    Install-Module -Name DBATools


#Copy the database using DBATools
    Copy-DbaDatabase -Source ssrstoolkit\MSSQLSERVER -Destination ssrstoolkit2\MSSQLSERVER -Database ReportServer, ReportServerTempDB -Force -WithReplace -BackupRestore -SharedPath '\\ssrstoolkit\backup' -SourceSqlCredential $sqlCredential -DestinationSqlCredential $sqlCredential -Verbose


#Set the SSRS database
    Set-RsDatabase -DatabaseServerName 'ssrstoolkit2' -Name 'ReportServer'-IsExistingDatabase $sqlCredential -ReportServerInstance 'SSRS' -ReportServerVersion SQLServer2017 -AdminDatabaseCredentialType SQL -AdminDatabaseCredential $sqlCredential -DatabaseCredentialType ServiceAccount -Verbose


#Restore and backup the encryption key
    $keyPath = (Resolve-Path .\).Path
    Restore-RSEncryptionKey -Password 'Pa$$w0rd' -KeyPath "$keyPath\SSRSKey.snk" -ReportServerInstance 'SSRS' -ReportServerVersion SQLServer2017

    Restart-Service -Name 'SQLServerReportingServices' -Verbose
    Get-Service -Name 'SQLServerReportingServices'

    Backup-RsEncryptionKey -Password 'Pa$$w0rd' -KeyPath "$keyPath\SSRSKey.snk" -ReportServerInstance 'SSRS' -ReportServerVersion SQLServer2017 -Verbose


#Delete Subscriptions
 


#Revert all Security

    #We've already done this in the Security demo.

#Test it all out


Connect-RsReportServer -ReportServerUri 'http://ssrstoolkit2/ReportServer/ReportService2010.asmx?wsdl'

Get-RsCatalogItemRole -Path '/' -Recurse | Where-Object TypeName -eq 'Folder'
