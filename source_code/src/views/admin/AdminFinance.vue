<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { useAdminStore } from '../../stores/admin';
import { io } from 'socket.io-client';

const adminStore = useAdminStore();
const activeTab = ref('pending');
const lightboxUrl = ref(null);
let socket = null;

onMounted(() => {
    adminStore.fetchTransactions();

    // Connect and listen for real-time new deposit/withdrawal events
    const token = localStorage.getItem('token');
    if (token) {
        socket = io('/chat', { auth: { token }, transports: ['websocket', 'polling'] });
        socket.on('finance:new-transaction', () => {
            // Auto-refresh the transaction list
            adminStore.fetchTransactions();
        });
    }
});

onUnmounted(() => {
    if (socket) socket.disconnect();
});

const pendingTransactions = computed(() => {
    return adminStore.transactions.filter(t => t.status === 'pending');
});

const historyTransactions = computed(() => {
    return adminStore.transactions.filter(t => t.status !== 'pending');
});

function formatDate(dateStr) {
    return new Date(dateStr).toLocaleString();
}

const approve = (id) => {
    adminStore.updateTransactionStatus(id, 'approved');
};

const reject = (id) => {
    adminStore.updateTransactionStatus(id, 'rejected');
};

const openLightbox = (url) => {
    lightboxUrl.value = url;
};

const closeLightbox = () => {
    lightboxUrl.value = null;
};
</script>

<template>
    <div>
        <h1 class="text-2xl font-bold mb-6">Finance Management</h1>

        <!-- Tabs -->
        <div class="flex border-b border-gray-700 mb-6">
            <button @click="activeTab = 'pending'" class="px-6 py-3 font-bold border-b-2 transition-colors"
                :class="activeTab === 'pending' ? 'text-yellow-500 border-yellow-500' : 'text-gray-400 border-transparent hover:text-white'">
                Pending Requests ({{ pendingTransactions.length }})
            </button>
            <button @click="activeTab = 'history'" class="px-6 py-3 font-bold border-b-2 transition-colors"
                :class="activeTab === 'history' ? 'text-yellow-500 border-yellow-500' : 'text-gray-400 border-transparent hover:text-white'">
                History
            </button>
        </div>

        <div class="bg-gray-800 rounded-xl border border-gray-700 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-gray-400">
                    <thead class="bg-gray-900/50 text-xs uppercase font-bold text-gray-500">
                        <tr>
                            <th class="px-6 py-4">Type</th>
                            <th class="px-6 py-4">User</th>
                            <th class="px-6 py-4 text-right">Amount</th>
                            <th class="px-6 py-4">Network</th>
                            <th class="px-6 py-4">Destination / Proof</th>
                            <th class="px-6 py-4">Date</th>
                            <th class="px-6 py-4">Status</th>
                            <th v-if="activeTab === 'pending'" class="px-6 py-4 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-gray-700/50">
                        <tr v-if="activeTab === 'pending' && pendingTransactions.length === 0">
                            <td colspan="8" class="px-6 py-8 text-center text-gray-500">No pending transactions</td>
                        </tr>
                        <tr v-for="tx in (activeTab === 'pending' ? pendingTransactions : historyTransactions)"
                            :key="tx.id" class="hover:bg-gray-700/20 transition-colors">
                            <td class="px-6 py-4">
                                <span class="font-bold text-xs px-2 py-1 rounded"
                                    :class="tx.type === 'DEPOSIT' ? 'bg-green-900/30 text-green-400' : 'bg-red-900/30 text-red-500'">
                                    {{ tx.type }}
                                </span>
                            </td>
                            <td class="px-6 py-4">
                                <div class="flex flex-col">
                                    <span class="font-bold text-white">{{ tx.user }}</span>
                                    <span class="text-xs text-gray-500">{{ tx.email }}</span>
                                </div>
                            </td>
                            <td class="px-6 py-4 font-mono font-bold text-white text-right">
                                {{ tx.amount.toLocaleString('en-US', { style: 'currency', currency: 'USD' }) }}
                            </td>
                            <td class="px-6 py-4">
                                <span class="text-xs font-mono bg-gray-900 text-gray-300 px-2 py-1 rounded">{{ tx.asset
                                    }} ({{ tx.network }})</span>
                            </td>
                            <td class="px-6 py-4">
                                <div v-if="tx.type === 'DEPOSIT'">
                                    <img v-if="tx.proofUrl" 
                                        :src="tx.proofUrl" 
                                        class="w-10 h-10 object-cover rounded border border-gray-600 cursor-pointer hover:opacity-80 transition-opacity"
                                        @dblclick="openLightbox(tx.proofUrl)"
                                        title="Double-click to enlarge" />
                                    <span v-else class="text-xs text-gray-600">—</span>
                                </div>
                                <div v-else-if="tx.type === 'WITHDRAWAL'">
                                    <div v-if="tx.targetAddress" class="flex items-center gap-1">
                                        <span class="text-[10px] font-mono text-gray-400 max-w-[120px] truncate" :title="tx.targetAddress">{{ tx.targetAddress }}</span>
                                        <button @click="navigator.clipboard.writeText(tx.targetAddress)" class="text-gray-500 hover:text-white" title="Copy Address">
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-3 h-3">
                                                <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 17.25v3.375c0 .621-.504 1.125-1.125 1.125h-9.75a1.125 1.125 0 01-1.125-1.125V7.875c0-.621.504-1.125 1.125-1.125H6.75a9.06 9.06 0 011.5.124m7.5 10.376h3.375c.621 0 1.125-.504 1.125-1.125V11.25c0-4.46-3.243-8.161-7.5-8.876a9.06 9.06 0 00-1.5-.124H9.375c-.621 0-1.125.504-1.125 1.125v3.5m7.5 10.375H9.375a1.125 1.125 0 01-1.125-1.125v-9.25m12 6.625v-1.875a3.375 3.375 0 00-3.375-3.375h-1.5a1.125 1.125 0 01-1.125-1.125v-1.5a3.375 3.375 0 00-3.375-3.375H9.75" />
                                            </svg>
                                        </button>
                                    </div>
                                    <span v-else class="text-xs text-gray-600">—</span>
                                </div>
                            </td>
                            <td class="px-6 py-4 text-xs font-mono">{{ formatDate(tx.date) }}</td>
                            <td class="px-6 py-4">
                                <span class="text-xs font-bold uppercase" :class="{
                                    'text-yellow-500': tx.status === 'pending',
                                    'text-green-500': tx.status === 'approved' || tx.status === 'completed',
                                    'text-red-500': tx.status === 'rejected' || tx.status === 'failed'
                                }">
                                    {{ tx.status }}
                                </span>
                            </td>
                            <td v-if="activeTab === 'pending'" class="px-6 py-4 text-right">
                                <div class="flex justify-end gap-2">
                                    <button @click="reject(tx.id)"
                                        class="bg-red-900/20 border border-red-900/50 text-red-400 px-3 py-1.5 rounded text-xs font-bold hover:bg-red-900/40 transition-colors">Reject</button>
                                    <button @click="approve(tx.id)"
                                        class="bg-green-600 hover:bg-green-500 text-white px-3 py-1.5 rounded text-xs font-bold shadow-lg transition-colors">Approve</button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Lightbox Modal -->
        <div v-if="lightboxUrl" class="fixed inset-0 bg-black/90 flex items-center justify-center z-50 cursor-pointer" @click="closeLightbox">
            <button @click="closeLightbox" class="absolute top-4 right-4 text-white text-3xl font-bold hover:text-yellow-500 transition-colors">&times;</button>
            <img :src="lightboxUrl" class="max-w-[90vw] max-h-[90vh] object-contain rounded-lg shadow-2xl" @click.stop />
        </div>
    </div>
</template>
