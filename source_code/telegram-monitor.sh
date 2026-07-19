#!/bin/bash

# Configuration
BOT_TOKEN="8950273498:AAFtqKVmPgFVbX3j8CfW69bHc8jwoRkAMok"
CHAT_ID="2002706432"
DOMAIN="https://mycoinflips.com"
CONTAINERS=("source_code-frontend-1" "source_code-server-1" "source_code-db-1")
LOG_FILE="/var/log/mycoinflips-monitor.log"

send_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="${message}" \
        -d parse_mode="HTML" > /dev/null
}

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

ALERT_MESSAGE=""

# 1. Server Resource Monitoring
# CPU Usage (Load average)
LOAD_1M=$(awk '{print $1}' /proc/loadavg)
# Memory Usage
MEM_FREE=$(free -m | awk '/Mem:/ {print $4}')
# Disk Usage (Root partition)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

log_msg "SYSTEM: Load=$LOAD_1M, MemFree=${MEM_FREE}MB, DiskUsage=${DISK_USAGE}%"

if [ "$DISK_USAGE" -gt 85 ]; then
    ALERT_MESSAGE+="⚠️ <b>Disk Space Alert</b>: Usage is at ${DISK_USAGE}%\n"
fi

if [ "$MEM_FREE" -lt 200 ]; then
    ALERT_MESSAGE+="⚠️ <b>Memory Alert</b>: Free memory is low (${MEM_FREE}MB)\n"
fi

# 2. Website Health Check
HTTP_STATUS=$(curl -k -o /dev/null -s -w "%{http_code}\n" "https://localhost")
log_msg "WEBSITE: Status $HTTP_STATUS"
if [ "$HTTP_STATUS" != "200" ] && [ "$HTTP_STATUS" != "301" ]; then
    ALERT_MESSAGE+="🔴 <b>Website Down</b>: $DOMAIN returned HTTP $HTTP_STATUS\n"
fi

# 3. Docker Container Status & Logs
for container in "${CONTAINERS[@]}"; do
    if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        log_msg "CONTAINER: $container is DOWN!"
        ALERT_MESSAGE+="🔴 <b>Container Down</b>: $container\n"
        
        # Get last 5 lines of logs if container exists but is stopped/crashed
        if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
            CONTAINER_LOGS=$(docker logs --tail 5 "$container" 2>&1)
            ALERT_MESSAGE+="<i>Recent Logs for $container:</i>\n<code>$CONTAINER_LOGS</code>\n\n"
        fi
    else
        log_msg "CONTAINER: $container is UP"
    fi
done

# Send Alert if there is any issue
if [ -n "$ALERT_MESSAGE" ]; then
    send_telegram "🚨 <b>SERVER ALERT</b> 🚨\n\n${ALERT_MESSAGE}"
    log_msg "Alert sent to Telegram."
fi
