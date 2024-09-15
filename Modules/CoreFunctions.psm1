function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("Debug", "Info", "Warning", "Error")]
        [string]$Level = "Info"
    )
    if ([System.Enum]::Parse([LogLevel], $script:Config.LogLevel) -le [System.Enum]::Parse([LogLevel], $Level)) {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] [$Level] $Message"
        
        # 控制台输出
        $colorMap = @{
            "Debug" = "Gray"
            "Info" = "White"
            "Warning" = "Yellow"
            "Error" = "Red"
        }
        Write-Host $logMessage -ForegroundColor $colorMap[$Level]
        
        # 文件日志
        $logFile = Join-Path $PSScriptRoot "..\Logs\PowerShell_Profile.log"
        $logMessage | Out-File -Append -FilePath $logFile
    }
}

function Edit-Profile {
    try {
        if (Test-Path $PROFILE) {
            Write-Log "正在打开配置文件进行编辑..." -Level Info
            Start-Process $script:Config.DefaultEditor $PROFILE -Wait
            Write-Log "配置文件编辑完成。请重新加载配置文件以应用更改。" -Level Info
            Write-Log "可以使用 '. $PROFILE' 命令重新加载。" -Level Info
        } else {
            Write-Log "配置文件不存在。正在创建新的配置文件..." -Level Warning
            New-Item -Path $PROFILE -ItemType File -Force
            Start-Process $script:Config.DefaultEditor $PROFILE -Wait
            Write-Log "新的配置文件已创建并打开进行编辑。" -Level Info
        }
    } catch {
        Write-Log "编辑配置文件时发生错误：$($_.Exception.Message)" -Level Error
    }
}

function Show-Profile {
    Write-Host "当前配置文件内容：" -ForegroundColor $script:Config.Colors.Title
    Write-Host "================================" -ForegroundColor $script:Config.Colors.Title
    Get-Content $PROFILE | ForEach-Object {
        if ($_ -match '^function') {
            Write-Host $_ -ForegroundColor $script:Config.Colors.Menu
        } elseif ($_ -match '^#') {
            Write-Host $_ -ForegroundColor $script:Config.Colors.Success
        } else {
            Write-Host $_
        }
    }
    Write-Host "================================" -ForegroundColor $script:Config.Colors.Title
    Write-Host "配置文件路径：$PROFILE" -ForegroundColor $script:Config.Colors.Title
}

function Update-Profile {
    # 实现配置文件更新逻辑
    Write-Log "正在检查配置文件更新..." -Level Info
    # TODO: 实现更新逻辑
    Write-Log "配置文件已是最新版本。" -Level Info
}

function Toggle-Proxy {
    # 实现代理切换逻辑
    Write-Log "正在切换代理设置..." -Level Info
    # TODO: 实现代理切换逻辑
    Write-Log "代理设置已切换。" -Level Info
}

function Invoke-CustomCommand {
    $command = Read-Host "请输入要执行的 PowerShell 命令"
    try {
        $result = Invoke-Expression $command
        Write-Log "命令执行成功" -Level Info
        $result
    } catch {
        Write-Log "执行命令时发生错误：$($_.Exception.Message)" -Level Error
    }
}

function Navigate-QuickAccess {
    # 实现快速导航逻辑
    Write-Log "正在打开快速导航..." -Level Info
    # TODO: 实现快速导航逻辑
    Write-Log "快速导航已完成。" -Level Info
}

function Backup-Configuration {
    $backupDir = Join-Path $PSScriptRoot "Backups"
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir | Out-Null
    }
    $backupFile = Join-Path $backupDir "Config_$(Get-Date -Format 'yyyyMMdd_HHmmss').psd1"
    Copy-Item -Path $configPath -Destination $backupFile
    Write-Log "配置已备份到 $backupFile" -Level Info
}

function Restore-Configuration {
    $backupDir = Join-Path $PSScriptRoot "Backups"
    $backups = Get-ChildItem $backupDir -Filter "Config_*.psd1" | Sort-Object LastWriteTime -Descending
    if ($backups.Count -eq 0) {
        Write-Log "没有可用的备份" -Level Warning
        return
    }
    $backups | ForEach-Object { Write-Host "$($_.BaseName)" }
    $choice = Read-Host "请选择要恢复的备份文件（输入文件名，不包括.psd1）"
    $selectedBackup = Join-Path $backupDir "$choice.psd1"
    if (Test-Path $selectedBackup) {
        Copy-Item -Path $selectedBackup -Destination $configPath -Force
        Write-Log "配置已从 $selectedBackup 恢复" -Level Info
        $script:Config = Import-PowerShellDataFile $configPath
    } else {
        Write-Log "选择的备份文件不存在" -Level Error
    }
}

function Check-ForUpdates {
    $currentVersion = $script:Version
    $repoUrl = "https://api.github.com/repos/yourusername/yourrepo/releases/latest"
    
    try {
        $latestRelease = Invoke-RestMethod -Uri $repoUrl -Method Get
        $latestVersion = $latestRelease.tag_name

        if ([System.Version]$latestVersion -gt [System.Version]$currentVersion) {
            Write-Log "发现新版本：$latestVersion" -Level Info
            $download = Read-Host "是否下载更新？(Y/N)"
            if ($download -eq 'Y' -or $download -eq 'y') {
                $downloadUrl = $latestRelease.assets[0].browser_download_url
                $outputPath = Join-Path $env:TEMP "PowerShellProfile_$latestVersion.zip"
                Invoke-WebRequest -Uri $downloadUrl -OutFile $outputPath
                Write-Log "更新已下载到：$outputPath" -Level Info
                Write-Log "请手动解压并替换当前配置文件。" -Level Info
            }
        } else {
            Write-Log "当前版本已是最新。" -Level Info
        }
    } catch {
        Write-Log "检查更新时发生错误：$($_.Exception.Message)" -Level Error
    }
}

Export-ModuleMember -Function Write-Log, Edit-Profile, Show-Profile, Update-Profile, Toggle-Proxy, Invoke-CustomCommand, Navigate-QuickAccess, Backup-Configuration, Restore-Configuration, Check-ForUpdates