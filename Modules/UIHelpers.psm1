<#
.SYNOPSIS
    UI 辅助函数模块
.DESCRIPTION
    本模块提供了一系列用于创建一致用户界面的函数。
.NOTES
    版本：1.0
    作者：Your Name
    最后更新：2023-05-12
#>

$script:Colors = @{
    Title = 'Cyan'
    Menu = 'Yellow'
    Success = 'Green'
    Error = 'Red'
    Warning = 'DarkYellow'
    Info = 'White'
}

function Show-Menu {
    param (
        [string]$Title,
        [string[]]$Options
    )
    
    Clear-Host
    Write-Host $Title -ForegroundColor $script:Config.Colors.Title
    Write-Host ("=" * $Title.Length) -ForegroundColor $script:Config.Colors.Title
    
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host ("[{0}] {1}" -f $i, $Options[$i]) -ForegroundColor $script:Config.Colors.Menu
    }
    
    do {
        $choice = Read-Host "请输入您的选择"
    } while ($choice -notin 0..($Options.Count - 1))
    
    return [int]$choice
}

function Write-StatusMessage {
    param (
        [string]$Message,
        [ValidateSet('Success', 'Error', 'Warning', 'Info')]
        [string]$Type = 'Info'
    )
    
    Write-Host $Message -ForegroundColor $script:Config.Colors[$Type]
}

function Show-ProgressBar {
    param (
        [int]$PercentComplete,
        [string]$Status
    )
    
    Write-Progress -Activity $Status -PercentComplete $PercentComplete
}

Export-ModuleMember -Function Show-Menu, Write-StatusMessage, Show-ProgressBar