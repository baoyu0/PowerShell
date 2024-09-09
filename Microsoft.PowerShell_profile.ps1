# 主题部分
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\1_shell.omp.json" | Invoke-Expression

function Set-PoshTheme {
    param (
        [string]$ThemeName
    )
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\$ThemeName.omp.json" | Invoke-Expression
}

# 智能预测
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -Colors @{ InlinePrediction = '#666666' }
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# 设置PSModuleHistory变量
$global:PSModuleHistory = 'S'

# 启用第三方模块
$ModulesToImport = @('Terminal-Icons', 'PSReadLine', 'Microsoft.WinGet.CommandNotFound')

foreach ($module in $ModulesToImport) {
    if (Get-Module -ListAvailable -Name $module) {
        Import-Module $module
    } else {
        Write-Warning "模块 '$module' 不可用。请运行 Install-RequiredModules 函数安装。"
    }
}

# 快捷键设置
Set-PSReadLineKeyHandler -Chord "Ctrl+w" -Function BackwardDeleteWord
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key "Ctrl+z" -Function Undo
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key 'Ctrl+l' -Function ClearScreen
Set-PSReadLineKeyHandler -Chord 'Ctrl+,' -ScriptBlock {
    notepad $PROFILE
}

# 代理设置
function Toggle-Proxy {
    $httpPort = 20001
    $socksPort = 20000
    if ($env:http_proxy) {
        $env:http_proxy = $null
        $env:https_proxy = $null
        $env:SOCKS_SERVER = $null
        Write-Host "代理已关闭"
    } else {
        $env:http_proxy = "http://127.0.0.1:$httpPort"
        $env:https_proxy = "http://127.0.0.1:$httpPort"
        $env:SOCKS_SERVER = "socks5://127.0.0.1:$socksPort"
        Write-Host "代理已开启"
    }
}

# Scoop代理设置
# scoop config proxy 127.0.0.1:20000

# Winget tab自动补全
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
    $Local:word = $wordToComplete.Replace('"', '""')
    $Local:ast = $commandAst.ToString().Replace('"', '""')
    winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# Chocolatey配置
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# PowerToys CommandNotFound模块
Import-Module -Name Microsoft.WinGet.CommandNotFound

# 实用函数
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function Edit-Profile {
    if (Test-Path $PROFILE) {
        Write-Host "正在打开配置文件进行编辑..." -ForegroundColor Cyan
        Start-Process notepad $PROFILE -Wait
        Write-Host "配置文件编辑完成。请重新加载配置文件以应用更改。" -ForegroundColor Green
        Write-Host "可以使用 '. $PROFILE' 命令重新加载。" -ForegroundColor Green
    } else {
        Write-Host "配置文件不存在。正在创建新的配置文件..." -ForegroundColor Yellow
        New-Item -Path $PROFILE -ItemType File -Force
        Start-Process notepad $PROFILE -Wait
        Write-Host "新的配置文件已创建并打开进行编辑。" -ForegroundColor Green
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
        Write-Host "获取系统信息时出错：$($_.Exception.Message)" -ForegroundColor Red
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
    Write-Warning "别名 'goto' 已存在，未设置新别名。"
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
            Write-Host "正在安装模块: $module" -ForegroundColor Yellow
            Install-Module -Name $module -Force -Scope CurrentUser
        }
    }
}

# 运行安装函数
Install-RequiredModules

function Install-OhMyPosh {
    if (!(Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Host "正在安装 Oh My Posh..." -ForegroundColor Yellow
        winget install JanDeDobbeleer.OhMyPosh -s winget
    }
}

# 运行安装函数
Install-OhMyPosh

function Install-PackageManagers {
    # 检查并安装 Scoop
    if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "正在安装 Scoop..." -ForegroundColor Yellow
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    }

    # 检查并安装 Chocolatey
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "正在安��� Chocolatey..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
}

# 运行安装函数
Install-PackageManagers

function Update-PowerShellProfile {
    $githubUrl = "https://raw.githubusercontent.com/baoyu0/PowerShell/main/Microsoft.PowerShell_profile.ps1"
    $localPath = $PROFILE
    $lastCheckFile = Join-Path $env:TEMP "LastProfileUpdateCheck.txt"

    # 检查是否需要更新（每24小时检查一次）
    if (Test-Path $lastCheckFile) {
        $lastCheck = Get-Content $lastCheckFile
        if ($lastCheck -and (Get-Date) - [DateTime]::Parse($lastCheck) -lt (New-TimeSpan -Hours 24)) {
            Write-Host "今天已经检查过更新。跳过检查。" -ForegroundColor Cyan
            return
        }
    }

    try {
        # 获取GitHub上的最新内容
        $latestContent = Invoke-WebRequest -Uri $githubUrl -UseBasicParsing | Select-Object -ExpandProperty Content

        # 获取本地文件内容
        $localContent = Get-Content -Path $localPath -Raw

        # 比较内容
        if ($latestContent -ne $localContent) {
            Write-Host "发现新版本的配置文件。正在更新..." -ForegroundColor Yellow
            $latestContent | Set-Content -Path $localPath -Force
            Write-Host "配置文件已更新。请重新加载配置文件以应用更改。" -ForegroundColor Green
            Write-Host "可以使用 '. $PROFILE' 命令重新加载。" -ForegroundColor Green
        } else {
            Write-Host "配置文件已是最新版本。" -ForegroundColor Green
        }
    } catch {
        Write-Host "更新配置文件时出错：$($_.Exception.Message)" -ForegroundColor Red
    }

    # 更新最后检查时间
    Get-Date -Format "yyyy-MM-dd HH:mm:ss" | Out-File $lastCheckFile
}

# 在配置文件加载时检查更新
Update-PowerShellProfile

# 添加一个函数来手动触发更新
function Update-Profile {
    Update-PowerShellProfile
    if (Test-Path $PROFILE) {
        . $PROFILE
    } else {
        Write-Host "配置文件不存在。" -ForegroundColor Red
    }
}

function Show-ProfileMenu {
    $options = @(
        @{Symbol="🔄"; Name="强制检查更新"; Action={Update-Profile}},
        @{Symbol="👀"; Name="查看当前配置文件"; Action={Show-Profile}},
        @{Symbol="✏️"; Name="编辑配置文件"; Action={Edit-Profile}},
        @{Symbol="🌐"; Name="切换代理"; Action={Toggle-Proxy}},
        @{Symbol="💻"; Name="查看系统信息"; Action={Get-SystemInfo}},
        @{Symbol="🚀"; Name="执行PowerShell命令"; Action={Invoke-CustomCommand}},
        @{Symbol="📁"; Name="快速导航"; Action={Navigate-QuickAccess}},
        @{Symbol="🔧"; Name="安装/更新工具"; Action={Manage-Tools}},
        @{Symbol="❌"; Name="退出菜单"; Action={return $true}}
    )

    function Draw-Menu {
        Clear-Host
        Write-Host "╔═════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║     PowerShell 配置文件管理菜单     ║" -ForegroundColor Cyan
        Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
        for ($i = 0; $i -lt $options.Count; $i++) {
            Write-Host ("[{0}] {1} {2}" -f ($i+1), $options[$i].Symbol, $options[$i].Name) -ForegroundColor Yellow
        }
        Write-Host "══════════════════════════════════════" -ForegroundColor Cyan
    }

    function Invoke-CustomCommand {
        $commonCommands = @(
            @{Name="查看当前目录内容"; Command="Get-ChildItem"},
            @{Name="查看系统信息"; Command="Get-ComputerInfo"},
            @{Name="查看网络连接"; Command="Get-NetAdapter"},
            @{Name="查看进程"; Command="Get-Process"},
            @{Name="查看服务"; Command="Get-Service"},
            @{Name="自定义命令"; Command=$null}
        )

        Write-Host "常用PowerShell命令：" -ForegroundColor Cyan
        for ($i = 0; $i -lt $commonCommands.Count; $i++) {
            Write-Host ("[{0}] {1}" -f ($i+1), $commonCommands[$i].Name) -ForegroundColor Yellow
        }

        $choice = Read-Host "请选择要执行的命令 (1-$($commonCommands.Count))"
        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $commonCommands.Count) {
            $selectedCommand = $commonCommands[[int]$choice - 1]
            if ($selectedCommand.Command -eq $null) {
                $command = Read-Host "请输入要执行的PowerShell命令"
            } else {
                $command = $selectedCommand.Command
            }

            try {
                Write-Host "执行命令: $command" -ForegroundColor Cyan
                Invoke-Expression $command
            } catch {
                Write-Host "执行命令时出错：$($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "无效的选择。" -ForegroundColor Red
        }
        Read-Host "按 Enter 键返回菜单"
    }

    function Navigate-QuickAccess {
        $locations = @("Desktop", "Documents", "Downloads", "自定义路径")
        $choice = Show-Menu "选择要导航的位置" $locations
        switch ($choice) {
            {$_ -in 0..2} { Set-CommonLocation $locations[$_] }
            3 { 
                $path = Read-Host "请输入自定义路径"
                if (Test-Path $path) {
                    Set-Location $path
                } else {
                    Write-Host "路径不存在" -ForegroundColor Red
                }
            }
        }
        Write-Host "当前位置：$(Get-Location)" -ForegroundColor Green
        Read-Host "按 Enter 键返回菜单"
    }

    function Manage-Tools {
        $tools = @(
            @{Name="Oh My Posh"; Action={Install-OhMyPosh}},
            @{Name="Terminal-Icons"; Action={Install-Module Terminal-Icons -Force -Scope CurrentUser}},
            @{Name="PSReadLine"; Action={Install-Module PSReadLine -Force -Scope CurrentUser}},
            @{Name="Scoop"; Action={Install-Scoop}},
            @{Name="Chocolatey"; Action={Install-Chocolatey}},
            @{Name="返回主菜单"; Action={return}}
        )

        do {
            Clear-Host
            Write-Host "安装/更新工具" -ForegroundColor Cyan
            Write-Host "================" -ForegroundColor Cyan
            for ($i = 0; $i -lt $tools.Count; $i++) {
                Write-Host ("[{0}] {1}" -f ($i+1), $tools[$i].Name) -ForegroundColor Yellow
            }
            Write-Host "================" -ForegroundColor Cyan
            $choice = Read-Host "请选择要安装/更新的工具 (1-$($tools.Count))"

            if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $tools.Count) {
                $selectedTool = $tools[[int]$choice - 1]
                if ($selectedTool.Name -eq "返回主菜单") {
                    return
                }
                Write-Host "正在安装/更新 $($selectedTool.Name)..." -ForegroundColor Cyan
                try {
                    & $selectedTool.Action
                    Write-Host "$($selectedTool.Name) 安装/更新完成。" -ForegroundColor Green
                } catch {
                    Write-Host "安装/更新 $($selectedTool.Name) 时出错：$($_.Exception.Message)" -ForegroundColor Red
                }
                Read-Host "按 Enter 键继续"
            } else {
                Write-Host "无效的选择。" -ForegroundColor Red
                Read-Host "按 Enter 键继续"
            }
        } while ($true)
    }

    function Show-Menu($title, $options) {
        Write-Host $title -ForegroundColor Cyan
        for ($i = 0; $i -lt $options.Count; $i++) {
            Write-Host ("[{0}] {1}" -f ($i+1), $options[$i]) -ForegroundColor Yellow
        }
        $choice = Read-Host "请输入您的选择"
        return [int]$choice - 1
    }

    do {
        Draw-Menu
        $choice = Read-Host "请输入您的选择 (1-$($options.Count))"
        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $options.Count) {
            $result = & $options[[int]$choice - 1].Action
            if ($result -is [bool] -and $result) {
                break
            }
            if ($choice -ne $options.Count) {  # 如果不是退出选项
                Read-Host "按 Enter 键返回菜单"
            }
        } else {
            Write-Host "无效的选择，请重试。" -ForegroundColor Red
            Read-Host "按 Enter 键继续"
        }
    } while ($true)
}

# 在配置文件末尾直接调用菜单函数
Show-ProfileMenu
