# 主配置文件
$configPath = Split-Path -Parent $PROFILE
$modules = @(
    "core-settings",
    "aliases",
    "proxy-management",
    "custom-functions",
    "environment-setup"
)

# 在文件开头添加
$logPath = Join-Path $configPath "powershell_profile.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $logPath
}

# 延迟加载函数
function Import-ConfigModule {
    param([string]$ModuleName)
    $modulePath = Join-Path $configPath "modules\$ModuleName.ps1"
    if (Test-Path $modulePath) {
        try {
            . $modulePath
            Get-ChildItem function: | Where-Object { $_.Source -eq $modulePath } | ForEach-Object {
                Export-ModuleMember -Function $_.Name -Verbose
            }
            Write-Log "成功加载模块: $ModuleName"
            
            # 调用帮助函数（如果存在）
            $helpFunctionName = "Show-" + ($ModuleName -replace '-', '') + "Help"
            if (Get-Command $helpFunctionName -ErrorAction SilentlyContinue) {
                & $helpFunctionName
            }
            
            return $true
        } catch {
            Write-Warning "加载模块 $ModuleName 时出错: $_"
            Write-Log "错误: 加载模块 $ModuleName 失败 - $_"
            return $false
        }
    } else {
        Write-Warning "配置模块 $ModuleName 不存在"
        Write-Log "警告: 配置模块 $ModuleName 不存在"
        return $false
    }
}

# 立即加载核心设置
Import-ConfigModule "core-settings"

# 为其他模块创建加载函数
$modules | Where-Object { $_ -ne "core-settings" } | ForEach-Object {
    $moduleName = $_
    Set-Item -Path Function:Global:"Load-$moduleName" -Value {
        $loaded = Import-ConfigModule $moduleName
        if ($loaded) {
            Write-Host "模块 $moduleName 已成功加载" -ForegroundColor Green
        } else {
            Write-Host "模块 $moduleName 加载失败" -ForegroundColor Red
        }
    }.GetNewClosure()
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

# 在文件末尾添加
function Show-ModuleHelp {
    param([string]$ModuleName)
    $helpFunctionName = "Show-" + ($ModuleName -replace '-', '') + "Help"
    Write-Host "Attempting to call function: $helpFunctionName" -ForegroundColor Yellow
    if (Get-Command $helpFunctionName -ErrorAction SilentlyContinue) {
        & $helpFunctionName
    } else {
        Write-Host "未找到 $ModuleName 模块的帮助信息" -ForegroundColor Yellow
        Write-Host "Available functions:" -ForegroundColor Yellow
        Get-ChildItem function: | Where-Object { $_.Source -like "*$ModuleName*" } | Format-Table Name, Source
    }
}

Write-Host "使用 'Show-ModuleHelp <模块名>' 来查看特定模块的帮助信息" -ForegroundColor Cyan

# 在文件末尾添加以下函数

function Show-AllModulesHelp {
    Write-Host "PowerShell 配置模块摘要" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    
    foreach ($moduleName in $modules) {
        Write-Host "`n$moduleName 模块:" -ForegroundColor Yellow
        
        # 加载模块（如果还没有加载）
        if ($moduleName -ne "core-settings") {
            & (Get-Item "Function:Load-$moduleName")
        }
        
        $helpFunctionName = "Show-" + ($moduleName -replace '-', '') + "Help"
        if (Get-Command $helpFunctionName -ErrorAction SilentlyContinue) {
            & $helpFunctionName
        } else {
            Write-Host "  未找到帮助信息" -ForegroundColor Red
            $moduleFunctions = Get-ChildItem function: | Where-Object { $_.Source -like "*$moduleName*" }
            if ($moduleFunctions) {
                Write-Host "  可用函数:" -ForegroundColor Gray
                $moduleFunctions | ForEach-Object { Write-Host "    - $($_.Name)" -ForegroundColor Gray }
            } else {
                Write-Host "  没有找到相关函数" -ForegroundColor Gray
            }
        }
    }
    
    Write-Host "`n使用 'Show-ModuleHelp <模块名>' 来查看特定模块的详细帮助信息" -ForegroundColor Cyan
}

# 添加新的别名
Set-Alias -Name help-all -Value Show-AllModulesHelp

# 在显示可用模块的信息后添加以下行
Write-Host "使用 'help-all' 来查看所有模块的���要信息" -ForegroundColor Cyan
