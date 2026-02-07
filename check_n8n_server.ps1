# Скрипт для проверки n8n сервера
# Запустите этот файл в PowerShell

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Проверка n8n сервера" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$password = "TCSug8nGTLdZ54"
$username = "root"
$server = "193.168.196.225"

Write-Host "Подключение к $server..." -ForegroundColor Yellow
Write-Host ""

# Команды для выполнения на сервере
$commands = @(
    "echo '=== Docker контейнеры ==='",
    "docker ps -a",
    "echo ''",
    "echo '=== Проверка n8n локально ==='",
    "curl -s http://localhost:5678/healthz || echo 'n8n не отвечает на localhost:5678'",
    "echo ''",
    "echo '=== Процессы n8n ==='",
    "ps aux | grep n8n | grep -v grep || echo 'Процессы n8n не найдены'",
    "echo ''",
    "echo '=== Проверка портов ==='",
    "netstat -tlnp | grep 5678 || ss -tlnp | grep 5678 || echo 'Порт 5678 не прослушивается'"
)

$commandString = $commands -join "; "

Write-Host "ИНСТРУКЦИЯ:" -ForegroundColor Green
Write-Host "1. Сейчас откроется окно SSH подключения" -ForegroundColor White
Write-Host "2. Введите пароль: $password" -ForegroundColor White
Write-Host "3. Скопируйте весь вывод и отправьте мне" -ForegroundColor White
Write-Host ""
Write-Host "Нажмите любую клавишу для продолжения..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Попытка подключения
ssh -o StrictHostKeyChecking=no $username@$server $commandString

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Скопируйте весь вывод выше и отправьте Claude" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
