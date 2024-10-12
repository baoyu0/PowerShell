$startTime = Get-Date
# 主配置文件
$configPath = Split-Path -Parent $PROFILE
$modules = @(
    "core-settings",
    "aliases",
    "proxy-management",
    "custom-functions",
    "environment-setup",
    "theme-manager"
)

$logPath = Join-Path $configPath "powershell_profile.log"
$VerbosePreference = 'SilentlyContinue'

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $logPath
}

function Import-ConfigModule {
    param([string]$ModuleName)
    $modulePath = Join-Path $configPath "modules\$ModuleName.ps1"
    if (Test-Path $modulePath) {
        try {
            . $modulePath
            Write-Log "成功加载模块: $ModuleName"
            return $true
        } catch {
            Write-Log "错误: 加载模块 $ModuleName 失败 - $_"
            return $false
        }
    } else {
        Write-Log "警告: 配置模块 $ModuleName 不存在"
        return $false
    }
}

# 静默加载所有模块
$modules | ForEach-Object { Import-ConfigModule $_ | Out-Null }

# 加载主题配置
if (Get-Command Load-ThemeConfig -ErrorAction SilentlyContinue) {
    Load-ThemeConfig -ErrorAction SilentlyContinue | Out-Null
}

function Show-WelcomeMessage {
    Write-Host "欢迎使用自定义 PowerShell 环境！" -ForegroundColor Cyan
    Write-Host "输入 'help-all' 查看所有可用模块和命令。" -ForegroundColor Cyan
}

# 显示欢迎信息
Show-WelcomeMessage

function Get-ModuleHelp {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("core-settings", "aliases", "proxy-management", "custom-functions", "environment-setup", "theme-manager")]
        [string]$ModuleName
    )

    $helpFunctionName = "Show-$($ModuleName -replace '-', '')Help"
    & $helpFunctionName
}

# 其他必要的函数定义（如 Show-AllModulesHelp）保持不变

function Show-AllModulesHelp {
    Write-Host "PowerShell 配置模块摘要" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    
    foreach ($moduleName in $modules) {
        Write-Host "`n$moduleName 模块:" -ForegroundColor Yellow
        Get-ModuleHelp $moduleName
    }
    
    Write-Host "`n使用 'Get-ModuleHelp <模块名>' 来查看特定模块的详细帮助信息" -ForegroundColor Cyan
}

# 添加别名
Set-Alias -Name help-all -Value Show-AllModulesHelp

$endTime = Get-Date
$loadTime = ($endTime - $startTime).TotalMilliseconds
Write-Host "配置文件加载时间: $($loadTime.ToString("F0"))ms" -ForegroundColor DarkGray

# 在文件末尾添加
function Manage-Proxy {
    Show-ProxyMenu
}
