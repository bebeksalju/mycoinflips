<script setup>
import { reactive, computed, ref, onMounted } from 'vue';
import { RouterLink } from 'vue-router';
import { useWalletStore } from '../stores/wallet';
import { useMarketStore } from '../stores/market';
import { useAuthStore } from '../stores/auth';
import api from '../api/axios';

const walletStore = useWalletStore();
const marketStore = useMarketStore();
const authStore = useAuthStore();

const isKycApproved = computed(() => authStore.user.kycStatus === 'approved');
const kycStatus = computed(() => authStore.user.kycStatus);

const withdrawalForm = reactive({
    network: 'TRC20',
    address: '',
    amount: ''
});

const maxAmount = computed(() => walletStore.wallet.usdt);
const showConfirmModal = ref(false);
const isSubmitting = ref(false);

const adminWallets = ref({
    'BTC': 'Not configured',
    'ETH': 'Not configured',
    'USDT_ERC20': 'Not configured',
    'USDT_TRC20': 'Not configured',
    'USDC': 'Not configured'
});

// Withdrawal history
const withdrawHistory = ref([]);
const isLoadingHistory = ref(false);

onMounted(async () => {
    try {
        const res = await api.get('/admin/wallets/public');
        if (res.data) {
            adminWallets.value = { ...adminWallets.value, ...res.data };
            withdrawalForm.network = Object.keys(adminWallets.value)[0];
        }
    } catch (error) {
        console.error('Failed to fetch admin wallets:', error);
    }
    fetchWithdrawHistory();
});

const fetchWithdrawHistory = async () => {
    isLoadingHistory.value = true;
    try {
        const res = await api.get('/wallet/transactions');
        withdrawHistory.value = (res.data || [])
            .filter(tx => tx.type === 'WITHDRAWAL')
            .slice(0, 5);
    } catch (e) {
        console.error('Failed to fetch withdrawal history:', e);
    } finally {
        isLoadingHistory.value = false;
    }
};

const requestWithdrawal = () => {
    if (!withdrawalForm.address || !withdrawalForm.amount) {
        marketStore.showToast('Error', 'Please fill all fields', 'error');
        return;
    }
    if (parseFloat(withdrawalForm.amount) <= 0) {
        marketStore.showToast('Error', 'Amount must be greater than 0', 'error');
        return;
    }
    if (parseFloat(withdrawalForm.amount) > walletStore.wallet.usdt) {
        marketStore.showToast('Error', 'Insufficient USDT Balance', 'error');
        return;
    }
    // Open confirmation modal
    showConfirmModal.value = true;
};

const submitWithdrawal = async () => {
    isSubmitting.value = true;
    const result = await walletStore.withdraw(withdrawalForm.amount, withdrawalForm.address, withdrawalForm.network);
    isSubmitting.value = false;
    showConfirmModal.value = false;

    if (result.success) {
        marketStore.showToast('Withdrawal Submitted', result.msg, 'success');
        withdrawalForm.amount = '';
        withdrawalForm.address = '';
        fetchWithdrawHistory();
    } else {
        marketStore.showToast('Withdrawal Failed', result.msg, 'error');
    }
};

const setMax = () => {
    withdrawalForm.amount = walletStore.wallet.usdt;
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

function maskAddress(addr) {
    if (!addr || addr.length < 12) return addr;
    return addr.slice(0, 8) + '...' + addr.slice(-6);
}
</script>

<template>
    <div class="h-full overflow-y-auto bg-gray-950 p-4 md:p-8">
        <div class="max-w-2xl mx-auto w-full pb-20">
            <h2 class="text-2xl font-bold mb-6 flex items-center gap-2">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                    stroke="currentColor" class="w-8 h-8 text-yellow-500">
                    <path stroke-linecap="round" stroke-linejoin="round"
                        d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3" />
                </svg>
                Withdraw Funds
            </h2>

            <div class="bg-gray-900 border border-gray-800 rounded-xl p-4 md:p-6 space-y-6 md:space-y-8">
                <!-- Info Banner -->
                <div class="bg-blue-500/10 border border-blue-500/20 p-4 rounded-lg flex gap-3 text-sm text-blue-200">
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor"
                        class="w-5 h-5 flex-none text-blue-400 mt-0.5">
                        <path fill-rule="evenodd"
                            d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a.75.75 0 000 1.5h.253a.25.25 0 01.244.304l-.459 2.066A1.75 1.75 0 0010.747 15H11a.75.75 0 000-1.5h-.253a.25.25 0 01-.244-.304l.459-2.066A1.75 1.75 0 009.253 9H9z"
                            clip-rule="evenodd" />
                    </svg>
                    <div>
                        <p class="font-bold mb-1">Processing Information</p>
                        <p class="text-blue-200/80 leading-relaxed text-xs md:text-sm">Withdrawals are processed
                            manually by our finance team. Please verify your address carefully. Standard processing time
                            is 1-2 hours during business hours.</p>
                    </div>
                </div>

                <!-- KYC Required Gate -->
                <div v-if="!isKycApproved"
                    class="flex flex-col items-center text-center py-10 px-4 space-y-5">
                    <div class="w-20 h-20 rounded-full flex items-center justify-center"
                        :class="kycStatus === 'pending' ? 'bg-blue-500/10' : 'bg-orange-500/10'">
                        <svg v-if="kycStatus === 'pending'" xmlns="http://www.w3.org/2000/svg" fill="none"
                            viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
                            class="w-10 h-10 text-blue-400">
                            <path stroke-linecap="round" stroke-linejoin="round"
                                d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                        <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                            stroke-width="1.5" stroke="currentColor" class="w-10 h-10 text-orange-400">
                            <path stroke-linecap="round" stroke-linejoin="round"
                                d="M15 9h3.75M15 12h3.75M15 15h3.75M4.5 19.5h15a2.25 2.25 0 002.25-2.25V6.75A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25v10.5A2.25 2.25 0 004.5 19.5zm6-10.125a1.875 1.875 0 11-3.75 0 1.875 1.875 0 013.75 0zm1.294 6.336a6.721 6.721 0 01-3.17.789 6.721 6.721 0 01-3.168-.789 3.376 3.376 0 016.338 0z" />
                        </svg>
                    </div>

                    <div>
                        <h3 class="text-xl font-bold text-white mb-2">
                            {{ kycStatus === 'pending' ? 'KYC Under Review' : 'Identity Verification Required' }}
                        </h3>
                        <p class="text-gray-400 text-sm leading-relaxed max-w-sm">
                            <span v-if="kycStatus === 'pending'">
                                Your KYC documents are currently being reviewed by our compliance team. Withdrawals will
                                be enabled once your identity is verified.
                            </span>
                            <span v-else-if="kycStatus === 'rejected'">
                                Your KYC verification was rejected. Please re-submit your documents to enable
                                withdrawals.
                            </span>
                            <span v-else>
                                To protect your funds and comply with regulations, you must complete identity
                                verification (KYC) before making withdrawals.
                            </span>
                        </p>
                    </div>

                    <RouterLink v-if="kycStatus !== 'pending'" to="/kyc"
                        class="inline-flex items-center gap-2 px-6 py-3 bg-yellow-500 hover:bg-yellow-400 text-gray-900 font-bold rounded-lg transition-all shadow-lg shadow-yellow-500/20">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2"
                            stroke="currentColor" class="w-4 h-4">
                            <path stroke-linecap="round" stroke-linejoin="round"
                                d="M15 9h3.75M15 12h3.75M15 15h3.75M4.5 19.5h15a2.25 2.25 0 002.25-2.25V6.75A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25v10.5A2.25 2.25 0 004.5 19.5zm6-10.125a1.875 1.875 0 11-3.75 0 1.875 1.875 0 013.75 0zm1.294 6.336a6.721 6.721 0 01-3.17.789 6.721 6.721 0 01-3.168-.789 3.376 3.376 0 016.338 0z" />
                        </svg>
                        {{ kycStatus === 'rejected' ? 'Re-submit KYC Documents' : 'Complete KYC Verification' }}
                    </RouterLink>

                    <div v-if="kycStatus === 'pending'"
                        class="flex items-center gap-2 text-blue-400 text-xs font-medium">
                        <span class="w-2 h-2 rounded-full bg-blue-400 animate-pulse"></span>
                        Awaiting admin review...
                    </div>
                </div>

                <!-- Form (only when KYC approved) -->
                <template v-else>
                    <div class="space-y-4 md:space-y-6">
                        <div>
                            <label
                                class="block text-xs uppercase font-bold text-gray-500 mb-2 md:mb-3 tracking-wider">Select
                                Network</label>
                            <div class="grid grid-cols-3 gap-2 md:gap-3">
                                <button v-for="(addr, net) in adminWallets" :key="net"
                                    @click="withdrawalForm.network = net"
                                    class="px-2 py-3 rounded-lg text-xs md:text-sm font-bold border transition-all duration-200 flex flex-col items-center gap-1 group"
                                    :class="withdrawalForm.network === net ? 'bg-yellow-500 text-gray-900 border-yellow-500 shadow-lg shadow-yellow-500/20' : 'bg-gray-800 text-gray-400 border-gray-700 hover:border-gray-500 hover:bg-gray-750'">
                                    <span>{{ net.split('_')[0] }}</span>
                                    <span class="text-[10px] md:text-xs opacity-70 group-hover:opacity-100 uppercase">{{ net.split('_')[1] || net }}</span>
                                </button>
                            </div>
                        </div>

                        <div>
                            <label class="block text-xs uppercase font-bold text-gray-500 mb-2">Recipient Address</label>
                            <div class="relative group">
                                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                        stroke-width="1.5" stroke="currentColor"
                                        class="w-5 h-5 text-gray-500 group-focus-within:text-yellow-500 transition-colors">
                                        <path stroke-linecap="round" stroke-linejoin="round"
                                            d="M21 12a2.25 2.25 0 00-2.25-2.25H15a3 3 0 11-6 0H5.25A2.25 2.25 0 003 12m18 0v6a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 18v-6m18 0V9M3 12V9m18 0a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 9m18 0V6a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 6v3" />
                                    </svg>
                                </div>
                                <input type="text" v-model="withdrawalForm.address"
                                    placeholder="Paste your wallet address here..."
                                    class="w-full bg-gray-800 border border-gray-700 rounded-lg pl-10 p-3 text-white focus:outline-none focus:border-yellow-500 focus:ring-1 focus:ring-yellow-500 transition-all text-xs md:text-sm font-mono">
                            </div>
                        </div>

                        <div>
                            <div class="flex justify-between mb-2">
                                <label class="text-xs uppercase font-bold text-gray-500">Amount (USDT)</label>
                                <span class="text-xs text-gray-400">Available: <span class="text-white font-bold">{{
                                    maxAmount.toLocaleString('en-US', { style: 'currency', currency: 'USD' })
                                        }}</span></span>
                            </div>
                            <div class="relative">
                                <input type="number" v-model="withdrawalForm.amount" placeholder="0.00"
                                    class="w-full bg-gray-800 border border-gray-700 rounded-lg p-3 text-white focus:outline-none focus:border-yellow-500 pr-16 font-mono text-lg font-bold">
                                <button @click="setMax"
                                    class="absolute right-2 top-2 text-xs font-bold bg-gray-700 hover:bg-gray-600 text-yellow-500 px-3 py-2 rounded-md transition-colors border border-gray-600 hover:border-gray-500">MAX</button>
                            </div>
                        </div>
                    </div>

                    <div class="pt-4">
                        <button @click="requestWithdrawal"
                            class="w-full py-3.5 bg-red-500 hover:bg-red-600 text-white font-bold rounded-lg transition-all shadow-lg shadow-red-500/10 active:scale-[0.98] flex items-center justify-center gap-2">
                            <span>Confirm Withdrawal</span>
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2"
                                stroke="currentColor" class="w-4 h-4">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" />
                            </svg>
                        </button>
                    </div>
                </template>

            </div>
        </div>

        <!-- Withdrawal History -->
        <div class="mt-6">
            <h3 class="font-bold text-white mb-3 flex items-center gap-2">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 text-yellow-500">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                Recent Withdrawals
            </h3>
            <div class="bg-gray-900 border border-gray-800 rounded-xl overflow-hidden">
                <div v-if="isLoadingHistory" class="py-8 text-center text-gray-500 text-sm">Loading...</div>
                <div v-else-if="withdrawHistory.length === 0" class="py-8 text-center text-gray-600 text-sm">No withdrawal history yet</div>
                <div v-else class="divide-y divide-gray-800">
                    <div v-for="tx in withdrawHistory" :key="tx.id"
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

    <!-- Confirmation Modal -->
    <Teleport to="body">
        <div v-if="showConfirmModal" class="fixed inset-0 z-[9999] flex items-center justify-center p-4"
            style="background-color: rgba(0,0,0,0.75); backdrop-filter: blur(8px);">
            <div class="w-full max-w-sm bg-gray-900 border border-gray-700 rounded-2xl shadow-2xl overflow-hidden">
                <div class="p-6 space-y-4">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 bg-red-500/15 rounded-full flex items-center justify-center shrink-0">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5 text-red-400">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
                            </svg>
                        </div>
                        <div>
                            <h3 class="font-bold text-white">Confirm Withdrawal</h3>
                            <p class="text-xs text-gray-500">Please verify all details before confirming</p>
                        </div>
                    </div>

                    <div class="bg-gray-800 rounded-xl p-4 space-y-3">
                        <div class="flex justify-between">
                            <span class="text-gray-500 text-sm">Amount</span>
                            <span class="text-white font-bold text-sm">${{ parseFloat(withdrawalForm.amount).toLocaleString('en-US', { minimumFractionDigits: 2 }) }} USDT</span>
                        </div>
                        <div class="flex justify-between">
                            <span class="text-gray-500 text-sm">Network</span>
                            <span class="text-white font-bold text-sm">{{ withdrawalForm.network }}</span>
                        </div>
                        <div class="flex justify-between items-start gap-2">
                            <span class="text-gray-500 text-sm shrink-0">Address</span>
                            <span class="text-yellow-400 font-mono text-xs text-right break-all">{{ withdrawalForm.address }}</span>
                        </div>
                    </div>

                    <p class="text-xs text-red-400/80 text-center">⚠️ Withdrawals cannot be reversed once submitted</p>

                    <div class="flex gap-3">
                        <button @click="showConfirmModal = false" :disabled="isSubmitting"
                            class="flex-1 py-2.5 bg-gray-800 hover:bg-gray-700 text-gray-300 font-bold rounded-xl transition-all text-sm">
                            Cancel
                        </button>
                        <button @click="submitWithdrawal" :disabled="isSubmitting"
                            class="flex-1 py-2.5 bg-red-500 hover:bg-red-600 disabled:opacity-60 text-white font-bold rounded-xl transition-all text-sm flex items-center justify-center gap-2">
                            <svg v-if="isSubmitting" class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                            </svg>
                            {{ isSubmitting ? 'Processing...' : 'Confirm' }}
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </Teleport>
</template>
