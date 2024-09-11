function Test-NetworkConnection {
    param (
        [string]$Target = "www.baidu.com",
        [int]$Count = 4
    )
    Write-Host "正在 ping $Target..." -ForegroundColor Cyan
    ping $Target -n $Count
}

function Get-TraceRoute {
    param (
        [string]$Target = "www.baidu.com"
    )
    Write-Host "正在跟踪到 $Target 的路由..." -ForegroundColor Cyan
    tracert $Target
}

function Get-PublicIP {
    $ip = Invoke-RestMethod -Uri "https://api.ipify.org?format=json"
    Write-Host "您的公网 IP 地址是：$($ip.ip)" -ForegroundColor Green
}

Export-ModuleMember -Function Test-NetworkConnection, Get-TraceRoute, Get-PublicIP