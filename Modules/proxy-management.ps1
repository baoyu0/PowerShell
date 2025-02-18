# 代理管理模块

# 默认代理设置
$script:defaultHttpProxy = "http://127.0.0.1:7890"
$script:defaultSocksProxy = "socks5://127.0.0.1:7890"
$script:proxyEnabled = $false

# 配置文件路径
$global:proxyConfigFile = if ($env:USERPROFILE) {
    Join-Path $env:USERPROFILE ".powershell_proxy_config.json"
} else {
    Write-Warning "无法获取用户配置文件路径，将使用当前目录。"
    Join-Path $PSScriptRoot ".powershell_proxy_config.json"
}

# 确保配置文件目录存在
$configDir = Split-Path -Parent $global:proxyConfigFile
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
}

# 加载代理配置
function Import-ProxyConfig {
    if (-not $global:proxyConfigFile) {
        Write-Error "代理配置文件路径未定义"
        return
    }
    if (Test-Path $global:proxyConfigFile) {
        try {
            $config = Get-Content $global:proxyConfigFile | ConvertFrom-Json
            $script:defaultHttpProxy = $config.HttpProxy
            $script:defaultSocksProxy = $config.SocksProxy
            $script:proxyEnabled = $config.Enabled
            if ($script:proxyEnabled) {
                Set-ProxyStatus -Status On -Silent
            }
            Write-Host "已加载代理配置" -ForegroundColor Green
        } catch {
            Write-Error "加载代理配置时出错: $_"
        }
    } else {
        Write-Warning "代理配置文件不存在，将使用默认设置"
    }
}

# 保存代理配置
function Save-ProxyConfig {
    if (-not $global:proxyConfigFile) {
        Write-Error "代理配置文件路径未定义"
        return
    }
    try {
        $config = @{
            HttpProxy = $script:defaultHttpProxy
            SocksProxy = $script:defaultSocksProxy
            Enabled = $script:proxyEnabled
        }
        $config | ConvertTo-Json | Set-Content $global:proxyConfigFile -ErrorAction Stop
        Write-Host "代理配置已保存到 $global:proxyConfigFile" -ForegroundColor Green
    } catch {
        Write-Error "保存代理配置时出错: $_"
    }
}

# 设置代理
function Set-ProxyStatus {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("On", "Off")]
        [string]$Status,
        [Parameter(Mandatory=$false)]
        [string]$HttpProxy,
        [Parameter(Mandatory=$false)]
        [string]$SocksProxy,
        [switch]$Silent
    )

    if ($Status -eq "On") {
        $HttpProxy = if ($HttpProxy) { $HttpProxy } else { $script:defaultHttpProxy }
        $SocksProxy = if ($SocksProxy) { $SocksProxy } else { $script:defaultSocksProxy }

        try {
            [System.Environment]::SetEnvironmentVariable('HTTP_PROXY', $HttpProxy, 'User')
            [System.Environment]::SetEnvironmentVariable('HTTPS_PROXY', $HttpProxy, 'User')
            [System.Environment]::SetEnvironmentVariable('ALL_PROXY', $SocksProxy, 'User')
            $script:proxyEnabled = $true
            if (-not $Silent) { Write-Host "代理已开启" -ForegroundColor Green }
        } catch {
            Write-Error "设置代理环境变量时出错: $_"
        }
    } else {
        try {
            [System.Environment]::SetEnvironmentVariable('HTTP_PROXY', $null, 'User')
            [System.Environment]::SetEnvironmentVariable('HTTPS_PROXY', $null, 'User')
            [System.Environment]::SetEnvironmentVariable('ALL_PROXY', $null, 'User')
            $script:proxyEnabled = $false
            if (-not $Silent) { Write-Host "代理已关闭" -ForegroundColor Yellow }
        } catch {
            Write-Error "移除代理环境变量时出错: $_"
        }
    }
    Save-ProxyConfig
}

# 获取代理状态
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

# 修改默认代理设置
function Set-DefaultProxy {
    param (
        [Parameter(Mandatory=$true)]
        [string]$HttpProxy,
        [Parameter(Mandatory=$true)]
        [string]$SocksProxy
    )

    # 添加协议前缀（如果没有）
    if ($HttpProxy -notmatch '^http://') {
        $HttpProxy = "http://$HttpProxy"
    }
    if ($SocksProxy -notmatch '^socks5://') {
        $SocksProxy = "socks5://$SocksProxy"
    }

    $script:defaultHttpProxy = $HttpProxy
    $script:defaultSocksProxy = $SocksProxy
    Save-ProxyConfig
    Write-Host "默认代理设置已更新" -ForegroundColor Green
}

# 自动检测网络环境并切换代理
function Switch-ProxyAuto {
    $testUrl = "https://www.google.com"
    try {
        Invoke-WebRequest -Uri $testUrl -TimeoutSec 5 | Out-Null
        Set-ProxyStatus -Status Off
        Write-Host "检测到直接连接可用，已关闭代理" -ForegroundColor Green
    } catch {
        Set-ProxyStatus -Status On
        Write-Host "检测到需要代理，已开启代理" -ForegroundColor Yellow
    }
}

# 交互式菜单
function Show-ProxyMenu {
    do {
        Clear-Host
        Write-Host "=== 代理管理菜单 ===" -ForegroundColor Cyan
        Write-Host "1. 开启代理"
        Write-Host "2. 关闭代理"
        Write-Host "3. 查看当前代理状态"
        Write-Host "4. 修改默认代理设置"
        Write-Host "5. 自动检测并切换代理"
        Write-Host "6. 退出"
        $choice = Read-Host "请选择操作 (1-6)"

        switch ($choice) {
            "1" { Set-ProxyStatus -Status On }
            "2" { Set-ProxyStatus -Status Off }
            "3" { Get-ProxyStatus }
            "4" {
                $httpProxy = Read-Host "请输入新的 HTTP 代理地址"
                $socksProxy = Read-Host "请输入新的 SOCKS 代理地址"
                Set-DefaultProxy -HttpProxy $httpProxy -SocksProxy $socksProxy
            }
            "5" { Switch-ProxyAuto }
            "6" { return }
            default { Write-Host "无效的选择，请重试" -ForegroundColor Red }
        }
        Pause
    } while ($true)
}

# 帮助函数
function Show-ProxyManagementHelp {
    Write-Host "代理管理模块帮助：" -ForegroundColor Cyan
    Write-Host "  Set-ProxyStatus On/Off [HttpProxy] [SocksProxy] - 开启或关闭代理"
    Write-Host "  Get-ProxyStatus                                - 显示当前代理设置"
    Write-Host "  Set-DefaultProxy <HttpProxy> <SocksProxy>      - 设置默认代理"
    Write-Host "  Switch-ProxyAuto                               - 自动检测并切换代理"
    Write-Host "  Show-ProxyMenu                                 - 显示交互式代理管理菜单"
    Write-Host "  Invoke-ProxyManager                            - 启动代理管理器（等同于 Show-ProxyMenu）"
    Write-Host "  Manage-Proxy                                   - 'Invoke-ProxyManager' 的别名（用于向后兼容）"
}

# 初始化时加载配置
Import-ProxyConfig

# 使用新的函数名
function Invoke-ProxyManager {
    Show-ProxyMenu
}

# 添加别名前检查，避免覆盖
if (-not (Get-Alias -Name Manage-Proxy -ErrorAction SilentlyContinue)) {
    # 添加别名并抑制 PSScriptAnalyzer 规则 PSUseApprovedVerbs
    # <Disable-PSScriptAnalyzer Rule=PSUseApprovedVerbs>
    New-Alias -Name Manage-Proxy -Value Invoke-ProxyManager -Force
    # <Enable-PSScriptAnalyzer Rule=PSUseApprovedVerbs>
    
    # 添加注释
    Write-Host "'Manage-Proxy' 别名已创建，指向 'Invoke-ProxyManager'。" -ForegroundColor Green
} else {
    Write-Host "'Manage-Proxy' 别名已存在，不会覆盖。" -ForegroundColor Yellow
}

# 在文件末尾添加注释
# 注意：'Manage-Proxy' 别名保留是为了向后兼容性。新代码应使用 'Invoke-ProxyManager'。
