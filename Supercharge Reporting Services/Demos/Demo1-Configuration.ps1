##############################################################
# Supercharge your Reporting Services - An essential toolkit #
# @cporteous | craigporteous.com | github.com/cporteou       #
##############################################################
break
#------------------------------------------------------
# Connect to remote Azure VM using session created earlier (if disconnected)
Enter-PSSession -Name ssrsToolkitVM


# Prerequisites
#------------------------------------------------------

Install-Module -Name ReportingServicesTools


#What commands are available
#------------------------------------------------------

Get-Command -module ReportingServicesTools


#Backup RS Encryption Key
#------------------------------------------------------

$keyPath = (Resolve-Path .\).Path


#Opens connection for all subsequent commands using the ReportingServicesTools module
Connect-RsReportServer -ReportServerUri 'http://ssrstoolkit/ReportServer/ReportService2010.asmx?wsdl'


Backup-RsEncryptionKey -Password 'Pa$$w0rd' -KeyPath "$keyPath\SSRSKey.snk" -ReportServerInstance 'SSRS' -ReportServerVersion SQLServer2017 -Verbose

