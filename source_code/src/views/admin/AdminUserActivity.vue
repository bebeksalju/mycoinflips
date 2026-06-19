<script setup>
import { ref, onMounted, computed, watch } from 'vue';
import api from '../../api/axios';

const isLoading = ref(false);
const transactions = ref([]);
const total = ref(0);
const currentPage = ref(1);
const limit = 50;

const filterType = ref('all');
const filterStatus = ref('all');
const searchQuery = ref('');
let searchDebounce = null;

const totalPages = computed(() => Math.ceil(total.value / limit));

const typeOptions = [
    { value: 'all', label: 'All Types' },
    { value: 'DEPOSIT', label: 'Deposit' },
    { value: 'WITHDRAWAL', label: 'Withdrawal' },
    { value: 'TRADE_WIN', label: 'Trade Win' },
    { value: 'TRADE_LOSS', label: 'Trade Loss' },
    { value: 'TRADE_BUY', label: 'Trade Buy' },
    { value: 'TRADE_SELL', label: 'Trade Sell' },
];

const statusOptions = [
    { value: 'all', label: 'All Status' },
    { value: 'COMPLETED', label: 'Completed' },
    { value: 'PENDING', label: 'Pending' },
    { value: 'FAILED', label: 'Failed' },
];

const fetchActivity = async () => {
    isLoading.value = true;
    try {
        const params = {
            page: currentPage.value,
            limit,
            type: filterType.value,
            status: filterStatus.value,
        };
        if (searchQuery.value) params.search = searchQuery.value;

        const res = await api.get('/admin/user-activity', { params });
        transactions.value = res.data.data;
        total.value = res.data.total;
    } catch (err) {
        console.error('Failed to fetch user activity:', err);
    } finally {
        isLoading.value = false;
    }
};

onMounted(fetchActivity);

watch([filterType, filterStatus], () => {
    currentPage.value = 1;
    fetchActivity();
});

watch(searchQuery, () => {
    clearTimeout(searchDebounce);
    searchDebounce = setTimeout(() => {
        currentPage.value = 1;
        fetchActivity();
    }, 400);
});

function goToPage(p) {
    if (p < 1 || p > totalPages.value) return;
    currentPage.value = p;
    fetchActivity();
}

function formatDateTime(dateStr) {
    if (!dateStr) return '';
    return new Date(dateStr).toLocaleString('en-US', {
        year: 'numeric', month: 'short', day: '2-digit',
        hour: '2-digit', minute: '2-digit', second: '2-digit'
    });
}

function formatUSD(val) {
    return (val || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function typeLabel(type) {
    const labels = {
        DEPOSIT: 'Deposit', WITHDRAWAL: 'Withdrawal',
        TRADE_BUY: 'Buy', TRADE_SELL: 'Sell',
        TRADE_WIN: 'Win', TRADE_LOSS: 'Loss'
    };
    return labels[type] || type;
}

function typeBadgeClass(type) {
    if (type === 'DEPOSIT' || type === 'TRADE_WIN') return 'bg-green-500/15 text-green-400 border border-green-500/30';
    if (type === 'WITHDRAWAL' || type === 'TRADE_LOSS') return 'bg-red-500/15 text-red-400 border border-red-500/30';
    if (type === 'TRADE_BUY') return 'bg-blue-500/15 text-blue-400 border border-blue-500/30';
    if (type === 'TRADE_SELL') return 'bg-purple-500/15 text-purple-400 border border-purple-500/30';
    return 'bg-gray-700/50 text-gray-400 border border-gray-600/30';
}

function statusBadgeClass(status) {
    if (status === 'COMPLETED') return 'bg-green-500/10 text-green-400';
    if (status === 'PENDING') return 'bg-yellow-500/10 text-yellow-400';
    if (status === 'FAILED') return 'bg-red-500/10 text-red-400';
    return 'bg-gray-700 text-gray-400';
}

const visiblePages = computed(() => {
    const pages = [];
    const total = totalPages.value;
    const cur = currentPage.value;
    if (total <= 7) {
        for (let i = 1; i <= total; i++) pages.push(i);
    } else {
        pages.push(1);
        if (cur > 3) pages.push('...');
        for (let i = Math.max(2, cur - 1); i <= Math.min(total - 1, cur + 1); i++) pages.push(i);
        if (cur < total - 2) pages.push('...');
        pages.push(total);
    }
    return pages;
});
</script>

<template>
    <div class="space-y-6">
        <!-- Header -->
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-white">User Activity History</h1>
                <p class="text-gray-500 text-sm mt-0.5">All user transactions — deposits, withdrawals & trades</p>
            </div>
            <div class="flex items-center gap-3">
                <span class="text-sm text-gray-500 bg-gray-800 border border-gray-700 px-3 py-1.5 rounded-lg">
                    {{ total.toLocaleString() }} total records
                </span>
                <button
                    @click="fetchActivity"
                    :disabled="isLoading"
                    class="flex items-center gap-2 px-4 py-2 bg-gray-800 hover:bg-gray-700 border border-gray-700 text-gray-300 text-sm rounded-lg transition-all"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"
                        class="w-4 h-4" :class="{ 'animate-spin': isLoading }">
                        <path stroke-linecap="round" stroke-linejoin="round"
                            d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0l3.181 3.183a8.25 8.25 0 0013.803-3.7M4.031 9.865a8.25 8.25 0 0113.803-3.7l3.181 3.182m0-4.991v4.99" />
                    </svg>
                    Refresh
                </button>
            </div>
        </div>

        <!-- Filters -->
        <div class="flex flex-col sm:flex-row gap-3">
            <!-- Search -->
            <div class="relative flex-1 max-w-sm">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                    stroke="currentColor" class="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-500">
                    <path stroke-linecap="round" stroke-linejoin="round"
                        d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.602 10.602z" />
                </svg>
                <input v-model="searchQuery" type="text" placeholder="Search by name or email..."
                    class="w-full pl-9 pr-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-sm text-white placeholder-gray-500 focus:outline-none focus:border-yellow-500 transition-colors" />
            </div>

            <!-- Type filter -->
            <select v-model="filterType"
                class="px-3 py-2 bg-gray-800 border border-gray-700 rounded-lg text-sm text-white focus:outline-none focus:border-yellow-500 transition-colors">
                <option v-for="opt in typeOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
            </select>

            <!-- Status filter -->
            <select v-model="filterStatus"
                class="px-3 py-2 bg-gray-800 border border-gray-700 rounded-lg text-sm text-white focus:outline-none focus:border-yellow-500 transition-colors">
                <option v-for="opt in statusOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
            </select>
        </div>

        <!-- Table -->
        <div class="bg-gray-800 rounded-xl border border-gray-700 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="border-b border-gray-700 bg-gray-900/50 text-xs font-bold text-gray-400 uppercase tracking-wider">
                            <th class="px-5 py-4">Date & Time</th>
                            <th class="px-5 py-4">User</th>
                            <th class="px-5 py-4">Type</th>
                            <th class="px-5 py-4">Amount</th>
                            <th class="px-5 py-4">Asset</th>
                            <th class="px-5 py-4">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-700/50 text-sm">
                        <!-- Loading skeleton -->
                        <tr v-if="isLoading">
                            <td colspan="6" class="px-5 py-12 text-center">
                                <div class="animate-spin rounded-full h-7 w-7 border-t-2 border-b-2 border-yellow-500 mx-auto mb-3"></div>
                                <p class="text-gray-500 text-sm">Loading activity...</p>
                            </td>
                        </tr>
                        <!-- Empty state -->
                        <tr v-else-if="transactions.length === 0">
                            <td colspan="6" class="px-5 py-14 text-center">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                                    stroke="currentColor" class="w-10 h-10 mx-auto mb-3 text-gray-600">
                                    <path stroke-linecap="round" stroke-linejoin="round"
                                        d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                </svg>
                                <p class="text-gray-500">No activity found</p>
                            </td>
                        </tr>
                        <!-- Rows -->
                        <tr v-else v-for="tx in transactions" :key="tx.id"
                            class="hover:bg-gray-700/20 transition-colors">
                            <td class="px-5 py-3.5 whitespace-nowrap text-xs text-gray-400">
                                {{ formatDateTime(tx.createdAt) }}
                            </td>
                            <td class="px-5 py-3.5">
                                <p class="font-medium text-white text-sm truncate max-w-[160px]">{{ tx.userName }}</p>
                                <p class="text-xs text-gray-500 truncate max-w-[160px]">{{ tx.userEmail }}</p>
                            </td>
                            <td class="px-5 py-3.5">
                                <span :class="typeBadgeClass(tx.type)"
                                    class="text-[10px] font-bold px-2.5 py-1 rounded-md uppercase tracking-wide whitespace-nowrap">
                                    {{ typeLabel(tx.type) }}
                                </span>
                            </td>
                            <td class="px-5 py-3.5 font-mono font-semibold text-white whitespace-nowrap">
                                ${{ formatUSD(tx.amount) }}
                            </td>
                            <td class="px-5 py-3.5 text-gray-400 text-xs">
                                {{ tx.coinSymbol || 'USDT' }}
                            </td>
                            <td class="px-5 py-3.5">
                                <span :class="statusBadgeClass(tx.status)"
                                    class="text-[10px] font-bold px-2.5 py-1 rounded-md uppercase tracking-wide whitespace-nowrap">
                                    {{ tx.status }}
                                </span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>

            <!-- Pagination -->
            <div v-if="totalPages > 1" class="flex items-center justify-between px-5 py-4 border-t border-gray-700">
                <p class="text-xs text-gray-500">
                    Showing {{ (currentPage - 1) * limit + 1 }}–{{ Math.min(currentPage * limit, total) }} of {{ total.toLocaleString() }}
                </p>
                <div class="flex items-center gap-1">
                    <button @click="goToPage(currentPage - 1)" :disabled="currentPage === 1"
                        class="px-2.5 py-1.5 rounded-md text-xs bg-gray-700 text-gray-300 hover:bg-gray-600 disabled:opacity-30 disabled:cursor-not-allowed transition-colors">
                        ←
                    </button>
                    <template v-for="p in visiblePages" :key="p">
                        <span v-if="p === '...'" class="px-2 text-gray-600 text-xs">…</span>
                        <button v-else @click="goToPage(p)"
                            class="px-2.5 py-1.5 rounded-md text-xs font-semibold transition-colors"
                            :class="p === currentPage
                                ? 'bg-yellow-500 text-gray-900'
                                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'">
                            {{ p }}
                        </button>
                    </template>
                    <button @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages"
                        class="px-2.5 py-1.5 rounded-md text-xs bg-gray-700 text-gray-300 hover:bg-gray-600 disabled:opacity-30 disabled:cursor-not-allowed transition-colors">
                        →
                    </button>
                </div>
            </div>
        </div>
    </div>
</template>
