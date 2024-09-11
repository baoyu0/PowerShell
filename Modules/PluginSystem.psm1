<#
.SYNOPSIS
    插件系统模块
.DESCRIPTION
    本模块提供了一个简单的插件系统，允许用户轻松扩展功能。
.NOTES
    版本：1.0
    作者：Your Name
    最后更新：2023-05-16
#>

$script:PluginsDirectory = Join-Path $PSScriptRoot "Plugins"

function Initialize-PluginSystem {
    if (-not (Test-Path $script:PluginsDirectory)) {
        New-Item -ItemType Directory -Path $script:PluginsDirectory | Out-Null
    }
}

function Get-AvailablePlugins {
    Get-ChildItem $script:PluginsDirectory -Filter "*.psm1" | ForEach-Object {
        $pluginInfo = @{
            Name = $_.BaseName
            Path = $_.FullName
        }
        New-Object PSObject -Property $pluginInfo
    }
}

function Load-Plugin {
    param (
        [string]$PluginName
    )
    $pluginPath = Join-Path $script:PluginsDirectory "$PluginName.psm1"
    if (Test-Path $pluginPath) {
        Import-Module $pluginPath -Force
        Write-Log "插件 $PluginName 已加载" -Level Info
    } else {
        Write-Log "插件 $PluginName 不存在" -Level Error
    }
}

function Enable-Plugin {
    param (
        [string]$PluginName
    )
    $pluginConfig = Join-Path $PSScriptRoot "PluginConfig.json"
    $config = Get-Content $pluginConfig | ConvertFrom-Json
    $config.EnabledPlugins += $PluginName
    $config | ConvertTo-Json | Set-Content $pluginConfig
    Write-Log "插件 $PluginName 已启用" -Level Info
}

function Disable-Plugin {
    param (
        [string]$PluginName
    )
    $pluginConfig = Join-Path $PSScriptRoot "PluginConfig.json"
    $config = Get-Content $pluginConfig | ConvertFrom-Json
    $config.EnabledPlugins = $config.EnabledPlugins | Where-Object { $_ -ne $PluginName }
    $config | ConvertTo-Json | Set-Content $pluginConfig
    Write-Log "插件 $PluginName 已禁用" -Level Info
}

function Show-PluginManagement {
    do {
        $plugins = Get-AvailablePlugins
        $enabledPlugins = (Get-Content (Join-Path $PSScriptRoot "PluginConfig.json") | ConvertFrom-Json).EnabledPlugins
        $options = @("返回上级菜单")
        $options += $plugins | ForEach-Object { 
            $status = if ($enabledPlugins -contains $_.Name) { "[已启用]" } else { "[已禁用]" }
            "$($_.Name) $status"
        }
        $choice = Show-Menu -Title "插件管理" -Options $options
        
        if ($choice -eq 0) { return }
        if ($choice -le $plugins.Count) {
            $selectedPlugin = $plugins[$choice - 1].Name
            if ($enabledPlugins -contains $selectedPlugin) {
                Disable-Plugin $selectedPlugin
            } else {
                Enable-Plugin $selectedPlugin
            }
        }
        
        Read-Host "按 Enter 键继续"
    } while ($true)
}

Export-ModuleMember -Function Initialize-PluginSystem, Get-AvailablePlugins, Load-Plugin, Show-PluginManagement, Enable-Plugin, Disable-Plugin