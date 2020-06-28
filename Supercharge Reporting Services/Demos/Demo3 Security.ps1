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


# Auditing Permissions
#-----------------------------------------------------------------------------------------------------------------------------------------

#Declare the folder variable
	$directory = '/' #Use '/' for the Root folder

# Returns the security on the chosen parent directory and sub-folders
	$security = Get-RsCatalogItemRole -Path $directory -Recurse | Where-Object TypeName -eq 'Folder' | Select-Object Identity, Path, @{n="Roles";e={$_.Roles.name}}

	$security 
	$security | Export-csv -Path .\SSRS_Folder_Security.csv -NoTypeInformation


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
		Grant-RsCatalogItemRole -Identity $groupUserName -RoleName $roleName -Path $folder.Path -Verbose 

		#! This will respect inheritence if the user is already in the policy for the folder. See verbose output
	}


#Prove it!
	Get-RsCatalogItemRole -Path $directory -Recurse | Where-Object TypeName -eq 'Folder' | Select-Object Identity, Path, @{n="Roles";e={$_.Roles.name}}


# Removing a user from a folders. This will break inheritence from the parent
#-----------------------------------------------------------------------------------------------------------------------------------------

#Username or Group we want to remove
	$groupUserName = 'BUILTIN\Administrators'
	$directory = '/Sales Reporting' #Use '/' for the Root folder


#Remove access from a specific folder (and those inheriting)
	Revoke-AccessOnCatalogItem -Identity $groupUserName -Path $directory -Verbose


#Prove it!
	Get-RsCatalogItemRole -Path $directory -Recurse | Where-Object TypeName -eq 'Folder' | Select-Object Identity, Path, @{n="Roles";e={$_.Roles.name}}


# Revert to Inherit Permissions 
# It's not currently possible to reference inheritence flags within the ReportingServicesTools module so we need to connect the old-fashioned way 
#-----------------------------------------------------------------------------------------------------------------------------------------


#Declare SSRS URL
	$reportServerUri = 'http://localhost/ReportServer/ReportService2010.asmx?wsdl'


#Declare Proxy so we dont need to connect with every command
	$rsProxy = New-RsWebServiceProxy -ReportServerUri $reportServerUri
	$InheritParent = $true


#List out all subfolders under the parent directory
	$items = $rsProxy.ListChildren('/', $true) | Select-Object TypeName, Path, ID, Name | Where-Object TypeName -eq 'Folder'


#Iterate through every folder 		 
	foreach($item in $items){
		$rsProxy.GetPolicies($Item.Path, [ref]$InheritParent)
		#Skip over folders already marked to Inherit permissions. No changes needed.
		if(-not $InheritParent){
			
			#Set folder to inherit from Parent security
			$rsProxy.InheritParentSecurity($item.Path)
		}
	}


#Prove it!
	Get-RsCatalogItemRole -Path '/' -Recurse | Where-Object TypeName -eq 'Folder' | Select-Object Identity, Path, @{n="Roles";e={$_.Roles.name}}

#-----------------------------------------------------------------------------------------------------------------------------------------