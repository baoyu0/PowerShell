# PSReadLine 设置
$PSReadLineOptions = @{
    PredictionSource = 'History'
    PredictionViewStyle = 'ListView'
    Colors = @{ InlinePrediction = '#666666' }
    HistorySearchCursorMovesToEnd = $true
    EditMode = 'Emacs'
}
Set-PSReadLineOption @PSReadLineOptions

# 快捷键设置
@{
    'Ctrl+w' = 'BackwardDeleteWord'
    'Tab' = 'MenuComplete'
    'Ctrl+z' = 'Undo'
    'UpArrow' = 'HistorySearchBackward'
    'DownArrow' = 'HistorySearchForward'
    'Ctrl+l' = 'ClearScreen'
}.GetEnumerator() | ForEach-Object { Set-PSReadLineKeyHandler -Key $_.Key -Function $_.Value }

# 实用函数和别名
function Set-LocationUp { Set-Location .. }
function Set-LocationUpUp { Set-Location ..\.. }
Set-Alias -Name '..' -Value Set-LocationUp
Set-Alias -Name '...' -Value Set-LocationUpUp
Set-Alias -Name 'which' -Value Get-Command
Set-Alias -Name 'touch' -Value New-Item
Set-Alias -Name 'open' -Value Invoke-Item

# 延迟加载函数
function Initialize-PowerShellEnvironment {
    # 主题设置
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\1_shell.omp.json" | Invoke-Expression

    # 启用模块
    $ModulesToImport = @('Terminal-Icons', 'PowerGPT')
    foreach ($module in $ModulesToImport) {
        Import-Module -Name $module -ErrorAction SilentlyContinue
    }

    # Winget tab自动补全
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        $Local:word = $wordToComplete.Replace('"', '""')
        $Local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }

    # 加载自定义模块
    $customModules = @('ProxyManagement', 'CoreFunctions', 'EnvironmentManagement', 'FileOperations', 'MenuSystem')
    foreach ($module in $customModules) {
        $modulePath = Join-Path $PSScriptRoot "Modules\$module.psm1"
        if (Test-Path $modulePath) {
            Import-Module $modulePath -ErrorAction SilentlyContinue
        }
    }
}

# 使用 PowerShell 的事件系统来延迟加载
$null = Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    Initialize-PowerShellEnvironment
    Unregister-Event -SourceIdentifier PowerShell.OnIdle
}
