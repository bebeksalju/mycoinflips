<script setup>
import { ref, onMounted, computed } from 'vue';
import api from '../../api/axios';

const logs = ref([]);
const isLoading = ref(false);
const searchQuery = ref('');

const fetchLogs = async () => {
    isLoading.value = true;
    try {
        const response = await api.get('/admin/audit-logs');
        logs.value = response.data;
    } catch (error) {
        console.error('Failed to fetch audit logs:', error);
    } finally {
        isLoading.value = false;
    }
};

onMounted(() => {
    fetchLogs();
});

const filteredLogs = computed(() => {
    if (!searchQuery.value) return logs.value;
    const query = searchQuery.value.toLowerCase();
    return logs.value.filter(log => 
        (log.userEmail && log.userEmail.toLowerCase().includes(query)) ||
        (log.userName && log.userName.toLowerCase().includes(query)) ||
        (log.action && log.action.toLowerCase().includes(query)) ||
        (log.ipAddress && log.ipAddress.toLowerCase().includes(query))
    );
});

function formatDateTime(dateStr) {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    return date.toLocaleString('en-US', {
        year: 'numeric',
        month: 'short',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
    });
}
</script>

<template>
    <div>
        <div class="flex flex-col md:flex-row md:items-center md:justify-between mb-6 gap-4">
            <h1 class="text-2xl font-bold">Admin Activity Log</h1>
            <button 
                @click="fetchLogs" 
                class="px-4 py-2 bg-gray-800 border border-gray-700 rounded-lg text-sm hover:bg-gray-700 transition-colors flex items-center gap-2"
                :disabled="isLoading"
            >
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-4 h-4" :class="{ 'animate-spin': isLoading }">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0l3.181 3.183a8.25 8.25 0 0013.803-3.7M4.031 9.865a8.25 8.25 0 0113.803-3.7l3.181 3.182m0-4.991v4.99" />
                </svg>
                Refresh
            </button>
        </div>

        <!-- Search Bar -->
        <div class="mb-6">
            <div class="relative max-w-md">
                <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-500">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.602 10.602z" />
                    </svg>
                </span>
                <input 
                    v-model="searchQuery"
                    type="text" 
                    placeholder="Search by email, name, action..." 
                    class="w-full pl-10 pr-4 py-2 bg-gray-800 border border-gray-700 rounded-xl text-white placeholder-gray-500 focus:outline-none focus:border-yellow-500 transition-colors text-sm"
                />
            </div>
        </div>

        <!-- Logs Table -->
        <div class="bg-gray-800 rounded-xl border border-gray-700 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="border-b border-gray-700 bg-gray-900/50 text-xs font-bold text-gray-400 uppercase tracking-wider">
                            <th class="px-6 py-4">Date & Time</th>
                            <th class="px-6 py-4">Admin Name</th>
                            <th class="px-6 py-4">Email</th>
                            <th class="px-6 py-4">Action</th>
                            <th class="px-6 py-4">IP Address</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-700/50 text-sm">
                        <tr v-if="isLoading" class="hover:bg-transparent">
                            <td colspan="5" class="px-6 py-12 text-center text-gray-500">
                                <div class="animate-spin rounded-full h-6 w-6 border-t-2 border-b-2 border-yellow-500 mx-auto mb-3"></div>
                                Loading log data...
                            </td>
                        </tr>
                        <tr v-else-if="filteredLogs.length === 0" class="hover:bg-transparent">
                            <td colspan="5" class="px-6 py-12 text-center text-gray-500">
                                No activity logs found.
                            </td>
                        </tr>
                        <tr v-else-if="filteredLogs.length > 0" v-for="log in filteredLogs" :key="log.id" class="hover:bg-gray-700/20 transition-colors">
                            <td class="px-6 py-4 whitespace-nowrap text-gray-400 text-xs">
                                {{ formatDateTime(log.createdAt) }}
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap font-medium text-white">
                                {{ log.userName || 'Admin' }}
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-gray-300">
                                {{ log.userEmail }}
                            </td>
                            <td class="px-6 py-4 text-white">
                                {{ log.action }}
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-gray-500 text-xs font-mono">
                                {{ log.ipAddress || '-' }}
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</template>
