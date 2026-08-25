<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { useAdminStore } from '../stores/admin';
import { io } from 'socket.io-client';
import api from '../api/axios';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();
const adminStore = useAdminStore();
const isSidebarOpen = ref(false);
const unreadChatCount = ref(0);

let chatSocket = null;
let heartbeatInterval = null;
let pendingCountsInterval = null;
let visibilityTimer = null;

const HEARTBEAT_INTERVAL_MS = 60 * 1000;
const VISIBILITY_TIMEOUT_MS = 5 * 60 * 1000;

const isSuperuser = computed(() => authStore.user.role === 'SUPERUSER');

const pendingDeposits = computed(() => {
    return adminStore.transactions.filter(t => t.status === 'pending' && t.type === 'DEPOSIT').length;
});

const pendingKyc = computed(() => {
    return adminStore.kycRequests.filter(k => k.status === 'pending').length;
});

const primaryNav = computed(() => {
    const items = [
        { key: 'dashboard', label: 'Dashboard', to: '/admin/dashboard', superuserOnly: true },
        { key: 'users', label: 'Users', to: '/admin/users' },
        { key: 'finance', label: 'Finance', to: '/admin/finance', superuserOnly: true },
        { key: 'kyc', label: 'KYC', to: '/admin/kyc', superuserOnly: true },
        { key: 'wallet', label: 'Wallet', to: '/admin/wallet', superuserOnly: true },
        { key: 'chat', label: 'Chat', to: '/admin/chat', superuserOnly: true },
        { key: 'email', label: 'Email', to: '/admin/email' }
    ];
    return items.filter(item => !item.superuserOnly || isSuperuser.value);
});

const systemNav = computed(() => {
    const items = [
        { key: 'admins', label: 'Admins', to: '/admin/admins', superuserOnly: true },
        { key: 'activity', label: 'User Activity', to: '/admin/user-activity', superuserOnly: true },
        { key: 'logs', label: 'Activity Logs', to: '/admin/logs', superuserOnly: true },
        { key: 'settings', label: 'Settings', to: '/admin/settings', superuserOnly: true },
        { key: 'profile', label: 'Profile', to: '/admin/profile' }
    ];
    return items.filter(item => !item.superuserOnly || isSuperuser.value);
});

const badgeFor = (key) => {
    if (key === 'finance') return pendingDeposits.value;
    if (key === 'kyc') return pendingKyc.value;
    if (key === 'chat') return unreadChatCount.value;
    return 0;
};

const fetchPendingCounts = async () => {
    try {
        await Promise.all([
            adminStore.fetchTransactions(),
            adminStore.fetchKycRequests()
        ]);
    } catch (err) {
        console.error('Failed to fetch pending counts:', err);
    }
};

const forceLogout = () => {
    authStore.logout();
    router.push('/admin/login');
};

const sendHeartbeat = async () => {
    try {
        await api.post('/auth/heartbeat');
    } catch (error) {
        if (error.response?.status === 401) {
            forceLogout();
        }
    }
};

const handleBeforeUnload = () => {
    const token = localStorage.getItem('token');
    if (!token) return;

    fetch('/api/auth/logout', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({}),
        keepalive: true
    }).catch(() => {});
};

const handleVisibilityChange = () => {
    if (document.hidden) {
        visibilityTimer = setTimeout(() => {
            forceLogout();
        }, VISIBILITY_TIMEOUT_MS);
    } else {
        if (visibilityTimer) {
            clearTimeout(visibilityTimer);
            visibilityTimer = null;
        }
        sendHeartbeat();
    }
};

const logout = async () => {
    isSidebarOpen.value = false;
    await authStore.logout();
    router.push('/login');
};

onMounted(() => {
    fetchPendingCounts();
    pendingCountsInterval = setInterval(fetchPendingCounts, 30000);

    sendHeartbeat();
    heartbeatInterval = setInterval(sendHeartbeat, HEARTBEAT_INTERVAL_MS);

    window.addEventListener('beforeunload', handleBeforeUnload);
    document.addEventListener('visibilitychange', handleVisibilityChange);

    const token = localStorage.getItem('token');
    if (token) {
        chatSocket = io('/chat', {
            auth: { token },
            transports: ['websocket', 'polling']
        });

        chatSocket.on('chat:new-message', () => {
            if (route.path !== '/admin/chat') unreadChatCount.value++;
        });
        chatSocket.on('finance:new-transaction', () => {
            adminStore.fetchTransactions();
        });
        chatSocket.on('kyc:new-request', (data) => {
            adminStore.addKycRequest(data);
        });
    }
});

onUnmounted(() => {
    if (pendingCountsInterval) clearInterval(pendingCountsInterval);
    if (heartbeatInterval) clearInterval(heartbeatInterval);
    if (visibilityTimer) clearTimeout(visibilityTimer);

    window.removeEventListener('beforeunload', handleBeforeUnload);
    document.removeEventListener('visibilitychange', handleVisibilityChange);

    if (chatSocket) chatSocket.disconnect();
});

watch(() => route.path, (newPath) => {
    isSidebarOpen.value = false;
    if (newPath === '/admin/chat') unreadChatCount.value = 0;
});
</script>

<template>
    <div class="flex h-screen bg-gray-900 text-white font-sans">
        <aside class="hidden md:flex w-64 shrink-0 bg-gray-800 border-r border-gray-700 flex-col">
            <div class="h-16 flex items-center px-6 border-b border-gray-700">
                <span class="text-xl font-bold text-yellow-500 tracking-wider">ADMIN PANEL</span>
            </div>

            <nav class="flex-1 overflow-y-auto py-4 px-3 space-y-1">
                <router-link
                    v-for="item in primaryNav"
                    :key="item.key"
                    :to="item.to"
                    class="flex items-center justify-between gap-3 px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-700 hover:text-white transition-colors"
                    active-class="bg-gray-700 text-white ring-1 ring-yellow-500/30"
                >
                    <span class="flex items-center gap-3">
                        <span class="w-2 h-2 rounded-full bg-gray-600"></span>
                        {{ item.label }}
                    </span>
                    <span
                        v-if="badgeFor(item.key) > 0"
                        class="min-w-5 h-5 px-1 rounded-full bg-red-500 text-white text-[10px] font-bold flex items-center justify-center"
                    >{{ badgeFor(item.key) > 9 ? '9+' : badgeFor(item.key) }}</span>
                </router-link>

                <div class="border-t border-gray-700 mt-4 pt-4">
                    <p class="px-3 text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">System</p>
                    <router-link
                        v-for="item in systemNav"
                        :key="item.key"
                        :to="item.to"
                        class="flex items-center gap-3 px-3 py-3 rounded-lg text-gray-400 hover:bg-gray-700 hover:text-white transition-colors"
                        active-class="bg-gray-700 text-white ring-1 ring-yellow-500/30"
                    >
                        <span class="w-2 h-2 rounded-full bg-gray-600"></span>
                        {{ item.label }}
                    </router-link>
                </div>
            </nav>

            <div class="p-4 border-t border-gray-700">
                <button @click="logout" class="w-full px-4 py-2 text-left text-sm text-red-400 hover:text-red-300 hover:bg-red-900/20 rounded-lg transition-colors">
                    Logout
                </button>
            </div>
        </aside>

        <div v-if="isSidebarOpen" class="fixed inset-0 z-50 md:hidden">
            <button
                class="absolute inset-0 w-full h-full bg-black/70"
                aria-label="Close admin menu"
                @click="isSidebarOpen = false"
            ></button>

            <aside class="absolute inset-y-0 left-0 w-[min(82vw,320px)] bg-gray-800 border-r border-gray-700 shadow-2xl flex flex-col">
                <div class="h-16 flex items-center justify-between px-5 border-b border-gray-700">
                    <span class="font-bold text-yellow-500 tracking-wider">MCFOPTION ADMIN</span>
                    <button @click="isSidebarOpen = false" class="w-10 h-10 rounded-lg text-gray-400 hover:bg-gray-700 hover:text-white" aria-label="Close menu">✕</button>
                </div>

                <nav class="flex-1 overflow-y-auto p-3 space-y-1">
                    <router-link
                        v-for="item in primaryNav"
                        :key="item.key"
                        :to="item.to"
                        class="flex items-center justify-between gap-3 px-4 py-3.5 rounded-xl text-gray-300 hover:bg-gray-700 transition-colors"
                        active-class="bg-gray-700 text-white ring-1 ring-yellow-500/30"
                    >
                        <span>{{ item.label }}</span>
                        <span
                            v-if="badgeFor(item.key) > 0"
                            class="min-w-5 h-5 px-1 rounded-full bg-red-500 text-white text-[10px] font-bold flex items-center justify-center"
                        >{{ badgeFor(item.key) > 9 ? '9+' : badgeFor(item.key) }}</span>
                    </router-link>

                    <div class="border-t border-gray-700 mt-4 pt-4">
                        <p class="px-4 text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">System</p>
                        <router-link
                            v-for="item in systemNav"
                            :key="item.key"
                            :to="item.to"
                            class="block px-4 py-3.5 rounded-xl text-gray-300 hover:bg-gray-700 transition-colors"
                            active-class="bg-gray-700 text-white ring-1 ring-yellow-500/30"
                        >{{ item.label }}</router-link>
                    </div>
                </nav>

                <div class="p-4 border-t border-gray-700">
                    <button @click="logout" class="w-full px-4 py-3 rounded-xl bg-red-500/10 text-red-400 font-semibold text-left">
                        Logout
                    </button>
                </div>
            </aside>
        </div>

        <main class="flex-1 flex flex-col min-w-0 overflow-hidden">
            <header class="md:hidden h-16 shrink-0 bg-gray-800 border-b border-gray-700 flex items-center justify-between px-4">
                <div>
                    <span class="text-lg font-bold text-yellow-500">MCFOPTION</span>
                    <span class="text-xs text-gray-500 ml-2">ADMIN</span>
                </div>
                <button
                    @click="isSidebarOpen = true"
                    class="w-11 h-11 rounded-xl border border-gray-700 flex items-center justify-center text-gray-300 hover:bg-gray-700"
                    aria-label="Open admin menu"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
                    </svg>
                </button>
            </header>

            <div class="flex-1 overflow-auto p-4 sm:p-6 md:p-8">
                <router-view />
            </div>
        </main>
    </div>
</template>
