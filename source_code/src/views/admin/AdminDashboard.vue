<script setup>
import { onMounted } from 'vue';
import { useAdminStore } from '../../stores/admin';
import { useRouter } from 'vue-router';

const adminStore = useAdminStore();
const router = useRouter();

onMounted(() => {
    adminStore.fetchPlatformStats();
});

function formatTime(dateStr) {
    const date = new Date(dateStr);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    const diffHrs = Math.floor(diffMins / 60);
    if (diffHrs < 24) return `${diffHrs}h ago`;
    const diffDays = Math.floor(diffHrs / 24);
    return `${diffDays}d ago`;
}

function formatUSD(val) {
    return (val || 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function typeLabel(type) {
    const labels = {
        'DEPOSIT': 'Deposit', 'WITHDRAWAL': 'Withdrawal',
        'TRADE_BUY': 'Buy', 'TRADE_SELL': 'Sell',
        'TRADE_WIN': 'Win', 'TRADE_LOSS': 'Loss'
    };
    return labels[type] || type;
}

function typeBadgeClass(type) {
    if (type === 'DEPOSIT' || type === 'TRADE_WIN') return 'bg-green-500/15 text-green-400 border border-green-500/30';
    if (type === 'WITHDRAWAL' || type === 'TRADE_LOSS') return 'bg-red-500/15 text-red-400 border border-red-500/30';
    if (type === 'TRADE_BUY') return 'bg-blue-500/15 text-blue-400 border border-blue-500/30';
    return 'bg-gray-700/50 text-gray-400 border border-gray-600/30';
}

function statusBadgeClass(status) {
    if (status === 'COMPLETED') return 'bg-green-500/10 text-green-400';
    if (status === 'PENDING') return 'bg-yellow-500/10 text-yellow-400';
    if (status === 'FAILED') return 'bg-red-500/10 text-red-400';
    return 'bg-gray-700 text-gray-400';
}
</script>

<template>
    <div class="space-y-6">
        <!-- Page Header -->
        <div class="flex items-center justify-between">
            <div>
                <h1 class="text-2xl font-bold text-white">Admin Dashboard</h1>
                <p class="text-gray-500 text-sm mt-0.5">Platform overview & key metrics</p>
            </div>
            <button @click="adminStore.fetchPlatformStats()"
                class="flex items-center gap-2 px-4 py-2 bg-gray-800 hover:bg-gray-700 border border-gray-700 text-gray-300 text-sm rounded-lg transition-all">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0l3.181 3.183a8.25 8.25 0 0013.803-3.7M4.031 9.865a8.25 8.25 0 0113.803-3.7l3.181 3.182m0-4.991v4.99" />
                </svg>
                Refresh
            </button>
        </div>

        <!-- Loading State -->
        <div v-if="adminStore.isLoading" class="flex items-center justify-center py-20">
            <div class="text-center">
                <div class="animate-spin rounded-full h-10 w-10 border-t-2 border-b-2 border-yellow-500 mx-auto mb-3"></div>
                <p class="text-gray-500 text-sm">Loading platform data...</p>
            </div>
        </div>

        <template v-else>
            <!-- ── Row 1: Stat Cards ─────────────────────── -->
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">

                <!-- Total Users -->
                <div class="col-span-1 bg-gray-800 rounded-xl border border-gray-700 p-5 relative overflow-hidden group hover:border-gray-600 transition-colors">
                    <div class="absolute top-0 right-0 w-16 h-16 bg-blue-500/5 rounded-full -translate-y-4 translate-x-4"></div>
                    <div class="w-8 h-8 bg-blue-500/15 rounded-lg flex items-center justify-center mb-3">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4 text-blue-400">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z" />
                        </svg>
                    </div>
                    <p class="text-xs text-gray-500 font-bold uppercase tracking-wider">Total Users</p>
                    <p class="text-2xl font-bold text-white mt-1">{{ adminStore.platformStats.totalUsers.toLocaleString() }}</p>
                    <p v-if="adminStore.platformStats.newUsersToday > 0" class="text-xs text-blue-400 mt-1 font-medium">
                        +{{ adminStore.platformStats.newUsersToday }} today
                    </p>
                </div>

                <!-- Total Deposits -->
                <div class="col-span-1 bg-gray-800 rounded-xl border border-gray-700 p-5 relative overflow-hidden hover:border-gray-600 transition-colors">
                    <div class="absolute top-0 right-0 w-16 h-16 bg-green-500/5 rounded-full -translate-y-4 translate-x-4"></div>
                    <div class="w-8 h-8 bg-green-500/15 rounded-lg flex items-center justify-center mb-3">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4 text-green-400">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5" />
                        </svg>
                    </div>
                    <p class="text-xs text-gray-500 font-bold uppercase tracking-wider">Total Deposits</p>
                    <p class="text-2xl font-bold text-white mt-1">${{ formatUSD(adminStore.platformStats.totalDeposits) }}</p>
                    <p class="text-xs text-gray-600 mt-1">USDT</p>
                </div>

                <!-- Pending KYC -->
                <div class="col-span-1 bg-gray-800 rounded-xl border p-5 relative overflow-hidden transition-colors"
                    :class="adminStore.platformStats.pendingKyc > 0 ? 'border-orange-500/40 hover:border-orange-500/60' : 'border-gray-700 hover:border-gray-600'">
                    <div class="w-8 h-8 bg-orange-500/15 rounded-lg flex items-center justify-center mb-3">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4 text-orange-400">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15 9h3.75M15 12h3.75M15 15h3.75M4.5 19.5h15a2.25 2.25 0 002.25-2.25V6.75A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25v10.5A2.25 2.25 0 004.5 19.5zm6-10.125a1.875 1.875 0 11-3.75 0 1.875 1.875 0 013.75 0zm1.294 6.336a6.721 6.721 0 01-3.17.789 6.721 6.721 0 01-3.168-.789 3.376 3.376 0 016.338 0z" />
                        </svg>
                    </div>
                    <p class="text-xs text-gray-500 font-bold uppercase tracking-wider">Pending KYC</p>
                    <p class="text-2xl font-bold mt-1" :class="adminStore.platformStats.pendingKyc > 0 ? 'text-orange-400' : 'text-white'">
                        {{ adminStore.platformStats.pendingKyc }}
                    </p>
                    <p v-if="adminStore.platformStats.pendingKyc > 0" class="text-xs text-orange-500/80 mt-1 font-medium animate-pulse">Action required</p>
                    <p v-else class="text-xs text-gray-600 mt-1">All clear</p>
                </div>

                <!-- Pending Withdrawals -->
                <div class="col-span-1 bg-gray-800 rounded-xl border p-5 relative overflow-hidden transition-colors"
                    :class="adminStore.platformStats.pendingWithdrawals > 0 ? 'border-red-500/40 hover:border-red-500/60' : 'border-gray-700 hover:border-gray-600'">
                    <div class="w-8 h-8 bg-red-500/15 rounded-lg flex items-center justify-center mb-3">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4 text-red-400">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3" />
                        </svg>
                    </div>
                    <p class="text-xs text-gray-500 font-bold uppercase tracking-wider">Pending Withdrawals</p>
                    <p class="text-2xl font-bold mt-1" :class="adminStore.platformStats.pendingWithdrawals > 0 ? 'text-red-400' : 'text-white'">
                        {{ adminStore.platformStats.pendingWithdrawals }}
                    </p>
                    <p v-if="adminStore.platformStats.pendingWithdrawals > 0" class="text-xs text-red-500/80 mt-1 font-medium">
                        ${{ formatUSD(adminStore.platformStats.pendingWithdrawalAmount) }} pending
                    </p>
                    <p v-else class="text-xs text-gray-600 mt-1">All clear</p>
                </div>
            </div>

            <!-- ── Row 2: Activity + Overview ─────────────── -->
            <div class="grid grid-cols-1 lg:grid-cols-5 gap-6">

                <!-- Recent Activity (3 cols wide) -->
                <div class="lg:col-span-3 bg-gray-800 rounded-xl border border-gray-700">
                    <div class="flex items-center justify-between px-5 py-4 border-b border-gray-700">
                        <h3 class="font-bold text-white">Recent Activity</h3>
                        <span class="text-xs text-gray-500">Last 10 transactions</span>
                    </div>
                    <div v-if="adminStore.platformStats.recentActivity.length === 0"
                        class="flex flex-col items-center justify-center py-12 text-gray-600">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-10 h-10 mb-2 opacity-40">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h3.75M9 15h3.75M9 18h3.75m3 .75H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 00.75-.75 2.25 2.25 0 00-.1-.664m-5.8 0A2.251 2.251 0 0113.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V8.25m0 0H4.875c-.621 0-1.125.504-1.125 1.125v11.25c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V9.375c0-.621-.504-1.125-1.125-1.125H8.25zM6.75 12h.008v.008H6.75V12zm0 3h.008v.008H6.75V15zm0 3h.008v.008H6.75V18z" />
                        </svg>
                        <span class="text-sm">No recent activity</span>
                    </div>
                    <div v-else class="divide-y divide-gray-700/50">
                        <div v-for="activity in adminStore.platformStats.recentActivity" :key="activity.id"
                            class="flex items-center gap-3 px-5 py-3 hover:bg-gray-700/20 transition-colors">
                            <!-- Type Badge -->
                            <span :class="typeBadgeClass(activity.type)" class="text-[10px] font-bold px-2 py-1 rounded-md shrink-0 uppercase tracking-wide w-16 text-center">
                                {{ typeLabel(activity.type) }}
                            </span>
                            <!-- User & Amount -->
                            <div class="flex-1 min-w-0">
                                <p class="text-sm text-white font-bold truncate">${{ formatUSD(activity.amount) }} USDT</p>
                                <p class="text-xs text-gray-500 truncate">{{ activity.userEmail }}</p>
                            </div>
                            <!-- Status + Time -->
                            <div class="text-right shrink-0">
                                <span :class="statusBadgeClass(activity.status)" class="text-[10px] font-bold px-2 py-0.5 rounded block text-center mb-1">
                                    {{ activity.status }}
                                </span>
                                <span class="text-[10px] text-gray-600">{{ formatTime(activity.createdAt) }}</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Panel (2 cols wide) -->
                <div class="lg:col-span-2 flex flex-col gap-4">


                    <!-- Quick Actions -->
                    <div class="bg-gray-800 rounded-xl border border-gray-700 p-5">
                        <h3 class="font-bold text-white mb-3">Quick Actions</h3>
                        <div class="space-y-2">
                            <button @click="router.push('/admin/finance')"
                                class="w-full flex items-center gap-3 px-3 py-2.5 bg-gray-900/60 hover:bg-gray-700 rounded-lg transition-colors text-left group">
                                <span class="w-7 h-7 bg-orange-500/20 rounded-md flex items-center justify-center shrink-0">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4 text-orange-400">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v12m-3-2.818l.879.659c1.171.879 3.07.879 4.242 0 1.172-.879 1.172-2.303 0-3.182C13.536 12.219 12.768 12 12 12c-.725 0-1.45-.22-2.003-.659-1.106-.879-1.106-2.303 0-3.182s2.9-.879 4.006 0l.415.33M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                    </svg>
                                </span>
                                <div class="flex-1 min-w-0">
                                    <p class="text-sm font-semibold text-white">Finance</p>
                                    <p v-if="adminStore.platformStats.pendingWithdrawals > 0" class="text-xs text-orange-400">
                                        {{ adminStore.platformStats.pendingWithdrawals }} pending
                                    </p>
                                    <p v-else class="text-xs text-gray-500">Deposits & withdrawals</p>
                                </div>
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4 text-gray-600 group-hover:text-gray-400">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
                                </svg>
                            </button>

                            <button @click="router.push('/admin/kyc')"
                                class="w-full flex items-center gap-3 px-3 py-2.5 bg-gray-900/60 hover:bg-gray-700 rounded-lg transition-colors text-left group">
                                <span class="w-7 h-7 bg-blue-500/20 rounded-md flex items-center justify-center shrink-0">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4 text-blue-400">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 9h3.75M15 12h3.75M15 15h3.75M4.5 19.5h15a2.25 2.25 0 002.25-2.25V6.75A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25v10.5A2.25 2.25 0 004.5 19.5zm6-10.125a1.875 1.875 0 11-3.75 0 1.875 1.875 0 013.75 0zm1.294 6.336a6.721 6.721 0 01-3.17.789 6.721 6.721 0 01-3.168-.789 3.376 3.376 0 016.338 0z" />
                                    </svg>
                                </span>
                                <div class="flex-1 min-w-0">
                                    <p class="text-sm font-semibold text-white">KYC Review</p>
                                    <p v-if="adminStore.platformStats.pendingKyc > 0" class="text-xs text-blue-400">
                                        {{ adminStore.platformStats.pendingKyc }} awaiting review
                                    </p>
                                    <p v-else class="text-xs text-gray-500">Identity verification</p>
                                </div>
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4 text-gray-600 group-hover:text-gray-400">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
                                </svg>
                            </button>

                            <button @click="router.push('/admin/users')"
                                class="w-full flex items-center gap-3 px-3 py-2.5 bg-gray-900/60 hover:bg-gray-700 rounded-lg transition-colors text-left group">
                                <span class="w-7 h-7 bg-purple-500/20 rounded-md flex items-center justify-center shrink-0">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4 text-purple-400">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z" />
                                    </svg>
                                </span>
                                <div class="flex-1 min-w-0">
                                    <p class="text-sm font-semibold text-white">User Management</p>
                                    <p class="text-xs text-gray-500">{{ adminStore.platformStats.totalUsers }} total users</p>
                                </div>
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4 text-gray-600 group-hover:text-gray-400">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 4.5l7.5 7.5-7.5 7.5" />
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </template>
    </div>
</template>
