<script setup>
import { onMounted, computed, ref } from 'vue';
import { useWalletStore } from '../stores/wallet';
import { useAuthStore } from '../stores/auth';
import { useRouter } from 'vue-router';
import api from '../api/axios';

const walletStore = useWalletStore();
const authStore = useAuthStore();
const router = useRouter();

// Recent transactions for quick view
const recentTxs = ref([]);
const isLoadingTx = ref(false);

onMounted(() => {
    walletStore.fetchStats();
    walletStore.fetchBalance();
    fetchRecentTxs();
});

const fetchRecentTxs = async () => {
    isLoadingTx.value = true;
    try {
        const res = await api.get('/wallet/transactions');
        recentTxs.value = (res.data || []).slice(0, 6);
    } catch (e) {
        console.error('Failed to load transactions:', e);
    } finally {
        isLoadingTx.value = false;
    }
};

const userInitial = computed(() => {
    return (authStore.user.name || authStore.user.email || 'U')[0].toUpperCase();
});

const totalTrades = computed(() => walletStore.stats.wins + walletStore.stats.losses);
const winRate = computed(() => {
    return totalTrades.value > 0
        ? ((walletStore.stats.wins / totalTrades.value) * 100).toFixed(1)
        : '0.0';
});

function typeLabel(type) {
    const labels = {
        'DEPOSIT': 'Deposit', 'WITHDRAWAL': 'Withdrawal',
        'TRADE_WIN': 'Win', 'TRADE_LOSS': 'Loss',
        'TRADE_BUY': 'Buy', 'TRADE_SELL': 'Sell'
    };
    return labels[type] || type;
}

function typeBadgeClass(type) {
    if (type === 'DEPOSIT' || type === 'TRADE_WIN') return 'bg-green-500/10 text-green-400 border border-green-500/20';
    if (type === 'WITHDRAWAL' || type === 'TRADE_LOSS') return 'bg-red-500/10 text-red-400 border border-red-500/20';
    return 'bg-gray-700/50 text-gray-400 border border-gray-600';
}

function formatDate(dateStr) {
    return new Date(dateStr).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' });
}
</script>

<template>
    <div class="h-screen overflow-y-auto p-4 md:p-8 max-w-4xl mx-auto w-full pb-24">
        <!-- Profile Header -->
        <div class="flex flex-col md:flex-row items-center gap-6 mb-8 bg-gray-900/50 p-6 rounded-2xl border border-gray-800">
            <div class="relative">
                <div class="w-24 h-24 rounded-full bg-gradient-to-tr from-yellow-600 to-yellow-400 p-1">
                    <div class="w-full h-full rounded-full bg-gray-900 flex items-center justify-center overflow-hidden">
                        <span class="text-3xl font-bold text-white">{{ userInitial }}</span>
                    </div>
                </div>
            </div>

            <div class="text-center md:text-left flex-1">
                <h2 class="text-3xl font-bold flex items-center justify-center md:justify-start gap-2">
                    {{ authStore.user.name || 'Trader' }}
                    <span v-if="authStore.user.kycStatus === 'approved'"
                        class="bg-green-500/10 text-green-500 text-xs px-2 py-0.5 rounded-full border border-green-500/20 flex items-center gap-1">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3 h-3">
                            <path fill-rule="evenodd"
                                d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z"
                                clip-rule="evenodd" />
                        </svg>
                        Verified
                    </span>
                    <span v-else
                        class="bg-orange-500/10 text-orange-400 text-xs px-2 py-0.5 rounded-full border border-orange-500/20 flex items-center gap-1">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-3 h-3">
                            <path fill-rule="evenodd"
                                d="M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.189-1.458-1.515-2.625L8.485 2.495zM10 5a.75.75 0 01.75.75v3.5a.75.75 0 01-1.5 0v-3.5A.75.75 0 0110 5zm0 9a1 1 0 100-2 1 1 0 000 2z"
                                clip-rule="evenodd" />
                        </svg>
                        Unverified
                    </span>
                </h2>
                <p class="text-gray-400 mt-1">{{ authStore.user.email }}</p>
                <div class="flex items-center justify-center md:justify-start gap-3 mt-3">
                    <div class="bg-yellow-500/20 px-3 py-1 rounded text-xs font-bold text-yellow-500 border border-yellow-500/20">
                        {{ authStore.user.role }}
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="flex flex-col gap-2 shrink-0 w-full md:w-auto">
                <router-link to="/deposit"
                    class="flex items-center justify-center gap-2 px-5 py-2.5 bg-green-500/10 hover:bg-green-500/20 text-green-400 border border-green-500/20 font-bold text-sm rounded-xl transition-all">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5" />
                    </svg>
                    Deposit
                </router-link>
                <router-link to="/dashboard"
                    class="flex items-center justify-center gap-2 px-5 py-2.5 bg-yellow-500/10 hover:bg-yellow-500/20 text-yellow-400 border border-yellow-500/20 font-bold text-sm rounded-xl transition-all">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 3v11.25A2.25 2.25 0 006 16.5h2.25M3.75 3h-1.5m1.5 0h16.5m0 0h1.5m-1.5 0v11.25A2.25 2.25 0 0118 16.5h-2.25m-7.5 0h7.5m-7.5 0l-1 3m8.5-3l1 3m0 0l.5 1.5m-.5-1.5h-9.5m0 0l-.5 1.5" />
                    </svg>
                    Trade
                </router-link>
            </div>
        </div>

        <!-- Wallet Overview -->
        <div class="bg-gray-900 border border-gray-800 rounded-xl p-6 mb-6">
            <h3 class="text-lg font-bold text-white mb-4 flex items-center gap-2">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                    stroke="currentColor" class="w-5 h-5 text-yellow-500">
                    <path stroke-linecap="round" stroke-linejoin="round"
                        d="M21 12a2.25 2.25 0 00-2.25-2.25H15a3 3 0 11-6 0H5.25A2.25 2.25 0 003 12m18 0v6a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 18v-6m18 0V9M3 12V9m18 0a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 9m18 0V6a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 6v3" />
                </svg>
                Wallet Balance
            </h3>
            <p class="text-4xl font-bold text-white">{{ walletStore.wallet.usdt?.toLocaleString('en-US', {
                minimumFractionDigits: 2, maximumFractionDigits: 2 }) }} <span class="text-lg text-yellow-500">USDT</span></p>
            <p class="text-gray-500 text-sm mt-1">Total Assets (USDT)</p>
        </div>

        <div class="grid grid-cols-1 gap-6">
            <!-- Stats Overview -->
            <div class="bg-gray-900 border border-gray-800 rounded-xl p-6 relative overflow-hidden">
                <!-- Decorative BG -->
                <div
                    class="absolute top-0 right-0 w-64 h-64 bg-yellow-500/5 rounded-full blur-3xl -translate-y-1/2 translate-x-1/2 pointer-events-none">
                </div>

                <div class="flex items-center justify-between mb-6">
                    <h3 class="text-lg font-bold text-white flex items-center gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                            stroke="currentColor" class="w-5 h-5 text-yellow-500">
                            <path stroke-linecap="round" stroke-linejoin="round"
                                d="M3.75 3v11.25A2.25 2.25 0 006 16.5h2.25M3.75 3h-1.5m1.5 0h16.5m0 0h1.5m-1.5 0v11.25A2.25 2.25 0 0118 16.5h-2.25m-7.5 0h7.5m-7.5 0l-1 3m8.5-3l1 3m0 0l.5 1.5m-.5-1.5h-9.5m0 0l-.5 1.5m.75-9l3-3 2.148 2.148A12.061 12.061 0 0116.5 7.605" />
                        </svg>
                        Performance Overview
                    </h3>
                </div>

                <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
                    <!-- Total Trades -->
                    <div
                        class="bg-gray-800/40 p-4 rounded-lg border border-gray-700/50 hover:border-gray-600 transition-colors">
                        <label class="text-xs text-gray-500 uppercase font-bold tracking-wider">Total Trades</label>
                        <p class="text-2xl font-bold text-white mt-1">{{ totalTrades }}</p>
                    </div>

                    <!-- Win Rate -->
                    <div
                        class="bg-gray-800/40 p-4 rounded-lg border border-gray-700/50 hover:border-gray-600 transition-colors">
                        <label class="text-xs text-gray-500 uppercase font-bold tracking-wider">Win Rate</label>
                        <p class="text-2xl font-bold mt-1" :class="parseFloat(winRate) >= 50 ? 'text-green-400' : 'text-red-400'">{{ winRate }}%</p>
                    </div>

                    <!-- Net Profit (Highlighted) -->
                    <div
                        class="col-span-2 lg:col-span-2 bg-gradient-to-br from-gray-800 to-gray-900 p-4 rounded-lg border border-gray-700/50 shadow-lg relative overflow-hidden">
                        <div class="absolute inset-0 bg-yellow-500/5"></div>
                        <label class="text-xs text-gray-400 uppercase font-bold tracking-wider relative z-10">Net Profit
                            (PnL)</label>
                        <div class="flex items-center justify-between mt-1 relative z-10">
                            <p class="text-3xl font-bold"
                                :class="walletStore.stats.netProfit >= 0 ? 'text-green-400' : 'text-red-400'">
                                {{ walletStore.stats.netProfit >= 0 ? '+' : '' }}{{ walletStore.stats.netProfit.toLocaleString('en-US', {
                                    minimumFractionDigits: 2, maximumFractionDigits: 2 }) }} USDT
                            </p>
                        </div>
                    </div>

                    <!-- Wins -->
                    <div class="bg-gray-800/40 p-4 rounded-lg border border-gray-700/50">
                        <label class="text-xs text-gray-500 uppercase font-bold">Wins</label>
                        <p class="text-xl font-bold text-green-500 mt-1">{{ walletStore.stats.wins }}</p>
                    </div>
                    <!-- Losses -->
                    <div class="bg-gray-800/40 p-4 rounded-lg border border-gray-700/50">
                        <label class="text-xs text-gray-500 uppercase font-bold">Losses</label>
                        <p class="text-xl font-bold text-red-500 mt-1">{{ walletStore.stats.losses }}</p>
                    </div>
                </div>
            </div>

            <!-- Recent Transactions -->
            <div class="bg-gray-900 border border-gray-800 rounded-xl overflow-hidden">
                <div class="flex items-center justify-between px-5 py-4 border-b border-gray-800">
                    <h3 class="font-bold text-white flex items-center gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 text-yellow-500">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        Recent Transactions
                    </h3>
                    <router-link to="/wallet" class="text-xs text-yellow-500 hover:text-yellow-400 font-semibold transition-colors">View all →</router-link>
                </div>
                <div v-if="isLoadingTx" class="py-8 text-center text-gray-500 text-sm">
                    <div class="animate-spin rounded-full h-6 w-6 border-t-2 border-yellow-500 mx-auto mb-2"></div>
                    Loading...
                </div>
                <div v-else-if="recentTxs.length === 0" class="py-8 text-center text-gray-600 text-sm">No transactions yet</div>
                <div v-else class="divide-y divide-gray-800">
                    <div v-for="tx in recentTxs" :key="tx.id"
                        class="flex items-center gap-3 px-5 py-3 hover:bg-gray-800/20 transition-colors">
                        <span :class="typeBadgeClass(tx.type)" class="text-[10px] font-bold px-2 py-1 rounded-md shrink-0 uppercase tracking-wide min-w-[55px] text-center">
                            {{ typeLabel(tx.type) }}
                        </span>
                        <div class="flex-1 min-w-0">
                            <p class="text-sm font-bold text-white">${{ tx.amount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }} USDT</p>
                            <p class="text-[11px] text-gray-500">{{ formatDate(tx.createdAt) }}</p>
                        </div>
                        <span class="text-xs font-bold"
                            :class="tx.status === 'COMPLETED' ? 'text-green-400' : tx.status === 'PENDING' ? 'text-yellow-400' : 'text-red-400'">
                            {{ tx.status }}
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
