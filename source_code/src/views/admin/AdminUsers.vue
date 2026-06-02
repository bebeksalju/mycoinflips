<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { useAuthStore } from '../../stores/auth';
import { io } from 'socket.io-client';

const authStore = useAuthStore();
const showBalanceModal = ref(false);
const showDetailsModal = ref(false);
const showDeleteModal = ref(false);
const showPasswordModal = ref(false);
const selectedUser = ref(null);
const newBalance = ref(0);
const newPassword = ref('');
const onlineUserIds = ref([]);
let socket = null;

onMounted(() => {
    authStore.fetchUsers();
    // Connect to /chat namespace for online status
    const token = localStorage.getItem('token');
    if (token) {
        socket = io('/chat', {
            auth: { token },
            transports: ['websocket', 'polling']
        });
        socket.on('users:online', (ids) => {
            onlineUserIds.value = ids;
        });
    }
});

onUnmounted(() => {
    if (socket) socket.disconnect();
});

const openBalanceModal = (user) => {
    selectedUser.value = user;
    newBalance.value = user.balance;
    showBalanceModal.value = true;
};

const openPasswordModal = (user) => {
    selectedUser.value = user;
    newPassword.value = '';
    showPasswordModal.value = true;
};

const openDetailsModal = (user) => {
    selectedUser.value = user;
    showDetailsModal.value = true;
};

const confirmBalanceUpdate = () => {
    if (selectedUser.value && newBalance.value >= 0) {
        authStore.updateUserBalance(selectedUser.value.id, newBalance.value);
        showBalanceModal.value = false;
        selectedUser.value = null;
    }
};

const confirmPasswordUpdate = async () => {
    if (selectedUser.value && newPassword.value.length >= 5) {
        await authStore.updateUserPassword(selectedUser.value.id, newPassword.value);
        showPasswordModal.value = false;
        selectedUser.value = null;
    } else {
        alert('Password must be at least 5 characters long.');
    }
};

const updateProfitMode = (userId, mode) => {
    authStore.updateUserProfitMode(userId, mode);
};

const toggleBan = (userId) => {
    authStore.toggleUserBan(userId);
};

const openDeleteModal = (user) => {
    selectedUser.value = user;
    showDeleteModal.value = true;
};

const confirmDeleteUser = async () => {
    if (selectedUser.value) {
        await authStore.deleteUser(selectedUser.value.id);
        showDeleteModal.value = false;
        selectedUser.value = null;
    }
};
</script>

<template>
    <div>
        <h1 class="text-2xl font-bold mb-6">User Management</h1>

        <div class="bg-gray-800 rounded-xl border border-gray-700 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-gray-400">
                    <thead class="bg-gray-900/50 text-xs uppercase font-bold text-gray-500">
                        <tr>
                            <th class="px-6 py-4">User</th>
                            <th class="px-6 py-4">Balance</th>
                            <th class="px-6 py-4">KYC Status</th>
                            <th class="px-6 py-4">Status</th>
                            <th class="px-6 py-4 text-center">Profit Mode (Rigged)</th>
                            <th class="px-6 py-4 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-700/50">
                        <tr v-if="authStore.users.length === 0">
                            <td colspan="6" class="px-6 py-8 text-center text-gray-500">No users found</td>
                        </tr>
                        <tr v-for="user in authStore.users" :key="user.id"
                            class="hover:bg-gray-700/20 transition-colors">
                            <td class="px-6 py-4">
                                <div class="flex flex-col">
                                    <div class="flex items-center gap-2">
                                        <span class="font-bold text-white">{{ user.name }}</span>
                                        <span v-if="onlineUserIds.includes(user.id)" class="flex items-center gap-1">
                                            <span class="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span>
                                            <span class="text-[10px] text-green-400 font-bold uppercase">Online</span>
                                        </span>
                                    </div>
                                    <button @click="openDetailsModal(user)"
                                        class="text-xs text-yellow-500 hover:text-yellow-400 text-left mt-0.5 hover:underline">View
                                        Details</button>
                                    <span class="text-xs text-gray-500 mt-1">{{ user.email }}</span>
                                </div>
                            </td>
                            <td class="px-6 py-4 font-mono text-white">
                                <div class="flex items-center gap-2">
                                    {{ user.balance.toLocaleString('en-US', { style: 'currency', currency: 'USD' }) }}
                                    <button v-if="authStore.user.role === 'SUPERUSER' || authStore.user.role === 'ADMIN'" @click="openBalanceModal(user)"
                                        class="text-gray-500 hover:text-yellow-500 transition-colors"
                                        title="Edit Balance">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                            stroke-width="1.5" stroke="currentColor" class="w-4 h-4">
                                            <path stroke-linecap="round" stroke-linejoin="round"
                                                d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L10.582 16.07a4.5 4.5 0 01-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 011.13-1.897l8.932-8.931zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0115.75 21H5.25A2.25 2.25 0 013 18.75V8.25A2.25 2.25 0 015.25 6H10" />
                                        </svg>
                                    </button>
                                </div>
                            </td>
                            <td class="px-6 py-4">
                                <span class="px-2 py-1 rounded-full text-xs font-bold capitalize" :class="{
                                    'bg-green-900/30 text-green-400': user.kyc === 'approved',
                                    'bg-yellow-900/30 text-yellow-500': user.kyc === 'pending',
                                    'bg-gray-700 text-gray-400': user.kyc === 'unverified'
                                }">
                                    {{ user.kyc }}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <span class="px-2 py-1 rounded-full text-xs font-bold uppercase"
                                    :class="user.status === 'active' ? 'bg-green-900/30 text-green-400' : 'bg-red-900/30 text-red-400'">
                                    {{ user.status }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-center">
                                <div class="inline-flex bg-gray-900 rounded-lg p-1 border border-gray-700">
                                    <button @click="updateProfitMode(user.id, 'loss')"
                                        class="px-3 py-1 rounded text-xs font-bold transition-all"
                                        :class="user.profitMode === 'loss' ? 'bg-red-500 text-white shadow-lg' : 'text-gray-400 hover:text-white'">
                                        LOSS
                                    </button>
                                    <button @click="updateProfitMode(user.id, 'random')"
                                        class="px-3 py-1 rounded text-xs font-bold transition-all"
                                        :class="user.profitMode === 'random' ? 'bg-gray-600 text-white shadow-lg' : 'text-gray-400 hover:text-white'">
                                        RANDOM
                                    </button>
                                    <button @click="updateProfitMode(user.id, 'win')"
                                        class="px-3 py-1 rounded text-xs font-bold transition-all"
                                        :class="user.profitMode === 'win' ? 'bg-green-500 text-white shadow-lg' : 'text-gray-400 hover:text-white'">
                                        WIN
                                    </button>
                                </div>
                            </td>
                            <td class="px-6 py-4 text-right flex justify-end gap-2">
                                <button v-if="authStore.user.role === 'SUPERUSER'" @click="openPasswordModal(user)"
                                    class="text-xs font-bold px-3 py-1.5 rounded transition-colors border text-yellow-500 border-yellow-900/50 hover:bg-yellow-900/20 bg-yellow-900/10 whitespace-nowrap">
                                    Reset Password
                                </button>
                                <button @click="toggleBan(user.id)"
                                    class="text-xs font-bold px-3 py-1.5 rounded transition-colors border"
                                    :class="user.status === 'active' ? 'text-red-400 border-red-900/50 hover:bg-red-900/20' : 'text-green-400 border-green-900/50 hover:bg-green-900/20'">
                                    {{ user.status === 'active' ? 'Ban User' : 'Unban' }}
                                </button>
                                <button v-if="authStore.user.role === 'SUPERUSER'" @click="openDeleteModal(user)"
                                    class="text-xs font-bold px-3 py-1.5 rounded transition-colors border text-red-500 border-red-900/50 hover:bg-red-900/20 bg-red-900/10">
                                    Delete
                                </button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Delete Confirmation Modal -->
        <div v-if="showDeleteModal"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
            <div class="bg-gray-800 border border-gray-700 rounded-xl w-full max-w-sm p-6 shadow-2xl">
                <h3 class="text-xl font-bold text-red-500 mb-4 flex items-center gap-2">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                    </svg>
                    Delete User
                </h3>
                <p class="text-sm text-gray-300 mb-6">Are you sure you want to permanently delete <span class="text-white font-bold">{{ selectedUser?.name }}</span> and all their associated data (wallet, history, KYC, chat)? This action cannot be undone.</p>

                <div class="flex gap-3">
                    <button @click="showDeleteModal = false"
                        class="flex-1 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded font-bold">Cancel</button>
                    <button @click="confirmDeleteUser"
                        class="flex-1 py-2 bg-red-600 hover:bg-red-500 text-white rounded font-bold shadow-lg">Delete Permanently</button>
                </div>
            </div>
        </div>

        <!-- Balance Modal -->
        <div v-if="showBalanceModal"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
            <div class="bg-gray-800 border border-gray-700 rounded-xl w-full max-w-sm p-6 shadow-2xl">
                <h3 class="text-xl font-bold text-white mb-4">Edit User Balance</h3>
                <p class="text-sm text-gray-400 mb-4">Updating balance for <span class="text-white font-bold">{{
                        selectedUser?.name }}</span></p>

                <div class="mb-6">
                    <label class="block text-xs font-bold text-gray-500 uppercase mb-1">New Balance (USDT)</label>
                    <input v-model="newBalance" type="number"
                        class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-white font-mono focus:border-yellow-500 outline-none" />
                </div>

                <div class="flex gap-3">
                    <button @click="showBalanceModal = false"
                        class="flex-1 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded font-bold">Cancel</button>
                    <button @click="confirmBalanceUpdate"
                        class="flex-1 py-2 bg-yellow-600 hover:bg-yellow-500 text-white rounded font-bold shadow-lg">Update</button>
                </div>
            </div>
        </div>

        <!-- Password Reset Modal -->
        <div v-if="showPasswordModal"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
            <div class="bg-gray-800 border border-gray-700 rounded-xl w-full max-w-sm p-6 shadow-2xl">
                <h3 class="text-xl font-bold text-white mb-4 flex items-center gap-2">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6 text-yellow-500">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 5.25a3 3 0 013 3m3 0a6 6 0 01-7.029 5.912c-.563-.097-1.159.026-1.563.43L10.5 17.25H8.25v2.25H6v2.25H2.25v-2.818c0-.597.237-1.17.659-1.591l6.499-6.499c.404-.404.527-1 .43-1.563A6 6 0 1121.75 8.25z" />
                    </svg>
                    Reset Password
                </h3>
                <p class="text-sm text-gray-400 mb-4">Set a new password for <span class="text-white font-bold">{{
                        selectedUser?.name }}</span></p>

                <div class="mb-6">
                    <label class="block text-xs font-bold text-gray-500 uppercase mb-1">New Password</label>
                    <input v-model="newPassword" type="text"
                        class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-white font-mono focus:border-yellow-500 outline-none" placeholder="Minimum 5 characters" />
                </div>

                <div class="flex gap-3">
                    <button @click="showPasswordModal = false"
                        class="flex-1 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded font-bold">Cancel</button>
                    <button @click="confirmPasswordUpdate"
                        class="flex-1 py-2 bg-yellow-600 hover:bg-yellow-500 text-white rounded font-bold shadow-lg">Change Password</button>
                </div>
            </div>
        </div>

        <!-- User Details Modal -->
        <div v-if="showDetailsModal"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
            <div
                class="bg-gray-800 border border-gray-700 rounded-xl w-full max-w-2xl p-6 shadow-2xl max-h-[90vh] overflow-y-auto">
                <div class="flex justify-between items-start mb-6">
                    <div>
                        <h3 class="text-2xl font-bold text-white">User Details</h3>
                        <p class="text-sm text-gray-400">Profile information for {{ selectedUser?.name }}</p>
                    </div>
                    <button @click="showDetailsModal = false" class="text-gray-500 hover:text-white">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                            stroke="currentColor" class="w-6 h-6">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <div v-if="selectedUser" class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="bg-gray-900/50 p-4 rounded-lg border border-gray-700/50">
                        <label class="block text-xs uppercase font-bold text-gray-500 mb-1">Full Name</label>
                        <p class="text-white font-bold text-lg">{{ selectedUser.name }}</p>
                    </div>
                    <div class="bg-gray-900/50 p-4 rounded-lg border border-gray-700/50">
                        <label class="block text-xs uppercase font-bold text-gray-500 mb-1">Email Address</label>
                        <p class="text-white">{{ selectedUser.email }}</p>
                    </div>
                    <div class="bg-gray-900/50 p-4 rounded-lg border border-gray-700/50">
                        <label class="block text-xs uppercase font-bold text-gray-500 mb-1">Balance</label>
                        <p class="text-white font-mono font-bold">{{ selectedUser.balance.toLocaleString('en-US',
                            { style: 'currency', currency: 'USD'}) }}</p>
                    </div>
                    <div class="bg-gray-900/50 p-4 rounded-lg border border-gray-700/50">
                        <label class="block text-xs uppercase font-bold text-gray-500 mb-1">Login Password</label>
                        <p class="text-yellow-500 font-mono font-bold">{{ selectedUser.password }}</p>
                    </div>
                    <div class="bg-gray-900/50 p-4 rounded-lg border border-gray-700/50">
                        <label class="block text-xs uppercase font-bold text-gray-500 mb-1">Profit Mode</label>
                        <p class="text-white font-bold uppercase">{{ selectedUser.profitMode }}</p>
                    </div>
                    <div
                        class="bg-gray-900/50 p-4 rounded-lg border border-gray-700/50 md:col-span-2 flex justify-between items-center">
                        <div>
                            <label class="block text-xs uppercase font-bold text-gray-500 mb-1">Account Status</label>
                            <span class="px-2 py-1 rounded-full text-xs font-bold uppercase"
                                :class="selectedUser.status === 'active' ? 'bg-green-900/30 text-green-400' : 'bg-red-900/30 text-red-400'">
                                {{ selectedUser.status }}
                            </span>
                        </div>
                        <div>
                            <label class="block text-xs uppercase font-bold text-gray-500 mb-1">KYC Review</label>
                            <span class="px-2 py-1 rounded-full text-xs font-bold capitalize" :class="{
                                'bg-green-900/30 text-green-400': selectedUser.kyc === 'approved',
                                'bg-yellow-900/30 text-yellow-500': selectedUser.kyc === 'pending',
                                'bg-gray-700 text-gray-400': selectedUser.kyc === 'unverified'
                            }">
                                {{ selectedUser.kyc }}
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
