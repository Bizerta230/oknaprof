# Скрипт для проверки нового n8n сервера
# IP: 83.219.243.108

Write-Host "=== Проверка доступности сервера ===" -ForegroundColor Green
Test-Connection -ComputerName 83.219.243.108 -Count 2

Write-Host "`n=== Проверка доступности n8n через URL ===" -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "https://n8n.oknaprof59.ru" -TimeoutSec 10 -UseBasicParsing
    Write-Host "Статус: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "n8n доступен!" -ForegroundColor Green
} catch {
    Write-Host "Ошибка доступа: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Проверка API endpoint ===" -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "https://n8n.oknaprof59.ru/api/v1/workflows" -TimeoutSec 10 -UseBasicParsing
    Write-Host "API отвечает со статусом: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "API ошибка: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "Это нормально если API ключ не настроен" -ForegroundColor Yellow
}

Write-Host "`n=== Инструкции для SSH подключения ===" -ForegroundColor Cyan
Write-Host "Для проверки Docker контейнеров выполните:" -ForegroundColor Cyan
Write-Host "ssh root@83.219.243.108" -ForegroundColor White
Write-Host "Пароль: HbPFZDqCunT8Zz" -ForegroundColor White
Write-Host ""
Write-Host "Команды для диагностики:" -ForegroundColor Cyan
Write-Host "docker ps -a                    # Список всех контейнеров" -ForegroundColor White
Write-Host "docker logs n8n --tail 50       # Логи n8n" -ForegroundColor White
Write-Host "docker restart n8n              # Перезапуск n8n" -ForegroundColor White
Write-Host "curl http://localhost:5678/healthz  # Проверка здоровья" -ForegroundColor White
