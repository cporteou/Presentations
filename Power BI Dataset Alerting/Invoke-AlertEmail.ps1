
function Invoke-AlertEmail{
    <#
.SYNOPSIS
This is an email function that builds an HTML email to be used for script outputs and error handling

.DESCRIPTION
Long description

.PARAMETER subject
This is the email subject and is a mandatory parameter.

.PARAMETER title
This is the title of the email that will be included in the top, colour coded panel. It should contain the source script name or purpose

.PARAMETER htmlContent
This is the main body of the email and should be a string, constructed in the calling script to display the required information in the email

.PARAMETER companyLogo
This is a logo that will show above the title section of the email, for organisation branding

.PARAMETER companyLogoAlt
Alternative text for the logo

.PARAMETER team
This is used in the email signature as the source "team or user" for the email

.PARAMETER alertColour
This is a hex colour to colour code the email title section

.PARAMETER mailServer
Mail server to be used for distribution.

.PARAMETER mailFrom
Email address to be displayed as the sender

.PARAMETER mailTo
Recipient(s) for the email

.EXAMPLE
Invoke-AlertEmail -subject "Test subject" -title "Email Title" -htmlContent "Test content</br>More content"

.NOTES
General notes
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)] 
        [string]
        $subject,    

        [Parameter(Mandatory=$true)] 
        [string]
        $title,

        [Parameter(Mandatory=$true)] 
        [String]
        $htmlContent,

        [string]
        $companyLogo = 'https://i0.wp.com/sqlglasgow.co.uk/wp-content/uploads/2017/10/sql-glasgow-logo-full-TEMP_SQL-Glasgow-copy-e1508254573114.png?fit=700%2C140',

        [string]
        $companyLogoAlt = 'CraigPorteous.com BI Team Logo',

        [string]
        $team = 'CraigPorteous.com BI Team',

        [string]
        $alertColour = '#D3D3D3',

        #Flag for Auth required for email server
        [switch]
        $auth,
        #Set Mail settings for error handling
        [string]
        $mailServer = "smtp.office365.com",

        [string]
        $mailFrom = "cporteous@sqlglasgow.co.uk",

        [string]
        $mailTo = "cporteous@sqlglasgow.co.uk"        
    )

    begin{
        Write-Verbose 'Checking supplied Hex colour code'
        if($alertColour -Match '^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$')
        {
            #Perfect match
            Write-Verbose 'Hex colour code Accepted'
        }
        elseif($alertColour -Match '^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$') {
            #Add # Prefix
            $alertColour = "#$($alertColour)"
        }
        else{
            Write-Error 'Invalid HEX Colour code provided'
            $script = $MyInvocation.MyCommand.Name	
            $subject = "$script Error: Invalid Hex Colour used"
            $htmlContent = "HEX used in script: $($alertColour)"
            Invoke-AlertEmail -title $script -htmlContent $htmlContent -subject $subject -alertColour "#FF5733"  
            throw 
        }

        if ($auth) {
            Write-Verbose 'Retrieving Credential component for mail servers that require Auth'
            #----------------------------------------------------------------------
            Write-Verbose 'Get Username from encrypted text file'
            $path = (Resolve-Path .\).Path
            
            #Grab current user so encrypted file is tagged with who encrypted it	
            $user = $env:UserName	
            $file = ($mailFrom + "_cred_by_$($user).txt")
            Write-Verbose 'Testing if credential file exists & create if not'
            if(Test-Path $file)
            {
                $Pass = Get-Content ($path + '\' + $file) | ConvertTo-SecureString
            }
            else{
                Write-Host "Encrypted Credential file not found. Creating new file."
                Read-Host -Prompt "Please enter Password for $mailFrom" -AsSecureString | ConvertFrom-SecureString | Out-File "$($path)\$($mailFrom)_cred_by_$($user).txt"
                Write-Verbose 'Encrypted file created'
                $Pass = Get-Content ($path + '\' + $file) | ConvertTo-SecureString
            }
            $Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $mailFrom, $Pass
            #----------------------------------------------------------------------
        }
    }
    process{

        Write-Verbose 'Build email HTML header'
        $htmlHeader = "<style type=""text/css"">
            .auto-style1 {
                text-align: center;
            }
            .auto-style2 {
                text-align: left;
            }
            .auto-style3 {
                font-family: 'Segoe UI Semilight', 'wf_segoe-ui_light', 'Segoe UI Light', 'Segoe WP Light', 'Segoe UI', 'Segoe WP', Tahoma, Arial, sans-serif;
            }
            .auto-style4 {
                font-family: 'Segoe UI', 'Segoe UI Light', 'Segoe WP Light', 'Segoe WP', Tahoma, Arial, sans-serif;
            }
        </style>"

        Write-Verbose 'Build email HTML Body'
        $htmlBody = "<table width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0"">
            <tbody>
                <tr>
                    <td valign=""top"" width=""50%""></td>
                        <td valign=""top"" style=""padding-top: 20px"">
                            <table width=""600"" cellpadding=""10px 10px"" cellspacing=""0"" style=""border-collapse: collapse"">
                                <tbody>
                                    <!-- Company/Dept Logo -->
                                    <tr><td text-align=""center"" valign=""top""><img src=""$($companyLogo)"" alt=""$($companyLogoAlt)""></br></td></tr>
                                    <!-- Email Title / Source script -->
                                    <tr><td class=""auto-style4"" style=""margin: 5px 5px; padding: 10px 10px; font-size: 23px; background-color: $($alertColour); color: #333333""></br><div>$($title)</div></br></td></tr>
                                    <!-- Content generated by calling script -->
                                    <tr class=""auto-style2 auto-style4"" style=""font-size: 22px;"">
                                        <td>									
                                            </br>$($htmlContent)										
                                        </td>
                                    </tr>
                                    <!-- Email footer -->
                                    <tr class=""auto-style2 auto-style4"" style=""font-size: 16px; color: #333333"">
                                        <td>
                                            </br><div>Thanks,</div>
                                            <div>$($team)</div>								
                                        </td>
                                    </tr>
                                </tbody>							
                            </table>  
                        </td>
                    <td valign=""top"" width=""50%""></td>
                </tr>
            </tbody>
        </table>"
        
        $htmlEmail = ConvertTo-Html -Head $htmlHeader -Body $htmlBody | Out-String

        
        try {            
            if($auth)
            {
                Write-Verbose 'Send Mail using authentication & SSL'
                send-mailmessage -SmtpServer $mailServer -From $mailFrom -To $mailTo -Subject $subject -BodyAsHtml -Body $htmlEmail -Credential $Cred -UseSsl -Port "587"                           
            }
            else 
            {
                Write-Verbose 'Send Mail'
                send-mailmessage -SmtpServer $mailServer -From $mailFrom -To $mailTo -Subject $subject -BodyAsHtml -Body $htmlEmail           
            }            
        }
        catch {
            #Catch an issue
            throw $_
        }
    }
}