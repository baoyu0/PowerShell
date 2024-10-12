# 主配置文件
$configPath = Split-Path -Parent $PROFILE
$modules = @(
    "core-settings",
    "aliases",
    "proxy-management",
    "custom-functions",
    "environment-setup"
)

# 延迟加载函数
function Import-ConfigModule {
    param([string]$ModuleName)
    $modulePath = Join-Path $configPath "modules\$ModuleName.ps1"
    if (Test-Path $modulePath) {
        . $modulePath
    } else {
        Write-Warning "配置模块 $ModuleName 不存在"
    }
}

# 立即加载核心设置
Import-ConfigModule "core-settings"

# 延迟加载其他模块
$modules | Where-Object { $_ -ne "core-settings" } | ForEach-Object {
    $moduleName = $_
    New-Alias -Name "Load-$moduleName" -Value { Import-ConfigModule $moduleName } -Force
}

# 显示可用模块
Write-Host "可用配置模块: $($modules -join ', ')" -ForegroundColor Cyan
Write-Host "使用 'Load-<模块名>' 来加载特定模块" -ForegroundColor Cyan

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# ... 其他配置代码 ...

$stopwatch.Stop()
if ($stopwatch.Elapsed.TotalMilliseconds -gt 500) {
    Write-Warning "配置加载时间: $($stopwatch.Elapsed.TotalMilliseconds) ms。考虑进一步优化。"
}
