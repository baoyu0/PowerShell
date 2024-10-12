# 常用别名
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name g -Value git
Set-Alias -Name c -Value clear

# 自定义别名
function Open-ExplorerHere { explorer.exe . }
Set-Alias -Name here -Value Open-ExplorerHere

function Get-GitStatus { git status }
Set-Alias -Name gst -Value Get-GitStatus

# 模块帮助信息
function global:Show-AliasesHelp {
    Write-Host "别名模块帮助：" -ForegroundColor Cyan
    Write-Host "  ll   - 列出目录内容（Get-ChildItem）"
    Write-Host "  g    - Git 快捷命令"
    Write-Host "  c    - 清屏"
    Write-Host "  here - 在当前目录打开文件资源管理器"
    Write-Host "  gst  - 显示 Git 状态"
}

# 删除 Export-ModuleMember 行，因为这不是一个模块文件
