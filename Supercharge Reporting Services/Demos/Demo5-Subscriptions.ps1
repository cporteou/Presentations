##############################################################
# Supercharge your Reporting Services - An essential toolkit #
# @cporteous | craigporteous.com | github.com/cporteou       #
##############################################################

#------------------------------------------------------
# Connect to remote Azure VM using session created earlier (if disconnected)
Enter-PSSession -Name ssrsToolkitVM


# Update Subscription Owner
#-----------------------------------------------------------------------------------------------------------------------------------------

$currentOwner = 'ssrsToolkit\ssrsAdmin'  
$newOwner = 'ssrsToolkit\JamesH'  
#Declare SSRS URL
$reportServerUri = 'http://localhost/ReportServer/ReportService2010.asmx?wsdl'
  
#Declare Proxy so we dont need to connect with every command
$rsProxy = New-RsWebServiceProxy -ReportServerUri $reportServerUri
#List out all reports under the parent directory
$items = $rsProxy.ListChildren($folder, $true) | Select-Object TypeName, Path, ID, Name | Where-Object TypeName -eq 'Report', Owner -eq $currentOwner  

$subscriptions = @()  

ForEach ($item in $items){   
    $curRepSubs = $rs2010.ListSubscriptions($item.Path);  
    ForEach ($curRepSub in $curRepSubs){  
        if ($curRepSub.Owner -eq $currentOwner){  
            $subscriptions += $curRepSub;  
        }  
    }      
}  

ForEach ($sub in $subscriptions){  
    $rsProxy.ChangeSubscriptionOwner($sub.SubscriptionID, $newOwner);  
}  

# TITLE
#-----------------------------------------------------------------------------------------------------------------------------------------


