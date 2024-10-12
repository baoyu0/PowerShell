# 环境变量设置
$env:EDITOR = "code"  # 将默认编辑器设置为 VS Code

# 添加常用路径到 PATH
$customPaths = @(
    "C:\Tools",
    "C:\Program Files\Git\bin"
)

foreach ($path in $customPaths) {
    if (Test-Path $path) {
        $env:PATH += ";$path"
    }
}

# 自动安装常用模块
function Install-ModuleIfMissing {
    param([string]$ModuleName)
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "正在安装 $ModuleName 模块..." -ForegroundColor Yellow
        try {
            Install-Module -Name $ModuleName -Scope CurrentUser -Force -ErrorAction Stop
            Write-Host "$ModuleName 模块安装成功" -ForegroundColor Green
        } catch {
            Write-Warning "安装 $ModuleName 模块失败: $_"
            Write-Host "请尝试以管理员身份运行 PowerShell 并重新执行此命令" -ForegroundColor Yellow
        }
    }
}

Install-ModuleIfMissing -ModuleName "PSReadLine"
Install-ModuleIfMissing -ModuleName "Terminal-Icons"

# 模块帮助信息
function global:Show-EnvironmentSetupHelp {
    Write-Host "环境设置模块帮助：" -ForegroundColor Cyan
    Write-Host "  设置默认编辑器为 VS Code"
    Write-Host "  添加自定义路径到 PATH 环境变量"
    Write-Host "  自动安装常用 PowerShell 模块"
}
