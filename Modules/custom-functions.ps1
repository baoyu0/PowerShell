# 自定义函数

# 更新 PowerShell 配置文件
function Update-Profile {
    $profilePath = $PROFILE
    $backupPath = "$profilePath.backup"
    
    # 备份当前配置文件
    Copy-Item $profilePath $backupPath

    # 从远程仓库获取最新版本（假设您使用Git管理配置文件）
    git -C (Split-Path $profilePath) pull

    # 重新加载配置文件
    . $PROFILE

    Write-Host "配置文件已更新并重新加载。如需恢复，请使用备份文件：$backupPath" -ForegroundColor Green
}

# 网络连接测试
function Test-NetworkConnection {
    $testUrl = "https://www.microsoft.com"
    try {
        Invoke-WebRequest -Uri $testUrl -UseBasicParsing -TimeoutSec 5 | Out-Null
        Write-Host "网络连接正常" -ForegroundColor Green
    } catch {
        Write-Host "无法连接到互联网" -ForegroundColor Red
    }
}

# 添加帮助函数
function global:Show-CustomFunctionsHelp {
    Write-Host "自定义函数模块帮助：" -ForegroundColor Cyan
    Write-Host "  Update-Profile        - 更新并重新加载 PowerShell 配置文件"
    Write-Host "  Test-NetworkConnection - 测试网络连接"
}
