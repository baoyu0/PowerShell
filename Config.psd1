@{
    DefaultTheme = "1_shell"
    DefaultEditor = "notepad.exe"
    DefaultBrowser = "chrome.exe"
    CustomPaths = @(
        "C:\CustomTools"
        "D:\WorkProjects"
    )
    Colors = @{
        Title = 'Cyan'
        Menu = 'Yellow'
        Success = 'Green'
        Error = 'Red'
        Warning = 'DarkYellow'
        Info = 'White'
        InlinePrediction = '#666666'
    }
    UpdateCheckInterval = 7 # 天
    DefaultProxyPort = 20000
    LogLevel = "Info" # 可选值：Debug, Info, Warning, Error
}