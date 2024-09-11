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
            "查看 IP 配置",
            "DNS 查询",
            "端口扫描",
            "网络连接测试",
            "带宽测试"
        )
        
        switch ($choice) {
            0 { return }
            1 { Test-NetworkConnection }
            2 { Get-TraceRoute }
            3 { Get-IPConfiguration }
            4 { Resolve-DNSName }
            5 { Test-Port }
            6 { Test-NetConnection }
            7 { Test-NetworkBandwidth }
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

function Resolve-DNSName {
    $hostname = Read-Host "请输入要查询的主机名"
    Write-StatusMessage "正在查询 DNS..." -Type Info
    Resolve-DnsName $hostname | Format-Table
}

function Test-Port {
    $hostname = Read-Host "请输入要扫描的主机名或 IP 地址"
    $port = Read-Host "请输入要扫描的端口号"
    $result = Test-NetConnection -ComputerName $hostname -Port $port
    if ($result.TcpTestSucceeded) {
        Write-StatusMessage "端口 $port 在 $hostname 上是开放的" -Type Success
    } else {
        Write-StatusMessage "端口 $port 在 $hostname 上是关闭的" -Type Warning
    }
}

function Test-NetConnection {
    $hostname = Read-Host "请输入要测试连接的主机名或 IP 地址"
    Write-StatusMessage "正在测试网络连接..." -Type Info
    Test-NetConnection $hostname -InformationLevel Detailed
}

function Test-NetworkBandwidth {
    Write-StatusMessage "正在测试网络带宽..." -Type Info
    $url = "http://speedtest.wdc01.softlayer.com/downloads/test10.zip"
    $output = "$env:TEMP\speedtest.zip"
    $start = Get-Date
    Invoke-WebRequest -Uri $url -OutFile $output
    $end = Get-Date
    $time = ($end - $start).TotalSeconds
    $fileSize = (Get-Item $output).Length / 1MB
    $speedMbps = $fileSize / $time * 8
    Remove-Item $output
    Write-StatusMessage "下载速度: $($speedMbps.ToString("F2")) Mbps" -Type Info
}

Export-ModuleMember -Function Show-NetworkTools, Test-NetworkConnection, Get-TraceRoute, Get-IPConfiguration, Resolve-DNSName, Test-Port, Test-NetConnection, Test-NetworkBandwidth