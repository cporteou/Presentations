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


# Update Subscription Owner
#-----------------------------------------------------------------------------------------------------------------------------------------

    $newOwner = 'ssrsToolkit\AmosB'  


#Get All subscriptions and update owner
    Get-RSSubscription -RsItem '/' | Set-RsSubscription -Owner $newOwner -Verbose

    Get-RSSubscription -RsItem '/' | Select-Object SubscriptionID, Owner

