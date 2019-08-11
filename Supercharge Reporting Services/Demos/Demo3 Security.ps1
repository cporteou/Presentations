##############################################################
# Supercharge your Reporting Services - An essential toolkit #
# @cporteous | craigporteous.com | github.com/cporteou       #
##############################################################

#------------------------------------------------------
# Connect to remote Azure VM
Enter-PSSession -Name ssrsToolkitVM

#------------------------------------------------------
# Prerequisites
# Install-Module -Name ReportingServicesTools
#------------------------------------------------------

#What commands are available
Get-Command -module ReportingServicesTools

# Auditing Permissions
#-----------------------------------------------------------------------------------------------------------------------------------------

#Declare SSRS URL
$reportServerUri = 'http://localhost/ReportServer/ReportService2010.asmx?wsdl'
#Declare final Security Array
$rsSecurity = @()
#Declare Proxy so we dont need to connect with every command
$rsProxy = New-RsWebServiceProxy -ReportServerUri $reportServerUri
#List all folders in SSRS
$folders = Get-RsFolderContent -Proxy $rsProxy -RsFolder '/' -Recurse | Where-Object TypeName -eq 'Folder'

#Loop through each folder and add its security to the Security Array
foreach($folder in $folders.Path)
{
	# Returns the security on a folder
	$security = Get-RsCatalogItemRole -Proxy $rsProxy -Path $folder
	#Add to Security Array
	$rsSecurity += $security | Select-Object Identity, Path, @{n="Roles";e={$_.Roles.name}}
}
$rsSecurity | Export-csv -Path .\SSRS_Folder_Security.csv -NoTypeInformation


# Updating Permissions - Adding a user/Group to all folders 
#-----------------------------------------------------------------------------------------------------------------------------------------

$reportServerUri #Set earlier
$rsProxy #Set earlier
$InheritParent = $true

$groupUserName = 'ssrsToolkit\JamesH'
$roleName = 'Browser' #Defaults are: Browser, Content Manager, My Reports, Publisher, Report Builder
$folder = '/Internal Reporting' #Use '/' for the Root folder

$type = $rsProxy.GetType().Namespace;
$policyType = "{0}.Policy" -f $type;
$roleType = "{0}.Role" -f $type;
#List out all subfolders under the parent directory
$items = $rsProxy.ListChildren($folder, $true) | Select-Object TypeName, Path, ID, Name | Where-Object TypeName -eq 'Folder'
#Iterate through every folder 
foreach($item in $items){
	$Policies = $rsProxy.GetPolicies($Item.Path, [ref]$InheritParent)
	#Skip over folders marked to Inherit permissions. No changes needed.
	if($InheritParent -eq $false){
		#Return all policies that contain the user/group we want to add
		$Policy = $Policies | 
		    Where-Object { $_.GroupUserName -eq $GroupUserName } | 
		    Select-Object -First 1
		#Add a new policy if doesnt exist
		if (-not $Policy){
		    $Policy = New-Object ($policyType)
		    $Policy.GroupUserName = $GroupUserName
		    $Policy.Roles = @()
			#Add new policy to the folder's policies
		    $Policies += $Policy
		}
		#Add the role to the new Policy
		$r = $Policy.Roles |
	        Where-Object { $_.Name -eq $RoleName } |
	        Select-Object -First 1
	    if (-not $r){
	        $r = New-Object ($roleType)
	        $r.Name = $RoleName
	        $Policy.Roles += $r
    	}
		#Set folder policies
		$rsProxy.SetPolicies($Item.Path, $Policies);
	}
}

# Removing a user from all folders
#-----------------------------------------------------------------------------------------------------------------------------------------

$reportServerUri #Set earlier
$rsProxy #Set earlier
$InheritParent #Set earlier
$folder = '/'
$groupUserName = 'ssrsToolkit\AndersonD'

$rsProxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential
#List out all subfolders under the parent directory
$items = $rsProxy.ListChildren($folder, $true) | Select-Object TypeName, Path, ID, Name | Where-Object TypeName -eq 'Folder'
#Iterate through every folder 		 
foreach($item in $items){
	$Policies = $rsProxy.GetPolicies($Item.Path, [ref]$InheritParent)
	#Skip over folders marked to Inherit permissions. No changes needed.
	if($InheritParent -eq $false){
		#List out ALL policies on folder but do not include the policy for the specified user/group
		$Policies = $Policies | Where-Object { $_.GroupUserName -ne $GroupUserName }
		#Set the folder's policies to this new set of policies
		$rsProxy.SetPolicies($Item.Path, $Policies);
	}
}

# Revert to Inherit Permissions
#-----------------------------------------------------------------------------------------------------------------------------------------

$reportServerUri #Set earlier
$rsProxy #Set earlier
$InheritParent #Set earlier

#List out all subfolders under the parent directory
$items = $rsProxy.ListChildren($folder, $true) | Select-Object TypeName, Path, ID, Name | Where-Object TypeName -eq 'Folder'
#Iterate through every folder 		 
foreach($item in $items){
	#TODO $Policies = $rsProxy.GetPolicies($Item.Path, [ref]$InheritParent)
	#Skip over folders already marked to Inherit permissions. No changes needed.
	if(-not $InheritParent){
		Write-Host $item.Path
		#Set folder to inherit from Parent security
		$rsProxy.InheritParentSecurity($item.Path)
	}
}
