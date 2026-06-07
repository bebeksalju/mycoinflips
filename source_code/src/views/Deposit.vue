<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { useMarketStore } from '../stores/market';
import { useWalletStore } from '../stores/wallet';
import api from '../api/axios';

const marketStore = useMarketStore();
const walletStore = useWalletStore();
const showDepositNotice = ref(false);
const isSubmitting = ref(false);

const depositForm = reactive({
    network: 'USDT_TRC20',
    amount: '',
    txId: ''
});

const fileInput = ref(null);
const fileName = ref('');

const adminWallets = ref({
    'BTC': 'Not configured',
    'ETH': 'Not configured',
    'USDT_ERC20': 'Not configured',
    'USDT_TRC20': 'Not configured',
    'USDC': 'Not configured'
});

// History state
const depositHistory = ref([]);
const isLoadingHistory = ref(false);

onMounted(async () => {
    try {
        const res = await api.get('/admin/wallets/public');
        if (res.data) {
            adminWallets.value = { ...adminWallets.value, ...res.data };
        }
    } catch (error) {
        console.error('Failed to fetch deposit wallets:', error);
    }
    fetchDepositHistory();
});

const fetchDepositHistory = async () => {
    isLoadingHistory.value = true;
    try {
        const res = await api.get('/wallet/transactions');
        depositHistory.value = (res.data || [])
            .filter(tx => tx.type === 'DEPOSIT')
            .slice(0, 5);
    } catch (e) {
        console.error('Failed to fetch deposit history:', e);
    } finally {
        isLoadingHistory.value = false;
    }
};

const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text).then(() => {
        marketStore.showToast('Copied', 'Wallet address copied to clipboard', 'success');
    });
};

const proofFile = ref(null);

const handleFileUpload = (event) => {
    const file = event.target.files[0];
    if (file) {
        fileName.value = file.name;
        proofFile.value = file;
    }
};

const submitDeposit = async () => {
    if (!depositForm.amount || !depositForm.txId || !proofFile.value) {
        marketStore.showToast('Error', 'Please fill all fields and upload proof', 'error');
        return;
    }
    if (parseFloat(depositForm.amount) <= 0) {
        marketStore.showToast('Error', 'Amount must be greater than 0', 'error');
        return;
    }

    isSubmitting.value = true;
    const formData = new FormData();
    formData.append('amount', depositForm.amount);
    // Fix: also send txId to backend for record keeping
    formData.append('txId', depositForm.txId);
    formData.append('proof', proofFile.value);

    const result = await walletStore.deposit(formData);
    isSubmitting.value = false;

    if (result.success) {
        marketStore.showToast('Deposit Submitted', result.msg, 'success');
        depositForm.amount = '';
        depositForm.txId = '';
        fileName.value = '';
        proofFile.value = null;
        showDepositNotice.value = true;
        fetchDepositHistory();
    } else {
        marketStore.showToast('Error', result.msg, 'error');
    }
};

function formatDate(dateStr) {
    return new Date(dateStr).toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

function statusClass(status) {
    if (status === 'COMPLETED') return 'bg-green-500/10 text-green-400 border border-green-500/20';
    if (status === 'PENDING') return 'bg-yellow-500/10 text-yellow-500 border border-yellow-500/20';
    if (status === 'FAILED') return 'bg-red-500/10 text-red-400 border border-red-500/20';
    return 'bg-gray-700 text-gray-400';
}
</script>

<template>
    <div class="h-full overflow-y-auto bg-gray-950 p-4 md:p-8">
        <div class="max-w-2xl mx-auto w-full pb-20"> <!-- Added pb-20 for safe bottom spacing -->
            <h2 class="text-2xl font-bold mb-6 flex items-center gap-2">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                    stroke="currentColor" class="w-8 h-8 text-yellow-500">
                    <path stroke-linecap="round" stroke-linejoin="round"
                        d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5" />
                </svg>
                Deposit Funds
            </h2>

            <div class="bg-gray-900 border border-gray-800 rounded-xl p-4 md:p-6 space-y-6 md:space-y-8">

                <!-- Deposit Submitted Notice -->
                <div v-if="showDepositNotice" class="bg-green-500/10 border border-green-500/30 rounded-xl p-5 flex gap-4">
                    <div class="w-10 h-10 rounded-full bg-green-500/20 flex items-center justify-center flex-none">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-5 h-5 text-green-400">
                            <path fill-rule="evenodd" d="M16.704 4.153a.75.75 0 01.143 1.052l-8 10.5a.75.75 0 01-1.127.075l-4.5-4.5a.75.75 0 011.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 011.05-.143z" clip-rule="evenodd" />
                        </svg>
                    </div>
                    <div>
                        <h4 class="font-bold text-green-400 text-sm">Deposit Submitted Successfully!</h4>
                        <p class="text-xs text-green-200/80 mt-1 leading-relaxed">Your deposit request has been submitted and will be processed by our admin team. Please allow up to <strong>24 hours</strong> for your balance to be updated. You will receive a notification once your deposit is confirmed.</p>
                        <p class="text-xs text-gray-500 mt-2">For any questions, please contact us at <strong>admin@mycoinflips.com</strong></p>
                    </div>
                    <button @click="showDepositNotice = false" class="text-gray-500 hover:text-white flex-none">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>
                <!-- Warning Banner -->
                <div
                    class="bg-yellow-500/10 border border-yellow-500/20 p-4 rounded-lg flex gap-3 text-sm text-yellow-200">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                        stroke="currentColor" class="w-5 h-5 flex-none text-yellow-500 mt-0.5">
                        <path stroke-linecap="round" stroke-linejoin="round"
                            d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
                    </svg>
                    <div>
                        <p class="font-bold mb-1">Important Security Note</p>
                        <p class="text-yellow-200/80 leading-relaxed text-xs md:text-sm">Please ensure you select the
                            correct network. Sending funds to the wrong address or network will result in permanent
                            loss.</p>
                    </div>
                </div>

                <!-- Network Selection -->
                <div>
                    <label class="block text-xs uppercase font-bold text-gray-500 mb-3 tracking-wider">Select Payment
                        Network</label>
                    <div class="grid grid-cols-3 md:grid-cols-5 gap-2 md:gap-3">
                        <button v-for="(addr, net) in adminWallets" :key="net" @click="depositForm.network = net"
                            class="px-2 py-3 md:px-4 rounded-lg text-xs md:text-sm font-bold border transition-all duration-200 flex flex-col items-center gap-1 group"
                            :class="depositForm.network === net ? 'bg-yellow-500 text-gray-900 border-yellow-500 shadow-lg shadow-yellow-500/20' : 'bg-gray-800 text-gray-400 border-gray-700 hover:border-gray-500 hover:bg-gray-750'">
                            <span>{{ net.replace('_', ' ') }}</span>
                        </button>
                    </div>
                </div>

                <!-- Wallet Display + QR -->
                <div
                    class="bg-gray-800/50 border border-gray-700 rounded-xl p-4 md:p-6 flex flex-col md:flex-row gap-6 items-center">

                    <!-- Network Info Badge -->
                    <div class="hidden md:flex flex-col items-center justify-center w-28 h-28 bg-gray-900/80 border border-gray-700 rounded-xl shrink-0">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-8 h-8 text-yellow-500 mb-1">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M21 12a2.25 2.25 0 00-2.25-2.25H15a3 3 0 11-6 0H5.25A2.25 2.25 0 003 12m18 0v6a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 18v-6m18 0V9M3 12V9m18 0a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 9m18 0V6a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 6v3" />
                        </svg>
                        <p class="text-xs font-bold text-yellow-400 text-center leading-tight">{{ depositForm.network.replace('_', ' ') }}</p>
                        <p class="text-[10px] text-gray-500 mt-1">Network</p>
                    </div>

                    <div class="flex-1 w-full min-w-0">
                        <label class="block text-xs text-gray-500 mb-1">Deposit Address ({{ depositForm.network
                        }})</label>
                        <div
                            class="flex items-center gap-2 bg-gray-900 border border-gray-700 rounded-lg p-3 w-full group focus-within:border-yellow-500 transition-colors">
                            <p class="font-mono text-xs md:text-sm text-gray-300 break-all flex-1">{{
                                adminWallets[depositForm.network] }}</p>
                            <button @click="copyToClipboard(adminWallets[depositForm.network])"
                                class="p-2 text-gray-500 hover:text-white bg-gray-800 hover:bg-gray-700 rounded transition-all shrink-0">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                    stroke-width="1.5" stroke="currentColor" class="w-4 h-4">
                                    <path stroke-linecap="round" stroke-linejoin="round"
                                        d="M15.75 17.25v3.375c0 .621-.504 1.125-1.125 1.125h-9.75a1.125 1.125 0 01-1.125-1.125V7.875c0-.621.504-1.125 1.125-1.125H6.75a9.06 9.06 0 011.5.124m7.5 10.376h3.375c.621 0 1.125-.504 1.125-1.125V11.25c0-4.46-3.243-8.161-7.5-8.876a9.06 9.06 0 00-1.5-.124H9.375c-.621 0-1.125.504-1.125 1.125v3.5m7.5 10.375H9.375a1.125 1.125 0 01-1.125-1.125v-9.25m12 6.625v-1.875a3.375 3.375 0 00-3.375-3.375h-1.5a1.125 1.125 0 01-1.125-1.125v-1.5a3.375 3.375 0 00-3.375-3.375H9.75" />
                                </svg>
                            </button>
                        </div>
                        <p class="text-[10px] text-gray-500 mt-2">Only send {{ depositForm.network.replace('_', ' ') }} to this
                            address.</p>
                    </div>
                </div>

                <!-- Form -->
                <div class="space-y-6">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs uppercase font-bold text-gray-500 mb-2">Amount (USDT)</label>
                            <input type="number" v-model="depositForm.amount" placeholder="e.g. 100"
                                class="w-full bg-gray-800 border border-gray-700 rounded-lg p-3 text-white focus:outline-none focus:border-yellow-500 focus:ring-1 focus:ring-yellow-500 transition-all font-mono">
                        </div>
                        <div>
                            <label class="block text-xs uppercase font-bold text-gray-500 mb-2">TxID (Hash)</label>
                            <input type="text" v-model="depositForm.txId" placeholder="Paste Transaction ID"
                                class="w-full bg-gray-800 border border-gray-700 rounded-lg p-3 text-white focus:outline-none focus:border-yellow-500 focus:ring-1 focus:ring-yellow-500 transition-all">
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs uppercase font-bold text-gray-500 mb-2">Upload Payment Proof</label>
                        <div class="border-2 border-dashed border-gray-700 rounded-xl p-6 md:p-8 text-center hover:border-yellow-500/50 hover:bg-gray-800/50 transition-all cursor-pointer group"
                            @click="$refs.fileInput.click()">
                            <input type="file" ref="fileInput" class="hidden" @change="handleFileUpload"
                                accept="image/*">
                            <div
                                class="w-12 h-12 bg-gray-800 rounded-full flex items-center justify-center mx-auto mb-3 group-hover:scale-110 transition-transform">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                    stroke-width="1.5" stroke="currentColor"
                                    class="w-6 h-6 text-gray-400 group-hover:text-yellow-500">
                                    <path stroke-linecap="round" stroke-linejoin="round"
                                        d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5" />
                                </svg>
                            </div>
                            <p class="text-sm font-medium text-gray-300">{{ fileName || 'Click or drag to upload screenshot' }}</p>
                            <p class="text-xs text-gray-500 mt-1">Supports JPG, PNG (Max 5MB)</p>
                        </div>
                    </div>
                </div>

                <div class="pt-4">
                    <button @click="submitDeposit" :disabled="isSubmitting"
                        class="w-full py-3 bg-green-500 hover:bg-green-600 disabled:opacity-60 disabled:cursor-not-allowed text-white font-bold rounded-lg transition-all shadow-lg shadow-green-500/10 active:scale-[0.98] flex items-center justify-center gap-2">
                        <svg v-if="isSubmitting" class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                        </svg>
                        {{ isSubmitting ? 'Submitting...' : 'Submit Deposit Request' }}
                    </button>
                </div>

            </div>

            <!-- Deposit History -->
            <div class="mt-6">
                <h3 class="font-bold text-white mb-3 flex items-center gap-2">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 text-yellow-500">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    Recent Deposits
                </h3>
                <div class="bg-gray-900 border border-gray-800 rounded-xl overflow-hidden">
                    <div v-if="isLoadingHistory" class="py-8 text-center text-gray-500 text-sm">Loading...</div>
                    <div v-else-if="depositHistory.length === 0" class="py-8 text-center text-gray-600 text-sm">No deposit history yet</div>
                    <div v-else class="divide-y divide-gray-800">
                        <div v-for="tx in depositHistory" :key="tx.id"
                            class="flex items-center justify-between px-4 py-3">
                            <div>
                                <p class="text-white font-bold text-sm">${{ tx.amount.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }} USDT</p>
                                <p class="text-gray-500 text-xs">{{ formatDate(tx.createdAt) }}</p>
                            </div>
                            <span :class="statusClass(tx.status)" class="text-xs font-bold px-2.5 py-1 rounded-full">
                                {{ tx.status }}
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>
