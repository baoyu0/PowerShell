# 日志记录函数
function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = "Info"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # 控制台输出
    $colorMap = @{"Info" = "White"; "Warning" = "Yellow"; "Error" = "Red"}
    Write-Host $logMessage -ForegroundColor $colorMap[$Level]
    
    # 文件日志
    $logFile = Join-Path $PSScriptRoot "..\Logs\PowerShell_Profile.log"
    $logMessage | Out-File -Append -FilePath $logFile
}

# 配置管理函数
function Get-ProfileConfig {
    $configPath = Join-Path $PSScriptRoot "..\config.json"
    if (Test-Path $configPath) {
        try {
            $config = Get-Content $configPath | ConvertFrom-Json
            # 添加配置校验逻辑
            if (-not $config.ProxyPort) {
                $config.ProxyPort = 20000
            }
            return $config
        } catch {
            Write-Log "读取配置文件时出错：$($_.Exception.Message)" -Level Error
            return @{
                ProxyPort = 20000
                UpdateCheckInterval = 24
                DefaultTheme = "1_shell"
            }
        }
    } else {
        return @{
            ProxyPort = 20000
            UpdateCheckInterval = 24
            DefaultTheme = "1_shell"
        }
    }
}

function Set-ProfileConfig {
    param (
        [hashtable]$NewConfig
    )
    $configPath = Join-Path $PSScriptRoot "..\config.json"
    $NewConfig | ConvertTo-Json | Set-Content $configPath
    Write-Log "配置已更新" -Level Info
}

Export-ModuleMember -Function Write-Log, Get-ProfileConfig, Set-ProfileConfig