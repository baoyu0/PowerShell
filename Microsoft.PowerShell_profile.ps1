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
            Write-Host "错误: 加载模块 $ModuleName 失败。请检查日志文件获取详细信息。" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Log "警告: 配置模块 $ModuleName 不存在"
        Write-Host "警告: 配置模块 $ModuleName 不存在" -ForegroundColor Yellow
        return $false
    }
}

# 创建或加载缓存文件
$cacheFile = Join-Path $env:TEMP "PowerShell_ModuleCache.clixml"
if (Test-Path $cacheFile) {
    $moduleCache = Import-Clixml $cacheFile
} else {
    $moduleCache = @{}
}

# 修改模块加载部分
$failedModules = @{}

# 修改添加失败模块的逻辑
$modules | ForEach-Object { 
    if (-not $moduleCache.ContainsKey($_) -or -not $moduleCache[$_]) {
        if (Import-ConfigModule $_) {
            $moduleCache[$_] = $true
        } else {
            $failedModules[$_] = $false
            $moduleCache[$_] = $false
        }
    } elseif (-not $moduleCache[$_]) {
        $failedModules[$_] = $false
    }
}

# 保存缓存
$moduleCache | Export-Clixml $cacheFile

if ($failedModules.Count -gt 0) {
    Write-Host "警告: 以下模块加载失败: $($failedModules.Keys -join ', ')" -ForegroundColor Yellow
    Write-Host "某些功能可能无法正常工作。请检查日志文件获取详细信息。" -ForegroundColor Yellow
}

# 加载主题配置
if (Get-Command Import-ThemeConfig -ErrorAction SilentlyContinue) {
    Import-ThemeConfig | Out-Null
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

function Show-AllModulesHelp {
    Write-Host "PowerShell 配置模块摘要" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    
    foreach ($moduleName in $modules) {
        Write-Host "`n$moduleName 模块:" -ForegroundColor Yellow
        Get-ModuleHelp $moduleName
    }
    
    Write-Host "`n使用 'Get-ModuleHelp <模块名>' 来查看特定模块的详细帮助信息" -ForegroundColor Cyan
}

$endTime = Get-Date
$loadTime = ($endTime - $startTime).TotalMilliseconds
Write-Host "配置文件加载时间: $($loadTime.ToString("F0"))ms" -ForegroundColor DarkGray

# 确保代理管理模块已加载
if (-not (Get-Command Show-ProxyMenu -ErrorAction SilentlyContinue)) {
    Import-ConfigModule "proxy-management"
}

# 在文件开头添加版本号
$script:profileVersion = "1.1.0"

# 添加延迟加载功能
$script:lazyLoadModules = @("theme-manager", "proxy-management")

function Import-LazyModule {
    param([string]$ModuleName)
    if ($script:lazyLoadModules -contains $ModuleName) {
        Import-ConfigModule $ModuleName
        $script:lazyLoadModules = $script:lazyLoadModules | Where-Object { $_ -ne $ModuleName }
    }
}

# 添加错误报告功能
function New-ErrorReport {
    param([string]$ErrorMessage)
    $reportPath = Join-Path $configPath "error_reports"
    if (-not (Test-Path $reportPath)) {
        New-Item -ItemType Directory -Path $reportPath | Out-Null
    }
    $reportFile = Join-Path $reportPath "error_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    @"
错误报告
时间: $(Get-Date)
版本: $script:profileVersion
错误信息:
$ErrorMessage
"@ | Out-File $reportFile
    Write-Host "错误报告已保存到: $reportFile" -ForegroundColor Yellow
}

# 添加自动更新检查功能
function Test-ProfileUpdate {
    $repoPath = Split-Path $PROFILE
    if (Test-Path (Join-Path $repoPath ".git")) {
        try {
            $status = git -C $repoPath status -uno
            if ($status -match "Your branch is behind") {
                Write-Host "PowerShell 配置文件有可用更新。运行 Update-Profile 来更新。" -ForegroundColor Yellow
            }
        } catch {
            Write-Warning "检查更新失败: $_"
        }
    }
}

# 在配置文件加载完成后调用更新检查
Test-ProfileUpdate
