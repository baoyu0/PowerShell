using module .\UIHelpers.psm1
using module .\CoreFunctions.psm1

function Show-FileOperations {
    do {
        $choice = Show-Menu -Title "文件操作工具" -Options @(
            "返回上级菜单",
            "查找文件",
            "获取文件夹大小",
            "创建新文件",
            "批量重命名文件",
            "比较文件内容"
        )
        
        switch ($choice) {
            0 { return }
            1 { Find-File }
            2 { Get-FolderSize }
            3 { New-FileItem }
            4 { Rename-BatchFiles }
            5 { Compare-FileContent }
        }
        
        if ($choice -ne 0) { Read-Host "按 Enter 键继续" }
    } while ($true)
}

function Find-File {
    $name = Read-Host "请输入要查找的文件名"
    $results = Get-ChildItem -Recurse -Filter $name
    if ($results) {
        Write-StatusMessage "找到以下文件：" -Type Success
        $results | ForEach-Object { Write-Host $_.FullName }
    } else {
        Write-StatusMessage "未找到匹配的文件。" -Type Warning
    }
}

function Get-FolderSize {
    $path = Read-Host "请输入文件夹路径"
    $size = (Get-ChildItem $path -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-StatusMessage "文件夹大小：$($size.ToString('F2')) MB" -Type Info
}

function New-FileItem {
    $name = Read-Host "请输入新文件名"
    New-Item -ItemType File -Name $name
    Write-StatusMessage "文件 '$name' 已创建" -Type Success
}

function Rename-BatchFiles {
    $pattern = Read-Host "请输入要替换的模式（正则表达式）"
    $replacement = Read-Host "请输入替换后的内容"
    $files = Get-ChildItem | Where-Object { $_.Name -match $pattern }
    $totalFiles = $files.Count
    $currentFile = 0
    foreach ($file in $files) {
        $currentFile++
        $newName = $file.Name -replace $pattern, $replacement
        $percentComplete = ($currentFile / $totalFiles) * 100
        Show-ProgressBar -PercentComplete $percentComplete -Status "正在重命名文件 ($currentFile / $totalFiles)"
        Rename-Item $file.Name $newName
        Write-StatusMessage "已将 $($file.Name) 重命名为 $newName" -Type Success
    }
}

function Compare-FileContent {
    $file1 = Read-Host "请输入第一个文件的路径"
    $file2 = Read-Host "请输入第二个文件的路径"
    if (-not (Test-Path $file1) -or -not (Test-Path $file2)) {
        Write-StatusMessage "文件不存在" -Type Error
        return
    }
    $diff = Compare-Object (Get-Content $file1) (Get-Content $file2)
    if ($diff) {
        Write-StatusMessage "文件内容不同：" -Type Warning
        $diff | Format-Table -AutoSize
    } else {
        Write-StatusMessage "文件内容相同" -Type Success
    }
}

Export-ModuleMember -Function Show-FileOperations, Find-File, Get-FolderSize, New-FileItem, Rename-BatchFiles, Compare-FileContent