# 核心设置
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# 其他核心设置...

function prompt {
    $envName = $env:CONDA_DEFAULT_ENV
    $envPrefix = if ($envName) { "($envName) " } else { "" }
    $location = $PWD.Path
    $promptChar = '>' * ($nestedPromptLevel + 1)
    
    "${envPrefix}PS ${location}${promptChar} "
}

function global:Show-CoreSettingsHelp {
    Write-Host "核心设置模块帮助：" -ForegroundColor Cyan
    Write-Host "  设置 PSReadLine 选项"
    Write-Host "  定义自定义提示符"
    # 添加更多核心设置的描述
}
