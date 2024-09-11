function Rename-BatchFiles {
    param (
        [string]$Pattern,
        [string]$Replacement
    )
    $files = Get-ChildItem | Where-Object { $_.Name -match $Pattern }
    $totalFiles = $files.Count
    $currentFile = 0
    foreach ($file in $files) {
        $currentFile++
        $newName = $file.Name -replace $Pattern, $Replacement
        $percentComplete = ($currentFile / $totalFiles) * 100
        Show-ProgressBar -PercentComplete $percentComplete -Status "正在重命名文件 ($currentFile / $totalFiles)"
        Rename-Item $file.Name $newName
        Write-StatusMessage "已将 $($file.Name) 重命名为 $newName" -Type Success
    }
}

function Compare-FileContent {
    param (
        [string]$File1,
        [string]$File2
    )
    if (-not (Test-Path $File1) -or -not (Test-Path $File2)) {
        Write-Log "文件不存在" -Level Error
        return
    }
    $diff = Compare-Object (Get-Content $File1) (Get-Content $File2)
    if ($diff) {
        Write-Host "文件内容不同：" -ForegroundColor Yellow
        $diff | Format-Table -AutoSize
    } else {
        Write-Host "文件内容相同" -ForegroundColor Green
    }
}

Export-ModuleMember -Function Rename-BatchFiles, Compare-FileContent