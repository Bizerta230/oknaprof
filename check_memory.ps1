# Диагностика системы - Проверка памяти и производительности

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ДИАГНОСТИКА СИСТЕМЫ" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Общая информация о памяти
Write-Host "1. СОСТОЯНИЕ ПАМЯТИ (RAM)" -ForegroundColor Yellow
Write-Host "---" -ForegroundColor Gray
$os = Get-CimInstance Win32_OperatingSystem
$totalRAM = [math]::Round($os.TotalVisibleMemorySize/1MB, 2)
$freeRAM = [math]::Round($os.FreePhysicalMemory/1MB, 2)
$usedRAM = $totalRAM - $freeRAM
$percentUsed = [math]::Round(($usedRAM / $totalRAM) * 100, 1)

Write-Host "Всего памяти: $totalRAM GB" -ForegroundColor White
Write-Host "Используется: $usedRAM GB ($percentUsed%)" -ForegroundColor $(if ($percentUsed -gt 80) { "Red" } elseif ($percentUsed -gt 60) { "Yellow" } else { "Green" })
Write-Host "Свободно: $freeRAM GB" -ForegroundColor Green
Write-Host ""

# 2. Топ процессов по памяти
Write-Host "2. ТОП 15 ПРОЦЕССОВ ПО ИСПОЛЬЗОВАНИЮ ПАМЯТИ" -ForegroundColor Yellow
Write-Host "---" -ForegroundColor Gray
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 15 |
    Format-Table ProcessName,
        @{Label="Memory(MB)"; Expression={[math]::Round($_.WorkingSet/1MB, 2)}; Align="Right"},
        @{Label="CPU(s)"; Expression={if($_.CPU){[math]::Round($_.CPU, 2)}else{0}}; Align="Right"},
        Id -AutoSize
Write-Host ""

# 3. Использование диска
Write-Host "3. ИСПОЛЬЗОВАНИЕ ДИСКОВ" -ForegroundColor Yellow
Write-Host "---" -ForegroundColor Gray
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null } |
    Select-Object Name,
        @{Label="Used(GB)"; Expression={[math]::Round($_.Used/1GB, 2)}},
        @{Label="Free(GB)"; Expression={[math]::Round($_.Free/1GB, 2)}},
        @{Label="Total(GB)"; Expression={[math]::Round(($_.Used + $_.Free)/1GB, 2)}},
        @{Label="Used%"; Expression={[math]::Round(($_.Used / ($_.Used + $_.Free)) * 100, 1)}} |
    Format-Table -AutoSize
Write-Host ""

# 4. Размер временных файлов
Write-Host "4. ВРЕМЕННЫЕ ФАЙЛЫ" -ForegroundColor Yellow
Write-Host "---" -ForegroundColor Gray
$tempSize = 0
if (Test-Path $env:TEMP) {
    $tempSize = (Get-ChildItem $env:TEMP -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $tempSizeGB = [math]::Round($tempSize/1GB, 2)
    Write-Host "Папка TEMP: $tempSizeGB GB" -ForegroundColor $(if ($tempSizeGB -gt 5) { "Yellow" } else { "White" })
}

$npmCache = "$env:APPDATA\npm-cache"
if (Test-Path $npmCache) {
    $npmSize = (Get-ChildItem $npmCache -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    $npmSizeGB = [math]::Round($npmSize/1GB, 2)
    Write-Host "Кэш npm: $npmSizeGB GB" -ForegroundColor $(if ($npmSizeGB -gt 2) { "Yellow" } else { "White" })
}
Write-Host ""

# 5. Программы в автозагрузке
Write-Host "5. АВТОЗАГРУЗКА (первые 10)" -ForegroundColor Yellow
Write-Host "---" -ForegroundColor Gray
Get-CimInstance Win32_StartupCommand | Select-Object -First 10 Name, Command | Format-Table -AutoSize -Wrap
Write-Host ""

# 6. Рекомендации
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "РЕКОМЕНДАЦИИ" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($percentUsed -gt 80) {
    Write-Host "⚠️ КРИТИЧНО: Память загружена на $percentUsed%" -ForegroundColor Red
    Write-Host "   Рекомендуется закрыть ненужные программы" -ForegroundColor Red
} elseif ($percentUsed -gt 60) {
    Write-Host "⚠️ ВНИМАНИЕ: Память загружена на $percentUsed%" -ForegroundColor Yellow
    Write-Host "   Рекомендуется следить за использованием" -ForegroundColor Yellow
} else {
    Write-Host "✓ Использование памяти в норме ($percentUsed%)" -ForegroundColor Green
}

if ($tempSizeGB -gt 5) {
    Write-Host "⚠️ Много временных файлов: $tempSizeGB GB" -ForegroundColor Yellow
    Write-Host "   Рекомендуется очистить: Очистка диска Windows" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Для очистки временных файлов запустите:" -ForegroundColor Cyan
Write-Host "cleanmgr.exe" -ForegroundColor White
Write-Host ""
