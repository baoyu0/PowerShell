function Set-ProxyStatus {
    param (
        [switch]$Enable,
        [switch]$Disable
    )

    $proxyPort = $config.ProxyPort

    function Show-ProxyStatus {
        if ($env:http_proxy) {
            Write-Host "当前网络代理状态: 已开启" -ForegroundColor Green
            Write-Host "HTTP 代理: $env:http_proxy" -ForegroundColor Cyan
            Write-Host "SOCKS 代理: $env:SOCKS_SERVER" -ForegroundColor Cyan
        } else {
            Write-Host "当前网络代理状态: 已关闭" -ForegroundColor Yellow
        }
    }

    function Enable-Proxy {
        $env:http_proxy = "http://127.0.0.1:$proxyPort"
        $env:https_proxy = "http://127.0.0.1:$proxyPort"
        $env:SOCKS_SERVER = "socks5://127.0.0.1:$proxyPort"
        Write-Log "代理已开启" -Level Info
        Show-ProxyStatus
    }

    function Disable-Proxy {
        $env:http_proxy = $null
        $env:https_proxy = $null
        $env:SOCKS_SERVER = $null
        Write-Log "代理已关闭" -Level Info
        Show-ProxyStatus
    }

    if ($Enable) {
        Enable-Proxy
        return
    }

    if ($Disable) {
        Disable-Proxy
        return
    }

    # 交互式菜单
    do {
        Clear-Host
        $width = 60
        $title = "网络代理设置"
        
        $horizontalLine = "─" * ($width - 2)
        $topBorder    = "┌$horizontalLine┐"
        $bottomBorder = "└$horizontalLine┘"
        $middleBorder = "├$horizontalLine┤"

        Write-Host $topBorder -ForegroundColor Cyan
        $titlePadded = $title.PadLeft([Math]::Floor(($width + $title.Length) / 2)).PadRight($width - 2)
        Write-Host "│$titlePadded│" -ForegroundColor Cyan
        Write-Host $middleBorder -ForegroundColor Cyan
        
        Show-ProxyStatus
        Write-Host $middleBorder -ForegroundColor Cyan
        
        $options = @(
            "返回主菜单",
            "开启网络代理",
            "关闭网络代理"
        )
        
        for ($i = 0; $i -lt $options.Count; $i++) {
            $optionText = "[$i] $($options[$i])".PadRight($width - 3)
            Write-Host "│ $optionText│" -ForegroundColor Yellow
        }
        
        Write-Host $bottomBorder -ForegroundColor Cyan
        
        $choice = Read-Host "`n请选择操作 (0-$($options.Count - 1))"

        switch ($choice) {
            "0" { return }
            "1" { Enable-Proxy }
            "2" { Disable-Proxy }
            default { Write-Log "无效的选择，请重试。" -Level Warning }
        }

        if ($choice -ne "0") {
            Read-Host "按 Enter 键继续"
        }
    } while ($choice -ne "0")
}

function Manage-Proxy {
    # 函数内容
}

function Invoke-ProxyManager {
    # 函数内容
}

Set-Alias -Name Manage-Proxy -Value Invoke-ProxyManager

# 如果这是一个模块文件，确保导出新的函数名和别名
Export-ModuleMember -Function Invoke-ProxyManager -Alias Manage-Proxy
