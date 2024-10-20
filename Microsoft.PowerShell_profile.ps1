$startTime = Get-Date
# 主配置文件
$configPath = Split-Path -Parent $PROFILE
$modules = @(
    "core-settings",
    "aliases",
    "proxy-management",
    "custom-functions",  # 确保这个模块在前面
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
            Write-Host "错误: 加载模块 $ModuleName 失败。请检查日志文件获取详细信息。" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Log "警���: 配置模块 $ModuleName 不存在"
        Write-Host "警告: 配置模块 $ModuleName 不存在" -ForegroundColor Yellow
        return $false
    }
}

$modules | ForEach-Object { 
    $result = Import-ConfigModule $_
    if ($_ -eq "custom-functions" -and $result) {
        Write-Host "custom-functions 模块已成功加载" -ForegroundColor Green
    }
}

function Show-WelcomeMessage {
    Write-Host "欢迎使用自定义 PowerShell 环境！" -ForegroundColor Cyan
    Write-Host "输入 'help-all' 查看所有可用模块和命令。" -ForegroundColor Cyan
}

Show-WelcomeMessage

$endTime = Get-Date
$loadTime = ($endTime - $startTime).TotalMilliseconds
Write-Host "配置文件加载时间: $($loadTime.ToString("F0"))ms" -ForegroundColor DarkGray

# 在配置文件加载完成后调用更新检查
if (Get-Command Test-ProfileUpdate -ErrorAction SilentlyContinue) {
    Test-ProfileUpdate
} else {
    Write-Warning "Test-ProfileUpdate 函数未找到。请确保 custom-functions.ps1 模块已正确加载。"
    Get-ChildItem Function: | Where-Object { $_.Name -like "*Profile*" } | Format-Table Name, CommandType
}
