# 代理管理模块

$script:defaultHttpProxy = "http://127.0.0.1:7890"
$script:defaultSocksProxy = "socks5://127.0.0.1:7890"

function Set-ProxyStatus {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("On", "Off")]
        [string]$Status,
        [Parameter(Mandatory=$false)]
        [string]$HttpProxy,
        [Parameter(Mandatory=$false)]
        [string]$SocksProxy
    )

    if ($Status -eq "On") {
        $HttpProxy = if ($HttpProxy) { $HttpProxy } else { $script:defaultHttpProxy }
        $SocksProxy = if ($SocksProxy) { $SocksProxy } else { $script:defaultSocksProxy }

        [System.Environment]::SetEnvironmentVariable('HTTP_PROXY', $HttpProxy, 'User')
        [System.Environment]::SetEnvironmentVariable('HTTPS_PROXY', $HttpProxy, 'User')
        [System.Environment]::SetEnvironmentVariable('ALL_PROXY', $SocksProxy, 'User')
        Write-Host "代理已开启" -ForegroundColor Green
    } else {
        [System.Environment]::SetEnvironmentVariable('HTTP_PROXY', $null, 'User')
        [System.Environment]::SetEnvironmentVariable('HTTPS_PROXY', $null, 'User')
        [System.Environment]::SetEnvironmentVariable('ALL_PROXY', $null, 'User')
        Write-Host "代理已关闭" -ForegroundColor Yellow
    }
}

function Get-ProxyStatus {
    $httpProxy = [System.Environment]::GetEnvironmentVariable('HTTP_PROXY', 'User')
    $socksProxy = [System.Environment]::GetEnvironmentVariable('ALL_PROXY', 'User')
    
    if ($httpProxy -or $socksProxy) {
        Write-Host "当前代理设置:" -ForegroundColor Cyan
        if ($httpProxy) { Write-Host "  HTTP 代理: $httpProxy" -ForegroundColor Green }
        if ($socksProxy) { Write-Host "  SOCKS 代理: $socksProxy" -ForegroundColor Green }
    } else {
        Write-Host "当前未设置代理" -ForegroundColor Yellow
    }
}

# 修改帮助函数名称
function global:Show-ProxyManagementHelp {
    Write-Host "代理管理模块帮助：" -ForegroundColor Cyan
    Write-Host "  Set-ProxyStatus On/Off - 开启或关闭代理"
    Write-Host "  Get-ProxyStatus        - 显示当前代理设置"
}
