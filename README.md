# PowerShell 配置文件

这是一个简洁的 PowerShell 配置文件，包含以下特性：

- PSReadLine 智能预测和快捷键设置
- Terminal-Icons 支持
- 实用函数和别名
- 代理管理模块
- 自动更新检查
- 主题管理

## 安装

1. 克隆此仓库到您的 PowerShell 配置文件目录
2. 在 PowerShell 中运行 `. $PROFILE` 以加载配置

## 使用

配置文件会自动加载。享受增强的 PowerShell 体验！

### 代理管理模块

该模块提供了便捷的代理管理功能，包括设置、清除、测试代理等。

#### 使用方法

使用 `Invoke-ProxyManager` 函数来管理代理设置。为了保持向后兼容性，`Manage-Proxy` 别名也可以使用。

#### 可用命令

- `Set-ProxyStatus On/Off [HttpProxy] [SocksProxy]` - 开启或关闭代理
- `Get-ProxyStatus` - 显示当前代理设置
- `Set-DefaultProxy <HttpProxy> <SocksProxy>` - 设置默认代理
- `Switch-ProxyAuto` - 自动检测并切换代理
- `Show-ProxyMenu` - 显示交互式代理管理菜单

### 其他实用函数

- `Update-Profile` - 更新并重新加载 PowerShell 配置文件
- `Test-NetworkConnection` - 测试网络连接
- `Test-ProfileUpdate` - 检查配置文件是否有可用更新

## 主题管理

使用 `Set-PowerShellTheme` 和 `Set-CustomPrompt` 来自定义您的 PowerShell 外观。

## 贡献

欢迎提交 Pull Requests 来改进此配置文件。

## 许可

MIT License
