<#
.SYNOPSIS
    系统监控插件
.DESCRIPTION
    这个插件提供了一些基本的系统监控功能。
.NOTES
    版本：1.0
    作者：Your Name
    最后更新：2023-05-18
#>

function Show-SystemMonitorMenu {
    do {
        $choice = Show-Menu -Title "系统监控菜单" -Options @(
            "返回上级菜单",
            "显示CPU使用率",
            "显示内存使用情况",
            "显示磁盘使用情况",
            "显示网络使用情况"
        )
        
        switch ($choice) {
            0 { return }
            1 { Show-CPUUsage }
            2 { Show-MemoryUsage }
            3 { Show-DiskUsage }
            4 { Show-NetworkUsage }
        }
        
        if ($choice -ne 0) { Read-Host "按 Enter 键继续" }
    } while ($true)
}

function Show-CPUUsage {
    $cpu = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object Average
    Write-StatusMessage "CPU 使用率：$($cpu.Average)%" -Type Info
}

function Show-MemoryUsage {
    $memory = Get-WmiObject Win32_OperatingSystem
    $usedMemory = $memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory
    $usedMemoryGB = [math]::Round($usedMemory / 1MB, 2)
    $totalMemoryGB = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
    $memoryUsagePercent = [math]::Round(($usedMemory / $memory.TotalVisibleMemorySize) * 100, 2)
    Write-StatusMessage "内存使用情况：$usedMemoryGB GB / $totalMemoryGB GB ($memoryUsagePercent%)" -Type Info
}

function Show-DiskUsage {
    $disks = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }
    foreach ($disk in $disks) {
        $usedSpace = $disk.Size - $disk.FreeSpace
        $usedSpaceGB = [math]::Round($usedSpace / 1GB, 2)
        $totalSpaceGB = [math]::Round($disk.Size / 1GB, 2)
        $usagePercent = [math]::Round(($usedSpace / $disk.Size) * 100, 2)
        Write-StatusMessage "磁盘 $($disk.DeviceID) 使用情况：$usedSpaceGB GB / $totalSpaceGB GB ($usagePercent%)" -Type Info
    }
}

function Show-NetworkUsage {
    $network = Get-WmiObject Win32_PerfFormattedData_Tcpip_NetworkInterface | Select-Object Name, BytesTotalPersec, BytesReceivedPersec, BytesSentPersec
    foreach ($adapter in $network) {
        Write-StatusMessage "网络适配器：$($adapter.Name)" -Type Info
        Write-Host "  总流量：$([math]::Round($adapter.BytesTotalPersec / 1MB, 2)) MB/s"
        Write-Host "  接收：$([math]::Round($adapter.BytesReceivedPersec / 1MB, 2)) MB/s"
        Write-Host "  发送：$([math]::Round($adapter.BytesSentPersec / 1MB, 2)) MB/s"
    }
}

Export-ModuleMember -Function Show-SystemMonitorMenu