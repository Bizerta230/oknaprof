# Avito Webhook Processor - Setup Guide

## ✅ Completed Steps

### 1. PostgreSQL Database ✓
- **Status**: Installed and running
- **Container**: `postgres-avito`
- **Database**: `avito_db`
- **User**: `avito_user`
- **Password**: `AvitoDB2026Secure!Pass`
- **Port**: `5432`
- **Tables Created**:
  - `avito_orders` (with indexes)
  - `avito_listings` (with indexes)
  - `webhook_errors`

### 2. Workflow JSON ✓
- **File**: [Avito_Webhook_Processor.json](Avito_Webhook_Processor.json)
- **Nodes**: 13 nodes (10 main flow + 3 error handling)
- **Ready to import into n8n**

---

## 📋 Next Steps

### Step 1: Import Workflow into n8n

1. **Open n8n**: Navigate to https://n8n.oknaprof59.ru
2. **Login**: Use your n8n credentials
   - Email: `oknaprof59@gmail.com`
   - Password: `db2328addf` (if not changed)

3. **Import Workflow**:
   - Click the **"+" button** in top right
   - Select **"Import from File"**
   - Choose `Avito_Webhook_Processor.json`
   - Click **"Import"**

### Step 2: Configure PostgreSQL Credential

1. **Go to Credentials**:
   - Click **Settings** (gear icon) in left sidebar
   - Select **Credentials**
   - Click **"Add Credential"**

2. **Create PostgreSQL Credential**:
   - **Type**: PostgreSQL
   - **Name**: `Avito PostgreSQL`
   - **Host**: `localhost` (or `postgres-avito` if in Docker network)
   - **Database**: `avito_db`
   - **User**: `avito_user`
   - **Password**: `AvitoDB2026Secure!Pass`
   - **Port**: `5432`
   - **SSL Mode**: `Disable`
   - Click **"Create"**

3. **Test Connection**:
   - Click **"Test"** button
   - Should show "Connection successful"

### Step 3: Create Telegram Bot & Configure Credential

#### Create Telegram Bot:

1. **Open Telegram** and message [@BotFather](https://t.me/BotFather)
2. **Send command**: `/newbot`
3. **Follow prompts**:
   - Bot name: `Avito Assistant` (or your choice)
   - Username: `avito_oknaprof_bot` (must end with `_bot`)
4. **Copy the access token** (looks like: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)
5. **Start your bot**: Search for your bot in Telegram and click **"Start"**

#### Get Your Chat ID:

1. **Send a message** to your bot (any message)
2. **Open browser** and visit:
   ```
   https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
   ```
   Replace `<YOUR_TOKEN>` with your bot token
3. **Find your Chat ID** in the response:
   ```json
   {
     "result": [
       {
         "message": {
           "chat": {
             "id": 123456789,  ← This is your Chat ID
             "first_name": "Your Name"
           }
         }
       }
     ]
   }
   ```

#### Configure in n8n:

1. **Go to Credentials** in n8n
2. **Add Credential** → **Telegram**
3. **Configuration**:
   - **Name**: `Avito Notifications Bot`
   - **Access Token**: `<your bot token>`
   - Click **"Create"**

### Step 4: Link Credentials to Workflow Nodes

1. **Open the imported workflow**
2. **Click on each node** that needs credentials:

   **PostgreSQL Nodes** (4 nodes):
   - `Check for Duplicates`
   - `Insert New Order`
   - `Update Existing Order`
   - `Log Error to Database`

   For each node:
   - Click the node
   - In **"Credential to connect with"** dropdown
   - Select **"Avito PostgreSQL"**

   **Telegram Nodes** (2 nodes):
   - `Telegram Notification`
   - `Error Alert`

   For each node:
   - Click the node
   - Edit **"Chat ID"** parameter: Replace `YOUR_TELEGRAM_CHAT_ID` with your actual Chat ID
   - In **"Credential to connect with"** dropdown
   - Select **"Avito Notifications Bot"**

3. **Save the workflow**: Click **"Save"** button in top right

### Step 5: Activate the Workflow

1. **Click the toggle** in top right to activate
2. **Copy the webhook URL**: Should show:
   ```
   https://n8n.oknaprof59.ru/webhook/avito-marketplace
   ```
   This is your production webhook URL

---

## 🧪 Testing

### Test 1: Manual Webhook Test

Use curl to send a test webhook:

```bash
curl -X POST https://n8n.oknaprof59.ru/webhook/avito-marketplace \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "new_order",
    "timestamp": "2026-02-07T12:00:00Z",
    "data": {
      "order_id": "TEST_12345",
      "status": "pending",
      "total_amount": 5000,
      "items": [
        {
          "listing_id": "999",
          "title": "Test Item",
          "price": 5000,
          "quantity": 1
        }
      ],
      "customer": {
        "name": "Test Customer",
        "phone": "+79991234567",
        "email": "test@example.com"
      }
    }
  }'
```

**Expected Results**:
1. ✅ HTTP 200 response within 2 seconds
2. ✅ JSON response: `{"status":"received","webhook_id":"...","timestamp":"...","message":"Order processed successfully"}`
3. ✅ Telegram notification received
4. ✅ New record in database

### Test 2: Verify Database Insert

SSH to server and check database:

```bash
ssh root@83.219.243.108
docker exec -it postgres-avito psql -U avito_user -d avito_db -c \
  "SELECT id, external_id, total_amount, customer_name, created_at FROM avito_orders ORDER BY id DESC LIMIT 5;"
```

Should show your test order with `TEST_12345`.

### Test 3: Check n8n Execution Logs

1. Go to n8n UI: https://n8n.oknaprof59.ru
2. Click **"Executions"** in left sidebar
3. Find the latest execution
4. Click to view details
5. Review each node's output
6. Verify no errors

---

## 🔧 Troubleshooting

### Issue: Workflow Not Receiving Webhooks

**Check**:
1. Workflow is **activated** (toggle in top right)
2. Webhook URL is correct: `https://n8n.oknaprof59.ru/webhook/avito-marketplace`
3. n8n container is running: `docker ps | grep n8n`
4. Traefik is routing correctly

### Issue: Database Connection Failed

**Check**:
1. PostgreSQL container is running: `docker ps | grep postgres-avito`
2. Credentials are correct in n8n
3. Port 5432 is accessible
4. Try connecting manually:
   ```bash
   docker exec -it postgres-avito psql -U avito_user -d avito_db -c "SELECT 1;"
   ```

### Issue: Telegram Notifications Not Sent

**Check**:
1. Bot token is correct
2. Chat ID is correct (numeric)
3. You've started the bot (sent `/start`)
4. Test API call:
   ```bash
   curl "https://api.telegram.org/bot<YOUR_TOKEN>/getMe"
   ```

### Issue: Duplicate Key Errors

This is expected and handled! The workflow checks for duplicates before inserting. If you see this in logs, it means the duplicate detection is working correctly.

---

## 📱 Register Webhook in Avito

### Option 1: Avito Dashboard (if available)

1. Login to [Avito Seller Dashboard](https://www.avito.ru/professionals)
2. Navigate to **Settings** → **API** → **Webhooks**
3. Click **"Add Webhook"**
4. **Configuration**:
   - **URL**: `https://n8n.oknaprof59.ru/webhook/avito-marketplace`
   - **Events**: Select:
     - ✅ `new_order`
     - ✅ `order_status_change`
     - ✅ `listing_update` (optional)
     - ✅ `new_message` (optional)
   - **Secret**: Generate or create your own
5. Click **"Save"**
6. **Test webhook** from Avito dashboard

### Option 2: Avito API (if no dashboard option)

Contact Avito support to register webhook programmatically via their API.

**Note**: Save the webhook secret! You'll need it to validate webhook signatures (currently not implemented but can be added).

---

## 📊 Monitoring

### Daily Checks

1. **Check Telegram notifications** - ensure you're receiving alerts
2. **Review n8n executions** - check for any failures
3. **Monitor database growth**:
   ```bash
   docker exec postgres-avito psql -U avito_user -d avito_db -c \
     "SELECT COUNT(*) as total_orders FROM avito_orders;"
   ```

### Weekly Maintenance

1. **Review error logs**:
   ```bash
   docker exec postgres-avito psql -U avito_user -d avito_db -c \
     "SELECT * FROM webhook_errors ORDER BY occurred_at DESC LIMIT 10;"
   ```

2. **Check n8n container logs**:
   ```bash
   docker logs n8n-n8n-1 --tail 100
   ```

3. **Check PostgreSQL disk usage**:
   ```bash
   docker exec postgres-avito du -sh /var/lib/postgresql/data
   ```

---

## 🚀 Next Steps (Phase 2)

Once basic workflow is stable, consider adding:

1. **Avito API Enrichment**:
   - Add HTTP Request node to fetch additional order details
   - Requires Avito OAuth2 credentials

2. **Email Notifications**:
   - Add Email Send node for high-value orders

3. **External API Integration**:
   - Forward orders to ERP/CRM system

4. **Listing Processing Branch**:
   - Handle `listing_update` events
   - Store in `avito_listings` table

5. **Auto-responses**:
   - Reply to customer messages automatically

6. **Analytics Dashboard**:
   - Track order volumes
   - Monitor response times

---

## 📝 Important Files

- **Workflow JSON**: [Avito_Webhook_Processor.json](Avito_Webhook_Processor.json)
- **Implementation Plan**: [transient-prancing-sutton.md](.claude/plans/transient-prancing-sutton.md)
- **Server Details**: [НОВЫЙ_СЕРВЕР_ДАННЫЕ.md](НОВЫЙ_СЕРВЕР_ДАННЫЕ.md)
- **Project Documentation**: [avito_assist/Claud.md](avito_assist/Claud.md)

---

## ⚙️ Configuration Summary

| Component | Value |
|-----------|-------|
| **Webhook URL** | `https://n8n.oknaprof59.ru/webhook/avito-marketplace` |
| **n8n Instance** | `https://n8n.oknaprof59.ru` |
| **PostgreSQL Host** | `localhost:5432` |
| **Database Name** | `avito_db` |
| **Database User** | `avito_user` |
| **Database Password** | `AvitoDB2026Secure!Pass` |
| **Server IP** | `83.219.243.108` |
| **Server SSH** | `root@83.219.243.108` |

---

## 📞 Support

If you encounter issues:

1. Check this guide first
2. Review [troubleshooting section](#-troubleshooting)
3. Check n8n logs: `docker logs n8n-n8n-1 --tail 100`
4. Check PostgreSQL logs: `docker logs postgres-avito --tail 100`

---

**Status**: ✅ Database Ready | ⏳ Workflow needs manual import and credential configuration | ⏳ Testing pending

**Created**: 2026-02-07
**Last Updated**: 2026-02-07
