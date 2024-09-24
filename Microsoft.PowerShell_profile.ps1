# 代理管理模块
$proxyModule = {
    $script:defaultHttpProxy = "http://127.0.0.1:20000"
    $script:defaultSocksProxy = "socks5://127.0.0.1:20000"
    $script:proxyCache = @{}

    function Clear-ProxyEnvironmentVariables {
        $envVars = @('HTTP_PROXY', 'HTTPS_PROXY', 'FTP_PROXY', 'NO_PROXY', 'ALL_PROXY')
        foreach ($var in $envVars) {
            [System.Environment]::SetEnvironmentVariable($var, $null, 'User')
            [System.Environment]::SetEnvironmentVariable($var, $null, 'Process')
            Remove-Item Env:$var -ErrorAction SilentlyContinue
        }
        Write-Host "✅ 已清除所有代理环境变量" -ForegroundColor Green
    }

    function Test-ProxyAvailability {
        param ([string]$Proxy)
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.Proxy = New-Object System.Net.WebProxy($Proxy)
            $webClient.DownloadString("https://www.microsoft.com") | Out-Null
            Write-Host "✅ 代理 ($Proxy) 可用" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "❌ 代理 ($Proxy) 不可用" -ForegroundColor Red
            return $false
        }
    }

    function Test-ProxySpeed {
        param ([string]$Proxy)
        $url = "https://www.microsoft.com"
        
        if ([string]::IsNullOrWhiteSpace($Proxy)) {
            Write-Host "错误: 未设置代理地址" -ForegroundColor Red
            return -1
        }

        try {
            $webProxy = New-Object System.Net.WebProxy($Proxy)
            $webClient = New-Object System.Net.WebClient
            $webClient.Proxy = $webProxy
            
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $webClient.DownloadString($url) | Out-Null
            $stopwatch.Stop()
            Write-Host "✅ 代理 ($Proxy) 响应时间: $($stopwatch.ElapsedMilliseconds) 毫秒" -ForegroundColor Green
            return $stopwatch.ElapsedMilliseconds
        } catch [System.UriFormatException] {
            Write-Host "错误: 代理地址格式不正确 ($Proxy)" -ForegroundColor Red
            return -1
        } catch {
            Write-Host "错误: 测试失败 - $($_.Exception.Message)" -ForegroundColor Red
            return -1
        }
    }

    function Set-SystemProxy {
        param ([string]$Proxy, [bool]$Enable)
        $regKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
        if ($Enable) {
            Set-ItemProperty -Path $regKey -Name ProxyEnable -Value 1
            Set-ItemProperty -Path $regKey -Name ProxyServer -Value $Proxy
            Write-Host "✅ 系统代理已设置为: $Proxy" -ForegroundColor Green
        } else {
            Set-ItemProperty -Path $regKey -Name ProxyEnable -Value 0
            Remove-ItemProperty -Path $regKey -Name ProxyServer -ErrorAction SilentlyContinue
            Write-Host "✅ 系统代理已禁用" -ForegroundColor Yellow
        }
    }

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

            if (Test-ProxyAvailability -Proxy $HttpProxy) {
                [System.Environment]::SetEnvironmentVariable('HTTP_PROXY', $HttpProxy, 'User')
                [System.Environment]::SetEnvironmentVariable('HTTPS_PROXY', $HttpProxy, 'User')
                [System.Environment]::SetEnvironmentVariable('ALL_PROXY', $SocksProxy, 'User')
                $env:HTTP_PROXY = $HttpProxy
                $env:HTTPS_PROXY = $HttpProxy
                $env:ALL_PROXY = $SocksProxy
                Set-SystemProxy -Proxy $HttpProxy -Enable $true
                Write-Host "代理已开启:" -ForegroundColor Green
                Write-Host "HTTP 代理: $HttpProxy" -ForegroundColor Green
                Write-Host "SOCKS 代理: $SocksProxy" -ForegroundColor Green
            } else {
                Write-Host "代理不可用，请检查设置。" -ForegroundColor Red
                return
            }
        } else {
            Clear-ProxyEnvironmentVariables
            Set-SystemProxy -Enable $false
            Write-Host "代理已关闭" -ForegroundColor Yellow
        }
        $script:proxyCache.Clear()
    }

    function Get-ProxyStatus {
        $httpProxy = [System.Environment]::GetEnvironmentVariable('HTTP_PROXY', 'User')
        $socksProxy = [System.Environment]::GetEnvironmentVariable('ALL_PROXY', 'User')
        
        Write-Host "┃ 当前代理设置:                                            ┃" -ForegroundColor Cyan
        if ($httpProxy -or $socksProxy) {
            if ($httpProxy) { 
                $paddedHttpProxy = "{0,-54}" -f "HTTP 代理: $httpProxy"
                Write-Host "┃ $paddedHttpProxy ┃" -ForegroundColor Green
            }
            if ($socksProxy) { 
                $paddedSocksProxy = "{0,-54}" -f "SOCKS 代理: $socksProxy"
                Write-Host "┃ $paddedSocksProxy ┃" -ForegroundColor Green
            }
            Write-Host "┃ 当前网络代理状态: ● 已开启                                ┃" -ForegroundColor Green
        } else {
            Write-Host "┃ 当前网络代理状态: ○ 已关闭                                ┃" -ForegroundColor Red
        }
    }

    function Show-ProxyMenu {
        do {
            Clear-Host
            Write-Host "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓" -ForegroundColor Cyan
            Write-Host "┃                     网络代理设置管理                     ┃" -ForegroundColor Cyan
            Write-Host "┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫" -ForegroundColor Cyan
            Get-ProxyStatus
            Write-Host "┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫" -ForegroundColor Cyan
            Write-Host "┃ [0] ◀ 返回主菜单                                         ┃" -ForegroundColor Yellow
            Write-Host "┃ [1] ● 开启网络代理                                       ┃" -ForegroundColor Green
            Write-Host "┃ [2] ○ 关闭网络代理                                       ┃" -ForegroundColor Red
            Write-Host "┃ [3] ◉ 设置 HTTP 代理                                     ┃" -ForegroundColor Blue
            Write-Host "┃ [4] ◎ 设置 SOCKS 代理                                    ┃" -ForegroundColor Magenta
            Write-Host "┃ [5] ⚡ 测试当前代理速度                                   ┃" -ForegroundColor Cyan
            Write-Host "┃ [6] ❓ 帮助信息                                           ┃" -ForegroundColor White
            Write-Host "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛" -ForegroundColor Cyan

            $choice = Read-Host "请选择操作 (0-6)"

            switch ($choice) {
                "0" { return }
                "1" { 
                    $confirm = Read-Host "确认开启网络代理? (y/n)"
                    if ($confirm -eq "y") {
                        Set-ProxyStatus -Status On 
                    } else {
                        Write-Host "操作已取消" -ForegroundColor Yellow
                    }
                }
                "2" { 
                    $confirm = Read-Host "确认关闭网络代理? (y/n)"
                    if ($confirm -eq "y") {
                        Set-ProxyStatus -Status Off 
                    } else {
                        Write-Host "操作已取消" -ForegroundColor Yellow
                    }
                }
                "3" {
                    $newHttpProxy = Read-Host "请输入新的 HTTP 代理地址 (格式: http://127.0.0.1:7890) 或直接回车保持当前设置"
                    if ([string]::IsNullOrWhiteSpace($newHttpProxy)) {
                        Write-Host "✅ 保持当前 HTTP 代理设置不变" -ForegroundColor Yellow
                    } else {
                        if ($newHttpProxy -notmatch ':\d+$') {
                            $newHttpProxy += ':7890'
                        }
                        Set-ProxyStatus -Status On -HttpProxy $newHttpProxy
                        $script:defaultHttpProxy = $newHttpProxy
                    }
                }
                "4" {
                    $newSocksProxy = Read-Host "请输入新的 SOCKS 代理地址 (格式: socks5://127.0.0.1:7890) 或直接回车保持当前设置"
                    if ([string]::IsNullOrWhiteSpace($newSocksProxy)) {
                        Write-Host "✅ 保持当前 SOCKS 代理设置不变" -ForegroundColor Yellow
                    } else {
                        if ($newSocksProxy -notmatch ':\d+$') {
                            $newSocksProxy += ':7890'
                        }
                        Set-ProxyStatus -Status On -SocksProxy $newSocksProxy
                        $script:defaultSocksProxy = $newSocksProxy
                    }
                }
                "5" {
                    $currentProxy = $env:HTTP_PROXY
                    if ([string]::IsNullOrWhiteSpace($currentProxy)) {
                        Write-Host "当前未设置 HTTP 代理，无法测试速度。" -ForegroundColor Yellow
                    } else {
                        Write-Host "正在测试代理速度，请稍候..." -ForegroundColor Cyan
                        $speed = Test-ProxySpeed -Proxy $currentProxy
                        if ($speed -ge 0) {
                            Write-Host "当前代理 ($currentProxy) 响应时间: $speed 毫秒" -ForegroundColor Green
                        }
                    }
                }
                "6" {
                    Write-Host "帮助信息:" -ForegroundColor White
                    Write-Host "[0] 返回主菜单" -ForegroundColor Yellow
                    Write-Host "[1] 开启网络代理: 启用当前设置的 HTTP 和 SOCKS 代理。" -ForegroundColor Green
                    Write-Host "[2] 关闭网络代理: 禁用当前设置的 HTTP 和 SOCKS 代理。" -ForegroundColor Red
                    Write-Host "[3] 设置 HTTP 代理: 输入新的 HTTP 代理地址。" -ForegroundColor Blue
                    Write-Host "[4] 设置 SOCKS 代理: 输入新的 SOCKS 代理地址。" -ForegroundColor Magenta
                    Write-Host "[5] 测试当前代理速度: 测试当前设置的 HTTP 代理的响应速度。" -ForegroundColor Cyan
                    Write-Host "[6] 显示帮助信息: 显示此帮助信息。" -ForegroundColor White
                }
                default { Write-Host "❌ 无效选项，请重试。" -ForegroundColor Red }
            }

            if ($choice -ne "0") {
                Write-Host ""
                Read-Host "按回车键继续..."
            }
        } while ($choice -ne "0")
    }

    function Switch-Proxy {
        $currentStatus = [System.Environment]::GetEnvironmentVariable('HTTP_PROXY', 'User')
        if ($currentStatus) {
            Set-ProxyStatus -Status Off
        } else {
            Set-ProxyStatus -Status On
        }
        Get-ProxyStatus
    }

    Export-ModuleMember -Function Set-ProxyStatus, Get-ProxyStatus, Show-ProxyMenu, Switch-Proxy
}

New-Module -Name ProxyManagement -ScriptBlock $proxyModule | Import-Module

Set-Alias -Name proxy -Value Show-ProxyMenu
Set-Alias -Name proxyswitch -Value Switch-Proxy