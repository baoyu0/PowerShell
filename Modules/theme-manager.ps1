# 主题管理模块

$global:configFile = if ($env:USERPROFILE) {
    Join-Path $env:USERPROFILE ".powershell_theme_config.json"
} else {
    Write-Warning "无法获取用户配置文件路径，将使用当前目录。"
    ".\.powershell_theme_config.json"
}

# 确保 Save-ThemeConfig 和 Load-ThemeConfig 是全局函数
function global:Save-ThemeConfig {
    if (-not $global:configFile) {
        Write-Error "配置文件路径未定义"
        return
    }
    $config = @{
        Theme = $script:currentTheme
        PromptStyle = $script:currentPromptStyle
    }
    $config | ConvertTo-Json | Set-Content -Path $global:configFile
    Write-Host "主题配置已保存到 $global:configFile" -ForegroundColor Green
}

function global:Load-ThemeConfig {
    if (-not $global:configFile) {
        Write-Error "配置文件路径未定义"
        return
    }
    if (Test-Path $global:configFile) {
        $config = Get-Content -Path $global:configFile | ConvertFrom-Json
        if ($config.Theme -ne $script:currentTheme) {
            Set-PowerShellTheme $config.Theme
        }
        if ($config.PromptStyle -ne $script:currentPromptStyle) {
            Set-CustomPrompt $config.PromptStyle
        }
    } else {
        Write-Warning "主题配置文件不存在，将使用默认设置。"
        Set-PowerShellTheme "Default"
        Set-CustomPrompt "Default"
    }
}

# 定义一些预设的颜色主题
$global:themes = @{
    "Default" = @{
        Background = "Black"
        Foreground = "White"
        ErrorForeground = "Red"
        WarningForeground = "Yellow"
        VerboseForeground = "Cyan"
    }
    "Light" = @{
        Background = "White"
        Foreground = "Black"
        ErrorForeground = "DarkRed"
        WarningForeground = "DarkYellow"
        VerboseForeground = "DarkCyan"
    }
    "Solarized" = @{
        Background = "Black"
        Foreground = "Green"
        ErrorForeground = "Red"
        WarningForeground = "Yellow"
        VerboseForeground = "Cyan"
    }
}

# 当前主题
$script:currentTheme = "Default"
$script:currentPromptStyle = "Default"

# 设置主题
function global:Set-PowerShellTheme {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Default", "Light", "Solarized")]
        [string]$ThemeName
    )

    if ($ThemeName -eq $script:currentTheme -and -not $PSBoundParameters.ContainsKey('Verbose')) {
        return
    }

    try {
        $theme = $global:themes[$ThemeName]
        if ($null -eq $theme) {
            throw "主题 '$ThemeName' 未定义"
        }

        $Host.UI.RawUI.BackgroundColor = [System.ConsoleColor]$theme.Background
        $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]$theme.Foreground
        $Host.PrivateData.ErrorForegroundColor = [System.ConsoleColor]$theme.ErrorForeground
        $Host.PrivateData.WarningForegroundColor = [System.ConsoleColor]$theme.WarningForeground
        $Host.PrivateData.VerboseForegroundColor = [System.ConsoleColor]$theme.VerboseForeground

        $script:currentTheme = $ThemeName
        Save-ThemeConfig
        Write-Host "已成功应用并保存 $ThemeName 主题" -ForegroundColor Green
    
        # 刷新控制台颜色
        [Console]::Clear()
    } catch {
        Write-Error "设置主题时出错: $_"
    }
}

# 获取当前主题
function global:Get-CurrentTheme {
    Write-Host "当前主题: $script:currentTheme" -ForegroundColor Cyan
}

# 自定义提示符样式
function global:Set-CustomPrompt {
    param (
        [Parameter(Mandatory=$false)]
        [ValidateSet("Default", "Minimal", "Informative")]
        [string]$Style = "Default"
    )

    if ($Style -eq $script:currentPromptStyle -and -not $PSBoundParameters.ContainsKey('Verbose')) {
        return
    }

    switch ($Style) {
        "Default" {
            function global:prompt {
                $location = Get-Location
                "PS $location> "
            }
        }
        "Minimal" {
            function global:prompt {
                "$([char]0x03BB) "
            }
        }
        "Informative" {
            function global:prompt {
                $location = Get-Location
                $time = Get-Date -Format "HH:mm:ss"
                $user = $env:USERNAME
                $host = $env:COMPUTERNAME
                Write-Host "[$time] " -NoNewline -ForegroundColor Yellow
                Write-Host "$user@$host" -NoNewline -ForegroundColor Green
                Write-Host " $location" -ForegroundColor Cyan
                return "$ "
            }
        }
    }

    $script:currentPromptStyle = $Style
    Save-ThemeConfig
    Write-Host "已设置并保存 $Style 提示符样式" -ForegroundColor Green
}

# 修改模块帮助信息函数
function global:Show-ThemeManagerHelp {
    Write-Host "主题管理模块帮助：" -ForegroundColor Cyan
    Write-Host "  Set-PowerShellTheme <ThemeName> - 设置 PowerShell 主题 (可选: Default, Light, Solarized)"
    Write-Host "  Get-CurrentTheme               - 显示当前使用的主题"
    Write-Host "  Set-CustomPrompt <Style>       - 设置提示符样式 (可选: Default, Minimal, Informative)"
    Write-Host "  Get-AvailableThemes            - 列出所有可用的主题及其详细信息"
}

# 初始化默认主题和提示符，但不显示信息
Set-PowerShellTheme "Default" | Out-Null
Set-CustomPrompt "Default" | Out-Null

# 初始化时加载保存的配置，但不显示信息
Load-ThemeConfig | Out-Null

# 在文件的适当位置添加以下函数

function global:Get-AvailableThemes {
    Write-Host "可用的主题：" -ForegroundColor Cyan
    foreach ($themeName in $global:themes.Keys) {
        $theme = $global:themes[$themeName]
        Write-Host "  $themeName" -ForegroundColor Green
        Write-Host "    背景色: $($theme.Background)"
        Write-Host "    前景色: $($theme.Foreground)"
        Write-Host "    错误文本颜色: $($theme.ErrorForeground)"
        Write-Host "    警告文本颜色: $($theme.WarningForeground)"
        Write-Host "    详细信息文本颜色: $($theme.VerboseForeground)"
        Write-Host ""
    }
}
