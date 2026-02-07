# Avito Webhook Integration с n8n и Telegram

Автоматическая обработка уведомлений от Avito с отправкой в Telegram.

## 🎯 Статус: Production Ready ✅

Webhook полностью настроен и работает!

## 🔗 Ссылки

- **Webhook URL**: `https://n8n.oknaprof59.ru/webhook/avito`
- **n8n Dashboard**: https://n8n.oknaprof59.ru
- **Сервер**: 83.219.243.108
- **Telegram Bot**: [@oknaprof59_bot](https://t.me/oknaprof59_bot)

## ✅ Что работает

- ✅ Прием webhook уведомлений от Avito
- ✅ Парсинг данных о заказах (ID, сумма, клиент, телефон)
- ✅ Отправка форматированных уведомлений в Telegram
- ✅ Быстрый ответ Avito (<2 секунды)
- ✅ Регистрация webhook через Avito API v3

## 📋 Архитектура

### Компоненты

```
Avito API → Webhook → n8n → Telegram Bot → Уведомления
                ↓
         PostgreSQL (опционально)
```

### Стек технологий

- **n8n**: v2.6.4 (workflow automation)
- **Docker Compose**: контейнеризация
- **Traefik**: reverse proxy с SSL
- **PostgreSQL**: 16 Alpine (для хранения данных)
- **Telegram Bot API**: уведомления
- **Avito API**: OAuth2 + Webhooks v3

## 📁 Структура файлов

```
.
├── Avito_Working_Final.json          # Production workflow ⭐
├── Avito_Webhook_Simple.json         # Упрощенная версия
├── Avito_No_Credentials.json         # С hardcoded credentials
├── ИНСТРУКЦИЯ_ПО_НАСТРОЙКЕ.md        # Полная инструкция (RU)
├── НАСТРОЙКА_УЧЕТНЫХ_ДАННЫХ.md       # Гайд по credentials (RU)
├── НОВЫЙ_СЕРВЕР_ДАННЫЕ.md            # Данные сервера
└── README.md                         # Этот файл
```

## 🚀 Быстрый старт

### Если нужно восстановить работу:

1. **Проверьте n8n работает:**
   ```bash
   ssh root@83.219.243.108
   cd ~/n8n-compose
   docker compose ps
   ```

2. **Откройте n8n**: https://n8n.oknaprof59.ru

3. **Импортируйте workflow:**
   - Home → + New workflow
   - ⋮ → Import from File
   - Выберите: `Avito_Working_Final.json`
   - Save → Activate

4. **Тест:**
   ```bash
   curl -X POST https://n8n.oknaprof59.ru/webhook/avito \
     -H "Content-Type: application/json" \
     -d '{"data":{"order_id":"TEST","total_amount":1000,"customer":{"name":"Test","phone":"+79999999999"}}}'
   ```

## 🔧 Настройка

### Учетные данные

#### Telegram Bot
- **Токен**: `8572486644:AAEoc4R0nJVamvlWJhKHesQp2RGQJ8yLTjA`
- **Chat ID**: `378571507`
- **Бот**: [@oknaprof59_bot](https://t.me/oknaprof59_bot)

#### Avito API (Agent_Avito)
- **Client ID**: `CSQfc0XHQJDbIzlT6nI6`
- **Client Secret**: `mxUMrKpNcYVlNjxb5dFwVU-oLnlVE9XvOPk6_E1z`
- **Scope**: `messenger:read messenger:write`

#### PostgreSQL (для будущего расширения)
- **Host**: `localhost:5432`
- **Database**: `avito_db`
- **User**: `avito_user`
- **Password**: `AvitoDB2026Secure!Pass`
- **Container**: `postgres-avito`

### n8n Configuration

```bash
# ~/n8n-compose/.env
DOMAIN_NAME=oknaprof59.ru
SUBDOMAIN=n8n
N8N_TRUST_PROXY=true
N8N_API_ENABLED=true
```

## 📊 Формат данных

### Webhook от Avito

```json
{
  "event_type": "new_order",
  "timestamp": "2026-02-07T16:30:00Z",
  "data": {
    "order_id": "AVITO_12345",
    "status": "pending",
    "total_amount": 15000,
    "customer": {
      "name": "Иван Петров",
      "phone": "+7 (916) 123-45-67",
      "email": "ivan@example.com"
    }
  }
}
```

### Сообщение в Telegram

```
🛒 Новый заказ Avito

📦 ID: AVITO_12345
💰 Сумма: 15000 ₽
👤 Клиент: Иван Петров
📱 Телефон: +7 (916) 123-45-67

⏰ 07.02.2026 19:30
```

## 🗄️ База данных

### Схема таблицы avito_orders

```sql
CREATE TABLE avito_orders (
    id SERIAL PRIMARY KEY,
    external_id VARCHAR(255) UNIQUE NOT NULL,
    order_hash VARCHAR(32) UNIQUE,
    status VARCHAR(50),
    total_amount DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'RUB',
    customer_name VARCHAR(255),
    customer_phone VARCHAR(50),
    customer_email VARCHAR(255),
    items_json JSONB,
    webhook_data JSONB,
    enrichment_data JSONB,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_external_id ON avito_orders(external_id);
CREATE INDEX idx_order_hash ON avito_orders(order_hash);
```

## 🔍 Мониторинг

### Проверка статуса

```bash
# n8n работает?
docker logs n8n-n8n-1 --tail 20

# Webhook доступен?
curl -I https://n8n.oknaprof59.ru/webhook/avito

# PostgreSQL работает?
docker exec -it postgres-avito psql -U avito_user -d avito_db -c "SELECT 1;"
```

### n8n Executions

Все webhook события видны в:
- n8n Dashboard → Executions (левая панель)

## 🛠️ Устранение неполадок

### Webhook не отвечает (404)

```bash
# Перезапустите n8n
ssh root@83.219.243.108
cd ~/n8n-compose
docker compose restart n8n
```

### Не приходят уведомления в Telegram

1. Проверьте токен бота:
   ```bash
   curl https://api.telegram.org/bot8572486644:AAEoc4R0nJVamvlWJhKHesQp2RGQJ8yLTjA/getMe
   ```

2. Проверьте workflow активен в n8n

3. Проверьте Executions на ошибки

### API ошибки при активации workflow

**Workaround:** Перезапустите n8n, он автоматически активирует сохраненные workflows.

```bash
docker compose restart n8n
```

## 🚀 Расширения (TODO)

- [ ] Сохранение заказов в PostgreSQL
- [ ] Авто-ответы клиентам через Avito messenger
- [ ] Обогащение данных из Avito items API
- [ ] Email уведомления для больших заказов
- [ ] Интеграция с CRM/ERP системой
- [ ] Аналитика и дашборд заказов

## 📝 История изменений

### 2026-02-07 - Первый релиз
- ✅ Настроен n8n с Docker Compose
- ✅ Создана схема PostgreSQL
- ✅ Настроен Telegram бот
- ✅ Создан и протестирован webhook workflow
- ✅ Зарегистрирован webhook в Avito API
- ✅ Production готов!

## 👥 Авторы

- Анна (Oknaprof59)
- Claude Sonnet 4.5 (AI Assistant)

## 📄 Лицензия

Proprietary - все права защищены.

---

**Последнее обновление**: 07.02.2026
**Статус**: Production Ready ✅
**Версия**: 1.0.0
