const prisma = require('../db');

const executeTrade = async (req, res) => {
    try {
        const userId = req.user.userId;
        const { type, coinSymbol, amount, price, total } = req.body;

        // Validation
        if (!type || !coinSymbol || !amount || !price || !total) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        const symbolKey = coinSymbol.toLowerCase();

        // Transaction for Atomicity
        const result = await prisma.$transaction(async (tx) => {
            // 1. Get Wallet
            const wallet = await tx.wallet.findUnique({
                where: { userId },
            });

            if (!wallet) throw new Error('Wallet not found');

            let newBalance = wallet.balance;
            let newAssets = wallet.assets || {}; // Ensure it's an object

            // 2. Logic based on Type
            if (type.toUpperCase() === 'BUY') {
                // Check USDT Balance
                if (wallet.balance < total) {
                    throw new Error('Insufficient USDT Balance');
                }

                // Deduct USDT
                newBalance -= parseFloat(total);

                // Add Coin
                const currentCoinBalance = parseFloat(newAssets[symbolKey] || 0);
                newAssets[symbolKey] = currentCoinBalance + parseFloat(amount);

            } else if (type.toUpperCase() === 'SELL') {
                // Check Coin Balance
                const currentCoinBalance = parseFloat(newAssets[symbolKey] || 0);
                if (currentCoinBalance < amount) {
                    throw new Error(`Insufficient ${coinSymbol} Balance`);
                }

                // Deduct Coin
                newAssets[symbolKey] = currentCoinBalance - parseFloat(amount);

                // Add USDT
                newBalance += parseFloat(total);

            } else {
                throw new Error('Invalid Trade Type');
            }

            // 3. Update Wallet
            const updatedWallet = await tx.wallet.update({
                where: { userId },
                data: {
                    balance: newBalance,
                    assets: newAssets,
                },
            });

            // 4. Create Transaction Record
            const transaction = await tx.transaction.create({
                data: {
                    userId,
                    type: type.toUpperCase() === 'BUY' ? 'TRADE_BUY' : 'TRADE_SELL',
                    amount: parseFloat(amount),
                    price: parseFloat(price),
                    coinSymbol: coinSymbol.toUpperCase(),
                    status: 'COMPLETED',
                },
            });

            return { wallet: updatedWallet, transaction };
        });

        res.json({ success: true, ...result });

    } catch (error) {
        console.error('Trade Error:', error);
        res.status(400).json({ success: false, error: error.message });
    }
};

const openGame = async (req, res) => {
    try {
        const userId = req.user.userId;
        const { amount, pair, durationSeconds, type } = req.body; // type = 'UP' or 'DOWN'

        if (!amount || amount <= 0 || !pair) {
            return res.status(400).json({ error: 'Invalid data' });
        }

        const result = await prisma.$transaction(async (tx) => {
            const wallet = await tx.wallet.findUnique({ where: { userId } });
            if (!wallet) throw new Error('Wallet not found');

            const user = await tx.user.findUnique({ where: { id: userId }, select: { profitMode: true } });

            let minBalance = 0;
            if (durationSeconds) {
                const duration = await tx.tradingDuration.findUnique({ where: { seconds: parseInt(durationSeconds) } });
                if (duration) minBalance = duration.minBalance || 0;
            }

            if (wallet.balance < minBalance) {
                throw new Error(`Minimum balance of $${minBalance} required for this duration`);
            }

            if (wallet.balance < amount) throw new Error('Insufficient balance');

            // Deduct immediately
            const updatedWallet = await tx.wallet.update({
                where: { userId },
                data: { balance: wallet.balance - parseFloat(amount) },
            });

            // Create PENDING transaction to prevent bypassing
            const transaction = await tx.transaction.create({
                data: {
                    userId,
                    type: type === 'UP' ? 'TRADE_BUY' : 'TRADE_SELL',
                    amount: parseFloat(amount),
                    price: 0,
                    coinSymbol: pair,
                    status: 'PENDING',
                },
            });

            return { wallet: updatedWallet, transactionId: transaction.id, profitMode: user?.profitMode || 'random' };
        });

        res.json({ success: true, wallet: result.wallet, transactionId: result.transactionId, profitMode: result.profitMode });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
};

const settleGame = async (req, res) => {
    try {
        const userId = req.user.userId;
        const { result, amount, profit, pair, durationSeconds, transactionId } = req.body;

        console.log('--- DEBUG SETTLEMENT PAYLOAD ---', { result, amount, pair, transactionId, body: req.body });

        if (!['win', 'loss'].includes(result) || !amount || !pair || !transactionId) {
            console.error('Validation failed. Returning 400.');
            return res.status(400).json({ error: 'Invalid settlement data' });
        }

        const dbResult = await prisma.$transaction(async (tx) => {
            // Verify PENDING transaction exists
            const existingTx = await tx.transaction.findUnique({ where: { id: parseInt(transactionId) } });
            if (!existingTx || existingTx.userId !== userId || existingTx.status !== 'PENDING') {
                throw new Error('Invalid or already settled transaction');
            }

            const wallet = await tx.wallet.findUnique({ where: { userId } });
            if (!wallet) throw new Error('Wallet not found');

            const user = await tx.user.findUnique({ where: { id: userId }, select: { profitMode: true } });

            // Look up duration percentage from DB
            let percentage = 80; // default fallback
            if (durationSeconds) {
                const duration = await tx.tradingDuration.findUnique({ where: { seconds: parseInt(durationSeconds) } });
                if (duration) {
                    percentage = duration.percentage;
                    // Skip minBalance check here since openGame already allowed it
                }
            }

            // SERVER-SIDE PROFIT MODE OVERRIDE
            let finalResult = result;
            if (user?.profitMode === 'win') {
                finalResult = 'win';
            } else if (user?.profitMode === 'loss') {
                finalResult = 'loss';
            }

            let newBalance = wallet.balance;
            let actualProfit = 0;
            let actualLoss = 0;

            if (finalResult === 'win') {
                actualProfit = parseFloat(amount) * (percentage / 100);
                newBalance += (parseFloat(amount) + actualProfit); // Return initial bet + profit
            } else {
                actualLoss = parseFloat(amount) * (percentage / 100);
                // Refund the remaining portion of the original wager
                newBalance += (parseFloat(amount) - actualLoss);
            }

            // 3. Update Wallet
            const updatedWallet = await tx.wallet.update({
                where: { userId },
                data: { balance: newBalance },
            });

            // 4. Update Transaction
            const transaction = await tx.transaction.update({
                where: { id: parseInt(transactionId) },
                data: {
                    type: finalResult === 'win' ? 'TRADE_WIN' : 'TRADE_LOSS',
                    status: 'COMPLETED',
                },
            });

            return { wallet: updatedWallet, transaction, finalResult, actualProfit, actualLoss };
        });

        res.json({ success: true, ...dbResult });

    } catch (error) {
        console.error('Settlement Error:', error);
        res.status(400).json({ success: false, error: error.message });
    }
};

const getStats = async (req, res) => {
    try {
        const userId = req.user.userId;

        const wins = await prisma.transaction.count({
            where: { userId, type: 'TRADE_WIN' }
        });

        const losses = await prisma.transaction.count({
            where: { userId, type: 'TRADE_LOSS' }
        });

        // Calculate Net Profit from actual transactions
        // WIN: profit = amount * 0.8 (80% payout)
        // LOSS: loss = -amount
        const winTxs = await prisma.transaction.findMany({
            where: { userId, type: 'TRADE_WIN' },
            select: { amount: true }
        });
        const lossTxs = await prisma.transaction.findMany({
            where: { userId, type: 'TRADE_LOSS' },
            select: { amount: true }
        });

        const totalWinProfit = winTxs.reduce((sum, tx) => sum + (tx.amount * 0.8), 0);
        const totalLossAmount = lossTxs.reduce((sum, tx) => sum + tx.amount, 0);
        const netProfit = totalWinProfit - totalLossAmount;

        res.json({
            wins,
            losses,
            netProfit: parseFloat(netProfit.toFixed(2)),
            totalTrades: wins + losses
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Admin: Platform-wide statistics
const getAdminStats = async (req, res) => {
    try {
        const totalUsers = await prisma.user.count({ where: { role: 'USER' } });
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        const newUsersToday = await prisma.user.count({ where: { role: 'USER', createdAt: { gte: today } } });

        const transactions = await prisma.transaction.findMany({
            where: { status: 'COMPLETED' },
            select: { type: true, amount: true }
        });

        const totalDeposits = transactions.filter(t => t.type === 'DEPOSIT').reduce((sum, t) => sum + t.amount, 0);
        const totalWithdrawals = transactions.filter(t => t.type === 'WITHDRAWAL').reduce((sum, t) => sum + t.amount, 0);

        const pendingWithdrawalsList = await prisma.transaction.findMany({ where: { type: 'WITHDRAWAL', status: 'PENDING' } });
        const pendingWithdrawalAmount = pendingWithdrawalsList.reduce((sum, t) => sum + t.amount, 0);

        const winTrades = transactions.filter(t => t.type === 'TRADE_WIN');
        const lossTrades = transactions.filter(t => t.type === 'TRADE_LOSS');
        
        // Revenue estimate: Platform keeps the loss, loses the win payout
        // Simplified: (Sum of Trade Loss amounts) - (Sum of Trade Win payouts)
        const revenue = lossTrades.reduce((sum, t) => sum + t.amount, 0) - winTrades.reduce((sum, t) => sum + (t.amount * 0.8), 0);

        const pendingKyc = await prisma.kyc.count({ where: { status: 'PENDING' } });

        const recentActivityRaw = await prisma.transaction.findMany({
            take: 10,
            orderBy: { createdAt: 'desc' },
            include: { user: { select: { name: true, email: true } } }
        });

        const recentActivity = recentActivityRaw.map(tx => ({
            id: tx.id,
            type: tx.type,
            amount: tx.amount,
            status: tx.status,
            createdAt: tx.createdAt,
            userEmail: tx.user?.email || 'Unknown',
            userName: tx.user?.name || 'Unknown'
        }));

        res.json({
            totalUsers,
            newUsersToday,
            totalDeposits,
            totalWithdrawals,
            pendingWithdrawals: pendingWithdrawalsList.length,
            pendingWithdrawalAmount,
            revenue: parseFloat(revenue.toFixed(2)),
            winCount: winTrades.length,
            lossCount: lossTrades.length,
            pendingKyc,
            recentActivity
        });
    } catch (error) {
        console.error('Admin Stats Error:', error);
        res.status(500).json({ error: error.message });
    }
};

module.exports = {
    executeTrade,
    openGame,
    settleGame,
    getStats,
    getAdminStats
};
