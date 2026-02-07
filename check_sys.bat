@echo off
chcp 65001 >nul
echo ========================================
echo ДИАГНОСТИКА СИСТЕМЫ
echo ========================================
echo.
echo 1. ТОП ПРОЦЕССОВ ПО ПАМЯТИ:
echo ---
powershell -NoProfile -Command "$procs = Get-Process | Sort-Object WS -Descending | Select-Object -First 15; foreach($p in $procs) { $mem = [math]::Round($p.WS/1MB,1); Write-Host ('{0,-35} {1,8} MB' -f $p.ProcessName, $mem) }"
echo.
echo 2. ИСПОЛЬЗОВАНИЕ ПАМЯТИ:
echo ---
powershell -NoProfile -Command "$os = Get-CimInstance Win32_OperatingSystem; $total = [math]::Round($os.TotalVisibleMemorySize/1MB, 2); $free = [math]::Round($os.FreePhysicalMemory/1MB, 2); $used = $total - $free; $pct = [math]::Round(($used / $total) * 100, 1); Write-Host \"Всего: $total GB\"; Write-Host \"Используется: $used GB ($pct%%)\"; Write-Host \"Свободно: $free GB\""
echo.
echo 3. ДИСКИ:
echo ---
wmic logicaldisk get caption,freespace,size /format:table
echo.
echo 4. РАЗМЕР ВРЕМЕННЫХ ФАЙЛОВ:
echo ---
powershell -NoProfile -Command "if(Test-Path $env:TEMP) { $size = (Get-ChildItem $env:TEMP -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum; $gb = [math]::Round($size/1GB, 2); Write-Host \"TEMP папка: $gb GB\" }"
echo.
echo ========================================
pause
