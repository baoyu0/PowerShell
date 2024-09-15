function .. { Set-Location .. }
function ... { Set-Location ..\.. }

function Edit-Profile {
    if (Test-Path $PROFILE) {
        Write-Log "正在打开配置文件进行编辑..." -Level Info
        Start-Process notepad $PROFILE -Wait
        Write-Log "配置文件编辑完成。请重新加载配置文件以应用更改。" -Level Info
        Write-Log "可以使用 '. $PROFILE' 命令重新加载。" -Level Info
    } else {
        Write-Log "配置文件不存在。正在创建新的配置文件..." -Level Warning
        New-Item -Path $PROFILE -ItemType File -Force
        Start-Process notepad $PROFILE -Wait
        Write-Log "新的配置文件已创建并打开进行编辑。" -Level Info
    }
}

function Show-Profile {
    Write-Host "当前配置文件内容：" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Get-Content $PROFILE | ForEach-Object {
        if ($_ -match '^function') {
            Write-Host $_ -ForegroundColor Yellow
        } elseif ($_ -match '^#') {
            Write-Host $_ -ForegroundColor Green
        } else {
            Write-Host $_
        }
    }
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "配置文件路径：$PROFILE" -ForegroundColor Cyan
}

function Find-File {
    param (
        [string]$name,
        [int]$depth = -1
    )
    Get-ChildItem -Recurse -Depth $depth -Filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        $place = $_.Directory
        Write-Output "${place}\$_"
    }
}

function Get-FolderSize {
    param (
        [string]$folder = "."
    )
    $folderSize = (Get-ChildItem $folder -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Output ("{0:N2} MB" -f $folderSize)
}

function New-File($name) {
    New-Item -Path $name -ItemType File
}

function Open-Explorer {
    param([string]$path = ".")
    explorer.exe $path
}

function Get-SystemInfo {
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop
        $ram = Get-CimInstance -ClassName Win32_PhysicalMemory -ErrorAction Stop | Measure-Object -Property Capacity -Sum

        Write-Host "操作系统：" $os.Caption
        Write-Host "CPU：" $cpu.Name
        Write-Host "内存：" ("{0:N2} GB" -f ($ram.Sum / 1GB))
    } catch {
        Write-Log "获取系统信息时出错：$($_.Exception.Message)" -Level Error
    }
}

function Set-CommonLocation {
    param (
        [ValidateSet("Desktop", "Documents", "Downloads")]
        [string]$Destination
    )
    
    switch ($Destination) {
        "Desktop" { Set-Location "$env:USERPROFILE\Desktop" }
        "Documents" { Set-Location "$env:USERPROFILE\Documents" }
        "Downloads" { Set-Location "$env:USERPROFILE\Downloads" }
    }
}

if (!(Get-Command goto -ErrorAction SilentlyContinue)) {
    Set-Alias -Name goto -Value Set-CommonLocation
} else {
    Write-Log "别名 'goto' 已存在，未设置新别名。" -Level Warning
}

function Install-Package {
    param (
        [string]$PackageName,
        [ValidateSet("winget", "scoop", "choco")]
        [string]$PackageManager = "winget"
    )

    switch ($PackageManager) {
        "winget" { winget install $PackageName }
        "scoop" { scoop install $PackageName }
        "choco" { choco install $PackageName -y }
    }
}

function Show-Welcome {
    Write-Host "欢迎使用PowerShell！当前时间：" (Get-Date) -ForegroundColor Cyan
    Write-Host "输入 'Get-Command' 查看所有可用命令。" -ForegroundColor Yellow
}

Show-Welcome

# 新增函数来安装必要的模块
function Install-RequiredModules {
    $requiredModules = @('Terminal-Icons', 'PSReadLine', 'Microsoft.WinGet.CommandNotFound')
    foreach ($module in $requiredModules) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            Write-Log "正在安装模块: $module" -Level Info
            Install-Module -Name $module -Force -Scope CurrentUser
        }
    }
}

# 运行安装函数
Install-RequiredModules

function Install-OhMyPosh {
    if (!(Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Log "正在安装 Oh My Posh..." -Level Info
        winget install JanDeDobbeleer.OhMyPosh -s winget
    }
}

# 运行安装函数
Install-OhMyPosh

function Install-Scoop {
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Log "正在安装 Scoop..." -Level Info
        try {
            Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        } catch {
            Write-Log "安装 Scoop 时出错：$($_.Exception.Message)" -Level Error
            return
        }
    } else {
        Write-Log "Scoop 已安装，正在更新..." -Level Info
        scoop update
    }
    Write-Log "Scoop 安装/更新完成。" -Level Info
}

function Install-Chocolatey {
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Log "正在安装 Chocolatey..." -Level Info
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        } catch {
            Write-Log "安装 Chocolatey 时出错：$($_.Exception.Message)" -Level Error
            return
        }
    } else {
        Write-Log "Chocolatey 已安装，正在更新..." -Level Info
        choco upgrade chocolatey -y
    }
}

function Show-UpdateProgress {
    param (
        [string]$Action,
        [scriptblock]$ScriptBlock
    )
    $spinner = "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"
    $spinnerIndex = 0
    $job = Start-Job -ScriptBlock $ScriptBlock

    while ($job.State -eq "Running") {
        Write-Host "`r$($spinner[$spinnerIndex]) $Action" -NoNewline -ForegroundColor Cyan
        $spinnerIndex = ($spinnerIndex + 1) % $spinner.Length
        Start-Sleep -Milliseconds 100
    }

    $result = Receive-Job -Job $job
    Remove-Job -Job $job

    Write-Host "`r✔️ $Action 完成" -ForegroundColor Green
    $result | Out-Host
}

# 确保启动时开启代理
if (-not $env:http_proxy) {
    $proxyPort = $config.ProxyPort
    $env:http_proxy = "http://127.0.0.1:$proxyPort"
    $env:https_proxy = "http://127.0.0.1:$proxyPort"
    $env:SOCKS_SERVER = "socks5://127.0.0.1:$proxyPort"
    Write-Host "已自动开启网络代理" -ForegroundColor Green
}

# 国际化支持
$messages = @{
    "zh-CN" = @{
        "WelcomeMessage" = "欢迎使用 PowerShell！当前时间："
        "CommandHint" = "输入 'Get-Command' 查看所有可用命令。"
    }
    "en-US" = @{
        "WelcomeMessage" = "Welcome to PowerShell! Current time:"
        "CommandHint" = "Type 'Get-Command' to see all available commands."
    }
}

$currentCulture = (Get-Culture).Name
$currentMessages = $messages[$currentCulture]
if (-not $currentMessages) {
    $currentMessages = $messages["en-US"]
}

function Show-Welcome {
    Write-Host $currentMessages.WelcomeMessage (Get-Date) -ForegroundColor Cyan
    Write-Host $currentMessages.CommandHint -ForegroundColor Yellow
}

Show-Welcome

# 插件系统
$pluginsPath = Join-Path $PSScriptRoot "Plugins"
if (Test-Path $pluginsPath) {
    Get-ChildItem $pluginsPath -Filter "*.ps1" | ForEach-Object {
        . $_.FullName
    }
}

# 添加单元测试
function Test-ProfileFunctions {
    $testResults = @()

    # 测试 Add-PathVariable 函数
    $testPath = "C:\TestPath"
    Add-PathVariable -Path $testPath
    $testResults += @{
        Name = "Add-PathVariable"
        Result = $env:PATH -like "*$testPath*"
    }

    # 测试 Write-Log 函数
    $testMessage = "Test log message"
    $output = Write-Log $testMessage -Level Info
    $testResults += @{
        Name = "Write-Log"
        Result = $output -like "*$testMessage*"
    }

    # 输出测试结果
    $testResults | ForEach-Object {
        if ($_.Result) {
            Write-Host "测试通过: $($_.Name)" -ForegroundColor Green
        } else {
            Write-Host "测试失败: $($_.Name)" -ForegroundColor Red
        }
    }
}

# 运行测试
Test-ProfileFunctions

# 创建 README.md
$readmePath = Join-Path $PSScriptRoot "README.md"
if (-not (Test-Path $readmePath)) {
    @"
# PowerShell 配置文件

这是一个功能丰富的 PowerShell 配置文件，包含以下特性：

- 自动代理设置
- 常用工具安装和更新
- 自定义提示符
- 插件系统
- 国际化支持
- 单元测试

## 安装

1. 克隆此仓库到您的 PowerShell 配置文件目录
2. 在 PowerShell 中运行 `. $PROFILE` 以加载配置

## 使用

- 使用 `Show-ProfileMenu` 或别名 `s` 打开配置文件管理菜单
- 使用 `Update-Profile` 手动更新配置文件

## 贡献

欢迎提交 Pull Requests 来改进此配置文件。

## 许可

MIT License
"@ | Set-Content $readmePath
}

# 性能优化
$sw = [System.Diagnostics.Stopwatch]::StartNew()

# ... 在这里放置您的主要代码 ...

$sw.Stop()
$elapsedMs = $sw.ElapsedMilliseconds
Write-Log "配置文件加载耗时: ${elapsedMs}ms" -Level Info

# 清理未使用的代码
# 请手动检查并删除任何未使用的函数或变量

# 更新通知系统
$lastUpdateCheck = Get-Date
function Check-ProfileUpdate {
    $currentDate = Get-Date
    if (($currentDate - $lastUpdateCheck).TotalHours -ge 24) {
        $needsUpdate = Update-PowerShellProfile
        if ($needsUpdate) {
            Write-Host "发现新版本的配置文件。请运行 Update-Profile 来更新。" -ForegroundColor Yellow
        }
        $script:lastUpdateCheck = $currentDate
    }
}

# 在每次加载配置文件时检查更新
Check-ProfileUpdate

Write-Host "配置文件加载完成。输入 's' 或 'Show-ProfileMenu' 打开配置文件管理菜单。" -ForegroundColor Cyan

# 环境变量管理
function Set-EnvVar {
    param (
        [string]$Name,
        [string]$Value,
        [ValidateSet('User', 'Machine')]
        [string]$Scope = 'User'
    )
    [System.Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
    Set-Item -Path "Env:$Name" -Value $Value
}

function Add-PathVariable {
    param (
        [string]$Path
    )
    $env:PATH = "$Path;$env:PATH"
}

# 更新通知
function Check-UpdateCache {
    $updateCheckInterval = $config.UpdateCheckInterval
    $lastUpdateCheck = Get-Date (Get-Content $updateCachePath) -ErrorAction SilentlyContinue
    if (-not $lastUpdateCheck -or ((Get-Date) - $lastUpdateCheck).TotalHours -ge $updateCheckInterval) {
        $updateCache = @{
            LastUpdateCheck = (Get-Date).ToString()
            NeedsUpdate = $false
        }
        $updateCache | ConvertTo-Json | Set-Content $updateCachePath
        return $true
    }
    return $false
}

function Update-PowerShellProfile {
    $updateCachePath = Join-Path $PSScriptRoot "update_cache.json"
    $updateCache = Get-Content $updateCachePath | ConvertFrom-Json
    $updateCache.NeedsUpdate = $true
    $updateCache | ConvertTo-Json | Set-Content $updateCachePath
    return $updateCache.NeedsUpdate
}

# 清理重复代码
function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = "Info"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $colorMap = @{
        "Info" = "White"
        "Warning" = "Yellow"
        "Error" = "Red"
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $colorMap[$Level]
}

# 安全性
function Confirm-Action {
    param (
        [string]$Message,
        [switch]$YesToAll
    )
    if ($YesToAll) {
        return $true
    }
    $confirmation = Read-Host "$Message (Y/N)"
    return $confirmation -eq "Y"
}

# 代理设置
function Get-ProxySettings {
    $proxySettings = @{}
    $proxySettings.Enabled = $env:http_proxy -ne $null
    $proxySettings.HttpProxy = $env:http_proxy
    $proxySettings.HttpsProxy = $env:https_proxy
    $proxySettings.SocksProxy = $env:SOCKS_SERVER
    return $proxySettings
}

function Set-ProxySettings {
    param (
        [switch]$Enable,
        [switch]$Disable,
        [string]$HttpProxy,
        [string]$HttpsProxy,
        [string]$SocksProxy
    )
    if ($Enable) {
        $env:http_proxy = $HttpProxy
        $env:https_proxy = $HttpsProxy
        $env:SOCKS_SERVER = $SocksProxy
    } elseif ($Disable) {
        $env:http_proxy = $null
        $env:https_proxy = $null
        $env:SOCKS_SERVER = $null
    }
}

# 帮助文档
function Get-Help {
    param (
        [string]$Command
    )
    Get-Help $Command -Full
}

# 主菜单
function Show-ProfileMenu {
    $width = 60
    $title = "PowerShell 配置文件管理菜单"
    
    $horizontalLine = "─" * ($width - 2)
    $topBorder    = "┌$horizontalLine┐"
    $bottomBorder = "└$horizontalLine┘"
    $middleBorder = "├$horizontalLine┤"

    Write-Host $topBorder -ForegroundColor Cyan
    $titlePadded = $title.PadLeft([Math]::Floor(($width + $title.Length) / 2)).PadRight($width - 2)
    Write-Host "│$titlePadded│" -ForegroundColor Cyan
    Write-Host $middleBorder -ForegroundColor Cyan
    
    $options = @(
        "返回 PowerShell",
        "编辑配置文件",
        "显示配置文件内容",
        "查找文件",
        "获取文件夹大小",
        "新建文件",
        "打开资源管理器",
        "获取系统信息",
        "设置常用位置",
        "安装软件包",
        "安装必要模块",
        "安装 Oh My Posh",
        "安装 Scoop",
        "安装 Chocolatey",
        "切换网络代理",
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

function Edit-Profile {
    if (Test-Path $PROFILE) {
        Write-Log "正在打开配置文件进行编辑..." -Level Info
        Start-Process notepad $PROFILE -Wait
        Write-Log "配置文件编辑完成。请重新加载配置文件以应用更改。" -Level Info
        Write-Log "可以使用 '. $PROFILE' 命令重新加载。" -Level Info
    } else {
        Write-Log "配置文件不存在。正在创建新的配置文件..." -Level Warning
        New-Item -Path $PROFILE -ItemType File -Force
        Start-Process notepad $PROFILE -Wait
        Write-Log "新的配置文件已创建并打开进行编辑。" -Level Info
    }
}

function Show-Profile {
    Write-Host "当前配置文件内容：" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Get-Content $PROFILE | ForEach-Object {
        if ($_ -match '^function') {
            Write-Host $_ -ForegroundColor Yellow
        } elseif ($_ -match '^#') {
            Write-Host $_ -ForegroundColor Green
        } else {
            Write-Host $_
        }
    }
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "配置文件路径：$PROFILE" -ForegroundColor Cyan
}

function Find-File {
    param (
        [string]$name,
        [int]$depth = -1
    )
    Get-ChildItem -Recurse -Depth $depth -Filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        $place = $_.Directory
        Write-Output "${place}\$_"
    }
}

function Get-FolderSize {
    param (
        [string]$folder = "."
    )
    $folderSize = (Get-ChildItem $folder -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Output ("{0:N2} MB" -f $folderSize)
}

function New-File($name) {
    New-Item -Path $name -ItemType File
}

function Open-Explorer {
    param([string]$path = ".")
    explorer.exe $path
}

function Get-SystemInfo {
    try {
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop
        $ram = Get-CimInstance -ClassName Win32_PhysicalMemory -ErrorAction Stop | Measure-Object -Property Capacity -Sum

        Write-Host "操作系统：" $os.Caption
        Write-Host "CPU：" $cpu.Name
        Write-Host "内存：" ("{0:N2} GB" -f ($ram.Sum / 1GB))
    } catch {
        Write-Log "获取系统信息时出错：$($_.Exception.Message)" -Level Error
    }
}

function Set-CommonLocation {
    param (
        [ValidateSet("Desktop", "Documents", "Downloads")]
        [string]$Destination
    )
    
    switch ($Destination) {
        "Desktop" { Set-Location "$env:USERPROFILE\Desktop" }
        "Documents" { Set-Location "$env:USERPROFILE\Documents" }
        "Downloads" { Set-Location "$env:USERPROFILE\Downloads" }
    }
}

function Install-Package {
    param (
        [string]$PackageName,
        [ValidateSet("winget", "scoop", "choco")]
        [string]$PackageManager = "winget"
    )

    switch ($PackageManager) {
        "winget" { winget install $PackageName }
        "scoop" { scoop install $PackageName }
        "choco" { choco install $PackageName -y }
    }
}

function Show-Welcome {
    Write-Host "欢迎使用PowerShell！当前时间：" (Get-Date) -ForegroundColor Cyan
    Write-Host "输入 'Get-Command' 查看所有可用命令。" -ForegroundColor Yellow
}

function Install-RequiredModules {
    $requiredModules = @('Terminal-Icons', 'PSReadLine', 'Microsoft.WinGet.CommandNotFound')
    foreach ($module in $requiredModules) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            Write-Log "正在安装模块: $module" -Level Info
            Install-Module -Name $module -Force -Scope CurrentUser
        }
    }
}

function Set-EnvVar {
    param (
        [string]$Name,
        [string]$Value,
        [ValidateSet('User', 'Machine')]
        [string]$Scope = 'User'
    )
    [System.Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
    Set-Item -Path "Env:$Name" -Value $Value
}

function Show-UpdateProgress {
    param (
        [string]$Action,
        [scriptblock]$ScriptBlock
    )
    $spinner = "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"
    $spinnerIndex = 0
    $job = Start-Job -ScriptBlock $ScriptBlock

    while ($job.State -eq "Running") {
        Write-Host "`r$($spinner[$spinnerIndex]) $Action" -NoNewline -ForegroundColor Cyan
        $spinnerIndex = ($spinnerIndex + 1) % $spinner.Length
        Start-Sleep -Milliseconds 100
    }

    $result = Receive-Job -Job $job
    Remove-Job -Job $job

    Write-Host "`r✔️ $Action 完成" -ForegroundColor Green
    $result | Out-Host
}

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = "Info"
    )
}