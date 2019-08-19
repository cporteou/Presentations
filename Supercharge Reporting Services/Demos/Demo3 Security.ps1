##############################################################
# Supercharge your Reporting Services - An essential toolkit #
# @cporteous | craigporteous.com | github.com/cporteou       #
##############################################################
break
#------------------------------------------------------
# Connect to remote Azure VM using session created earlier (if disconnected)
Enter-PSSession -Name ssrsToolkitVM


# Auditing Permissions
#-----------------------------------------------------------------------------------------------------------------------------------------

#Declare the folder variable
$directory = '/' #Use '/' for the Root folder
$rsSecurity = @()

# Returns the security on the chosen parent directory and sub-folders
$security = Get-RsCatalogItemRole -Path $directory -Recurse | Where-Object TypeName -eq 'Folder'


#Add to Security Array
$rsSecurity = $security | Select-Object Identity, Path, @{n="Roles";e={$_.Roles.name}}


$rsSecurity 
$rsSecurity | Export-csv -Path .\SSRS_Folder_Security.csv -NoTypeInformation


# Updating Permissions - Adding a user/Group to all folders 
#-----------------------------------------------------------------------------------------------------------------------------------------

#Username or Group we want to add
$groupUserName = 'ssrsToolkit\JamesH' 
$roleName = 'Content Manager' #Defaults are: Browser, Content Manager, My Reports, Publisher, Report Builder
$directory = '/Internal Reporting' #Use '/' for the Root folder


#Grant chosen permissions on this folder
Grant-RsCatalogItemRole -Identity $groupUserName -RoleName $roleName -Path $directory -Verbose # No Recurse flag


#List out all subfolders under the chosen parent directory
$folders = Get-RsFolderContent -RsFolder $directory -Recurse | Where-Object TypeName -eq 'Folder'
$folders


#Iterate through every folder 
foreach($folder in $folders){

	#Grant chosen permissions on this folder
	Grant-RsCatalogItemRole -Identity $groupUserName -RoleName $roleName -Path $directory -Verbose 

	#* This will respect inheritence if the user is already in the policy for the folder. See verbose output
}


# Removing a user from all folders
#-----------------------------------------------------------------------------------------------------------------------------------------

#Username or Group we want to remove
$groupUserName = 'ssrsToolkit\AndersonD'
$directory = '/Sales Reporting' #Use '/' for the Root folder


#Remove access from a specific folder
Revoke-AccessOnCatalogItem -Identity $groupUserName -Path $directory -Verbose


# Remove access globally on this environment. Alias: Revoke-AccessToRs
Revoke-RsSystemAccess -Identity $groupUserName -Verbose


# Revert to Inherit Permissions 
# It's not currently possible to reference inheritence flags within the ReportingServicesTools module so we need to connect the old-fashioned way 
#-----------------------------------------------------------------------------------------------------------------------------------------


#Declare SSRS URL
$reportServerUri = 'http://localhost/ReportServer/ReportService2010.asmx?wsdl'


#Declare Proxy so we dont need to connect with every command
$rsProxy = New-RsWebServiceProxy -ReportServerUri $reportServerUri
$InheritParent = $true


#List out all subfolders under the parent directory
$items = $rsProxy.ListChildren($folder, $true) | Select-Object TypeName, Path, ID, Name | Where-Object TypeName -eq 'Folder'


#Iterate through every folder 		 
foreach($item in $items){
	#TODO $Policies = $rsProxy.GetPolicies($Item.Path, [ref]$InheritParent)
	#Skip over folders already marked to Inherit permissions. No changes needed.
	if(-not $InheritParent){

		#Set folder to inherit from Parent security
		$rsProxy.InheritParentSecurity($item.Path)
	}
}

#-----------------------------------------------------------------------------------------------------------------------------------------