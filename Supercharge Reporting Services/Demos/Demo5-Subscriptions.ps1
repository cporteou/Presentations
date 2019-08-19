##############################################################
# Supercharge your Reporting Services - An essential toolkit #
# @cporteous | craigporteous.com | github.com/cporteou       #
##############################################################
break
#------------------------------------------------------
# Connect to remote Azure VM using session created earlier (if disconnected)
Enter-PSSession -Name ssrsToolkitVM


# Update Subscription Owner
#-----------------------------------------------------------------------------------------------------------------------------------------

$newOwner = 'ssrsToolkit\JamesH'  


#Get All subscriptions and update owner
Get-RSSubscription -RsItem '/' | Set-RsSubscription -Owner $newOwner -Verbose


Get-RSSubscription -RsItem '/' | Select-Object SubscriptionID, Owner


# TITLE
#-----------------------------------------------------------------------------------------------------------------------------------------


