#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
if (-not $env:CONDA_SHLVL) {
    $condaExe = "C:\Users\dandan\anaconda3\Scripts\conda.exe"
    If (Test-Path $condaExe) {
        $initScript = (& $condaExe "shell.powershell" "hook") | Out-String | Where-Object {$_}
        Invoke-Expression $initScript
        $env:CONDA_SHLVL = "1"
    }
}
#endregion
