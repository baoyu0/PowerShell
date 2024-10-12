# 核心设置
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# 其他核心设置...

function global:Show-CoreSettingsHelp {
    Write-Host "核心设置模块帮助：" -ForegroundColor Cyan
    Write-Host "  设置 PSReadLine 选项"
    # 添加更多核心设置的描述
}
