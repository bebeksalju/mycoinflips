<script setup>
import { computed, onMounted, ref } from 'vue';
import { useWalletStore } from '../stores/wallet';
import { useRouter } from 'vue-router';

const walletStore = useWalletStore();
const router = useRouter();
const showWithdrawPopup = ref(false);

onMounted(() => {
    walletStore.fetchBalance();
});

const goToChat = () => {
    showWithdrawPopup.value = false;
    router.push('/chat');
};
</script>

<template>
    <div class="p-4 md:p-8 max-w-2xl mx-auto w-full h-full overflow-y-auto pb-24">
        <h2 class="text-2xl font-bold mb-6 flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                stroke="currentColor" class="w-8 h-8 text-yellow-500">
                <path stroke-linecap="round" stroke-linejoin="round"
                    d="M21 12a2.25 2.25 0 00-2.25-2.25H15a3 3 0 11-6 0H5.25A2.25 2.25 0 003 12m18 0v6a2.25 2.25 0 01-2.25 2.25H5.25A2.25 2.25 0 013 18v-6m18 0V9M3 12V9m18 0a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 9m18 0V6a2.25 2.25 0 00-2.25-2.25H5.25A2.25 2.25 0 003 6v3" />
            </svg>
            My Wallet
        </h2>

        <div class="bg-gray-900 border border-gray-800 rounded-xl p-6 space-y-8 shadow-xl">
            <!-- Total Balance Card -->
            <div class="text-center space-y-2">
                <p class="text-sm text-gray-400 uppercase tracking-wider font-bold">Total Balance</p>
                <h1 class="text-4xl font-bold text-white font-mono tracking-tight">
                    {{ walletStore.wallet.usdt.toLocaleString('en-US', { style: 'currency', currency: 'USD' }) }}
                </h1>
                <p class="text-xs text-gray-500">≈ Rp {{ (walletStore.wallet.usdt * 15500).toLocaleString('id-ID') }}
                </p>
            </div>

            <!-- Asset List -->
            <div class="border border-gray-800 rounded-xl overflow-hidden bg-gray-900/50">
                <div
                    class="grid grid-cols-3 bg-gray-800 p-3 font-bold text-gray-500 uppercase text-[10px] tracking-wider">
                    <span>Asset</span>
                    <span class="text-right">Balance</span>
                    <span class="text-right">Value (USDT)</span>
                </div>

                <!-- USDT Row -->
                <div class="grid grid-cols-3 p-4 hover:bg-gray-800/30 transition-colors items-center">
                    <div class="flex items-center gap-3">
                        <div
                            class="w-8 h-8 bg-green-500/20 rounded-full flex items-center justify-center text-green-500 border border-green-500/30">
                            <span class="font-bold text-xs">$</span>
                        </div>
                        <div class="flex flex-col">
                            <span class="font-bold text-white text-sm">USDT</span>
                            <span class="text-[10px] text-gray-500">Tether</span>
                        </div>
                    </div>
                    <div class="flex flex-col text-right justify-center">
                        <span class="font-mono text-gray-300 text-sm">{{ walletStore.wallet.usdt.toLocaleString()
                        }}</span>
                    </div>
                    <div class="flex flex-col text-right justify-center">
                        <span class="font-mono text-white font-bold text-sm">{{
                            walletStore.wallet.usdt.toLocaleString('en-US', { style: 'currency', currency: 'USD' })
                        }}</span>
                    </div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="grid grid-cols-2 gap-4 pt-2">
                <router-link to="/deposit"
                    class="flex items-center justify-center gap-2 py-3 bg-green-600 hover:bg-green-500 text-white font-bold rounded-lg transition-all shadow-lg shadow-green-900/20">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2"
                        stroke="currentColor" class="w-5 h-5">
                        <path stroke-linecap="round" stroke-linejoin="round"
                            d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5" />
                    </svg>
                    Deposit
                </router-link>
                <button @click="showWithdrawPopup = true"
                    class="flex items-center justify-center gap-2 py-3 bg-gray-700 hover:bg-gray-600 text-white font-bold rounded-lg transition-all border border-gray-600">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2"
                        stroke="currentColor" class="w-5 h-5">
                        <path stroke-linecap="round" stroke-linejoin="round"
                            d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3" />
                    </svg>
                    Withdraw
                </button>
            </div>
        </div>

        <!-- Withdraw Notice Popup -->
        <Teleport to="body">
            <div v-if="showWithdrawPopup" class="fixed inset-0 z-[9999] flex items-center justify-center p-4"
                style="background-color: rgba(0,0,0,0.7); backdrop-filter: blur(8px);">
                <div class="w-full max-w-sm bg-gray-900 border border-gray-700 rounded-2xl shadow-2xl overflow-hidden">
                    <div class="p-6 text-center space-y-4">
                        <div class="w-16 h-16 mx-auto rounded-full bg-yellow-500/10 flex items-center justify-center">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                                stroke="currentColor" class="w-8 h-8 text-yellow-500">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                    d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
                            </svg>
                        </div>
                        <h3 class="text-lg font-bold text-white">Withdrawal Request</h3>
                        <p class="text-sm text-gray-400 leading-relaxed">To process your withdrawal, please contact our
                            <span class="text-yellow-500 font-semibold">Admin Support</span> team via Live Chat. Our
                            team will assist you within 24 hours.
                        </p>
                        <div class="flex flex-col gap-3 pt-2">
                            <button @click="goToChat"
                                class="w-full py-3 bg-yellow-500 hover:bg-yellow-400 text-gray-900 font-bold rounded-xl transition-all flex items-center justify-center gap-2">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"
                                    stroke-width="2" stroke="currentColor" class="w-5 h-5">
                                    <path stroke-linecap="round" stroke-linejoin="round"
                                        d="M20.25 8.511c.884.284 1.5 1.128 1.5 2.097v4.286c0 1.136-.84 2.1-1.98 2.193-.34.027-.68.052-1.02.072v3.091l-3-3c-1.354 0-2.694-.055-4.02-.163a2.115 2.115 0 01-.825-.242m9.345-8.334a2.126 2.126 0 00-.476-.095 48.64 48.64 0 00-8.048 0c-1.131.094-1.976 1.057-1.976 2.192v4.286c0 .837.46 1.58 1.155 1.951m9.345-8.334V6.637c0-1.621-1.152-3.026-2.76-3.235A48.455 48.455 0 0011.25 3c-2.115 0-4.198.137-6.24.402-1.608.209-2.76 1.614-2.76 3.235v6.226c0 1.621 1.152 3.026 2.76 3.235.577.075 1.157.14 1.74.194V21l4.155-4.155" />
                                </svg>
                                Chat with Support
                            </button>
                            <button @click="showWithdrawPopup = false"
                                class="w-full py-2.5 text-gray-500 hover:text-white text-sm font-medium transition-colors">
                                Close
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </Teleport>
    </div>
</template>
