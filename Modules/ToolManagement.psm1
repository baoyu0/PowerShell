function Update-AllTools {
    # 将原来的 Update-AllTools 函数内容移到这里
}

function Install-OhMyPosh {
    # 将原来的 Install-OhMyPosh 函数内容移到这里
}

# 其他工具相关的函数也可以移到这里

function Get-EnvVariables {
    Get-ChildItem Env: | Format-Table -AutoSize
}

function Set-EnvVariable {
    param (
        [string]$Name,
        [string]$Value,
        [ValidateSet('User', 'Machine')]
        [string]$Scope = 'User'
    )
    [System.Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
    Set-Item -Path "Env:$Name" -Value $Value
    Write-Log "环境变量 $Name 已设置为 $Value" -Level Info
}

function Remove-EnvVariable {
    param (
        [string]$Name,
        [ValidateSet('User', 'Machine')]
        [string]$Scope = 'User'
    )
    [System.Environment]::SetEnvironmentVariable($Name, $null, $Scope)
    Remove-Item -Path "Env:$Name" -ErrorAction SilentlyContinue
    Write-Log "环境变量 $Name 已删除" -Level Info
}

Export-ModuleMember -Function Update-AllTools, Install-OhMyPosh, Get-EnvVariables, Set-EnvVariable, Remove-EnvVariable