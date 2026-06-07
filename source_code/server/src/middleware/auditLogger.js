const prisma = require('../db');

const auditLogger = async (req, res, next) => {
    // Only log write/mutation operations (POST, PUT, DELETE)
    if (req.method === 'GET') {
        return next();
    }

    const { method, originalUrl, body } = req;
    const path = originalUrl.split('?')[0]; // Remove query params

    let targetUser = null;
    let targetTransaction = null;
    let targetKyc = null;
    let targetAdmin = null;
    let targetDuration = null;
    let targetSessionUser = null;

    try {
        // Pre-fetch targets for deletion or updates
        if (path.match(/\/api\/admin\/users\/(\d+)/)) {
            const userId = parseInt(path.match(/\/api\/admin\/users\/(\d+)/)[1]);
            if (userId) {
                targetUser = await prisma.user.findUnique({ where: { id: userId } }).catch(() => null);
            }
        } else if (path.match(/\/api\/admin\/transactions\/(\d+)\/status/)) {
            const txId = parseInt(path.match(/\/api\/admin\/transactions\/(\d+)\/status/)[1]);
            if (txId) {
                targetTransaction = await prisma.transaction.findUnique({
                    where: { id: txId },
                    include: { user: true }
                }).catch(() => null);
            }
        } else if (path.match(/\/api\/admin\/kyc\/(\d+)\/status/)) {
            const kycId = parseInt(path.match(/\/api\/admin\/kyc\/(\d+)\/status/)[1]);
            if (kycId) {
                targetKyc = await prisma.kyc.findUnique({
                    where: { id: kycId },
                    include: { user: true }
                }).catch(() => null);
            }
        } else if (path.match(/\/api\/admin\/admins\/(\d+)/)) {
            const adminId = parseInt(path.match(/\/api\/admin\/admins\/(\d+)/)[1]);
            if (adminId) {
                targetAdmin = await prisma.user.findUnique({ where: { id: adminId } }).catch(() => null);
            }
        } else if (path.match(/\/api\/admin\/durations\/(\d+)/)) {
            const durationId = parseInt(path.match(/\/api\/admin\/durations\/(\d+)/)[1]);
            if (durationId) {
                targetDuration = await prisma.tradingDuration.findUnique({ where: { id: durationId } }).catch(() => null);
            }
        } else if (path.match(/\/api\/admin\/sessions\/user\/(\d+)/)) {
            const userId = parseInt(path.match(/\/api\/admin\/sessions\/user\/(\d+)/)[1]);
            if (userId) {
                targetUser = await prisma.user.findUnique({ where: { id: userId } }).catch(() => null);
            }
        } else if (path.match(/\/api\/admin\/sessions\/(\d+)/)) {
            const sessionId = parseInt(path.match(/\/api\/admin\/sessions\/(\d+)/)[1]);
            if (sessionId) {
                const session = await prisma.session.findUnique({
                    where: { id: sessionId },
                    include: { user: true }
                }).catch(() => null);
                if (session) {
                    targetSessionUser = session.user;
                }
            }
        }
    } catch (err) {
        console.error('Audit logger pre-fetch error:', err.message);
    }

    res.on('finish', async () => {
        // Only log successful operations
        if (res.statusCode < 200 || res.statusCode >= 300) {
            return;
        }

        // Exclude the developer email
        if (!req.user || req.user.email === 'admin@myflipcoin.com') {
            return;
        }

        try {
            let action = '';

            // Match path patterns to create detailed English logs
            if (path.match(/\/api\/admin\/users\/\d+\/balance/)) {
                if (targetUser) {
                    action = `Changed balance of user ${targetUser.name || 'Unknown'} (${targetUser.email}) to $${body.balance}`;
                } else {
                    const userId = path.split('/')[4];
                    action = `Changed balance of user ID ${userId} to $${body.balance}`;
                }
            } else if (path.match(/\/api\/admin\/users\/\d+\/password/)) {
                if (targetUser) {
                    action = `Updated password of user ${targetUser.name || 'Unknown'} (${targetUser.email})`;
                } else {
                    const userId = path.split('/')[4];
                    action = `Updated password of user ID ${userId}`;
                }
            } else if (path.match(/\/api\/admin\/users\/\d+\/profit-mode/)) {
                if (targetUser) {
                    action = `Updated trading result mode of user ${targetUser.name || 'Unknown'} (${targetUser.email}) to "${body.mode}"`;
                } else {
                    const userId = path.split('/')[4];
                    action = `Updated trading result mode of user ID ${userId} to "${body.mode}"`;
                }
            } else if (path.match(/\/api\/admin\/users\/\d+\/ban/)) {
                if (targetUser) {
                    const actionWord = targetUser.status === 'banned' ? 'Unblocked' : 'Blocked';
                    action = `${actionWord} user ${targetUser.name || 'Unknown'} (${targetUser.email})`;
                } else {
                    const userId = path.split('/')[4];
                    action = `Changed block status of user ID ${userId}`;
                }
            } else if (path.match(/\/api\/admin\/users\/\d+/) && method === 'DELETE') {
                if (targetUser) {
                    action = `Deleted user account: ${targetUser.name || 'Unknown'} (${targetUser.email})`;
                } else {
                    const userId = path.split('/')[4];
                    action = `Deleted user ID ${userId}`;
                }
            } else if (path.match(/\/api\/admin\/transactions\/\d+\/status/)) {
                if (targetTransaction) {
                    const actionWord = body.status === 'approved' ? 'Approved' : 'Rejected';
                    const typeWord = targetTransaction.type.toLowerCase();
                    action = `${actionWord} ${typeWord} request of $${targetTransaction.amount} for user ${targetTransaction.user.name || 'Unknown'} (${targetTransaction.user.email})`;
                } else {
                    const txId = path.split('/')[4];
                    action = `Changed status of transaction ID ${txId} to "${body.status}"`;
                }
            } else if (path.match(/\/api\/admin\/kyc\/\d+\/status/)) {
                if (targetKyc) {
                    const actionWord = body.status === 'approved' ? 'Approved' : 'Rejected';
                    action = `${actionWord} KYC verification request for user ${targetKyc.user.name || 'Unknown'} (${targetKyc.user.email})`;
                } else {
                    const kycId = path.split('/')[4];
                    action = `Changed KYC status of ID ${kycId} to "${body.status}"`;
                }
            } else if (path.match(/\/api\/admin\/password/)) {
                action = 'Updated their own admin password';
            } else if (path.match(/\/api\/admin\/admins/) && method === 'POST') {
                action = `Created a new admin account: ${body.email}`;
            } else if (path.match(/\/api\/admin\/admins\/\d+/) && method === 'DELETE') {
                if (targetAdmin) {
                    action = `Deleted admin account: ${targetAdmin.name || 'Unknown'} (${targetAdmin.email})`;
                } else {
                    const adminId = path.split('/')[4];
                    action = `Deleted admin with ID ${adminId}`;
                }
            } else if (path.match(/\/api\/admin\/wallets/) && method === 'PUT') {
                action = 'Updated the admin deposit wallet addresses';
            } else if (path.match(/\/api\/admin\/durations/) && method === 'POST') {
                action = `Added a new trading duration slot: ${body.seconds} seconds with a ${body.percentage}% payout`;
            } else if (path.match(/\/api\/admin\/durations\/\d+/) && method === 'DELETE') {
                if (targetDuration) {
                    action = `Removed trading duration slot: ${targetDuration.seconds} seconds (${targetDuration.percentage}% payout)`;
                } else {
                    const durationId = path.split('/')[4];
                    action = `Removed trading duration ID ${durationId}`;
                }
            } else if (path.match(/\/api\/admin\/sessions\/user\/\d+/) && method === 'DELETE') {
                if (targetUser) {
                    action = `Terminated all active login sessions for user ${targetUser.name || 'Unknown'} (${targetUser.email})`;
                } else {
                    const userId = path.split('/')[5];
                    action = `Terminated all active login sessions for user ID ${userId}`;
                }
            } else if (path.match(/\/api\/admin\/sessions\/\d+/) && method === 'DELETE') {
                if (targetSessionUser) {
                    action = `Terminated login session for user ${targetSessionUser.name || 'Unknown'} (${targetSessionUser.email})`;
                } else {
                    const sessionId = path.split('/')[4];
                    action = `Terminated login session ID ${sessionId}`;
                }
            } else {
                action = `${method} ${originalUrl}`;
            }

            if (action) {
                const ipAddress = req.headers['x-forwarded-for'] || req.socket.remoteAddress || '';
                await prisma.auditLog.create({
                    data: {
                        userId: req.user.userId,
                        userEmail: req.user.email,
                        userName: req.user.name || 'Admin',
                        action,
                        ipAddress
                    }
                });
            }
        } catch (err) {
            console.error('Failed to save audit log:', err.message);
        }
    });

    next();
};

module.exports = { auditLogger };
