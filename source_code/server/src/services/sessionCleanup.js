/**
 * Session Cleanup Service
 * 
 * Periodically removes stale admin/superuser sessions that haven't
 * sent a heartbeat within the idle threshold. This handles the case
 * where an admin closes their browser tab without logging out.
 * 
 * Regular user sessions are NOT affected — they keep their 24h expiry.
 */
const prisma = require('../db');

const CLEANUP_INTERVAL_MS = 2 * 60 * 1000;  // Run every 2 minutes
const IDLE_THRESHOLD_MS   = 5 * 60 * 1000;  // 5 minutes without heartbeat

let cleanupTimer = null;

async function cleanupStaleSessions() {
    try {
        const threshold = new Date(Date.now() - IDLE_THRESHOLD_MS);

        // Only delete sessions for ADMIN/SUPERUSER that are idle
        const result = await prisma.session.deleteMany({
            where: {
                lastActivity: { lt: threshold },
                user: {
                    role: { in: ['ADMIN', 'SUPERUSER'] }
                }
            }
        });

        if (result.count > 0) {
            console.log(`[SessionCleanup] Revoked ${result.count} idle admin session(s)`);
        }
    } catch (error) {
        console.error('[SessionCleanup] Error cleaning up sessions:', error.message);
    }
}

function startSessionCleanup() {
    // Run immediately on startup
    cleanupStaleSessions();

    // Then run periodically
    cleanupTimer = setInterval(cleanupStaleSessions, CLEANUP_INTERVAL_MS);

    console.log('[SessionCleanup] Started — checking every 2 minutes for idle admin sessions (threshold: 5 min)');
}

function stopSessionCleanup() {
    if (cleanupTimer) {
        clearInterval(cleanupTimer);
        cleanupTimer = null;
        console.log('[SessionCleanup] Stopped');
    }
}

module.exports = { startSessionCleanup, stopSessionCleanup };
