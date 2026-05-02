@echo off
:: 切换代码页为 UTF-8 以解决中文乱码
chcp 65001 >nul

:: 自动请求管理员权限
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit

title 隐藏设备清理工具
echo ===================================================
echo   正在扫描并移除系统中未连接的隐藏设备...
echo ===================================================

:: 运行 PowerShell 清理逻辑
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$devices = Get-PnpDevice | Where-Object { $_.Present -eq $false -and $_.FriendlyName -ne $null }; " ^
    "if ($devices.Count -eq 0) { Write-Host '未发现可清理的隐藏设备。' -ForegroundColor Yellow; } " ^
    "foreach ($dev in $devices) { " ^
    "  Write-Host '正在移除: ' $dev.FriendlyName -ForegroundColor Cyan; " ^
    "  pnputil /remove-device \"$($dev.InstanceId)\" >$null; " ^
    "}"

echo.
echo ===================================================
echo 清理任务已完成！
pause
