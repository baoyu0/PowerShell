# 主题管理模块

$global:configFile = if ($env:USERPROFILE) {
    Join-Path $env:USERPROFILE ".powershell_theme_config.json"
} else {
    Write-Warning "无法获取用户配置文件路径，将使用当前目录。"
    Join-Path $PSScriptRoot ".powershell_theme_config.json"
}

# 确保 Save-ThemeConfig 和 Import-ThemeConfig 是全局函数
function Save-ThemeConfig {
    if (-not $global:configFile) {
        Write-Error "配置文件路径未定义"
        return
    }
    try {
        $config = @{
            Theme = $script:currentTheme
            PromptStyle = $script:currentPromptStyle
        }
        $config | ConvertTo-Json | Set-Content -Path $global:configFile -ErrorAction Stop
        Write-Host "主题配置已保存到 $global:configFile" -ForegroundColor Green
    } catch {
        Write-Error "保存主题配置时出错: $_"
    }
}

function Import-ThemeConfig {
    if (-not $global:configFile) {
        Write-Error "配置文件路径未定义"
        return
    }
    if (Test-Path $global:configFile) {
        try {
            $config = Get-Content -Path $global:configFile | ConvertFrom-Json
            if ($null -ne $config.Theme -and $config.Theme -ne $script:currentTheme) {
                Set-PowerShellTheme $config.Theme
            }
            if ($null -ne $config.PromptStyle -and $config.PromptStyle -ne $script:currentPromptStyle) {
                Set-CustomPrompt $config.PromptStyle
            }
        } catch {
            Write-Error "加载主题配置时出错: $_"
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
function Set-PowerShellTheme {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Default", "Light", "Solarized")]
        [string]$ThemeName
    )

    if ($ThemeName -eq $script:currentTheme -and -not $PSBoundParameters.ContainsKey('Verbose')) {
        return
    }

    if ($global:themes.ContainsKey($ThemeName)) {
        # 应用主题设置（具体实现视环境而定）
        Write-Host "应用主题: $ThemeName" -ForegroundColor Green
        $script:currentTheme = $ThemeName
        Save-ThemeConfig
    } else {
        Write-Warning "未定义的主题: $ThemeName"
    }
}

# 设置自定义提示符
function Set-CustomPrompt {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Default", "Minimal", "Informative")]
        [string]$Style
    )

    if ($Style -eq $script:currentPromptStyle -and -not $PSBoundParameters.ContainsKey('Verbose')) {
        return
    }

    switch ($Style) {
        "Default" {
            function prompt {
                $location = Get-Location
                "PS $location> "
            }
        }
        "Minimal" {
            function prompt {
                "$([char]0x03BB) "
            }
        }
        "Informative" {
            function prompt {
                $location = Get-Location
                $time = Get-Date -Format "HH:mm:ss"
                $user = $env:USERNAME
                $computerName = $env:COMPUTERNAME  # 使用 $computerName 替代 $host
                Write-Host "[$time] " -NoNewline -ForegroundColor Yellow
                Write-Host "$user@$computerName" -NoNewline -ForegroundColor Green
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
function Show-ThemeManagerHelp {
    Write-Host "主题管理模块帮助：" -ForegroundColor Cyan
    Write-Host "  Set-PowerShellTheme <ThemeName>   - 设置 PowerShell 主题"
    Write-Host "  Set-CustomPrompt <Style>          - 设置提示符样式"
    Write-Host "  Save-ThemeConfig                  - 保存当前主题配置"
    Write-Host "  Import-ThemeConfig                - 导入主题配置"
}

# 初始化时导入配置
Import-ThemeConfig
