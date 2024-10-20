# 自定义函数

# 更新 PowerShell 配置文件
function global:Update-Profile {
    $profilePath = $PROFILE
    $backupPath = "$profilePath.backup"
    
    try {
        Copy-Item $profilePath $backupPath -ErrorAction Stop
        Write-Host "配置文件已备份到 $backupPath" -ForegroundColor Green
        
        if (Test-Path (Join-Path (Split-Path $profilePath) ".git")) {
            git -C (Split-Path $profilePath) pull
            Write-Host "配置文件已从 Git 仓库更新" -ForegroundColor Green
        } else {
            Write-Warning "配置文件目录不是 Git 仓库，无法自动更新"
        }
        
        . $PROFILE
        Write-Host "配置文件已重新加载。" -ForegroundColor Green
    } catch {
        Write-Error "更新配置文件失败: $_"
    }
}

# 网络连接测试
function global:Test-NetworkConnection {
    $testUrl = "https://www.microsoft.com"
    try {
        Invoke-WebRequest -Uri $testUrl -TimeoutSec 5 | Out-Null
        Write-Host "网络连接正常" -ForegroundColor Green
    } catch {
        Write-Host "无法连接到互联网: $_" -ForegroundColor Red
    }
}

# 添加帮助函数
function global:Show-CustomFunctionsHelp {
    Write-Host "自定义函数模块帮助：" -ForegroundColor Cyan
    Write-Host "  Update-Profile           - 更新并重新加载 PowerShell 配置文件"
    Write-Host "  Test-NetworkConnection   - 测试网络连接"
    Write-Host "  Test-ProfileUpdate       - 检查配置文件是否有可用更新"
}

# 添加自动更新检查功能
function global:Test-ProfileUpdate {
    Write-Host "正在检查配置文件更新..." -ForegroundColor Cyan
    $repoPath = Split-Path $PROFILE
    if (Test-Path (Join-Path $repoPath ".git")) {
        try {
            $status = git -C $repoPath status -uno
            if ($status -match "Your branch is behind") {
                Write-Host "PowerShell 配置文件有可用更新。运行 Update-Profile 来更新。" -ForegroundColor Yellow
            } else {
                Write-Host "PowerShell 配置文件已是最新版本。" -ForegroundColor Green
            }
        } catch {
            Write-Warning "检查更新失败: $_"
        }
    } else {
        Write-Warning "配置文件目录不是 Git 仓库，无法检查更新。"
    }
}
