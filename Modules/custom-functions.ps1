# 自定义函数

# 更新 PowerShell 配置文件
function global:Update-Profile {
    $profilePath = $PROFILE
    $backupPath = "$profilePath.backup"
    
    # 备份当前配置文件
    Copy-Item $profilePath $backupPath

    # 检查是否是 Git 仓库
    if (Test-Path (Join-Path (Split-Path $profilePath) ".git")) {
        # 从远程仓库获取最新版本
        try {
            git -C (Split-Path $profilePath) pull
            Write-Host "配置文件已从 Git 仓库更新" -ForegroundColor Green
        } catch {
            Write-Warning "从 Git 仓库更新失败: $_"
            Write-Host "请手动更新您的配置文件" -ForegroundColor Yellow
        }
    } else {
        Write-Warning "配置文件目录不是 Git 仓库，无法自动更新"
    }

    # 重新加载配置文件
    . $PROFILE

    Write-Host "配置文件已重新加载。如需恢复，请使用备份文件：$backupPath" -ForegroundColor Green
}

# 网络连接测试
function global:Test-NetworkConnection {
    $testUrl = "https://www.microsoft.com"
    try {
        Invoke-WebRequest -Uri $testUrl -UseBasicParsing -TimeoutSec 5 | Out-Null
        Write-Host "网络连接正常" -ForegroundColor Green
    } catch {
        Write-Host "无法连接到互联网: $_" -ForegroundColor Red
    }
}

# 添加帮助函数
function global:Show-CustomFunctionsHelp {
    Write-Host "自定义函数模块帮助：" -ForegroundColor Cyan
    Write-Host "  Update-Profile        - 更新并重新加载 PowerShell 配置文件"
    Write-Host "  Test-NetworkConnection - 测试网络连接"
}
