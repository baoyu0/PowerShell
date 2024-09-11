function Rename-BatchFiles {
    param (
        [string]$Pattern,
        [string]$Replacement
    )
    Get-ChildItem | Where-Object { $_.Name -match $Pattern } | ForEach-Object {
        $newName = $_.Name -replace $Pattern, $Replacement
        Rename-Item $_.Name $newName
        Write-Host "已将 $($_.Name) 重命名为 $newName" -ForegroundColor Green
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