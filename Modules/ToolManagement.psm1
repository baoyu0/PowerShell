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

function Show-ToolManagement {
    do {
        $choice = Show-Menu -Title "工具管理" -Options @(
            "返回上级菜单",
            "更新所有工具",
            "安装/更新 Oh My Posh",
            "安装/更新 PowerShell 7",
            "安装/更新 Git",
            "安装/更新 Visual Studio Code",
            "安装/更新 Windows Terminal"
        )
        
        switch ($choice) {
            0 { return }
            1 { Update-AllTools }
            2 { Install-OhMyPosh }
            3 { Install-PowerShell7 }
            4 { Install-Git }
            5 { Install-VSCode }
            6 { Install-WindowsTerminal }
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
        @{Name="Windows Terminal"; Action={Install-WindowsTerminal}}
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

Export-ModuleMember -Function Show-ToolManagement, Update-AllTools, Install-OhMyPosh, Install-PowerShell7, Install-Git, Install-VSCode, Install-WindowsTerminal