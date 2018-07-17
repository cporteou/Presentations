
# Testing presentations requirements & windows settings

Describe "Testing pre-requisites for presentations" {

    Context 'Required PowerShell Modules' {
        It 'Pester module is installed' {
            [bool](Get-Module -Name Pester -ListAvailable) | Should -Be $true
        }

        It 'Pester version is >= 4.3.1' {
            (Get-Module -Name Pester -ListAvailable | Select-Object -First 1).Version -ge [Version]"4.3.1" | Should -Be $true
        }

        It 'Power BI Metadata is installed' {
            [bool](Get-Module -Name PowerBI-Metadata -ListAvailable) | Should -Be $true
        }

        It 'Microsoft.ADAL.PowerShell is installed' {
            [bool](Get-Module -Name Microsoft.ADAL.PowerShell -ListAvailable) | Should -Be $true
        }

        It 'CredentialManager is installed' {
            [bool](Get-Module -Name CredentialManager -ListAvailable) | Should -Be $true
        }

        It 'AzureAD is installed' {
            [bool](Get-Module -Name AzureAD -ListAvailable) | Should -Be $true
        }
    }
    Context 'Variables are set for demo' {
        It "Unattended Auth variables set" {
            $client_Id | Should Not BeNullorEmpty
            $client_Secret | Should Not BeNullorEmpty
            $email | Should Not BeNullorEmpty
        }
        It "Prompted Auth variables set" {
            $clientId | Should Not BeNullorEmpty
            $redirectUrl | Should Not BeNullorEmpty
        }
        It "Demo Credential is clear (Power BI Auth Demo)" {
            (Get-StoredCredential -Target 'Power BI Auth Demo') | Should BeNullorEmpty
        }
        It "Automation Credential exists (Power BI Licenses)" {
            (Get-StoredCredential -Target 'Power BI Licenses' | Select-Object $_.UserName ) | Should Not BeNullOrEmpty
        }
    }
    Context 'VS Code Configuration' {
        It "Should have VS Code running" {
            (Get-Process 'Code' -ErrorAction SilentlyContinue).Count | Should Not BeNullorEmpty
        }
        # TODO Check VS Code theme is set to something bright for ease of viewing
    }
    Context 'PowerPoint Presentation' {
        It "Should have PowerPoint Open" {
            (Get-Process POWERPNT -ErrorAction SilentlyContinue) | Should Not BeNullorEmpty
        }
        It "Should have One PowerPoint Open" {
            (Get-Process POWERPNT -ErrorAction SilentlyContinue).Count | Should Be 1
        }
        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'Power BI and PowerShell.pptx - PowerPoint'
        }
    }
    Context 'Messenger apps' {
        It "Telegram should be closed" {
            (Get-Process Telegram -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Skype should be closed" {
            (Get-Process Skype* -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Slack should be closed" {
            (Get-Process Slack* -ErrorAction SilentlyContinue).Count | Should Be 0
        }
    }
}