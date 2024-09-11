<#
.SYNOPSIS
    环境变量管理模块
.DESCRIPTION
    本模块提供了一系列环境变量管理工具，包括查看、设置和删除环境变量等功能。
.NOTES
    版本：1.0
    作者：Your Name
    最后更新：2023-05-11
#>

function Show-EnvVariableManagement {
    do {
        Clear-Host
        Write-Host "环境变量管理" -ForegroundColor Cyan
        Write-Host "0. 返回上级菜单"
        Write-Host "1. 查看所有环境变量"
        Write-Host "2. 设置环境变量"
        Write-Host "3. 删除环境变量"
        $choice = Read-Host "请选择操作"
        switch ($choice) {
            "0" { return }
            "1" { Show-AllEnvVariables }
            "2" { Set-NewEnvVariable }
            "3" { Remove-EnvVariable }
            default { Write-Host "无效的选择，请重试。" -ForegroundColor Red }
        }
        if ($choice -ne "0") { Read-Host "按 Enter 键继续" }
    } while ($true)
}

function Show-AllEnvVariables {
    Get-ChildItem Env: | Format-Table -AutoSize
}

function Set-NewEnvVariable {
    $name = Read-Host "请输入环境变量名"
    $value = Read-Host "请输入环境变量值"
    [Environment]::SetEnvironmentVariable($name, $value, "User")
    Write-Host "环境变量 '$name' 已设置为 '$value'" -ForegroundColor Green
}

function Remove-EnvVariable {
    $name = Read-Host "请输入要删除的环境变量名"
    [Environment]::SetEnvironmentVariable($name, $null, "User")
    Write-Host "环境变量 '$name' 已删除" -ForegroundColor Green
}

Export-ModuleMember -Function Show-EnvVariableManagement, Show-AllEnvVariables, Set-NewEnvVariable, Remove-EnvVariable