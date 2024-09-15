<#
.SYNOPSIS
    示例插件
.DESCRIPTION
    这是一个示例插件，展示如何使用插件系统扩展功能。
.NOTES
    版本：1.0
    作者：Your Name
    最后更新：2023-05-17
#>

function Show-ExamplePluginMenu {
    do {
        $choice = Show-Menu -Title "示例插件菜单" -Options @(
            "返回上级菜单",
            "显示当前日期和时间",
            "显示系统信息"
        )
        
        switch ($choice) {
            0 { return }
            1 { Show-CurrentDateTime }
            2 { Show-SystemInfo }
        }
        
        if ($choice -ne 0) { Read-Host "按 Enter 键继续" }
    } while ($true)
}

function Show-CurrentDateTime {
    $currentDateTime = Get-Date
    Write-StatusMessage "当前日期和时间：$currentDateTime" -Type Info
}

function Show-SystemInfo {
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $processorInfo = Get-CimInstance Win32_Processor
    $memoryInfo = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum

    Write-StatusMessage "系统信息：" -Type Info
    Write-Host "操作系统：$($osInfo.Caption) $($osInfo.Version)"
    Write-Host "处理器：$($processorInfo.Name)"
    Write-Host "内存：$([math]::Round($memoryInfo.Sum / 1GB, 2)) GB"
}

Export-ModuleMember -Function Show-ExamplePluginMenu