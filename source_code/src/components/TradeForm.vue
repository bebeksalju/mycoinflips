<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { useMarketStore } from '../stores/market';
import { useWalletStore } from '../stores/wallet';
import TradeCountdown from './TradeCountdown.vue';
import api from '../api/axios';

const store = useMarketStore();
const walletStore = useWalletStore();
const inputAmount = ref(0);
const tradeType = ref('buy');
const tradeMode = ref('timed'); // Forced to 'timed'
const limitPrice = ref(0); // New State
const duration = ref(10); // seconds
const showConfirmModal = ref(false);
const tradingDurations = ref([]);
const activeTradePosition = ref(null); // For countdown popup

onMounted(async () => {
    try {
        const res = await api.get('/trade/durations');
        tradingDurations.value = res.data;
        if (res.data.length > 0) {
            duration.value = res.data[0].seconds;
        }
    } catch (e) {
        console.error('Failed to fetch durations:', e);
    }
});

const selectedPercentage = computed(() => {
    const d = tradingDurations.value.find(d => d.seconds === duration.value);
    return d?.percentage || 80;
});

const selectedMinBalance = computed(() => {
    const d = tradingDurations.value.find(d => d.seconds === duration.value);
    return d?.minBalance || 0;
});

const totalEstimate = computed(() => {
    return inputAmount.value;
});

// Update limit price when current price changes (optional convenience)
watch(() => store.currentPrice, (newVal) => {
    if (limitPrice.value === 0 && newVal > 0) limitPrice.value = newVal;
});

const isValidTrade = computed(() => {
    if (inputAmount.value <= 0) return false;
    const coinKey = store.activeCoin.symbol.toLowerCase();

    if (tradeType.value === 'buy' || tradeMode.value === 'timed') {
        if (tradeMode.value === 'timed' && walletStore.wallet.usdt < selectedMinBalance.value) {
            return false;
        }
        return walletStore.wallet.usdt >= inputAmount.value;
    } else {
        return walletStore.wallet.usdt >= inputAmount.value;
    }
});

const setPercentage = (percent) => {
    const coinKey = store.activeCoin.symbol.toLowerCase();

    if (tradeType.value === 'buy' || tradeMode.value === 'timed') {
        inputAmount.value = walletStore.wallet.usdt * (percent / 100);
    } else {
        inputAmount.value = walletStore.wallet.usdt * (percent / 100);
    }
};

const handleTrade = () => {
    if (!isValidTrade.value) return;
    showConfirmModal.value = true;
};

const executeConfirmedTrade = async () => {
    let result;
    if (tradeMode.value === 'timed') {
        // Timed Trade: Type is UP (Buy) or DOWN (Sell)
        const type = tradeType.value === 'buy' ? 'UP' : 'DOWN';
        result = await walletStore.openPosition(type, totalEstimate.value, duration.value, selectedPercentage.value);
    } else if (tradeMode.value === 'limit') {
        // Limit Order
        result = await walletStore.placeLimitOrder(tradeType.value, limitPrice.value, inputAmount.value, totalEstimate.value);
    } else {
        // Spot Trade
        result = await walletStore.executeTrade(tradeType.value, inputAmount.value, totalEstimate.value);
    }

    if (result.success) {
        inputAmount.value = 0;
        showConfirmModal.value = false;
        // Show countdown popup for timed trades
        if (tradeMode.value === 'timed' && result.position) {
            activeTradePosition.value = result.position;
        }
    } else {
        // The store handles its own error alerting
        showConfirmModal.value = false;
    }
};

const closeCountdown = () => {
    activeTradePosition.value = null;
};
</script>

<template>
    <div class="bg-gray-900 p-3 pb-16 md:pb-3 flex flex-col gap-2 text-sm font-sans">
        <!-- Trade Mode Toggle (Hidden/Removed - Forced to TIMED) -->
        <div class="flex gap-2 mb-4">
            <button @click="tradeType = 'buy'; limitPrice = store.currentPrice"
                class="flex-1 py-1.5 rounded font-bold text-xs border transition-all"
                :class="tradeType === 'buy' ? 'bg-green-600 border-green-500 text-white' : 'bg-transparent border-gray-700 text-gray-500 hover:border-gray-500'">
                Buy
            </button>
            <button @click="tradeType = 'sell'; limitPrice = store.currentPrice"
                class="flex-1 py-1.5 rounded font-bold text-xs border transition-all"
                :class="tradeType === 'sell' ? 'bg-red-600 border-red-500 text-white' : 'bg-transparent border-gray-700 text-gray-500 hover:border-gray-500'">
                Sell
            </button>
        </div>

        <div class="flex justify-between text-[10px] text-gray-400">
            <span>Available</span>
            <span v-if="store.currentPrice > 0" class="font-mono text-gray-200">
                {{ tradeType === 'buy' || tradeMode === 'timed'
                    ? walletStore.wallet.usdt.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' USDT'
                    : (walletStore.wallet[store.activeCoin.symbol.toLowerCase()] || 0).toFixed(5) + ' ' +
                    store.activeCoin.symbol
                }}
            </span>
            <span v-else class="w-16 h-3 bg-gray-800 animate-pulse rounded"></span>
        </div>

        <div class="flex flex-col gap-1.5">
            <div v-if="tradeMode === 'timed'">
                <span class="text-[10px] text-gray-500 mb-1 block">Timer</span>
                <div class="flex gap-1.5">
                    <button v-for="d in tradingDurations" :key="d.seconds" @click="duration = d.seconds"
                        class="flex-1 flex flex-col items-center justify-center py-1.5 rounded border transition-all relative overflow-hidden"
                        :title="'Min. Balance: $' + (d.minBalance || 0)"
                        :class="duration === d.seconds
                            ? 'bg-yellow-500/10 border-yellow-500/50 text-yellow-500'
                            : 'bg-gray-800 border-gray-700 text-gray-400 hover:bg-gray-700/50'">
                        <span class="text-xs font-bold font-mono">{{ d.seconds }}s</span>
                        <span class="text-[9px] opacity-70">{{ d.percentage }}%</span>
                        <div v-if="walletStore.wallet.usdt < (d.minBalance || 0)" class="absolute inset-0 bg-red-900/60 backdrop-blur-[1px] flex flex-col items-center justify-center text-[8px] font-bold text-white uppercase p-1 leading-tight" title="Insufficient Balance">
                           <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3 text-red-300 mb-0.5" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z" clip-rule="evenodd" /></svg>
                           LOCKED
                        </div>
                    </button>
                </div>
                <!-- Min Balance Warning -->
                <div v-if="walletStore.wallet.usdt < selectedMinBalance" class="mt-2 text-red-500 text-[10px] font-bold text-center border border-red-900/50 bg-red-900/10 p-1.5 rounded flex items-center justify-center gap-1">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-3 w-3" viewBox="0 0 20 20" fill="currentColor"><path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" /></svg>
                    Min Balance ${{ selectedMinBalance.toFixed(2) }} required
                </div>
            </div>

            <div class="flex bg-gray-800 rounded border border-gray-700 px-2 py-1.5 items-center"
                :class="{ 'opacity-60': tradeMode !== 'limit' }">
                <span class="text-[10px] text-gray-500 w-10">{{ tradeMode === 'limit' ? 'Limit' : 'Price' }}</span>

                <input v-if="tradeMode === 'limit'" v-model="limitPrice" type="number" step="0.01"
                    class="bg-transparent flex-1 text-right text-xs text-white font-mono outline-none" />

                <!-- Display properly formatted currency for current price -->
                <div v-else-if="store.currentPrice > 0"
                    class="bg-transparent flex-1 text-right text-xs font-mono outline-none"
                    :class="walletStore.wallet.usdt < selectedMinBalance ? 'text-gray-500' : 'text-gray-300'">
                    {{ store.currentPrice.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) }} USDT
                </div>

                <div v-else class="flex-1 flex justify-end"><span
                        class="w-12 h-3 bg-gray-700 animate-pulse rounded"></span></div>
                <!-- REMOVE 'USD' suffix since format includes $ -->
            </div>

            <div class="flex bg-gray-800 rounded border px-2 py-1.5 items-center transition-colors"
                 :class="walletStore.wallet.usdt < selectedMinBalance ? 'border-red-900/50 bg-gray-800/50 opacity-50' : 'border-gray-700'">
                <span class="text-[10px] w-10" :class="walletStore.wallet.usdt < selectedMinBalance ? 'text-gray-600' : 'text-gray-500'">Amount (USDT)</span>
                <input v-model="inputAmount" type="number" step="1"
                    class="bg-transparent flex-1 text-right text-xs font-mono outline-none"
                    :class="walletStore.wallet.usdt < selectedMinBalance ? 'text-gray-500 cursor-not-allowed' : 'text-white'"
                    placeholder="0.00" :disabled="walletStore.wallet.usdt < selectedMinBalance" />
                <span class="text-[10px] w-6 text-right" :class="walletStore.wallet.usdt < selectedMinBalance ? 'text-gray-600' : 'text-gray-500'">{{ store.activeCoin.symbol }}</span>
            </div>
        </div>

        <div class="flex gap-1" :class="{'opacity-50 pointer-events-none': walletStore.wallet.usdt < selectedMinBalance}">
            <button v-for="pct in [25, 50, 75, 100]" :key="pct" @click="setPercentage(pct)"
                class="flex-1 bg-gray-800 hover:bg-gray-700 text-[10px] text-gray-400 py-0.5 rounded border border-gray-700 transition"
                :disabled="walletStore.wallet.usdt < selectedMinBalance">
                {{ pct }}%
            </button>
        </div>

        <div class="pt-2 mt-1 border-t border-gray-800">
            <div class="flex justify-between items-center text-[10px] mb-2" :class="walletStore.wallet.usdt < selectedMinBalance ? 'opacity-50' : ''">
                <span class="text-gray-500">Total Value</span>
                <span class="font-mono font-bold" :class="walletStore.wallet.usdt < selectedMinBalance ? 'text-gray-500' : 'text-white'">
                    {{ totalEstimate.toLocaleString('en-US', { style: 'currency', currency: 'USD'}) }}
                </span>
            </div>

            <!-- Action Button -->
            <button v-if="walletStore.wallet.usdt < selectedMinBalance" @click="$router.push('/deposit')"
                class="w-full py-2.5 rounded font-bold text-gray-900 shadow-lg active:scale-95 text-xs tracking-wide transition-colors bg-yellow-500 hover:bg-yellow-400 flex items-center justify-center gap-2">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="w-4 h-4">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v12m-3-2.818l.879.659c1.171.879 3.07.879 4.242 0 1.172-.879 1.172-2.303 0-3.182-1.171-.879-3.07-.879-4.242 0-1.172.879-1.172 2.303 0 3.182.879.659 3.07.879 4.242 0z" />
                </svg>
                DEPOSIT FUNDS (MIN ${{ selectedMinBalance }})
            </button>
            <button v-else @click="handleTrade" :disabled="!isValidTrade"
                class="w-full py-2.5 rounded font-bold text-white shadow-lg active:scale-95 text-xs tracking-wide transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                :class="tradeType === 'buy' ? 'bg-green-600 hover:bg-green-500' : 'bg-red-600 hover:bg-red-500'">
                {{ tradeType }} {{ store.activeCoin.symbol }}
            </button>
        </div>

        <!-- Confirmation Modal -->
        <div v-if="showConfirmModal"
            class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
            <div class="bg-gray-900 border border-gray-700 rounded-lg p-4 w-full max-w-xs shadow-2xl">
                <h3 class="text-sm font-bold text-white mb-3">Confirm Trade</h3>

                <div class="space-y-2 text-xs text-gray-300 mb-4 bg-gray-800 p-3 rounded">
                    <div class="flex justify-between">
                        <span class="text-gray-500">Type</span>
                        <span class="font-bold uppercase"
                            :class="tradeType === 'buy' ? 'text-green-500' : 'text-red-500'">{{ tradeType }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Pair</span>
                        <span class="font-bold">{{ store.activeCoin.symbol }}/USDT</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Price</span>
                        <span class="font-mono">{{ store.currentPrice.toLocaleString() }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="font-mono text-white">{{ inputAmount.toFixed(2) }} USDT</span>
                    </div>
                    <div class="border-t border-gray-700 pt-1 flex justify-between font-bold">
                        <span class="text-gray-400">Total</span>
                        <span class="text-white">{{ totalEstimate.toLocaleString('en-US', {
                            style: 'currency', currency:
                            'USD'}) }}</span>
                    </div>

                    <div v-if="tradeMode === 'timed'" class="flex justify-between text-yellow-500 pt-1">
                        <span>Duration</span>
                        <span>{{ duration }}s</span>
                    </div>
                    <div v-if="tradeMode === 'limit'" class="flex justify-between text-blue-400 pt-1">
                        <span>Limit Price</span>
                        <span>{{ limitPrice.toLocaleString('en-US', { style: 'currency', currency: 'USD' }) }}</span>
                    </div>
                    <div v-if="tradeMode === 'timed'" class="flex justify-between text-green-400 pt-1">
                        <span>Payout ({{ selectedPercentage }}%)</span>
                        <span>{{ (totalEstimate * (1 + selectedPercentage / 100)).toLocaleString('en-US', {
                            style:
                            'currency', currency: 'USD'}) }}</span>
                    </div>
                </div>

                <div class="flex gap-2">
                    <button @click="showConfirmModal = false"
                        class="flex-1 py-1.5 rounded bg-gray-800 hover:bg-gray-700 text-gray-300 text-xs font-bold transition-colors">
                        Cancel
                    </button>
                    <button @click="executeConfirmedTrade"
                        class="flex-1 py-1.5 rounded text-white text-xs font-bold transition-colors shadow-lg"
                        :class="tradeType === 'buy' ? 'bg-green-600 hover:bg-green-500' : 'bg-red-600 hover:bg-red-500'">
                        Confirm
                    </button>
                </div>
            </div>
        </div>

        <!-- Trade Countdown Popup -->
        <TradeCountdown v-if="activeTradePosition" :position="activeTradePosition" @close="closeCountdown" />
    </div>
</template>