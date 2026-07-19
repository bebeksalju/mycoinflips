const TelegramBot = require('node-telegram-bot-api');
const Docker = require('dockerode');
const si = require('systeminformation');
const { exec } = require('child_process');

const token = process.env.TELEGRAM_BOT_TOKEN;
const allowedChatId = parseInt(process.env.TELEGRAM_CHAT_ID);

if (!token || !allowedChatId) {
  console.error("Missing TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID in environment.");
  process.exit(1);
}

// Initialize Bot
const bot = new TelegramBot(token, { polling: true });

// Initialize Docker API
const docker = new Docker({ socketPath: '/var/run/docker.sock' });

// Middleware to check authorization
function isAuthorized(msg) {
  return msg.chat.id === allowedChatId;
}

bot.onText(/\/start|\/help/, (msg) => {
  if (!isAuthorized(msg)) return;
  const helpText = `
🤖 *Server Bot Management*
Berikut daftar command yang tersedia:
/status - Cek beban server (CPU, RAM, Disk)
/containers - Cek status semua Docker container
/logs [container_name] - Lihat 10 baris terakhir dari log container
/backup - Jalankan script backup-to-github.sh secara manual
`;
  bot.sendMessage(msg.chat.id, helpText, { parse_mode: 'Markdown' });
});

bot.onText(/\/status/, async (msg) => {
  if (!isAuthorized(msg)) return;
  
  try {
    const mem = await si.mem();
    const currentLoad = await si.currentLoad();
    const fsSize = await si.fsSize();
    
    // Calculate values
    const loadAvg = currentLoad.avgLoad.toFixed(2);
    const cpuUsage = currentLoad.currentLoad.toFixed(2);
    const memTotal = (mem.total / (1024 ** 3)).toFixed(2);
    const memUsed = (mem.active / (1024 ** 3)).toFixed(2);
    const memPercent = ((mem.active / mem.total) * 100).toFixed(2);
    
    let diskText = '';
    for (const fs of fsSize) {
      if (fs.mount === '/' || fs.mount.includes('vda') || fs.mount.includes('sda')) {
        const diskTotal = (fs.size / (1024 ** 3)).toFixed(2);
        const diskUsed = (fs.used / (1024 ** 3)).toFixed(2);
        diskText += `💾 *Disk (${fs.mount}):* ${diskUsed}GB / ${diskTotal}GB (${fs.use.toFixed(2)}%)\n`;
      }
    }

    const reply = `
📊 *System Status*
🖥️ *CPU Load:* ${loadAvg} (Usage: ${cpuUsage}%)
🧠 *Memory:* ${memUsed}GB / ${memTotal}GB (${memPercent}%)
${diskText}
`;
    bot.sendMessage(msg.chat.id, reply, { parse_mode: 'Markdown' });
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Error getting status: ${error.message}`);
  }
});

bot.onText(/\/containers/, async (msg) => {
  if (!isAuthorized(msg)) return;
  
  try {
    const containers = await docker.listContainers({ all: true });
    if (containers.length === 0) {
      return bot.sendMessage(msg.chat.id, "Tidak ada container ditemukan.");
    }
    
    let reply = "📦 *Docker Containers:*\n\n";
    containers.forEach(c => {
      const name = c.Names[0].replace('/', '');
      const state = c.State;
      const status = c.Status;
      
      const icon = state === 'running' ? '✅' : '🔴';
      reply += `${icon} *${name}*\nStatus: ${status}\n\n`;
    });
    
    bot.sendMessage(msg.chat.id, reply, { parse_mode: 'Markdown' });
  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Error getting containers: ${error.message}`);
  }
});

bot.onText(/\/logs(?: (.+))?/, async (msg, match) => {
  if (!isAuthorized(msg)) return;
  
  const containerName = match[1];
  if (!containerName) {
    return bot.sendMessage(msg.chat.id, "⚠️ Harap sebutkan nama container. Contoh: `/logs source_code-server-1`", { parse_mode: 'Markdown' });
  }
  
  try {
    const container = docker.getContainer(containerName.trim());
    const logBuffer = await container.logs({ stdout: true, stderr: true, tail: 10 });
    
    // Clean up docker log binary headers (8 bytes at start of each line)
    // A quick hack is just stripping non-printable characters for standard readable logs
    let readableLogs = logBuffer.toString('utf8').replace(/[\x00-\x1F\x7F-\x9F]/g, "\n");
    
    // We can also just use exec to fetch it natively, which is sometimes cleaner
    exec(`docker logs --tail 10 ${containerName.trim()}`, (error, stdout, stderr) => {
       const logs = stdout || stderr;
       if (!logs) {
           return bot.sendMessage(msg.chat.id, `Log kosong untuk ${containerName}.`);
       }
       bot.sendMessage(msg.chat.id, `📝 *Logs for ${containerName}*\n\`\`\`\n${logs.trim().substring(0, 3000)}\n\`\`\``, { parse_mode: 'Markdown' });
    });

  } catch (error) {
    bot.sendMessage(msg.chat.id, `❌ Error getting logs: ${error.message}`);
  }
});

bot.onText(/\/backup/, (msg) => {
  if (!isAuthorized(msg)) return;
  
  bot.sendMessage(msg.chat.id, "🔄 *Memulai proses backup ke GitHub...*\nHarap tunggu sebentar.", { parse_mode: 'Markdown' });
  
  exec('cd /app/source_code && ./backup-to-github.sh', (error, stdout, stderr) => {
    if (error) {
      return bot.sendMessage(msg.chat.id, `❌ *Backup Gagal!*\n\n\`\`\`\n${error.message}\n\`\`\``, { parse_mode: 'Markdown' });
    }
    
    const lastLines = stdout.split('\n').slice(-15).join('\n');
    bot.sendMessage(msg.chat.id, `✅ *Backup Selesai!*\n\n\`\`\`\n${lastLines}\n\`\`\``, { parse_mode: 'Markdown' });
  });
});

console.log("Telegram Bot started!");
