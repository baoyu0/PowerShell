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

function Show-NetworkTools {
    <#
    .SYNOPSIS
        显示网络诊断工具菜单
    .DESCRIPTION
        该函数显示一个交互式菜单，允许用户选择不同的网络诊断工具。
    .EXAMPLE
        Show-NetworkTools
    #>
    do {
        Clear-Host
        Write-Host "网络诊断工具" -ForegroundColor Cyan
        Write-Host "0. 返回上级菜单"
        Write-Host "1. Ping 测试"
        Write-Host "2. 路由跟踪"
        Write-Host "3. 查看 IP 配置"
        $choice = Read-Host "请选择操作"
        switch ($choice) {
            "0" { return }
            "1" { Test-NetworkConnection }
            "2" { Get-TraceRoute }
            "3" { Get-IPConfiguration }
            default { Write-Host "无效的选择，请重试。" -ForegroundColor Red }
        }
        if ($choice -ne "0") { Read-Host "按 Enter 键继续" }
    } while ($true)
}

function Test-NetworkConnection {
    <#
    .SYNOPSIS
        执行 Ping 测试
    .DESCRIPTION
        该函数允许用户输入一个主机名或IP地址，然后执行Ping测试。
    .EXAMPLE
        Test-NetworkConnection
    #>
    $host = Read-Host "请输入要 Ping 的主机名或 IP 地址"
    ping $host
}

function Get-TraceRoute {
    <#
    .SYNOPSIS
        执行路由跟踪
    .DESCRIPTION
        该函数允许用户输入一个目标主机名或IP地址，然后执行路由跟踪。
    .EXAMPLE
        Get-TraceRoute
    #>
    $host = Read-Host "请输入目标主机名或 IP 地址"
    tracert $host
}

function Get-IPConfiguration {
    <#
    .SYNOPSIS
        显示 IP 配置信息
    .DESCRIPTION
        该函数显示当前系统的详细 IP 配置信息。
    .EXAMPLE
        Get-IPConfiguration
    #>
    ipconfig /all
}

Export-ModuleMember -Function Show-NetworkTools, Test-NetworkConnection, Get-TraceRoute, Get-IPConfiguration