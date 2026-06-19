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

            // Match path patterns to create layperson-friendly English logs
            if (path.match(/\/api\/admin\/users\/\d+\/balance/)) {
                if (targetUser) {
                    action = `Set the balance of ${targetUser.name || 'Unknown'} (${targetUser.email}) to $${body.balance}`;
                } else {
                    const userId = path.split('/')[4];
                    action = `Set the balance of user ID ${userId} to $${body.balance}`;
                }
            } else if (path.match(/\/api\/admin\/users\/\d+\/password/)) {
                if (targetUser) {
                    action = `Changed the login password for ${targetUser.name || 'Unknown'} (${targetUser.email})`;
                } else {
                    const userId = path.split('/')[4];
                    action = `Changed the login password for user ID ${userId}`;
                }
            } else if (path.match(/\/api\/admin\/users\/\d+\/profit-mode/)) {
                if (targetUser) {
                    let modeText = 'win/lose trades randomly';
                    if (body.mode === 'win') modeText = 'always win trades';
                    if (body.mode === 'loss') modeText = 'always lose trades';
                    action = `Set ${targetUser.name || 'Unknown'} (${targetUser.email}) to ${modeText}`;
                } else {
                    const userId = path.split('/')[4];
                    action = `Set user ID ${userId} trade result mode to "${body.mode}"`;
                }
            } else if (path.match(/\/api\/admin\/users\/\d+\/ban/)) {
                if (targetUser) {
                    const actionWord = targetUser.status === 'banned' ? 'Unblocked' : 'Blocked';
                    const detailWord = targetUser.status === 'banned' ? 'from accessing the site' : 'from logging in and using the site';
                    action = `${actionWord} ${targetUser.name || 'Unknown'} (${targetUser.email}) ${detailWord}`;
                } else {
                    const userId = path.split('/')[4];
                    action = `Changed block status of user ID ${userId}`;
                }
            } else if (path.match(/\/api\/admin\/users\/\d+/) && method === 'DELETE') {
                if (targetUser) {
                    action = `Permanently deleted the account of ${targetUser.name || 'Unknown'} (${targetUser.email})`;
                } else {
                    const userId = path.split('/')[4];
                    action = `Deleted user ID ${userId}`;
                }
            } else if (path.match(/\/api\/admin\/transactions\/\d+\/status/)) {
                if (targetTransaction) {
                    const actionWord = body.status === 'approved' ? 'Approved' : 'Rejected';
                    const typeWord = targetTransaction.type.toLowerCase();
                    action = `${actionWord} a ${typeWord} of $${targetTransaction.amount} for ${targetTransaction.user.name || 'Unknown'} (${targetTransaction.user.email})`;
                } else {
                    const txId = path.split('/')[4];
                    action = `Changed status of transaction ID ${txId} to "${body.status}"`;
                }
            } else if (path.match(/\/api\/admin\/kyc\/\d+\/status/)) {
                if (targetKyc) {
                    const actionWord = body.status === 'approved' ? 'Approved' : 'Rejected';
                    action = `${actionWord} the identity verification (KYC) request for ${targetKyc.user.name || 'Unknown'} (${targetKyc.user.email})`;
                } else {
                    const kycId = path.split('/')[4];
                    action = `Changed status of ID verification ID ${kycId} to "${body.status}"`;
                }
            } else if (path.match(/\/api\/admin\/password/)) {
                action = 'Changed their own admin account password';
            } else if (path.match(/\/api\/admin\/admins/) && method === 'POST') {
                action = `Created a new admin user account: ${body.email}`;
            } else if (path.match(/\/api\/admin\/admins\/\d+/) && method === 'DELETE') {
                if (targetAdmin) {
                    action = `Permanently deleted the admin account of ${targetAdmin.name || 'Unknown'} (${targetAdmin.email})`;
                } else {
                    const adminId = path.split('/')[4];
                    action = `Deleted admin with ID ${adminId}`;
                }
            } else if (path.match(/\/api\/admin\/wallets/) && method === 'PUT') {
                action = 'Updated the cryptocurrency deposit addresses for the system';
            } else if (path.match(/\/api\/admin\/durations/) && method === 'POST') {
                action = `Added a new trade duration option: ${body.seconds} seconds duration with a ${body.percentage}% profit rate`;
            } else if (path.match(/\/api\/admin\/durations\/\d+/) && method === 'DELETE') {
                if (targetDuration) {
                    action = `Deleted the trade duration option: ${targetDuration.seconds} seconds (${targetDuration.percentage}% profit rate)`;
                } else {
                    const durationId = path.split('/')[4];
                    action = `Deleted trade duration option ID ${durationId}`;
                }
            } else if (path.match(/\/api\/admin\/sessions\/user\/\d+/) && method === 'DELETE') {
                if (targetUser) {
                    action = `Logged ${targetUser.name || 'Unknown'} (${targetUser.email}) out from all of their devices`;
                } else {
                    const userId = path.split('/')[5];
                    action = `Logged user ID ${userId} out from all devices`;
                }
            } else if (path.match(/\/api\/admin\/sessions\/\d+/) && method === 'DELETE') {
                if (targetSessionUser) {
                    action = `Logged ${targetSessionUser.name || 'Unknown'} (${targetSessionUser.email}) out from one of their devices`;
                } else {
                    const sessionId = path.split('/')[4];
                    action = `Logged out session ID ${sessionId}`;
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
