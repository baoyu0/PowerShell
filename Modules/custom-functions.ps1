# 自定义函数

# 更新 PowerShell 配置文件
function Update-Profile {
    try {
        $profilePath = $PROFILE
        Copy-Item $profilePath "$profilePath.backup"
        if (Test-Path (Join-Path (Split-Path $profilePath) ".git")) {
            git -C (Split-Path $profilePath) pull
        }
        . $PROFILE
        Write-Host "配置文件已更新并重新加载。" -ForegroundColor Green
    } catch { Write-Error "更新失败: $_" }
}

# 网络连接测试
function Test-NetworkConnection {
    try {
        Invoke-WebRequest -Uri "https://www.microsoft.com" -TimeoutSec 5 | Out-Null
        Write-Host "网络连接正常" -ForegroundColor Green
    } catch { Write-Host "无法连接到互联网" -ForegroundColor Red }
}

# 添加帮助函数
function Show-CustomFunctionsHelp {
    @"
自定义函数模块帮助：
  Update-Profile           - 更新并重新加载 PowerShell 配置文件
  Test-NetworkConnection   - 测试网络连接
  Test-ProfileUpdate       - 检查配置文件是否有可用更新
"@ | Write-Host -ForegroundColor Cyan
}

# 添加自动更新检查功能
function Test-ProfileUpdate {
    $repoPath = Split-Path $PROFILE
    if (Test-Path (Join-Path $repoPath ".git")) {
        $status = git -C $repoPath status -uno
        if ($status -match "Your branch is behind") {
            Write-Host "PowerShell 配置文件有可用更新。运行 Update-Profile 来更新。" -ForegroundColor Yellow
        }
    }
}
