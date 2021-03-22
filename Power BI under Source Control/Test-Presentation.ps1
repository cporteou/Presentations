
# Testing presentations requirements & windows settings

Describe "Testing pre-requisites for presentations" {

    Context 'Required PowerShell Modules' {
        It 'Pester module is installed' {
            [bool](Get-Module -Name Pester -ListAvailable) | Should -Be $true
        }

        It 'Pester version is >= 4.3.1' {
            (Get-Module -Name Pester -ListAvailable | Select-Object -First 1).Version -ge [Version]"4.3.1" | Should -Be $true
        }

        It 'Power BI Mgmt Module is installed' {
            [bool](Get-Module -Name MicrosoftPowerBIMgmt -ListAvailable) | Should -Be $true
        }

        It 'AzureAD is installed' {
            [bool](Get-Module -Name AzureAD -ListAvailable) | Should -Be $true
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
        It "Should have only One PowerPoint Open" {
            (Get-Process POWERPNT -ErrorAction SilentlyContinue).Count | Should Be 1
        }
        It "Should have the correct PowerPoint Presentation Open" {
            (Get-Process POWERPNT -ErrorAction SilentlyContinue).MainWindowTitle| Should Be 'Power BI under Source Control.pptx - PowerPoint'
        }
    }
    Context 'Environment Clean' {
        It "Telegram should be closed" {
            (Get-Process Telegram -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Teams should be closed" {
            (Get-Process Teams -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Skype should be closed" {
            (Get-Process Skype* -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Slack should be closed" {
            (Get-Process Slack* -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Default browser set" {
        (Get-ItemProperty HKCU:\Software\Microsoft\windows\Shell\Associations\UrlAssociations\http\UserChoice).Progid | Should BeLike 'Chrome*'
        }
    }

}