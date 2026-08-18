<script setup>
import { RouterLink } from 'vue-router';
import { useMarketStore } from '../stores/market';
import { onMounted, computed, ref, onUnmounted, reactive } from 'vue';

const marketStore = useMarketStore();

const isMobileMenuOpen = ref(false);
const isLightMode = ref(localStorage.getItem('theme') === 'light');

// Simulated Stats
const stats = reactive({
    activeUsers: 14520,
    activetx: 890,
    volume: 125000000
});

// Transaction Popups
const popups = ref([]);
let popupId = 0;
const coinSymbols = ['BTC', 'ETH', 'SOL', 'BNB', 'XRP', 'ADA', 'DOGE', 'AVAX'];

const createPopup = () => {
    if (popups.value.length >= 3) {
        popups.value.shift();
    }
    const coin = coinSymbols[Math.floor(Math.random() * coinSymbols.length)];
    const amount = (Math.random() * (coin === 'BTC' ? 0.5 : coin === 'ETH' ? 5 : 1000)).toFixed(2);
    const priceStr = Math.floor(Math.random() * 50000 + 100).toLocaleString();
    const hash = Math.random().toString(36).substring(2, 7);
    
    const newPopup = {
        id: popupId++,
        message: `User ***${hash} bought ${amount} ${coin} at $${priceStr}`
    };
    
    popups.value.push(newPopup);
    
    setTimeout(() => {
        popups.value = popups.value.filter(p => p.id !== newPopup.id);
    }, 4000); // Dismiss after 4s
};

let statsInterval = null;
let popupInterval = null;

onMounted(() => {
    marketStore.fetchMarketOverview();
    
    // Apply initial theme
    if (isLightMode.value) {
        document.documentElement.classList.add('light-mode');
    }

    statsInterval = setInterval(() => {
        stats.activeUsers = Math.max(10000, stats.activeUsers + Math.floor(Math.random() * 100) - 50);
        stats.activetx = Math.max(200, stats.activetx + Math.floor(Math.random() * 40) - 20);
        stats.volume += Math.floor(Math.random() * 50000);
    }, 3000);

    // Start popup generator
    setTimeout(() => {
        createPopup();
        popupInterval = setInterval(() => {
            if (Math.random() > 0.3) { // 70% chance to show a popup every interval
                createPopup();
            }
        }, 5000 + Math.random() * 3000); // Every 5-8 seconds
    }, 2000);
});

onUnmounted(() => {
    if (statsInterval) clearInterval(statsInterval);
    if (popupInterval) clearInterval(popupInterval);
});

const toggleMobileMenu = () => {
    isMobileMenuOpen.value = !isMobileMenuOpen.value;
};

const toggleTheme = () => {
    isLightMode.value = !isLightMode.value;
    if (isLightMode.value) {
        document.documentElement.classList.add('light-mode');
        localStorage.setItem('theme', 'light');
    } else {
        document.documentElement.classList.remove('light-mode');
        localStorage.setItem('theme', 'dark');
    }
};

const topCoins = computed(() => marketStore.marketOverview);

const formatCompact = (num) => {
    if (num >= 1e9) return '$' + (num / 1e9).toFixed(1) + 'B';
    if (num >= 1e6) return '$' + (num / 1e6).toFixed(1) + 'M';
    return '$' + num.toLocaleString();
};
</script>

<template>
    <div class="landing-page-root min-h-screen font-sans overflow-x-hidden selection:bg-gold-500 selection:text-black"
         style="background-color: var(--lp-bg-primary); color: var(--lp-text-primary);">

        <!-- Global SVG Background Pattern -->
        <div class="absolute inset-0 pointer-events-none z-0 opacity-10"
             style="background-image: url('data:image/svg+xml,%3Csvg width=\'60\' height=\'60\' viewBox=\'0 0 60 60\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cg fill=\'none\' fill-rule=\'evenodd\'%3E%3Cg fill=\'%23DAA520\' fill-opacity=\'1\'%3E%3Cpath d=\'M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z\'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E'); background-repeat: repeat;">
        </div>

        <!-- Navbar -->
        <nav class="fixed top-0 w-full z-50 backdrop-blur-xl border-b transition-colors"
             style="background-color: var(--lp-bg-navbar); border-color: var(--lp-border);">
            <div class="container mx-auto px-4 sm:px-6 py-3 flex justify-between items-center">
                <RouterLink to="/" class="flex items-center gap-2 relative z-50">
                    <!-- Text Logo with Gold Accent -->
                    <span class="text-xl font-black tracking-tight"><span class="text-gold-500">My</span>COINFLIP</span>
                </RouterLink>
                
                <div class="hidden md:flex items-center gap-8">
                    <a href="#features" style="color: var(--lp-text-secondary);" class="text-sm font-semibold hover:text-gold-500 transition-colors">Features</a>
                    <a href="#market" style="color: var(--lp-text-secondary);" class="text-sm font-semibold hover:text-gold-500 transition-colors">Markets</a>
                    <a href="#steps" style="color: var(--lp-text-secondary);" class="text-sm font-semibold hover:text-gold-500 transition-colors">How it Works</a>
                </div>
                
                <div class="hidden md:flex items-center gap-4 relative z-50">
                    <!-- Theme Toggle -->
                    <button @click="toggleTheme" class="p-2 rounded-full hover:bg-black/5 dark:hover:bg-white/5 transition-colors" style="color: var(--lp-text-secondary);">
                        <svg v-if="!isLightMode" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" />
                        </svg>
                        <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z" />
                        </svg>
                    </button>

                    <RouterLink to="/login" class="text-sm font-bold transition-colors" style="color: var(--lp-text-primary);">Log In</RouterLink>
                    <RouterLink to="/register" class="px-5 py-2 text-sm font-bold text-black rounded-lg transition-all hover:scale-105 shadow-md" style="background: var(--gradient-gold); box-shadow: var(--shadow-gold);">
                        Sign Up
                    </RouterLink>
                </div>

                <!-- Mobile Hamburger -->
                <button @click="toggleMobileMenu" class="md:hidden relative z-50 p-2 text-gold-500">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6">
                        <path v-if="!isMobileMenuOpen" stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
                        <path v-else stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </nav>

        <!-- Mobile Menu Overlay -->
        <Teleport to="body">
            <Transition name="fade">
                <div v-if="isMobileMenuOpen" class="fixed inset-0 z-[9999] flex flex-col md:hidden p-6" style="background-color: var(--lp-bg-primary);">
                    <div class="flex justify-between items-center mb-10">
                        <span class="text-xl font-black tracking-tight" style="color: var(--lp-text-primary);"><span class="text-gold-500">My</span>COINFLIP</span>
                        <button @click="toggleMobileMenu" class="p-2 text-gold-500">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" /></svg>
                        </button>
                    </div>
                    <div class="flex flex-col gap-6 text-center text-lg font-bold">
                        <a href="#features" @click="toggleMobileMenu" style="color: var(--lp-text-secondary);">Features</a>
                        <a href="#market" @click="toggleMobileMenu" style="color: var(--lp-text-secondary);">Markets</a>
                        <a href="#steps" @click="toggleMobileMenu" style="color: var(--lp-text-secondary);">How it Works</a>
                        
                        <div class="w-full h-px my-4" style="background-color: var(--lp-border);"></div>
                        
                        <button @click="toggleTheme" class="py-3 rounded-xl border flex justify-center items-center gap-2" style="border-color: var(--lp-border); color: var(--lp-text-primary);">
                            {{ isLightMode ? 'Switch to Dark Mode' : 'Switch to Light Mode' }}
                        </button>
                        
                        <RouterLink to="/login" @click="toggleMobileMenu" class="py-3 rounded-xl border" style="border-color: var(--lp-border); color: var(--lp-text-primary);">Log In</RouterLink>
                        <RouterLink to="/register" @click="toggleMobileMenu" class="py-3 rounded-xl text-black shadow-lg" style="background: var(--gradient-gold);">Sign Up</RouterLink>
                    </div>
                </div>
            </Transition>
        </Teleport>

        <!-- HERO SECTION -->
        <section class="relative pt-32 pb-20 overflow-hidden min-h-[90vh] flex items-center z-10" style="background: var(--gradient-hero);">
            <div class="container mx-auto px-4 sm:px-6 relative z-10">
                <div class="grid md:grid-cols-2 gap-12 items-center">
                    
                    <!-- Left: Content & Form -->
                    <div>
                        <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border mb-6 text-xs font-bold"
                             style="background-color: var(--lp-bg-card); border-color: var(--lp-border); color: var(--gold-600);">
                            <span class="w-2 h-2 rounded-full bg-gold-500 animate-pulse"></span>
                            Trusted by {{ stats.activeUsers.toLocaleString() }}+ traders globally
                        </div>

                        <h1 class="text-5xl sm:text-6xl md:text-7xl font-black mb-6 leading-[1.1] tracking-tight">
                            Trade Crypto <br/>
                            <span class="text-transparent bg-clip-text" style="background-image: var(--gradient-gold);">Smarter & Faster</span>
                        </h1>
                        
                        <p class="text-lg mb-8 max-w-lg leading-relaxed" style="color: var(--lp-text-secondary);">
                            Join the premier exchange offering spot, futures, and timed trading with deep liquidity, bank-grade security, and zero hidden fees.
                        </p>

                        <!-- Quick Signup -->
                        <div class="flex flex-col sm:flex-row gap-3 max-w-md">
                            <RouterLink to="/register" class="flex-1 py-4 px-6 rounded-xl text-center text-black font-extrabold text-lg transition-all hover:scale-105"
                                  style="background: var(--gradient-gold); box-shadow: var(--shadow-gold);">
                                Claim Your Account
                            </RouterLink>
                            <RouterLink to="/dashboard" class="py-4 px-6 rounded-xl border text-center font-bold text-lg transition-colors hover:bg-black/5 dark:hover:bg-white/5"
                                  style="border-color: var(--lp-border); color: var(--lp-text-primary);">
                                View Exchange
                            </RouterLink>
                        </div>
                    </div>

                    <!-- Right: Floating Elements / App Preview -->
                    <div class="relative hidden md:block">
                        <!-- Simulated App Interface Floating -->
                        <div class="relative rounded-2xl border p-6 backdrop-blur-md transform rotate-[-2deg] hover:rotate-0 transition-transform duration-500"
                             style="background-color: var(--lp-bg-card); border-color: var(--lp-border); box-shadow: var(--shadow-card);">
                            
                            <div class="flex justify-between items-center mb-6 border-b pb-4" style="border-color: var(--lp-border);">
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-full bg-gold-500/20 flex items-center justify-center text-gold-500 font-bold">BTC</div>
                                    <div>
                                        <div class="font-bold text-lg">Bitcoin / USD</div>
                                        <div class="text-xs" style="color: var(--gold-600);">+2.45% Today</div>
                                    </div>
                                </div>
                                <div class="text-right">
                                    <div class="font-mono text-xl font-black">$64,230.50</div>
                                </div>
                            </div>
                            
                            <!-- Fake Chart Lines -->
                            <div class="h-32 w-full flex items-end gap-2 opacity-80">
                                <div v-for="i in 15" :key="i" class="flex-1 rounded-t-sm" 
                                     :style="`height: ${20 + Math.random() * 80}%; background-color: var(--${Math.random() > 0.4 ? 'gold-500' : 'silver-400'});`"></div>
                            </div>

                            <div class="mt-6 flex gap-3">
                                <button class="flex-1 py-2 rounded bg-green-500 text-white font-bold text-sm">Buy Long</button>
                                <button class="flex-1 py-2 rounded bg-red-500 text-white font-bold text-sm">Sell Short</button>
                            </div>
                        </div>

                        <!-- Floating Coins Decor -->
                        <div class="absolute -top-10 -right-10 w-24 h-24 rounded-full border border-gold-500/30 bg-gold-500/10 flex items-center justify-center animate-float">
                            <span class="text-3xl font-black text-gold-500">₿</span>
                        </div>
                        <div class="absolute -bottom-10 -left-10 w-20 h-20 rounded-full border border-silver-400/30 bg-silver-400/10 flex items-center justify-center animate-float" style="animation-delay: 1s;">
                            <span class="text-3xl font-black text-silver-500">Ξ</span>
                        </div>
                    </div>

                </div>
            </div>
        </section>

        <!-- MARKET TICKER -->
        <div class="w-full border-y py-3 relative z-20 flex overflow-hidden backdrop-blur-sm"
             style="background-color: var(--lp-bg-navbar); border-color: var(--lp-border);">
            <div class="flex animate-ticker-scroll whitespace-nowrap" v-if="topCoins.length > 0">
                <div class="flex gap-8 px-4" v-for="n in 3" :key="n"> <!-- Loop multiple times for seamless scrolling -->
                    <div v-for="coin in topCoins.slice(0, 10)" :key="coin.id + n" class="flex items-center gap-3">
                        <img :src="coin.image" class="w-5 h-5 rounded-full" />
                        <span class="font-bold text-sm">{{ coin.symbol.toUpperCase() }}</span>
                        <span class="font-mono text-sm" style="color: var(--lp-text-secondary);">
                            {{ coin.current_price.toLocaleString('en-US', {style: 'currency', currency: 'USD'}) }}
                        </span>
                        <span class="text-xs font-bold" :class="coin.price_change_percentage_24h >= 0 ? 'text-green-500' : 'text-red-500'">
                            {{ coin.price_change_percentage_24h >= 0 ? '+' : '' }}{{ coin.price_change_percentage_24h?.toFixed(2) }}%
                        </span>
                    </div>
                </div>
            </div>
            <div v-else class="text-center w-full text-sm" style="color: var(--lp-text-muted);">Loading live markets...</div>
        </div>

        <!-- FEATURES BENTO GRID -->
        <section id="features" class="py-24 relative z-10" style="background-color: var(--lp-bg-secondary);">
            <div class="container mx-auto px-4 sm:px-6">
                <div class="text-center mb-16">
                    <h2 class="text-3xl md:text-5xl font-black mb-4">Why Trade on <span class="text-gold-500">MyCOINFLIP</span>?</h2>
                    <p class="text-lg" style="color: var(--lp-text-secondary);">Professional-grade tools built for everyone.</p>
                </div>

                <div class="grid md:grid-cols-3 gap-6 max-w-6xl mx-auto">
                    <!-- Feature 1 -->
                    <div class="md:col-span-2 p-8 rounded-3xl border transition-colors hover:border-gold-500"
                         style="background-color: var(--lp-bg-card); border-color: var(--lp-border);">
                        <div class="w-14 h-14 rounded-2xl flex items-center justify-center mb-6" style="background: var(--gradient-gold-soft); color: var(--gold-500);">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-7 h-7"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z" /></svg>
                        </div>
                        <h3 class="text-2xl font-bold mb-3">Lightning Engine</h3>
                        <p style="color: var(--lp-text-secondary);">Our proprietary matching engine handles millions of transactions per second, ensuring your orders execute instantly with zero slippage, even during extreme market volatility.</p>
                    </div>

                    <!-- Feature 2 -->
                    <div class="p-8 rounded-3xl border transition-colors hover:border-silver-400"
                         style="background-color: var(--lp-bg-card); border-color: var(--lp-border);">
                        <div class="w-14 h-14 rounded-2xl flex items-center justify-center mb-6 bg-silver-500/10 text-silver-500">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-7 h-7"><path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z" /></svg>
                        </div>
                        <h3 class="text-xl font-bold mb-3">Bank-Grade Security</h3>
                        <p class="text-sm" style="color: var(--lp-text-secondary);">99% of user funds are held securely in cold storage with multi-signature technology.</p>
                    </div>

                    <!-- Feature 3 -->
                    <div class="p-8 rounded-3xl border transition-colors hover:border-silver-400"
                         style="background-color: var(--lp-bg-card); border-color: var(--lp-border);">
                        <div class="w-14 h-14 rounded-2xl flex items-center justify-center mb-6 bg-silver-500/10 text-silver-500">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-7 h-7"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v12m-3-2.818l.879.659c1.171.879 3.07.879 4.242 0 1.172-.879 1.172-2.303 0-3.182C13.536 12.219 12.768 12 12 12c-.725 0-1.45-.22-2.003-.659-1.106-.879-1.106-2.303 0-3.182s2.9-.879 4.006 0l.415.33M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                        </div>
                        <h3 class="text-xl font-bold mb-3">Deep Liquidity</h3>
                        <p class="text-sm" style="color: var(--lp-text-secondary);">Aggregated from top global liquidity providers for the best bid/ask spreads available.</p>
                    </div>

                    <!-- Feature 4 -->
                    <div class="md:col-span-2 p-8 rounded-3xl border transition-colors hover:border-gold-500 relative overflow-hidden"
                         style="background-color: var(--lp-bg-card); border-color: var(--lp-border);">
                        <div class="absolute right-0 top-0 bottom-0 w-1/2 opacity-10" style="background: var(--gradient-gold); mask-image: linear-gradient(to left, black, transparent);"></div>
                        <div class="relative z-10">
                            <div class="w-14 h-14 rounded-2xl flex items-center justify-center mb-6" style="background: var(--gradient-gold-soft); color: var(--gold-500);">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-7 h-7"><path stroke-linecap="round" stroke-linejoin="round" d="M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z" /><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z" /></svg>
                            </div>
                            <h3 class="text-2xl font-bold mb-3">Timed Trading Platform</h3>
                            <p class="max-w-md" style="color: var(--lp-text-secondary);">Predict price direction in as little as 10 seconds. Set your duration, place your call, and potentially double your investment instantly. High stakes, high reward.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- HOW IT WORKS (STEPS) -->
        <section id="steps" class="py-24 relative z-10">
            <div class="container mx-auto px-4 sm:px-6 max-w-5xl">
                <h2 class="text-3xl md:text-4xl font-black text-center mb-16">Start trading in <span class="text-gold-500">3 simple steps</span></h2>
                
                <div class="grid md:grid-cols-3 gap-8 relative">
                    <!-- Connector Line (Desktop) -->
                    <div class="hidden md:block absolute top-12 left-[16%] right-[16%] h-0.5 border-t-2 border-dashed z-0" style="border-color: var(--lp-border);"></div>
                    
                    <!-- Step 1 -->
                    <div class="text-center relative z-10">
                        <div class="w-24 h-24 mx-auto rounded-full border-4 mb-6 flex items-center justify-center text-3xl font-black bg-white/5"
                             style="border-color: var(--gold-500); color: var(--gold-500);">1</div>
                        <h3 class="text-xl font-bold mb-2">Create Account</h3>
                        <p class="text-sm" style="color: var(--lp-text-secondary);">Sign up in seconds. Verify your identity to unlock higher limits and premium features.</p>
                    </div>

                    <!-- Step 2 -->
                    <div class="text-center relative z-10">
                        <div class="w-24 h-24 mx-auto rounded-full border-4 mb-6 flex items-center justify-center text-3xl font-black bg-white/5"
                             style="border-color: var(--silver-400); color: var(--silver-500);">2</div>
                        <h3 class="text-xl font-bold mb-2">Deposit Funds</h3>
                        <p class="text-sm" style="color: var(--lp-text-secondary);">Fund your wallet via crypto transfer or fiat gateway instantly with zero deposit fees.</p>
                    </div>

                    <!-- Step 3 -->
                    <div class="text-center relative z-10">
                        <div class="w-24 h-24 mx-auto rounded-full border-4 mb-6 flex items-center justify-center text-3xl font-black bg-white/5"
                             style="border-color: var(--gold-600); color: var(--gold-600);">3</div>
                        <h3 class="text-xl font-bold mb-2">Start Trading</h3>
                        <p class="text-sm" style="color: var(--lp-text-secondary);">Access spot markets or try our timed trading platform to multiply your portfolio.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- CTA SECTION -->
        <section class="py-24 relative z-10 text-center border-t" style="border-color: var(--lp-border); background-color: var(--lp-bg-secondary);">
            <div class="container mx-auto px-4">
                <h2 class="text-4xl md:text-6xl font-black mb-6">Ready to dominate the market?</h2>
                <p class="text-lg mb-10" style="color: var(--lp-text-secondary);">Join millions of users on the fastest-growing crypto platform.</p>
                <RouterLink to="/register" class="inline-block px-12 py-5 rounded-full text-black font-extrabold text-lg transition-all hover:scale-105 shadow-xl"
                      style="background: var(--gradient-gold); box-shadow: var(--shadow-gold);">
                    Create Free Account
                </RouterLink>
            </div>
        </section>

        <!-- FOOTER -->
        <footer class="py-12 border-t text-sm relative z-10" style="border-color: var(--lp-border); background-color: var(--lp-bg-navbar); color: var(--lp-text-muted);">
            <div class="container mx-auto px-4 grid grid-cols-2 md:grid-cols-4 gap-8">
                <div class="col-span-2 md:col-span-1">
                    <span class="text-xl font-black tracking-tight block mb-4" style="color: var(--lp-text-primary);"><span class="text-gold-500">My</span>COINFLIP</span>
                    <p class="mb-4">The premier platform for professional crypto trading.</p>
                    <p>&copy; 2024 MyCOINFLIP. All rights reserved.</p>
                </div>
                <div>
                    <h4 class="font-bold mb-4 uppercase tracking-widest" style="color: var(--lp-text-primary);">Products</h4>
                    <ul class="space-y-2">
                        <li><a href="#" class="hover:text-gold-500 transition-colors">Spot Trading</a></li>
                        <li><a href="#" class="hover:text-gold-500 transition-colors">Timed Trading</a></li>
                        <li><a href="#" class="hover:text-gold-500 transition-colors">Wallet</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="font-bold mb-4 uppercase tracking-widest" style="color: var(--lp-text-primary);">Support</h4>
                    <ul class="space-y-2">
                        <li><a href="#" class="hover:text-gold-500 transition-colors">Help Center</a></li>
                        <li><a href="#" class="hover:text-gold-500 transition-colors">Fees</a></li>
                        <li><a href="#" class="hover:text-gold-500 transition-colors">API Documentation</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="font-bold mb-4 uppercase tracking-widest" style="color: var(--lp-text-primary);">Legal</h4>
                    <ul class="space-y-2">
                        <li><a href="#" class="hover:text-gold-500 transition-colors">Terms of Service</a></li>
                        <li><a href="#" class="hover:text-gold-500 transition-colors">Privacy Policy</a></li>
                        <li><a href="#" class="hover:text-gold-500 transition-colors">KYC/AML</a></li>
                    </ul>
                </div>
            </div>
        </footer>

        <!-- TRANSACTION POPUPS (Simulated Activity) -->
        <div class="fixed bottom-6 left-6 z-[9999] flex flex-col gap-3 pointer-events-none">
            <TransitionGroup name="popup">
                <div v-for="popup in popups" :key="popup.id" 
                     class="px-4 py-3 rounded-lg border backdrop-blur-md shadow-lg flex items-center gap-3 animate-slide-in-left max-w-xs"
                     style="background-color: var(--popup-bg); border-color: var(--popup-border);">
                    <div class="w-8 h-8 rounded-full flex items-center justify-center bg-green-500/20 text-green-500">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="w-4 h-4"><path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" /></svg>
                    </div>
                    <p class="text-sm font-medium" style="color: var(--lp-text-primary);">{{ popup.message }}</p>
                </div>
            </TransitionGroup>
        </div>

    </div>
</template>

<style scoped>
/* Scoped overrides to protect rest of app */
.landing-page-root {
    transition: background-color 0.3s ease, color 0.3s ease;
}

/* Animations */
.popup-enter-active, .popup-leave-active {
    transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
}
.popup-enter-from {
    opacity: 0;
    transform: translateX(-50px);
}
.popup-leave-to {
    opacity: 0;
    transform: translateX(-50px) scale(0.9);
}

.fade-enter-active, .fade-leave-active {
    transition: opacity 0.3s;
}
.fade-enter-from, .fade-leave-to {
    opacity: 0;
}
</style>
