$startTime = Get-Date
# 主配置文件
$configPath = Split-Path -Parent $PROFILE
$modules = @(
    "core-settings",
    "aliases",
    "proxy-management",
    "custom-functions",  # 确保这个模块在前面
    "theme-manager"
)

foreach ($module in $modules) {
    $modulePath = Join-Path $configPath "modules\$module.ps1"
    if (Test-Path $modulePath) { . $modulePath }
}

Write-Host "欢迎使用自定义 PowerShell 环境！输入 'help-all' 查看所有可用命令。" -ForegroundColor Cyan

$loadTime = ((Get-Date) - $startTime).TotalMilliseconds
Write-Host "配置文件加载时间: $($loadTime.ToString("F0"))ms" -ForegroundColor DarkGray

Test-ProfileUpdate
