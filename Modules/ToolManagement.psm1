<#
.SYNOPSIS
    工具管理模块
.DESCRIPTION
    本模块提供了一系列用于管理和更新各种开发工具的函数。
.NOTES
    版本：1.1
    作者：Your Name
    最后更新：2023-05-11
#>

using module .\UIHelpers.psm1
using module .\CoreFunctions.psm1

function Show-ToolManagement {
    $tools = @(
        @{Name="返回上级菜单"; Action={return}}
        @{Name="更新所有工具"; Action={Update-AllTools}}
        @{Name="Oh My Posh"; Action={Install-OhMyPosh}}
        @{Name="Terminal-Icons"; Action={Install-Module -Name Terminal-Icons -Force}}
        @{Name="PSReadLine"; Action={Install-Module -Name PSReadLine -Force}}
        @{Name="Chocolatey"; Action={Install-Chocolatey}}
        @{Name="Scoop"; Action={Install-Scoop}}
        @{Name="Winget"; Action={Update-Winget}}
    )

    do {
        Clear-Host
        $width = 60
        $title = "工具管理"
        
        $horizontalLine = "─" * ($width - 2)
        $topBorder    = "┌$horizontalLine┐"
        $bottomBorder = "└$horizontalLine┘"

        Write-Host $topBorder -ForegroundColor Cyan
        Write-Host "│" -NoNewline -ForegroundColor Cyan
        Write-Host $title.PadLeft([math]::Floor(($width + $title.Length) / 2)).PadRight($width - 2) -NoNewline
        Write-Host "│" -ForegroundColor Cyan
        Write-Host "├$horizontalLine┤" -ForegroundColor Cyan

        for ($i = 0; $i -lt $tools.Count; $i++) {
            $option = "│ [$i] $($tools[$i].Name)".PadRight($width - 1) + "│"
            Write-Host $option -ForegroundColor Yellow
        }

        Write-Host $bottomBorder -ForegroundColor Cyan

        $choice = Read-Host "`n请选择要安装/更新的工具 (0-$($tools.Count - 1))"
        if ($choice -match '^\d+$' -and [int]$choice -ge 0 -and [int]$choice -lt $tools.Count) {
            if ($choice -eq 0) { return }
            Clear-Host
            Write-Host "正在执行：$($tools[$choice].Name)" -ForegroundColor Cyan
            & $tools[$choice].Action
            if ($choice -ne 0) { 
                Write-Host "`n操作完成。" -ForegroundColor Green
                Read-Host "按 Enter 键继续"
            }
        } else {
            Write-Host "无效的选择，请重试。" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    } while ($true)
}

function Update-AllTools {
    $tools = @(
        @{Name="Oh My Posh"; Action={Update-OhMyPosh}},
        @{Name="Terminal-Icons"; Action={Update-TerminalIcons}},
        @{Name="PSReadLine"; Action={Update-PSReadLine}},
        @{Name="Chocolatey"; Action={Update-Chocolatey}},
        @{Name="Scoop"; Action={Update-Scoop}},
        @{Name="Winget"; Action={Update-Winget}}
    )

    Write-Host "正在更新所有工具..." -ForegroundColor Yellow
    foreach ($tool in $tools) {
        Write-Host "正在更新 $($tool.Name)..." -ForegroundColor Cyan
        try {
            & $tool.Action
            Write-Host "$($tool.Name) 更新成功" -ForegroundColor Green
        } catch {
            Write-Host "更新 $($tool.Name) 时发生错误：$($_.Exception.Message)" -ForegroundColor Red
        }
    }
    Write-Host "所有工具更新完成。" -ForegroundColor Green
}

function Install-OhMyPosh {
    <#
    .SYNOPSIS
        安装或更新 Oh My Posh
    .DESCRIPTION
        该函数使用 winget 安装或更新 Oh My Posh。
    .EXAMPLE
        Install-OhMyPosh
    #>
    try {
        winget install JanDeDobbeleer.OhMyPosh -s winget
        Write-Host "Oh My Posh 安装/更新成功。" -ForegroundColor Green
    }
    catch {
        Write-Host "安装/更新 Oh My Posh 时发生错误：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Install-PowerShell7 {
    <#
    .SYNOPSIS
        安装或更新 PowerShell 7
    .DESCRIPTION
        该函数使用 winget 安装或更新 PowerShell 7。
    .EXAMPLE
        Install-PowerShell7
    #>
    try {
        winget install --id Microsoft.Powershell --source winget
        Write-Host "PowerShell 7 安装/更新成功。" -ForegroundColor Green
    }
    catch {
        Write-Host "安装/更新 PowerShell 7 时发生错误：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Install-Git {
    <#
    .SYNOPSIS
        安装或更新 Git
    .DESCRIPTION
        该函数使用 winget 安装或更新 Git。
    .EXAMPLE
        Install-Git
    #>
    try {
        winget install --id Git.Git --source winget
        Write-Host "Git 安装/更新成功。" -ForegroundColor Green
    }
    catch {
        Write-Host "安装/更新 Git 时发生错误：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Install-VSCode {
    <#
    .SYNOPSIS
        安装或更新 Visual Studio Code
    .DESCRIPTION
        该函数使用 winget 安装或更新 Visual Studio Code。
    .EXAMPLE
        Install-VSCode
    #>
    try {
        winget install --id Microsoft.VisualStudioCode --source winget
        Write-Host "Visual Studio Code 安装/更新成功。" -ForegroundColor Green
    }
    catch {
        Write-Host "安装/更新 Visual Studio Code 时发生错误：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Install-WindowsTerminal {
    <#
    .SYNOPSIS
        安装或更新 Windows Terminal
    .DESCRIPTION
        该函数使用 winget 安装或更新 Windows Terminal。
    .EXAMPLE
        Install-WindowsTerminal
    #>
    try {
        winget install --id Microsoft.WindowsTerminal --source winget
        Write-Host "Windows Terminal 安装/更新成功。" -ForegroundColor Green
    }
    catch {
        Write-Host "安装/更新 Windows Terminal 时发生错误：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Install-Winget {
    <#
    .SYNOPSIS
        安装或更新 Winget
    .DESCRIPTION
        该函数检查 Winget 是否已安装，如果未安装则尝试安装它。
    .EXAMPLE
        Install-Winget
    #>
    try {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "Winget 已安装，正在检查更新..." -ForegroundColor Yellow
            Update-Winget
        } else {
            Write-Host "Winget 未安装，正在尝试安装..." -ForegroundColor Yellow
            # 尝试从 Microsoft Store 安装 Winget
            Start-Process "ms-windows-store://pdp/?ProductId=9nblggh4nns1" -Wait
            Write-Host "请在 Microsoft Store 中完成 Winget 的安装，然后按任意键继续..." -ForegroundColor Cyan
            [Console]::ReadKey($true) | Out-Null
            
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                Write-Host "Winget 安装成功。" -ForegroundColor Green
            } else {
                Write-Host "Winget 安装失败。请手动安装 Winget。" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "安装/更新 Winget 时发生错误：$($_.Exception.Message)" -ForegroundColor Red
    }
}

function Update-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "正在更新 Chocolatey..." -ForegroundColor Yellow
        choco upgrade chocolatey -y
    } else {
        Write-Host "Chocolatey 未安装，跳过更新。" -ForegroundColor Yellow
    }
}

function Update-Scoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "正在更新 Scoop..." -ForegroundColor Yellow
        scoop update
    } else {
        Write-Host "Scoop 未安装，跳过更新。" -ForegroundColor Yellow
    }
}

function Update-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $wingetVersion = (winget --version).Trim()
        Write-Host "当前 Winget 版本: $wingetVersion" -ForegroundColor Cyan

        Write-Host "正在更新软件源..." -ForegroundColor Yellow
        winget source update

        Write-Host "正在检查可用更新..." -ForegroundColor Yellow
        $updateOutput = winget upgrade
        $updates = $updateOutput | Select-Object -Skip 2 | Where-Object { 
            $_ -match '^\S+' -and 
            $_ -notmatch '^\s*$' -and 
            $_ -notmatch '^\s*名称\s+ID\s+版本\s+可用\s+源$' -and
            $_ -notmatch '^\s*----' -and
            $_ -notmatch '升级可用。$' -and
            $_ -notmatch '程序包的版本号无法确定。'
        }
        
        if ($updates) {
            $updateCount = ($updates | Measure-Object).Count
            Write-Host "发现 $updateCount 个可更新的软件包：" -ForegroundColor Green
            $updates | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }

            $confirm = Read-Host "是否要更新所有软件包？(Y/N)"
            if ($confirm -eq 'Y' -or $confirm -eq 'y') {
                Write-Host "正在更新所有软件包，这可能需要一些时间..." -ForegroundColor Yellow
                $currentUpdate = 0
                foreach ($update in $updates) {
                    $currentUpdate++
                    $packageId = ($update -split '\s+')[0]
                    $percentComplete = [math]::Floor(($currentUpdate / $updateCount) * 100)
                    Write-Progress -Activity "正在更新软件包" -Status "$packageId ($currentUpdate / $updateCount)" -PercentComplete $percentComplete
                    winget upgrade $packageId --accept-source-agreements
                }
                Write-Progress -Activity "正在更新软件包" -Completed
                Write-Host "所有 Winget 软件包更新完成！" -ForegroundColor Green
            } else {
                Write-Host "更新已取消。" -ForegroundColor Yellow
            }
        } else {
            Write-Host "所有 Winget 软件包都是最新的。" -ForegroundColor Green
        }
    } else {
        Write-Host "Winget 未找到。请确保 Windows 已更新到最新版本。" -ForegroundColor Yellow
    }
}

function Update-PowerShell7 {
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Write-Host "正在更新 PowerShell 7..." -ForegroundColor Yellow
        iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
    } else {
        Write-Host "当前不是 PowerShell 7，跳过更新。" -ForegroundColor Yellow
    }
}

function Update-Git {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Write-Host "正在更新 Git..." -ForegroundColor Yellow
        git update-git-for-windows
    } else {
        Write-Host "Git 未安装，跳过更新。" -ForegroundColor Yellow
    }
}

function Update-VSCode {
    if (Get-Command code -ErrorAction SilentlyContinue) {
        Write-Host "正在更新 Visual Studio Code..." -ForegroundColor Yellow
        code --install-extension ms-vscode.powershell
    } else {
        Write-Host "Visual Studio Code 未安装，跳过更新。" -ForegroundColor Yellow
    }
}

function Update-WindowsTerminal {
    if (Get-Command wt -ErrorAction SilentlyContinue) {
        Write-Host "Windows Terminal 已安装，请通过 Microsoft Store 更新。" -ForegroundColor Yellow
    } else {
        Write-Host "Windows Terminal 未安装，跳过更新。" -ForegroundColor Yellow
    }
}

Export-ModuleMember -Function Show-ToolManagement, Update-AllTools, Install-OhMyPosh, Install-Chocolatey, Install-Scoop, Install-Winget, Update-Scoop, Update-Chocolatey, Update-Winget