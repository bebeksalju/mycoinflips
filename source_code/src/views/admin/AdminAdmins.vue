<script setup>
import { ref, reactive, onMounted } from 'vue';
import { useAuthStore } from '../../stores/auth';
import api from '../../api/axios';

const authStore = useAuthStore();
const showModal = ref(false);
const sessions = ref([]);
const loadingSessions = ref(false);

const form = reactive({
    name: '',
    email: '',
    password: '',
    role: 'administrator'
});

onMounted(() => {
    authStore.fetchAdminUsers();
    if (authStore.user.role === 'SUPERUSER') {
        fetchSessions();
    }
});

const fetchSessions = async () => {
    loadingSessions.value = true;
    try {
        const res = await api.get('/admin/sessions');
        sessions.value = res.data;
    } catch (err) {
        console.error('Failed to fetch sessions:', err);
    } finally {
        loadingSessions.value = false;
    }
};

const deleteSession = async (id) => {
    if (!confirm('Delete this session? The user will be logged out from that device.')) return;
    try {
        await api.delete(`/admin/sessions/${id}`);
        sessions.value = sessions.value.filter(s => s.id !== id);
    } catch (err) {
        console.error('Failed to delete session:', err);
    }
};

const deleteAllUserSessions = async (userId, userName) => {
    if (!confirm(`Delete ALL sessions for ${userName}? They will be logged out from all devices.`)) return;
    try {
        await api.delete(`/admin/sessions/user/${userId}`);
        sessions.value = sessions.value.filter(s => s.userId !== userId);
    } catch (err) {
        console.error('Failed to delete user sessions:', err);
    }
};

const openAddModal = () => {
    form.name = '';
    form.email = '';
    form.password = '';
    form.role = 'administrator';
    showModal.value = true;
};

const deleteAdmin = (id) => {
    if (confirm('Are you sure you want to remove this admin?')) {
        authStore.removeAdmin(id);
    }
};

const submitForm = () => {
    if (!form.name || !form.email || !form.password) return;

    authStore.addAdmin({
        name: form.name,
        email: form.email,
        password: form.password,
        role: form.role
    });

    showModal.value = false;
};

const formatDate = (dateStr) => {
    if (!dateStr) return '';
    const d = new Date(dateStr);
    return d.toLocaleString('en-US', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
};
</script>

<template>
    <div>
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-2xl font-bold">Admin Management</h1>
            <button v-if="authStore.user.role === 'SUPERUSER'" @click="openAddModal"
                class="bg-yellow-500 hover:bg-yellow-400 text-gray-900 font-bold px-4 py-2 rounded shadow transition-colors">
                + Add Admin
            </button>
        </div>

        <div v-if="authStore.user.role !== 'SUPERUSER'"
            class="bg-red-900/20 border border-red-900/50 p-4 rounded text-red-200 text-center">
            You do not have permission to manage administrators.
        </div>

        <div v-else class="bg-gray-800 rounded-xl border border-gray-700 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-gray-400">
                    <thead class="bg-gray-900/50 text-xs uppercase font-bold text-gray-500">
                        <tr>
                            <th class="px-6 py-4">Name</th>
                            <th class="px-6 py-4">Email</th>
                            <th class="px-6 py-4">Role</th>
                            <th class="px-6 py-4 text-center">Password</th>
                            <th class="px-6 py-4 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-700/50">
                        <tr v-if="authStore.adminUsers.length === 0">
                            <td colspan="5" class="px-6 py-8 text-center text-gray-500">No admin users found</td>
                        </tr>
                        <tr v-for="admin in authStore.adminUsers" :key="admin.id"
                            class="hover:bg-gray-700/20 transition-colors">
                            <td class="px-6 py-4 font-bold text-white">{{ admin.name }}</td>
                            <td class="px-6 py-4">{{ admin.email }}</td>
                            <td class="px-6 py-4">
                                <span class="px-2 py-1 rounded text-xs font-bold uppercase"
                                    :class="admin.role === 'superuser' ? 'bg-purple-900/30 text-purple-400' : 'bg-blue-900/30 text-blue-400'">
                                    {{ admin.role }}
                                </span>
                            </td>
                            <td class="px-6 py-4 text-center">
                                <span class="font-mono text-yellow-500 font-bold text-xs">{{ admin.password || '••••••' }}</span>
                            </td>
                            <td class="px-6 py-4 text-right">
                                <button v-if="admin.email !== authStore.user.email" @click="deleteAdmin(admin.id)"
                                    class="text-red-400 hover:text-red-300 font-bold text-xs">
                                    Remove
                                </button>
                                <span v-else class="text-gray-600 text-xs italic">Current Session</span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- SESSION MANAGEMENT SECTION -->
        <div v-if="authStore.user.role === 'SUPERUSER'" class="mt-8">
            <div class="flex justify-between items-center mb-4">
                <h2 class="text-xl font-bold flex items-center gap-2">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 text-yellow-500">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75L11.25 15 15 9.75m-3-7.036A11.959 11.959 0 013.598 6 11.99 11.99 0 003 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285z" />
                    </svg>
                    Active Sessions
                </h2>
                <button @click="fetchSessions" class="text-xs text-yellow-500 hover:text-yellow-400 font-bold flex items-center gap-1">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-3.5 h-3.5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0l3.181 3.183a8.25 8.25 0 0013.803-3.7M4.031 9.865a8.25 8.25 0 0113.803-3.7l3.181 3.182" />
                    </svg>
                    Refresh
                </button>
            </div>

            <div class="bg-gray-800 rounded-xl border border-gray-700 overflow-hidden">
                <div v-if="loadingSessions" class="p-8 text-center text-gray-500">
                    <div class="animate-spin w-6 h-6 border-2 border-yellow-500 border-t-transparent rounded-full mx-auto mb-2"></div>
                    Loading sessions...
                </div>
                <div v-else-if="sessions.length === 0" class="p-8 text-center text-gray-500">
                    No active admin sessions
                </div>
                <div v-else class="overflow-x-auto">
                    <table class="w-full text-left text-sm text-gray-400">
                        <thead class="bg-gray-900/50 text-xs uppercase font-bold text-gray-500">
                            <tr>
                                <th class="px-6 py-3">User</th>
                                <th class="px-6 py-3">Role</th>
                                <th class="px-6 py-3">Token</th>
                                <th class="px-6 py-3">Created</th>
                                <th class="px-6 py-3">Expires</th>
                                <th class="px-6 py-3">Status</th>
                                <th class="px-6 py-3 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-700/50">
                            <tr v-for="session in sessions" :key="session.id" class="hover:bg-gray-700/20 transition-colors">
                                <td class="px-6 py-3">
                                    <div class="flex flex-col">
                                        <span class="font-bold text-white text-xs">{{ session.user.name }}</span>
                                        <span class="text-[10px] text-gray-500">{{ session.user.email }}</span>
                                    </div>
                                </td>
                                <td class="px-6 py-3">
                                    <span class="px-2 py-0.5 rounded text-[10px] font-bold uppercase"
                                        :class="session.user.role === 'SUPERUSER' ? 'bg-purple-900/30 text-purple-400' : 'bg-blue-900/30 text-blue-400'">
                                        {{ session.user.role }}
                                    </span>
                                </td>
                                <td class="px-6 py-3 font-mono text-[10px] text-gray-500">{{ session.tokenPreview }}</td>
                                <td class="px-6 py-3 text-xs">{{ formatDate(session.createdAt) }}</td>
                                <td class="px-6 py-3 text-xs">{{ formatDate(session.expiresAt) }}</td>
                                <td class="px-6 py-3">
                                    <span v-if="session.isExpired" class="text-[10px] font-bold text-red-400 bg-red-900/30 px-2 py-0.5 rounded">EXPIRED</span>
                                    <span v-else class="text-[10px] font-bold text-green-400 bg-green-900/30 px-2 py-0.5 rounded">ACTIVE</span>
                                </td>
                                <td class="px-6 py-3 text-right">
                                    <div class="flex gap-2 justify-end">
                                        <button @click="deleteSession(session.id)"
                                            class="text-red-400 hover:text-red-300 text-xs font-bold bg-red-900/10 border border-red-900/30 px-2 py-1 rounded hover:bg-red-900/30 transition-colors">
                                            Revoke
                                        </button>
                                        <button @click="deleteAllUserSessions(session.userId, session.user.name)"
                                            class="text-orange-400 hover:text-orange-300 text-xs font-bold bg-orange-900/10 border border-orange-900/30 px-2 py-1 rounded hover:bg-orange-900/30 transition-colors">
                                            Revoke All
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Add Modal -->
        <div v-if="showModal"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
            <div class="bg-gray-800 border border-gray-700 rounded-xl w-full max-w-md p-6 shadow-2xl">
                <h3 class="text-xl font-bold text-white mb-4">Add New Administrator</h3>

                <div class="space-y-4">
                    <div>
                        <label class="block text-xs font-bold text-gray-500 uppercase mb-1">Name</label>
                        <input v-model="form.name" type="text"
                            class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-white focus:border-yellow-500 outline-none"
                            placeholder="Admin Name" />
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-gray-500 uppercase mb-1">Email</label>
                        <input v-model="form.email" type="email"
                            class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-white focus:border-yellow-500 outline-none"
                            placeholder="admin@mycoinflips.com" />
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-gray-500 uppercase mb-1">Password</label>
                        <input v-model="form.password" type="password"
                            class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-white focus:border-yellow-500 outline-none"
                            placeholder="••••••" />
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-gray-500 uppercase mb-1">Role</label>
                        <select v-model="form.role"
                            class="w-full bg-gray-900 border border-gray-700 rounded p-2 text-white focus:border-yellow-500 outline-none">
                            <option value="administrator">Administrator</option>
                            <option value="superuser">Superuser</option>
                        </select>
                    </div>
                </div>

                <div class="flex gap-3 mt-6">
                    <button @click="showModal = false"
                        class="flex-1 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded font-bold">Cancel</button>
                    <button @click="submitForm"
                        class="flex-1 py-2 bg-yellow-600 hover:bg-yellow-500 text-white rounded font-bold shadow-lg">Create
                        Admin</button>
                </div>
            </div>
        </div>
    </div>
</template>
