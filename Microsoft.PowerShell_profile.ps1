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
        Write-Log "模块 '$module' 不可用。请运行 Install-RequiredModules 函数安装。" -Level Warning
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
    $proxyPort = 20000

    function Show-ProxyStatus {
        if ($env:http_proxy) {
            Write-Host "当前网络代理状态: 已开启" -ForegroundColor Green
            Write-Host "HTTP 代理: $env:http_proxy" -ForegroundColor Cyan
            Write-Host "SOCKS 代理: $env:SOCKS_SERVER" -ForegroundColor Cyan
        } else {
            Write-Host "当前网络代理状态: 已关闭" -ForegroundColor Yellow
        }
    }

    function Enable-Proxy {
        $env:http_proxy = "http://127.0.0.1:$proxyPort"
        $env:https_proxy = "http://127.0.0.1:$proxyPort"
        $env:SOCKS_SERVER = "socks5://127.0.0.1:$proxyPort"
        Write-Log "代理已开启" -Level Info
        Show-ProxyStatus
    }

    function Disable-Proxy {
        $env:http_proxy = $null
        $env:https_proxy = $null
        $env:SOCKS_SERVER = $null
        Write-Log "代理已关闭" -Level Info
        Show-ProxyStatus
    }

    # 初始化时自动开启代理
    if (-not $env:http_proxy) {
        Enable-Proxy
    }

    do {
        Clear-Host
        Write-Host "网络代理设置" -ForegroundColor Cyan
        Write-Host "================" -ForegroundColor Cyan
        Show-ProxyStatus
        Write-Host "================" -ForegroundColor Cyan
        Write-Host "1. 开启网络代理" -ForegroundColor Yellow
        Write-Host "2. 关闭网络代理" -ForegroundColor Yellow
        Write-Host "0. 返回主菜单" -ForegroundColor Yellow
        Write-Host "================" -ForegroundColor Cyan
        $choice = Read-Host "请选择操作 (0-2)"

        switch ($choice) {
            "1" { Enable-Proxy }
            "2" { Disable-Proxy }
            "0" { return }
            default { Write-Log "无效的选择，请重试。" -Level Warning }
        }

        if ($choice -ne "0") {
            Read-Host "按 Enter 键继续"
        }
    } while ($choice -ne "0")
}

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
    Write-Log "Chocolatey 安装/更新完成。" -Level Info
}

function Update-PowerShellProfile {
    $githubUrl = "https://raw.githubusercontent.com/baoyu0/PowerShell/main/Microsoft.PowerShell_profile.ps1"
    $localPath = $PROFILE
    $lastCheckFile = Join-Path $env:TEMP "LastProfileUpdateCheck.txt"

    # 检查是否需要更新（每24小时检查一次）
    if (Test-Path $lastCheckFile) {
        $lastCheck = Get-Content $lastCheckFile
        if ($lastCheck -and (Get-Date) - [DateTime]::Parse($lastCheck) -lt (New-TimeSpan -Hours 24)) {
            Write-Log "今天已经检查过更新。跳过检查。" -Level Info
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
            Write-Log "发现新版本的配置文件。正在更新..." -Level Info
            $latestContent | Set-Content -Path $localPath -Force
            Write-Log "配置文件已更新。请重新加载配置文件以应用更改。" -Level Info
            Write-Log "可以使用 '. $PROFILE' 命令重新加载。" -Level Info
        } else {
            Write-Log "配置文件已是最新版本。" -Level Info
        }
    } catch {
        Write-Log "更新配置文件时出错：$($_.Exception.Message)" -Level Error
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
        Write-Log "配置文件不存在。" -Level Warning
    }
}

function Show-ProfileMenu {
    $options = @(
        @{Symbol="❌"; Name="退出菜单"; Action={return $true}},
        @{Symbol="🔄"; Name="强制检查更新"; Action={Update-Profile}},
        @{Symbol="👀"; Name="查看当前配置文件"; Action={Show-Profile}},
        @{Symbol="✏️"; Name="编辑配置文件"; Action={Edit-Profile}},
        @{Symbol="🌐"; Name="切换代理"; Action={Toggle-Proxy}},
        @{Symbol="🚀"; Name="执行PowerShell命令"; Action={Invoke-CustomCommand}},
        @{Symbol="📁"; Name="快速导航"; Action={Navigate-QuickAccess}},
        @{Symbol="🔧"; Name="安装/更新工具"; Action={Manage-Tools}}
    )

    function Draw-Menu {
        Clear-Host
        $width = 50
        $title = "PowerShell 配置文件管理菜单"
        
        Write-Host ("╔" + "═" * ($width - 2) + "╗") -ForegroundColor Cyan
        Write-Host ("║" + " " * [Math]::Floor(($width - $title.Length - 2) / 2) + $title + " " * [Math]::Ceiling(($width - $title.Length - 2) / 2) + "║") -ForegroundColor Cyan
        Write-Host ("╠" + "═" * ($width - 2) + "╣") -ForegroundColor Cyan
        
        Write-Host ("║ [0] " + $options[0].Symbol + " " + $options[0].Name.PadRight($width - 8) + "║") -ForegroundColor Yellow
        for ($i = 1; $i -lt $options.Count; $i++) {
            Write-Host ("║ [{0}] {1} {2}" -f $i, $options[$i].Symbol, $options[$i].Name.PadRight($width - 8) + "║") -ForegroundColor Yellow
        }
        
        Write-Host ("╚" + "═" * ($width - 2) + "╝") -ForegroundColor Cyan
    }

    function Invoke-CustomCommand {
        $commonCommands = @(
            @{Name="返回上一级菜单"; Command=$null},
            @{Name="查看当前目录内容"; Command="Get-ChildItem"},
            @{Name="查看系统信息"; Command={Get-SystemInfo}},
            @{Name="查看网络连接"; Command="Get-NetAdapter"},
            @{Name="查看进程"; Command="Get-Process"},
            @{Name="查看服务"; Command="Get-Service"},
            @{Name="自定义命令"; Command=$null}
        )

        Write-Host "常用PowerShell命令：" -ForegroundColor Cyan
        for ($i = 0; $i -lt $commonCommands.Count; $i++) {
            Write-Host ("[{0}] {1}" -f $i, $commonCommands[$i].Name) -ForegroundColor Yellow
        }

        $choice = Read-Host "请选择要执行的命令 (0-$($commonCommands.Count - 1))"
        if ($choice -match '^\d+$' -and [int]$choice -ge 0 -and [int]$choice -lt $commonCommands.Count) {
            $selectedCommand = $commonCommands[[int]$choice]
            if ($choice -eq "0") {
                return  # 返回上一级菜单
            } elseif ($selectedCommand.Command -eq $null) {
                $command = Read-Host "请输入要执行的PowerShell命令"
            } else {
                $command = $selectedCommand.Command
            }

            try {
                Write-Host "执行命令: $($selectedCommand.Name)" -ForegroundColor Cyan
                if ($command -is [scriptblock]) {
                    & $command
                } else {
                    Invoke-Expression $command | Out-Host
                }
            } catch {
                Write-Host "执行命令时出错：$($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "无效的选择。" -ForegroundColor Red
        }
        if ($choice -ne "0") {
            Read-Host "按 Enter 键返回菜单"
        }
    }

    function Navigate-QuickAccess {
        $locations = @("Desktop", "Documents", "Downloads", "自定义路径")
        $choice = Show-Menu "选择要导航的置" $locations
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
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        function Set-PSGallery {
            if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            }
            $currentUrl = (Get-PSRepository -Name PSGallery).SourceLocation
            $correctUrl = 'https://www.powershellgallery.com/api/v2'
            if ($currentUrl -ne $correctUrl) {
                Register-PSRepository -Default -ErrorAction SilentlyContinue
                Register-PSRepository -Name PSGallery -SourceLocation $correctUrl -InstallationPolicy Trusted -ErrorAction SilentlyContinue
            }
        }

        Set-PSGallery

        if ($env:http_proxy) {
            [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($env:http_proxy)
        }

        function Update-AllTools {
            param (
                [int]$Timeout = 300  # 默认超时时间为5分钟
            )

            function Show-StepProgress {
                param (
                    [string]$StepName,
                    [scriptblock]$Action
                )
                Write-Host "开始: $StepName" -ForegroundColor Cyan
                $startTime = Get-Date
                & $Action
                $endTime = Get-Date
                $duration = $endTime - $startTime
                Write-Host "完成: $StepName (耗时: $($duration.ToString('mm\:ss')))" -ForegroundColor Green
            }

            Write-Host "正在检查所有工具的更新..." -ForegroundColor Yellow
            $updatesAvailable = $false

            Show-StepProgress "检查 Oh My Posh 更新" {
                $currentVersion = (oh-my-posh --version).Trim()
                $latestVersion = (winget show JanDeDobbeleer.OhMyPosh | Select-String "版本" | Select-Object -First 1).ToString().Split()[-1]
                if ($currentVersion -ne $latestVersion) {
                    Write-Host "Oh My Posh 有可用更新：$currentVersion -> $latestVersion" -ForegroundColor Green
                    $script:updatesAvailable = $true
                }
            }

            $modules = @('Terminal-Icons', 'PSReadLine')
            foreach ($module in $modules) {
                Show-StepProgress "检查 $module 更新" {
                    $currentModule = Get-Module -Name $module -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
                    $onlineModule = Find-Module -Name $module
                    if ($currentModule.Version -lt $onlineModule.Version) {
                        Write-Host "$module 有可用更新：$($currentModule.Version) -> $($onlineModule.Version)" -ForegroundColor Green
                        $script:updatesAvailable = $true
                    }
                }
            }

            Show-StepProgress "检查 Scoop 更新" {
                $scoopOutput = scoop update 2>&1
                $scoopStatus = scoop status
                if ($scoopStatus -match "Updates are available") {
                    $updatesAvailable = $scoopStatus | Where-Object { $_ -match '^\S+\s+:\s+\S+\s+->\s+\S+$' }
                    if ($updatesAvailable) {
                        Write-Host "Scoop 有可用更新：" -ForegroundColor Green
                        $updatesAvailable | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
                        $script:updatesAvailable = $true
                    }
                } else {
                    Write-Host "Scoop 已是最新版本。" -ForegroundColor Green
                }
            }

            Show-StepProgress "检查 Chocolatey 更新" {
                $chocoOutdated = choco outdated
                if ($chocoOutdated -notmatch "All packages are up-to-date") {
                    Write-Host "Chocolatey 有可用更新：" -ForegroundColor Green
                    $chocoOutdated | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
                    $script:updatesAvailable = $true
                }
            }

            Show-StepProgress "检查 Winget 更新" {
                $wingetUpdates = winget upgrade | Where-Object {$_ -match '^\S+\s+\S+\s+\S+\s+Available'}
                if ($wingetUpdates) {
                    Write-Host "Winget 有可用更新：" -ForegroundColor Green
                    $wingetUpdates | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
                    $script:updatesAvailable = $true
                }
            }

            if ($updatesAvailable) {
                $confirm = Read-Host "发现可用更新。是否要更新所有工具？(Y/N)"
                if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                    Show-StepProgress "更新 Oh My Posh" {
                        winget upgrade JanDeDobbeleer.OhMyPosh
                    }

                    foreach ($module in $modules) {
                        Show-StepProgress "更新 $module" {
                            if ($module -eq 'PSReadLine') {
                                Write-Host "PSReadLine 需要手动更新。请在 PowerShell 重启后运行以下命令：" -ForegroundColor Cyan
                                Write-Host "Install-Module PSReadLine -Force -Scope CurrentUser" -ForegroundColor Cyan
                            } else {
                                Update-Module -Name $module -Force
                            }
                        }
                    }

                    Show-StepProgress "更新 Scoop" {
                        scoop update *
                    }

                    Show-StepProgress "更新 Chocolatey" {
                        choco upgrade all -y
                    }

                    Show-StepProgress "更新 Winget" {
                        $wingetUpdates = winget upgrade | Where-Object {$_ -match '^\S+\s+\S+\s+\S+\s+Available'}
                        if ($wingetUpdates) {
                            $updateCount = ($wingetUpdates | Measure-Object).Count
                            Write-Host "发现 $updateCount 个可更新的软件包。" -ForegroundColor Cyan
                            $currentUpdate = 0
                            foreach ($update in $wingetUpdates) {
                                $currentUpdate++
                                $packageId = ($update -split '\s+')[0]
                                Write-Progress -Activity "更新 Winget 软件包" -Status "正在更新 $packageId ($currentUpdate / $updateCount)" -PercentComplete (($currentUpdate / $updateCount) * 100)
                                winget upgrade $packageId --accept-source-agreements
                            }
                            Write-Progress -Activity "更新 Winget 软件包" -Completed
                        } else {
                            Write-Host "所有 Winget 软件包都是最新的。" -ForegroundColor Green
                        }
                    }

                    Write-Host "所有工具更新完成！" -ForegroundColor Green
                } else {
                    Write-Host "更新已取消。" -ForegroundColor Yellow
                }
            } else {
                Write-Host "所有工具都是最新的。" -ForegroundColor Green
            }
        }

        $tools = @(
            @{Name="返回主菜单"; Action={return}},
            @{Name="检查并更新所有工具"; Action={Update-AllTools}},
            @{Name="Oh My Posh"; Action={Install-OhMyPosh}},
            @{Name="Terminal-Icons"; Action={
                try {
                    Install-Package Terminal-Icons -Force -Scope CurrentUser -ErrorAction Stop
                } catch {
                    Write-Host "通过 PowerShell Gallery 安装失败，尝试通过 GitHub 安装..." -ForegroundColor Yellow
                    $tempDir = Join-Path $env:TEMP "Terminal-Icons"
                    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
                    git clone https://github.com/devblackops/Terminal-Icons.git $tempDir
                    Import-Module "$tempDir\Terminal-Icons.psd1" -Force
                    Write-Host "Terminal-Icons 已从 GitHub 安装并导入。" -ForegroundColor Green
                }
            }},
            @{Name="PSReadLine"; Action={
                try {
                    $currentVersion = (Get-Module PSReadLine).Version
                    $latestVersion = (Find-Module PSReadLine).Version
                    if ($currentVersion -lt $latestVersion) {
                        Write-Host "当前版本: $currentVersion" -ForegroundColor Yellow
                        Write-Host "最新版本: $latestVersion" -ForegroundColor Green
                        Write-Host "PSReadLine 需要更新。请在 PowerShell 重启后运行以下命令：" -ForegroundColor Cyan
                        Write-Host "Install-Module PSReadLine -Force -Scope CurrentUser" -ForegroundColor Cyan
                    } else {
                        Write-Host "PSReadLine 已是最新版本 ($currentVersion)。" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "检查 PSReadLine 版本时出错：$($_.Exception.Message)" -ForegroundColor Red
                }
            }},
            @{Name="Chocolatey"; Action={Install-Chocolatey}},
            @{Name="Scoop 自动更新程序"; Action={
                Write-Host "正在更新 Scoop bucket..." -ForegroundColor Yellow
                $scoopOutput = scoop update 2>&1
                Write-Host "正在检查 Scoop 可用更新..." -ForegroundColor Yellow
                $updates = scoop status | Where-Object { $_ -match '^\S+\s+:\s+\S+\s+->\s+\S+$' }
                if ($updates) {
                    Write-Host "发现以下可用更新：" -ForegroundColor Cyan
                    $updates | ForEach-Object { Write-Host $_ -ForegroundColor Green }
                    $confirm = Read-Host "是否要更新这些软件包？(Y/N)"
                    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                        Write-Host "正在更新软件包，这可能需要一些时间..." -ForegroundColor Yellow
                        $updateCount = ($updates | Measure-Object).Count
                        $currentUpdate = 0
                        foreach ($update in $updates) {
                            $currentUpdate++
                            $packageId = ($update -split '\s+')[0]
                            Write-Progress -Activity "更新 Scoop 软件包" -Status "正在更新 $packageId" -PercentComplete (($currentUpdate / $updateCount) * 100)
                            scoop update $packageId *>&1 | Out-Null
                        }
                        Write-Progress -Activity "更新 Scoop 软件包" -Completed
                        Write-Host "更新完成！" -ForegroundColor Green
                    } else {
                        Write-Host "更新已取消。" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "所有 Scoop 软件包都是最新的。" -ForegroundColor Green
                }
            }},
            @{Name="Winget 自动更新程序"; Action={
                Write-Host "正在检查可用更新..." -ForegroundColor Yellow
                $updates = winget upgrade | Where-Object {$_ -match '^\S+\s+\S+\s+\S+\s+Available'}
                if ($updates) {
                    Write-Host "发现以下可用更新：" -ForegroundColor Cyan
                    $updates | ForEach-Object { Write-Host $_ -ForegroundColor Green }
                    $confirm = Read-Host "是否要更新这些软件包？(Y/N)"
                    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                        Write-Host "正在更新软件包，这可能需要一些时间..." -ForegroundColor Yellow
                        $updateCount = ($updates | Measure-Object).Count
                        $currentUpdate = 0
                        foreach ($update in $updates) {
                            $currentUpdate++
                            $packageId = ($update -split '\s+')[0]
                            Write-Progress -Activity "更新 Winget 软件包" -Status "正在更新 $packageId" -PercentComplete (($currentUpdate / $updateCount) * 100)
                            winget upgrade $packageId --accept-source-agreements
                        }
                        Write-Progress -Activity "更新 Winget 软件包" -Completed
                        Write-Host "更新完成！" -ForegroundColor Green
                    } else {
                        Write-Host "更新已取消。" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "所有软件包都是最新的。" -ForegroundColor Green
                }
            }}
        )

        do {
            Clear-Host
            $width = 50
            $title = "安装/更新工具"
            
            Write-Host ("╔" + "═" * ($width - 2) + "╗") -ForegroundColor Cyan
            Write-Host ("║" + " " * [Math]::Floor(($width - $title.Length - 2) / 2) + $title + " " * [Math]::Ceiling(($width - $title.Length - 2) / 2) + "║") -ForegroundColor Cyan
            Write-Host ("╠" + "═" * ($width - 2) + "╣") -ForegroundColor Cyan
            
            Write-Host ("║ [0] 返回主菜单".PadRight($width - 1) + "║") -ForegroundColor Yellow
            for ($i = 1; $i -lt $tools.Count; $i++) {
                Write-Host ("║ [{0}] {1}" -f $i, $tools[$i].Name.PadRight($width - 6) + "║") -ForegroundColor Yellow
            }
            
            Write-Host ("╚" + "═" * ($width - 2) + "╝") -ForegroundColor Cyan
            
            $choice = Read-Host "`n请选择要安装/更新的工具 (0-$($tools.Count - 1))"

            if ($choice -match '^\d+$' -and [int]$choice -ge 0 -and [int]$choice -lt $tools.Count) {
                $selectedTool = $tools[[int]$choice]
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
        $choice = Read-Host "请输入您的选择 (0-$($options.Count - 1))，或输入 'q' 退出"
        if ($choice -eq 'q' -or $choice -eq '0') {
            break
        }
        if ($choice -match '^\d+$' -and [int]$choice -ge 0 -and [int]$choice -lt $options.Count) {
            Clear-Host
            Write-Host ("`n执行: " + $options[[int]$choice].Name) -ForegroundColor Cyan
            Write-Host ("=" * ($options[[int]$choice].Name.Length + 8)) -ForegroundColor Cyan
            $result = & $options[[int]$choice].Action
            if ($result -is [bool] -and $result) {
                break
            }
            if ($choice -ne '0') {  # 如果不是退出选项
                Write-Host "`n"
                Read-Host "按 Enter 键返回菜单"
            }
        } else {
            Write-Host "`n无效的选择，请重试。" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    } while ($true)
}

# 在配置文件末尾直接调用菜单函数
Show-ProfileMenu

Write-Host "提示：您可以随时输入 'Show-ProfileMenu' 来再次打开配文件管理菜单。" -ForegroundColor Cyan

# 为 Show-ProfileMenu 创建别名 's'
Set-Alias -Name s -Value Show-ProfileMenu

Write-Host "提示：您可以随时输入 's' 来打开配置文件管理菜单。" -ForegroundColor Cyan

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

# 确保在动时开启代理
if (-not $env:http_proxy) {
    $proxyPort = 20000
    $env:http_proxy = "http://127.0.0.1:$proxyPort"
    $env:https_proxy = "http://127.0.0.1:$proxyPort"
    $env:SOCKS_SERVER = "socks5://127.0.0.1:$proxyPort"
    Write-Host "已自动开启网络代理" -ForegroundColor Green
}

# 在配置文件的开头添加：
$modulesPath = Join-Path $PSScriptRoot "Modules"
if (Test-Path $modulesPath) {
    Get-ChildItem $modulesPath -Filter "*.psm1" | ForEach-Object {
        Import-Module $_.FullName -Force
    }
}

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

function Check-UpdateCache {
    $cacheFile = Join-Path $env:TEMP "PowerShellProfileUpdateCache.json"
    $cacheExpiration = 24 # 小时

    if (Test-Path $cacheFile) {
        $cache = Get-Content $cacheFile | ConvertFrom-Json
        if ((Get-Date) - [DateTime]::Parse($cache.LastCheck) -lt (New-TimeSpan -Hours $cacheExpiration)) {
            return $cache.NeedsUpdate
        }
    }

    $needsUpdate = Update-PowerShellProfile
    @{
        LastCheck = Get-Date -Format "o"
        NeedsUpdate = $needsUpdate
    } | ConvertTo-Json | Set-Content $cacheFile

    return $needsUpdate
}

function Add-PathVariable {
    param (
        [string]$Path
    )
    if ($env:PATH -notlike "*$Path*") {
        $env:PATH += ";$Path"
        Write-Log "已将 $Path 添加到 PATH 环境变量" -Level Info
    } else {
        Write-Log "$Path 已经在 PATH 环境变量中" -Level Warning
    }
}

function prompt {
    $location = Get-Location
    $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    $promptString = "PS $location"
    if ($gitBranch) {
        $promptString += " [$gitBranch]"
    }
    $promptString += "> "
    return $promptString
}

function prompt {
    $location = Get-Location
    $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    $promptString = "PS $location"
    if ($gitBranch) {
        $promptString += " [$gitBranch]"
    }
    $promptString += "> "
    return $promptString
}

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

function Check-UpdateCache {
    $cacheFile = Join-Path $env:TEMP "PowerShellProfileUpdateCache.json"
    $cacheExpiration = 24 # 小时

    if (Test-Path $cacheFile) {
        $cache = Get-Content $cacheFile | ConvertFrom-Json
        if ((Get-Date) - [DateTime]::Parse($cache.LastCheck) -lt (New-TimeSpan -Hours $cacheExpiration)) {
            return $cache.NeedsUpdate
        }
    }

    $needsUpdate = Update-PowerShellProfile
    @{
        LastCheck = Get-Date -Format "o"
        NeedsUpdate = $needsUpdate
    } | ConvertTo-Json | Set-Content $cacheFile

    return $needsUpdate
}

function Add-PathVariable {
    param (
        [string]$Path
    )
    if ($env:PATH -notlike "*$Path*") {
        $env:PATH += ";$Path"
        Write-Log "已将 $Path 添加到 PATH 环境变量" -Level Info
    } else {
        Write-Log "$Path 已经在 PATH 环境变量中" -Level Warning
    }
}

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
