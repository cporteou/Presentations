#-------------------------------------------------------
# Author: Craig Porteous
# Presentation: Power BI and PowerShell: A match made in Heaven
# Demo 2: Unattended Authentication
#-------------------------------------------------------
break

# Install-Module Microsoft.ADAL.PowerShell
# Install-Module -Name 'CredentialManager'

# Client ID can be obtained from creating a Power BI app:
# https://dev.powerbi.com/apps
# App Type: Server-side Web app
#-------------------------------------------------------

$client_Id
$client_Secret

$email

#Tenant ID function. Check Azure for Tenant ID
$tenantID = Get-AzureTenantID -Email $email

#-------------------------------------------------------


$authority = "https://login.windows.net/$tenantID/oauth2/token"
$resourceAppID = "https://analysis.windows.net/powerbi/api"


#-------------------------------------------------------
#* OPTION 1 - Use Credential Manager module - Thanks Josh King (@WindosNZ)

	$Splat = @{
		Target   = 'Power BI Auth Demo'
		Password = Read-Host -Prompt "Please enter Password for $email"
		Comment  = 'This helps remind my why I created this'
		Persist  = 'LocalMachine'
	}
	New-StoredCredential @Splat

	$cred = Get-StoredCredential -Target 'Power BI Licenses'
	$pass = $cred.Password

#-------------------------------------------------------
#* OPTION 2 - Use an encrypted text file

	$path = (Resolve-Path .\).Path
	$user = $env:UserName
	$file = ($email + "_cred_by_$($user).txt")

	# Encrypted Credential file not found. Creating new file
	Read-Host -Prompt "Please enter Password for $email" -AsSecureString | ConvertFrom-SecureString | Out-File "$($path)\$($email)_cred_by_$($user).txt"

	# Retrieve file
	$pass = Get-Content ($path + '\' + $file) | ConvertTo-SecureString

#-------------------------------------------------------

#Pull password from secure string - This only works for the user who encrypted the password in the first place
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass)
$textPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)


Write-Verbose 'Authenticating to Azure/PBI'
$authBody = @{
        'resource'=$resourceAppID
        'client_id'=$client_Id
        'grant_type'="password"
        'username'=$email
        'password'= $textPass #! THIS IS IN PLAIN TEXT!
        'scope'="openid"
        'client_secret'=$client_Secret
}

#! Clear password variable immediately after use
$textPass = $null

#-------------------------------------------------------

#Authentiate to Power BI
$auth = Invoke-RestMethod -Uri $authority -Body $authBody -Method POST -Verbose

#! Clear auth array immediately after use
$authBody = $null

$token = $auth.access_token

$token
