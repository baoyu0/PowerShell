# 核心设置
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# 其他核心设置...

function prompt {
    $envName = $env:CONDA_DEFAULT_ENV
    $envPrefix = if ($envName) { "($envName) " } else { "" }
    $location = $PWD.Path
    $promptChar = '>' * ($nestedPromptLevel + 1)
    
    "${envPrefix}PS ${location}${promptChar} "
}
