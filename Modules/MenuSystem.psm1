function Show-ProfileMenu {
    $options = @(
        @{Symbol="❌"; Name="退出菜单"; Action={return $true}},
        @{Symbol="🔄"; Name="强制检查更新"; Action={Update-Profile}},
        @{Symbol="👀"; Name="查看当前配置文件"; Action={Show-Profile}},
        @{Symbol="✏️"; Name="编辑配置文件"; Action={Edit-Profile}},
        @{Symbol="🌐"; Name="切换代理"; Action={Toggle-Proxy}},
        @{Symbol="🚀"; Name="执行PowerShell命令"; Action={Invoke-CustomCommand}},
        @{Symbol="📁"; Name="快速导航"; Action={Navigate-QuickAccess}},
        @{Symbol="🔧"; Name="安装/更新工具"; Action={Manage-Tools}},
        @{Symbol="🌐"; Name="网络诊断工具"; Action={Show-NetworkTools}},
        @{Symbol="📁"; Name="文件操作工具"; Action={Show-FileOperations}},
        @{Symbol="🔧"; Name="环境变量管理"; Action={Show-EnvVariableManagement}}
    )

    do {
        Clear-Host
        Write-Host "PowerShell 配置文件管理菜单" -ForegroundColor Cyan
        Write-Host "================================" -ForegroundColor Cyan
        
        for ($i = 0; $i -lt $options.Count; $i++) {
            Write-Host ("[$i] " + $options[$i].Symbol + " " + $options[$i].Name) -ForegroundColor Yellow
        }
        
        $choice = Read-Host "`n请输入您的选择 (0-$($options.Count - 1))，或按 'q' 退出"
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
            if ($choice -ne '0') {
                Write-Host "`n"
                Read-Host "按 Enter 键返回菜单"
            }
        } else {
            Write-Host "`n无效的选择，请重试。" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    } while ($true)
}

# 其他菜单相关函数...

Export-ModuleMember -Function Show-ProfileMenu