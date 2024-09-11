using module ..\Modules\CoreFunctions.psm1

Describe "CoreFunctions" {
    Context "Write-Log" {
        It "Should not throw an error" {
            { Write-Log "Test message" } | Should -Not -Throw
        }
    }

    Context "Edit-Profile" {
        It "Should not throw an error when profile exists" {
            Mock Test-Path { return $true }
            Mock Start-Process { return $null }
            { Edit-Profile } | Should -Not -Throw
        }
    }

    Context "Show-Profile" {
        It "Should not throw an error" {
            Mock Get-Content { return @("function Test-Function {}", "# Comment", "Write-Host 'Hello'") }
            { Show-Profile } | Should -Not -Throw
        }
    }

    # Add more tests for other functions...
}