<script setup>
import { onMounted, computed } from 'vue';
import { RouterLink } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { useWalletStore } from '../stores/wallet';
import { useMarketStore } from '../stores/market';

const authStore = useAuthStore();
const walletStore = useWalletStore();
const marketStore = useMarketStore();

onMounted(() => {
    marketStore.fetchMarketOverview();
    walletStore.fetchBalance();
    walletStore.fetchStats();
});

const greeting = computed(() => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
});

const userName = computed(() => {
    return authStore.user.name || authStore.user.email?.split('@')[0] || 'Trader';
});

const totalBalance = computed(() => {
    let total = walletStore.wallet.usdt || 0;
    const coinKey = marketStore.activeCoin.symbol.toLowerCase();
    const coinAmount = walletStore.wallet[coinKey] || 0;
    total += coinAmount * marketStore.currentPrice;
    return total;
});

const formatCurrency = (value) => {
    return (value || 0).toLocaleString('en-US', { style: 'currency', currency: 'USD' });
};

const formatCompact = (num) => {
    if (!num) return '$0';
    if (num >= 1e9) return '$' + (num / 1e9).toFixed(1) + 'B';
    if (num >= 1e6) return '$' + (num / 1e6).toFixed(1) + 'M';
    return '$' + num.toLocaleString();
};

const topCoins = computed(() => marketStore.marketOverview.slice(0, 6));

const recentOrders = computed(() => {
    return (walletStore.orderHistory || []).slice(-5).reverse();
});

const winRate = computed(() => {
    const total = walletStore.stats.wins + walletStore.stats.losses;
    if (total === 0) return 0;
    return ((walletStore.stats.wins / total) * 100).toFixed(1);
});

const quickActions = [
    {
        title: 'Trade',
        desc: 'Start trading crypto',
        route: '/dashboard',
        icon: 'chart',
        gradient: 'from-emerald-500/20 to-teal-500/20',
        border: 'border-emerald-500/30',
        iconColor: 'text-emerald-400',
        hoverBorder: 'hover:border-emerald-500/60'
    },
    {
        title: 'Deposit',
        desc: 'Fund your account',
        route: '/deposit',
        icon: 'upload',
        gradient: 'from-blue-500/20 to-cyan-500/20',
        border: 'border-blue-500/30',
        iconColor: 'text-blue-400',
        hoverBorder: 'hover:border-blue-500/60'
    },
    {
        title: 'Withdraw',
        desc: 'Cash out profits',
        route: '/withdrawal',
        icon: 'download',
        gradient: 'from-violet-500/20 to-purple-500/20',
        border: 'border-violet-500/30',
        iconColor: 'text-violet-400',
        hoverBorder: 'hover:border-violet-500/60'
    },
    {
        title: 'Wallet',
        desc: 'View your assets',
        route: '/wallet',
        icon: 'wallet',
        gradient: 'from-amber-500/20 to-orange-500/20',
        border: 'border-amber-500/30',
        iconColor: 'text-amber-400',
        hoverBorder: 'hover:border-amber-500/60'
    }
];
</script>

<template>
    <div class="min-h-full bg-gray-950 overflow-y-auto">
        <!-- Background Effects -->
        <div class="fixed inset-0 pointer-events-none overflow-hidden">
            <div
                class="absolute -top-40 -right-40 w-[500px] h-[500px] bg-emerald-500/[0.04] rounded-full blur-[120px] animate-pulse"
                style="animation-duration: 8s;">
            </div>
            <div class="absolute -bottom-40 -left-40 w-[400px] h-[400px] bg-blue-500/[0.03] rounded-full blur-[120px] animate-pulse"
                style="animation-duration: 10s; animation-delay: 3s;">
            </div>
        </div>

        <div class="relative z-10 max-w-6xl mx-auto px-4 sm:px-6 py-6 sm:py-8 pb-20 md:pb-8">

            <!-- Welcome Section -->
            <div class="mb-8">
                <div class="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4">
                    <div>
                        <p class="text-gray-500 text-sm font-medium mb-1">{{ greeting }},</p>
                        <h1 class="text-2xl sm:text-3xl font-black text-white tracking-tight">{{ userName }} 👋</h1>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="w-2 h-2 rounded-full animate-pulse"
                            :class="marketStore.connectionStatus.includes('Connected') ? 'bg-emerald-400' : 'bg-yellow-400'"></span>
                        <span class="text-xs text-gray-500 font-medium">{{ marketStore.connectionStatus }}</span>
                    </div>
                </div>
            </div>

            <!-- Portfolio Card -->
            <div
                class="relative rounded-2xl border border-white/[0.06] bg-gradient-to-br from-gray-900 via-gray-900 to-gray-800 p-6 sm:p-8 mb-6 overflow-hidden group">
                <!-- Shimmer effect -->
                <div
                    class="absolute inset-0 bg-gradient-to-r from-transparent via-white/[0.02] to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-1000 ease-in-out">
                </div>

                <div class="relative z-10">
                    <p class="text-gray-400 text-xs uppercase tracking-widest font-semibold mb-2">Estimated Portfolio
                        Value</p>
                    <div class="flex flex-col sm:flex-row sm:items-end gap-3 sm:gap-6 mb-6">
                        <h2 class="text-3xl sm:text-4xl md:text-5xl font-black text-white tabular-nums tracking-tight">
                            {{ formatCurrency(totalBalance) }}
                        </h2>
                        <div class="flex items-center gap-4 text-sm">
                            <div class="flex items-center gap-1.5 px-3 py-1 rounded-lg bg-emerald-500/10 border border-emerald-500/20">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                    stroke-width="2" stroke="currentColor" class="w-3.5 h-3.5 text-emerald-400">
                                    <path stroke-linecap="round" stroke-linejoin="round"
                                        d="M4.5 10.5L12 3m0 0l7.5 7.5M12 3v18" />
                                </svg>
                                <span class="text-emerald-400 font-bold text-xs">{{ winRate }}% Win Rate</span>
                            </div>
                        </div>
                    </div>

                    <!-- $0 Balance Notice -->
                    <div v-if="walletStore.wallet.usdt === 0" class="mb-6 p-4 rounded-xl bg-yellow-500/10 border border-yellow-500/20 flex items-start gap-4 animate-pulse">
                        <div class="p-2 bg-yellow-500/20 rounded-lg shrink-0">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6 text-yellow-500">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z" />
                            </svg>
                        </div>
                        <div>
                            <h3 class="text-yellow-500 font-bold mb-1">Fund Your Account to Start Trading</h3>
                            <p class="text-sm text-yellow-500/80 mb-3">You need a minimum balance to trade. Click below to view deposit instructions.</p>
                            <RouterLink to="/deposit" class="inline-flex items-center gap-2 px-4 py-2 bg-yellow-500 hover:bg-yellow-400 text-gray-900 font-bold text-xs rounded-lg transition-colors">
                                Deposit Now
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-3.5 h-3.5">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
                                </svg>
                            </RouterLink>
                        </div>
                    </div>

                    <!-- Asset Strip -->
                    <div class="grid grid-cols-2 gap-2 sm:gap-3">
                        <div class="px-2.5 py-2 sm:px-4 sm:py-3 rounded-lg sm:rounded-xl bg-white/[0.03] border border-white/[0.04]">
                            <p class="text-[9px] sm:text-[10px] text-gray-500 uppercase tracking-widest font-semibold mb-0.5 sm:mb-1">USDT</p>
                            <p class="text-white font-bold text-xs sm:text-sm tabular-nums">{{
                                formatCurrency(walletStore.wallet.usdt) }}</p>
                        </div>
                        <div class="px-2.5 py-2 sm:px-4 sm:py-3 rounded-lg sm:rounded-xl bg-white/[0.03] border border-white/[0.04]">
                            <p class="text-[9px] sm:text-[10px] text-gray-500 uppercase tracking-widest font-semibold mb-0.5 sm:mb-1">Trades</p>
                            <p class="text-white font-bold text-xs sm:text-sm tabular-nums">{{ walletStore.stats.wins +
                                walletStore.stats.losses }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-2 sm:gap-3 mb-4 sm:mb-6">
                <RouterLink v-for="action in quickActions" :key="action.title" :to="action.route"
                    class="group relative rounded-xl sm:rounded-2xl border p-3 sm:p-5 transition-all duration-300 hover:scale-[1.02] hover:shadow-lg flex sm:block items-center sm:items-start gap-3 sm:gap-0"
                    :class="[action.border, action.hoverBorder]">
                    <div class="absolute inset-0 rounded-xl sm:rounded-2xl bg-gradient-to-br opacity-50 group-hover:opacity-100 transition-opacity"
                        :class="action.gradient"></div>
                    <div class="relative z-10 flex sm:block items-center w-full">
                        <!-- Chart Icon -->
                        <div class="sm:mb-3 flex-none">
                            <svg v-if="action.icon === 'chart'" xmlns="http://www.w3.org/2000/svg" fill="none"
                                viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
                                class="w-6 h-6 sm:w-7 sm:h-7 transition-transform group-hover:scale-110" :class="action.iconColor">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M3.75 3v11.25A2.25 2.25 0 006 16.5h2.25M3.75 3h-1.5m1.5 0h16.5m0 0h1.5m-1.5 0v11.25A2.25 2.25 0 0118 16.5h-2.25m-7.5 0h7.5m-7.5 0l-1 3m8.5-3l1 3m0 0l.5 1.5m-.5-1.5h-9.5m0 0l-.5 1.5m.75-9l3-3 2.148 2.148A12.061 12.061 0 0116.5 7.605" />
                            </svg>
                            <svg v-else-if="action.icon === 'upload'" xmlns="http://www.w3.org/2000/svg" fill="none"
                                viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
                                class="w-6 h-6 sm:w-7 sm:h-7 transition-transform group-hover:scale-110" :class="action.iconColor">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5" />
                            </svg>
                            <svg v-else-if="action.icon === 'download'" xmlns="http://www.w3.org/2000/svg" fill="none"
                                viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
                                class="w-6 h-6 sm:w-7 sm:h-7 transition-transform group-hover:scale-110" :class="action.iconColor">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3" />
                            </svg>
                            <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                stroke-width="1.5" stroke="currentColor"
                                class="w-6 h-6 sm:w-7 sm:h-7 transition-transform group-hover:scale-110" :class="action.iconColor">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M21 12a2.25 2.25 0 00-2.25-2.25H15a3 3 0 11-6 0H5.25A2.25 2.25 0 003 12m18 0v6a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 18v-6m18 0V9M3 12V9m18 0a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 9m18 0V6a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 6v3" />
                            </svg>
                        </div>
                        <div class="flex-1 min-w-0 flex flex-col justify-center">
                            <h3 class="text-white font-bold text-xs sm:text-sm mb-0 sm:mb-0.5">{{ action.title }}</h3>
                            <p class="hidden sm:block text-gray-500 text-[11px]">{{ action.desc }}</p>
                        </div>
                    </div>
                </RouterLink>
            </div>

            <!-- Two Column Layout: Market + Activity -->
            <div class="grid grid-cols-1 lg:grid-cols-5 gap-6">

                <!-- Market Highlights (3 cols) -->
                <div class="lg:col-span-3">
                    <div class="rounded-2xl border border-white/[0.06] bg-white/[0.02] overflow-hidden">
                        <div class="flex items-center justify-between px-5 py-4 border-b border-white/[0.04]">
                            <h3 class="text-white font-bold text-sm">Market Overview</h3>
                            <RouterLink to="/dashboard"
                                class="text-xs text-gray-500 hover:text-emerald-400 font-semibold transition-colors flex items-center gap-1">
                                View All
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                    stroke-width="2" stroke="currentColor" class="w-3 h-3">
                                    <path stroke-linecap="round" stroke-linejoin="round"
                                        d="M8.25 4.5l7.5 7.5-7.5 7.5" />
                                </svg>
                            </RouterLink>
                        </div>

                        <div v-if="topCoins.length === 0" class="p-8 text-center">
                            <div class="animate-spin w-6 h-6 border-2 border-gray-700 border-t-emerald-400 rounded-full mx-auto mb-3"></div>
                            <p class="text-gray-500 text-xs">Loading market data...</p>
                        </div>

                        <div v-else>
                            <div v-for="(coin, index) in topCoins" :key="coin.id"
                                class="flex items-center justify-between px-5 py-3.5 hover:bg-white/[0.02] transition-colors"
                                :class="index < topCoins.length - 1 ? 'border-b border-white/[0.03]' : ''">
                                <div class="flex items-center gap-3">
                                    <span class="text-[10px] text-gray-600 font-mono w-4">{{ index + 1 }}</span>
                                    <img :src="coin.image" :alt="coin.name" class="w-7 h-7 rounded-full" />
                                    <div>
                                        <p class="text-white font-bold text-sm">{{ coin.symbol.toUpperCase() }}</p>
                                        <p class="text-gray-500 text-[11px]">{{ coin.name }}</p>
                                    </div>
                                </div>
                                <div class="text-right">
                                    <p class="text-white font-mono font-bold text-sm tabular-nums">
                                        {{ coin.current_price.toLocaleString('en-US', { style: 'currency', currency:
                                            'USD' }) }}
                                    </p>
                                    <p class="text-[11px] font-bold tabular-nums"
                                        :class="coin.price_change_percentage_24h >= 0 ? 'text-emerald-400' : 'text-red-400'">
                                        {{ coin.price_change_percentage_24h >= 0 ? '+' : '' }}{{
                                            coin.price_change_percentage_24h?.toFixed(2) }}%
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Activity + Stats (2 cols) -->
                <div class="lg:col-span-2 space-y-6">

                    <!-- Trading Stats -->
                    <div class="rounded-2xl border border-white/[0.06] bg-white/[0.02] p-5">
                        <h3 class="text-white font-bold text-sm mb-4">Trading Performance</h3>
                        <div class="space-y-3">
                            <div class="flex items-center justify-between">
                                <span class="text-gray-400 text-xs">Wins</span>
                                <span class="text-emerald-400 font-bold text-sm tabular-nums">{{
                                    walletStore.stats.wins }}</span>
                            </div>
                            <div class="flex items-center justify-between">
                                <span class="text-gray-400 text-xs">Losses</span>
                                <span class="text-red-400 font-bold text-sm tabular-nums">{{
                                    walletStore.stats.losses }}</span>
                            </div>
                            <div class="w-full bg-gray-800 rounded-full h-2 overflow-hidden">
                                <div class="bg-gradient-to-r from-emerald-500 to-teal-400 h-2 rounded-full transition-all duration-500"
                                    :style="{ width: winRate + '%' }"></div>
                            </div>
                            <div class="flex items-center justify-between pt-2 border-t border-white/[0.04]">
                                <span class="text-gray-400 text-xs">Net P&L</span>
                                <span class="font-bold text-sm tabular-nums"
                                    :class="walletStore.stats.netProfit >= 0 ? 'text-emerald-400' : 'text-red-400'">
                                    {{ walletStore.stats.netProfit >= 0 ? '+' : '' }}{{
                                        formatCurrency(walletStore.stats.netProfit) }}
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Recent Activity -->
                    <div class="rounded-2xl border border-white/[0.06] bg-white/[0.02] overflow-hidden">
                        <div class="flex items-center justify-between px-5 py-4 border-b border-white/[0.04]">
                            <h3 class="text-white font-bold text-sm">Recent Activity</h3>
                            <RouterLink to="/dashboard"
                                class="text-xs text-gray-500 hover:text-emerald-400 font-semibold transition-colors">
                                See All
                            </RouterLink>
                        </div>

                        <div v-if="recentOrders.length === 0" class="p-6 text-center">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1"
                                stroke="currentColor" class="w-10 h-10 text-gray-700 mx-auto mb-2">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z" />
                            </svg>
                            <p class="text-gray-600 text-xs">No trades yet</p>
                            <RouterLink to="/dashboard"
                                class="inline-block mt-3 text-xs text-emerald-400 font-semibold hover:underline">
                                Start Trading →
                            </RouterLink>
                        </div>

                        <div v-else>
                            <div v-for="order in recentOrders" :key="order.id || order.timestamp"
                                class="flex items-center justify-between px-5 py-3 border-b border-white/[0.03] last:border-0 hover:bg-white/[0.01] transition-colors">
                                <div class="flex items-center gap-3">
                                    <div class="w-8 h-8 rounded-lg flex items-center justify-center"
                                        :class="order.type === 'BUY' ? 'bg-emerald-500/10' : 'bg-red-500/10'">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                            stroke-width="2" stroke="currentColor" class="w-4 h-4"
                                            :class="order.type === 'BUY' ? 'text-emerald-400' : 'text-red-400'">
                                            <path v-if="order.type === 'BUY'" stroke-linecap="round"
                                                stroke-linejoin="round" d="M4.5 10.5L12 3m0 0l7.5 7.5M12 3v18" />
                                            <path v-else stroke-linecap="round" stroke-linejoin="round"
                                                d="M19.5 13.5L12 21m0 0l-7.5-7.5M12 21V3" />
                                        </svg>
                                    </div>
                                    <div>
                                        <p class="text-white text-xs font-bold">{{ order.type }} {{ order.pair ||
                                            'BTC/USDT' }}</p>
                                        <p class="text-gray-600 text-[10px]">{{ order.amount }} @ {{
                                            formatCurrency(order.price) }}</p>
                                    </div>
                                </div>
                                <div class="text-right">
                                    <p class="text-xs font-bold tabular-nums"
                                        :class="order.result === 'WIN' ? 'text-emerald-400' : order.result === 'LOSS' ? 'text-red-400' : 'text-gray-400'">
                                        {{ order.result || order.status || 'FILLED' }}
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- KYC Status Card -->
                    <div class="rounded-2xl border p-5 transition-all"
                        :class="authStore.user.kycStatus === 'verified' ? 'border-emerald-500/20 bg-emerald-500/[0.03]' : 'border-amber-500/20 bg-amber-500/[0.03]'">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl flex items-center justify-center"
                                :class="authStore.user.kycStatus === 'verified' ? 'bg-emerald-500/10' : 'bg-amber-500/10'">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                    stroke-width="1.5" stroke="currentColor" class="w-5 h-5"
                                    :class="authStore.user.kycStatus === 'verified' ? 'text-emerald-400' : 'text-amber-400'">
                                    <path stroke-linecap="round" stroke-linejoin="round"
                                        d="M9 12.75L11.25 15 15 9.75M21 12c0 1.268-.63 2.39-1.593 3.068a3.745 3.745 0 01-1.043 3.296 3.745 3.745 0 01-3.296 1.043A3.745 3.745 0 0112 21c-1.268 0-2.39-.63-3.068-1.593a3.746 3.746 0 01-3.296-1.043 3.745 3.745 0 01-1.043-3.296A3.745 3.745 0 013 12c0-1.268.63-2.39 1.593-3.068a3.745 3.745 0 011.043-3.296 3.746 3.746 0 013.296-1.043A3.746 3.746 0 0112 3c1.268 0 2.39.63 3.068 1.593a3.746 3.746 0 013.296 1.043 3.746 3.746 0 011.043 3.296A3.745 3.745 0 0121 12z" />
                                </svg>
                            </div>
                            <div class="flex-1">
                                <p class="text-white text-sm font-bold">KYC Verification</p>
                                <p class="text-xs capitalize"
                                    :class="authStore.user.kycStatus === 'verified' ? 'text-emerald-400' : 'text-amber-400'">
                                    {{ authStore.user.kycStatus || 'Not Verified' }}
                                </p>
                            </div>
                            <RouterLink v-if="authStore.user.kycStatus !== 'verified'" to="/kyc"
                                class="px-4 py-1.5 text-[11px] font-bold rounded-lg bg-amber-500/10 border border-amber-500/30 text-amber-400 hover:bg-amber-500/20 transition-colors">
                                Verify Now
                            </RouterLink>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
