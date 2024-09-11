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
    do {
        $choice = Show-Menu -Title "工具管理" -Options @(
            "返回上级菜单",
            "更新所有工具",
            "安装/更新 Oh My Posh",
            "安装/更新 PowerShell 7",
            "安装/更新 Git",
            "安装/更新 Visual Studio Code",
            "安装/更新 Windows Terminal",
            "安装/更新 Chocolatey",
            "安装/更新 Scoop",
            "安装/更新 Winget"
        )
        
        switch ($choice) {
            0 { return }
            1 { Update-AllTools }
            2 { Install-OhMyPosh }
            3 { Install-PowerShell7 }
            4 { Install-Git }
            5 { Install-VSCode }
            6 { Install-WindowsTerminal }
            7 { Install-Chocolatey }
            8 { Install-Scoop }
            9 { Install-Winget }
        }
        
        if ($choice -ne 0) { Read-Host "按 Enter 键继续" }
    } while ($true)
}

function Update-AllTools {
    Write-StatusMessage "正在更新所有工具..." -Type Warning
    $tools = @(
        @{Name="Oh My Posh"; Action={Install-OhMyPosh}},
        @{Name="PowerShell 7"; Action={Install-PowerShell7}},
        @{Name="Git"; Action={Install-Git}},
        @{Name="Visual Studio Code"; Action={Install-VSCode}},
        @{Name="Windows Terminal"; Action={Install-WindowsTerminal}},
        @{Name="Chocolatey"; Action={Update-Chocolatey}},
        @{Name="Scoop"; Action={Update-Scoop}},
        @{Name="Winget"; Action={Update-Winget}}
    )
    
    for ($i = 0; $i -lt $tools.Count; $i++) {
        $tool = $tools[$i]
        $percentComplete = ($i + 1) / $tools.Count * 100
        Show-ProgressBar -PercentComplete $percentComplete -Status "正在更新 $($tool.Name)"
        
        try {
            & $tool.Action
            Write-StatusMessage "$($tool.Name) 更新成功" -Type Success
        } catch {
            Write-StatusMessage "更新 $($tool.Name) 时发生错误：$($_.Exception.Message)" -Type Error
        }
    }
    
    Write-StatusMessage "所有工具更新完成。" -Type Success
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

function Update-Scoop {
    Write-StatusMessage "正在更新 Scoop..." -Type Info
    scoop update
    $updates = scoop status
    if ($updates) {
        Write-StatusMessage "发现以下可用更新：" -Type Info
        $updates | ForEach-Object { Write-Host $_ }
        scoop update *
    } else {
        Write-StatusMessage "所有 Scoop 软件包都是最新的。" -Type Success
    }
}

function Update-Chocolatey {
    Write-StatusMessage "正在更新 Chocolatey..." -Type Info
    choco upgrade chocolatey -y
    $updates = choco outdated
    if ($updates -notmatch "Chocolatey has determined no packages are outdated") {
        Write-StatusMessage "发现以下可用更新：" -Type Info
        $updates | ForEach-Object { Write-Host $_ }
        choco upgrade all -y
    } else {
        Write-StatusMessage "所有 Chocolatey 软件包都是最新的。" -Type Success
    }
}

function Update-Winget {
    Write-StatusMessage "正在检查 Winget 更新..." -Type Info
    $updates = winget upgrade
    if ($updates -match "升级可用") {
        Write-StatusMessage "发现以下可用更新：" -Type Info
        $updates | ForEach-Object { Write-Host $_ }
        winget upgrade --all
    } else {
        Write-StatusMessage "所有 Winget 软件包都是最新的。" -Type Success
    }
}

Export-ModuleMember -Function Show-ToolManagement, Update-AllTools, Install-OhMyPosh, Install-PowerShell7, Install-Git, Install-VSCode, Install-WindowsTerminal, Update-Scoop, Update-Chocolatey, Update-Winget