<#
.SYNOPSIS
    网络诊断工具模块
.DESCRIPTION
    本模块提供了一系列网络诊断和管理工具，包括Ping测试、路由跟踪、查看IP配置等功能。
.NOTES
    版本：1.0
    作者：Your Name
    最后更新：2023-05-10
#>

using module .\UIHelpers.psm1

function Show-NetworkTools {
    do {
        $choice = Show-Menu -Title "网络诊断工具" -Options @(
            "返回上级菜单",
            "Ping 测试",
            "路由跟踪",
            "查看 IP 配置"
        )
        
        switch ($choice) {
            0 { return }
            1 { Test-NetworkConnection }
            2 { Get-TraceRoute }
            3 { Get-IPConfiguration }
        }
        
        if ($choice -ne 0) { Read-Host "按 Enter 键继续" }
    } while ($true)
}

function Test-NetworkConnection {
    $host = Read-Host "请输入要 Ping 的主机名或 IP 地址"
    Write-StatusMessage "正在 Ping $host..." -Type Info
    ping $host
}

function Get-TraceRoute {
    $host = Read-Host "请输入目标主机名或 IP 地址"
    Write-StatusMessage "正在跟踪到 $host 的路由..." -Type Info
    tracert $host
}

function Get-IPConfiguration {
    Write-StatusMessage "正在获取 IP 配置信息..." -Type Info
    ipconfig /all
}

Export-ModuleMember -Function Show-NetworkTools, Test-NetworkConnection, Get-TraceRoute, Get-IPConfiguration