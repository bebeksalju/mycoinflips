<script setup>
import { RouterLink } from 'vue-router';
import { useMarketStore } from '../stores/market';
import { onMounted, computed, ref, onUnmounted, reactive } from 'vue';

const marketStore = useMarketStore();

const isMobileMenuOpen = ref(false);
const isLightMode = ref(localStorage.getItem('theme') === 'light');

// ── Profit Calculator ──────────────────────────────────────────────
const depositAmount = ref(500);
const selectedPreset = ref(500);
const presets = [100, 500, 1000, 5000];

const setPreset = (amount) => {
    selectedPreset.value = amount;
    depositAmount.value = amount;
};

// 85% payout, 70% win rate, 3 trades / day, 10% stake per trade
const dailyProfit = computed(() => {
    const stake = depositAmount.value * 0.1;
    return (3 * 0.70 * stake * 0.85) - (3 * 0.30 * stake);
});
const weeklyProfit  = computed(() => dailyProfit.value * 7);
const monthlyProfit = computed(() => dailyProfit.value * 30);
const monthlyROI    = computed(() => (monthlyProfit.value / depositAmount.value) * 100);

const formatProfit = (val) =>
    val >= 1000 ? '$' + (val / 1000).toFixed(2) + 'K' : '$' + val.toFixed(2);

// ── Live Stats ──────────────────────────────────────────────────────
const stats = reactive({ activeUsers: 14475, volume: 125890000 });

// ── Announcement Ticker ─────────────────────────────────────────────
const announcements = [
    { tag: 'PRO TRADE', text: '0% Trading Fees on your first $10,000 volume + Instant 10s Timed Options!' },
    { tag: null,        text: 'Get 10x more with your First Deposit', highlight: true },
    { tag: null,        text: 'Live Market Cap: $1,850.0B' },
    { tag: 'NEW',       text: '85% Payout on Winning Trades — Start with as low as $10 deposit!' },
    { tag: null,        text: 'Withdraw instantly via USDT TRC20 · BTC · ETH — 24/7 Support' },
];

// ── Transaction Popups ──────────────────────────────────────────────
const popups = ref([]);
let popupId = 0;
const cities      = ['San Antonio', 'Los Angeles', 'New York', 'Chicago', 'Miami', 'Houston', 'Phoenix', 'Philadelphia', 'San Diego', 'Dallas', 'Austin', 'Seattle', 'Denver', 'Las Vegas', 'Portland', 'Nashville', 'Atlanta', 'Boston', 'Detroit', 'Minneapolis'];
const coinSymbols = ['BTC', 'ETH', 'SOL', 'BNB', 'XRP', 'ADA', 'DOGE', 'AVAX'];

const createPopup = () => {
    if (popups.value.length >= 2) popups.value.shift();
    const coin   = coinSymbols[Math.floor(Math.random() * coinSymbols.length)];
    const hash   = Math.random().toString(36).substring(2, 6).toUpperCase();
    const city   = cities[Math.floor(Math.random() * cities.length)];
    const isWin  = Math.random() > 0.35;
    const amount = isWin
        ? '+$' + (Math.random() * 2000 + 50).toFixed(0)
        : '$'  + (Math.random() * 1.5 + 0.3).toFixed(1) + 'K';

    const p = {
        id: popupId++,
        type: isWin ? 'WIN' : 'WITHDRAW',
        user: `trader***${hash}`,
        city,
        amount,
        coin,
        action: isWin ? 'just earned' : 'withdrew',
    };
    popups.value.push(p);
    setTimeout(() => { popups.value = popups.value.filter(x => x.id !== p.id); }, 4500);
};

let statsInterval = null;
let popupInterval = null;

onMounted(() => {
    marketStore.fetchMarketOverview();

    if (isLightMode.value) document.documentElement.classList.add('light-mode');

    statsInterval = setInterval(() => {
        stats.activeUsers = Math.max(10000, stats.activeUsers + Math.floor(Math.random() * 20) - 5);
        stats.volume      += Math.floor(Math.random() * 50000);
    }, 3000);

    setTimeout(() => {
        createPopup();
        popupInterval = setInterval(() => {
            if (Math.random() > 0.3) createPopup();
        }, 6000 + Math.random() * 3000);
    }, 2000);
});

onUnmounted(() => {
    if (statsInterval) clearInterval(statsInterval);
    if (popupInterval) clearInterval(popupInterval);
});

const toggleMobileMenu = () => { isMobileMenuOpen.value = !isMobileMenuOpen.value; };

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

const formatVolume = (num) => {
    if (num >= 1e9) return '$' + (num / 1e9).toFixed(2) + 'B';
    if (num >= 1e6) return '$' + (num / 1e6).toFixed(2) + 'M';
    return '$' + num.toLocaleString();
};
</script>

<template>
    <div class="lp-root" :class="{ 'lp-light': isLightMode }">

        <!-- ══════════════════════════════════════════
             ANNOUNCEMENT BAR (scrolling ticker)
        ══════════════════════════════════════════ -->
        <div class="ann-bar">
            <div class="ann-track">
                <template v-for="n in 3" :key="n">
                    <span v-for="(ann, i) in announcements" :key="i" class="ann-item">
                        <span v-if="ann.tag" class="ann-tag" :class="ann.tag === 'NEW' ? 'ann-tag--green' : 'ann-tag--gold'">
                            {{ ann.tag }}
                        </span>
                        <span :class="ann.highlight ? 'ann-highlight' : 'ann-text'">{{ ann.text }}</span>
                        <span class="ann-sep">·</span>
                    </span>
                </template>
            </div>
        </div>

        <!-- ══════════════════════════════════════════
             NAVBAR
        ══════════════════════════════════════════ -->
        <nav class="navbar">
            <div class="navbar-inner">
                <!-- Logo -->
                <RouterLink to="/" class="logo">
                    <span class="logo-rune">ᛏ</span>MyCOINFLIP
                </RouterLink>

                <!-- Desktop Nav Links -->
                <div class="nav-links">
                    <a href="#market"   class="nav-link">Markets</a>
                    <RouterLink to="/dashboard" class="nav-link">Live Trade</RouterLink>
                    <a href="#steps"    class="nav-link">3-Step Guide</a>
                    <a href="#features" class="nav-link">Features</a>
                    <a href="#security" class="nav-link">Security</a>
                </div>

                <!-- Desktop Actions -->
                <div class="nav-actions">
                    <button @click="toggleTheme" class="theme-btn" :title="isLightMode ? 'Dark mode' : 'Light mode'">
                        <svg v-if="!isLightMode" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="icon-sm">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M21.752 15.002A9.718 9.718 0 0118 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 003 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 009.002-5.998z" />
                        </svg>
                        <svg v-else xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="icon-sm">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2.25m6.364.386l-1.591 1.591M21 12h-2.25m-.386 6.364l-1.591-1.591M12 18.75V21m-4.773-4.227l-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z" />
                        </svg>
                    </button>
                    <RouterLink to="/login" class="login-btn">Log In</RouterLink>
                    <RouterLink to="/register" class="cta-btn">Start Trading</RouterLink>
                </div>

                <!-- Mobile Hamburger -->
                <button @click="toggleMobileMenu" class="hamburger">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="icon-md">
                        <path v-if="!isMobileMenuOpen" stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
                        <path v-else stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
        </nav>

        <!-- Mobile Overlay -->
        <Teleport to="body">
            <Transition name="fade">
                <div v-if="isMobileMenuOpen" class="mobile-overlay">
                    <div class="mobile-header">
                        <span class="logo"><span class="logo-rune">ᛏ</span>MyCOINFLIP</span>
                        <button @click="toggleMobileMenu" class="hamburger">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="icon-md">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                    <div class="mobile-links">
                        <a href="#market"   @click="toggleMobileMenu" class="mob-link">Markets</a>
                        <RouterLink to="/dashboard" @click="toggleMobileMenu" class="mob-link">Live Trade</RouterLink>
                        <a href="#steps"    @click="toggleMobileMenu" class="mob-link">3-Step Guide</a>
                        <a href="#features" @click="toggleMobileMenu" class="mob-link">Features</a>
                        <div class="mob-divider"></div>
                        <RouterLink to="/login"    @click="toggleMobileMenu" class="mob-btn mob-btn--outline">Log In</RouterLink>
                        <RouterLink to="/register" @click="toggleMobileMenu" class="mob-btn mob-btn--gold">Start Trading</RouterLink>
                    </div>
                </div>
            </Transition>
        </Teleport>

        <!-- ══════════════════════════════════════════
             HERO SECTION
        ══════════════════════════════════════════ -->
        <section class="hero">
            <!-- Glow orbs -->
            <div class="glow glow-gold"></div>
            <div class="glow glow-purple"></div>

            <div class="container hero-grid">

                <!-- ── LEFT COLUMN ────────────────── -->
                <div class="hero-left">
                    <!-- Active Traders badge -->
                    <div class="badge badge-green">
                        <span class="badge-dot"></span>
                        <span class="badge-sep">24h</span>
                        <span class="badge-pipe">|</span>
                        <span class="badge-count">{{ stats.activeUsers.toLocaleString() }} Active Traders</span>
                    </div>

                    <h1 class="hero-heading">
                        Next-Gen Crypto Exchange &amp;<br />
                        <span class="heading-gold">Timed Trading <span class="heading-gold-dim">Engine</span></span>
                    </h1>

                    <p class="hero-sub">
                        Trade 10+ top digital assets with instant sub-50ms execution, bank-grade
                        security, and zero fees on your first $10,000 volume.
                    </p>

                    <div class="hero-cta-row">
                        <RouterLink to="/register" class="btn-gold-hero">
                            Get Started Free
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="icon-sm"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" /></svg>
                        </RouterLink>
                        <RouterLink to="/dashboard" class="btn-outline-hero">Explore Live Markets</RouterLink>
                    </div>

                    <!-- Stats -->
                    <div class="hero-stats">
                        <div class="stat">
                            <div class="stat-value">{{ formatVolume(stats.volume) }}</div>
                            <div class="stat-label">24H VOL</div>
                        </div>
                        <div class="stat-sep"></div>
                        <div class="stat">
                            <div class="stat-value stat-gold">&lt; 50ms</div>
                            <div class="stat-label">ORDER MATCH</div>
                        </div>
                        <div class="stat-sep"></div>
                        <div class="stat">
                            <div class="stat-value">98%</div>
                            <div class="stat-label">COLD STORAGE</div>
                        </div>
                    </div>
                </div>

                <!-- ── RIGHT COLUMN: Profit Calculator ── -->
                <div class="hero-right">
                    <div class="calc-card">
                        <!-- Card Header -->
                        <div class="calc-header">
                            <div>
                                <div class="calc-brand">MCOPTION</div>
                                <div class="calc-title">Profit Calculator</div>
                            </div>
                            <div class="payout-badge">
                                <span class="payout-dot"></span>
                                85% Payout
                            </div>
                        </div>

                        <!-- Deposit Label -->
                        <div class="field-label">DEPOSIT AMOUNT (USDT)</div>

                        <!-- Amount Input -->
                        <div class="calc-input-wrap">
                            <span class="calc-dollar">$</span>
                            <input
                                id="deposit-input"
                                type="number"
                                v-model="depositAmount"
                                @input="selectedPreset = null"
                                class="calc-input"
                                min="10"
                            />
                        </div>

                        <!-- Presets -->
                        <div class="calc-presets">
                            <button
                                v-for="preset in presets"
                                :key="preset"
                                @click="setPreset(preset)"
                                class="preset-btn"
                                :class="{ 'preset-btn--active': selectedPreset === preset }"
                            >
                                {{ preset >= 1000 ? '$' + preset / 1000 + 'K' : '$' + preset }}
                            </button>
                        </div>

                        <!-- Earnings Row -->
                        <div class="earnings-row">
                            <div class="earning-cell">
                                <div class="earning-value">{{ formatProfit(dailyProfit) }}</div>
                                <div class="earning-label">DAILY</div>
                            </div>
                            <div class="earning-cell">
                                <div class="earning-value">{{ formatProfit(weeklyProfit) }}</div>
                                <div class="earning-label">WEEKLY</div>
                            </div>
                            <div class="earning-cell">
                                <div class="earning-value">{{ formatProfit(monthlyProfit) }}</div>
                                <div class="earning-label">MONTHLY</div>
                            </div>
                        </div>

                        <!-- ROI Bar -->
                        <div class="roi-section">
                            <div class="roi-header">
                                <span class="field-label" style="margin:0">EST. MONTHLY ROI</span>
                                <span class="roi-pct">+{{ monthlyROI.toFixed(1) }}%</span>
                            </div>
                            <div class="roi-track">
                                <div class="roi-fill" :style="{ width: Math.min(100, monthlyROI / 10) + '%' }"></div>
                            </div>
                        </div>

                        <p class="calc-disclaimer">
                            * Estimation based on 85% payout rate &amp; 70% win rate. Results may vary.
                        </p>

                        <RouterLink to="/register" class="calc-cta">
                            Start Earning Now
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="icon-sm"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" /></svg>
                        </RouterLink>
                    </div>
                </div>

            </div>
        </section>

        <!-- ══════════════════════════════════════════
             MARKET TICKER
        ══════════════════════════════════════════ -->
        <div id="market" class="ticker-bar">
            <div class="ticker-track" v-if="topCoins.length > 0">
                <div class="ticker-set" v-for="n in 3" :key="n">
                    <div v-for="coin in topCoins.slice(0, 10)" :key="coin.id + n" class="ticker-item">
                        <img :src="coin.image" class="ticker-img" />
                        <span class="ticker-sym">{{ coin.symbol.toUpperCase() }}</span>
                        <span class="ticker-price">
                            {{ coin.current_price.toLocaleString('en-US', { style: 'currency', currency: 'USD' }) }}
                        </span>
                        <span class="ticker-chg" :class="coin.price_change_percentage_24h >= 0 ? 'green' : 'red'">
                            {{ coin.price_change_percentage_24h >= 0 ? '+' : '' }}{{ coin.price_change_percentage_24h?.toFixed(2) }}%
                        </span>
                    </div>
                </div>
            </div>
            <div v-else class="ticker-loading">Loading live markets…</div>
        </div>

        <!-- ══════════════════════════════════════════
             FEATURES BENTO GRID
        ══════════════════════════════════════════ -->
        <section id="features" class="section section-alt">
            <div class="container">
                <div class="section-head">
                    <h2 class="section-title">Why Trade on <span class="gold">MyCOINFLIP</span>?</h2>
                    <p class="section-sub">Professional-grade tools built for everyone.</p>
                </div>

                <div class="bento-grid">
                    <div class="bento-card bento-wide hover-gold">
                        <div class="feature-icon gold-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="icon-lg"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 13.5l10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75z" /></svg>
                        </div>
                        <h3 class="feat-title">Lightning Engine</h3>
                        <p class="feat-desc">Our proprietary matching engine handles millions of transactions per second, ensuring your orders execute instantly with zero slippage, even during extreme market volatility.</p>
                    </div>

                    <div class="bento-card hover-silver">
                        <div class="feature-icon silver-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="icon-lg"><path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z" /></svg>
                        </div>
                        <h3 class="feat-title">Bank-Grade Security</h3>
                        <p class="feat-desc">99% of user funds are held securely in cold storage with multi-signature technology.</p>
                    </div>

                    <div class="bento-card hover-silver">
                        <div class="feature-icon silver-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="icon-lg"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v12m-3-2.818l.879.659c1.171.879 3.07.879 4.242 0 1.172-.879 1.172-2.303 0-3.182C13.536 12.219 12.768 12 12 12c-.725 0-1.45-.22-2.003-.659-1.106-.879-1.106-2.303 0-3.182s2.9-.879 4.006 0l.415.33M21 12a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
                        </div>
                        <h3 class="feat-title">Deep Liquidity</h3>
                        <p class="feat-desc">Aggregated from top global liquidity providers for the best bid/ask spreads available.</p>
                    </div>

                    <div class="bento-card bento-wide hover-gold bento-glow">
                        <div class="bento-glow-layer"></div>
                        <div style="position:relative;z-index:1;">
                            <div class="feature-icon gold-icon">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="icon-lg"><path stroke-linecap="round" stroke-linejoin="round" d="M10.5 6a7.5 7.5 0 107.5 7.5h-7.5V6z" /><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 10.5H21A7.5 7.5 0 0013.5 3v7.5z" /></svg>
                            </div>
                            <h3 class="feat-title">Timed Trading Platform</h3>
                            <p class="feat-desc" style="max-width:30rem;">Predict price direction in as little as 10 seconds. Set your duration, place your call, and potentially earn 85% payout instantly. High stakes, high reward.</p>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- ══════════════════════════════════════════
             3-STEP GUIDE
        ══════════════════════════════════════════ -->
        <section id="steps" class="section">
            <div class="container" style="max-width:900px;">
                <h2 class="section-title text-center">Start trading in <span class="gold">3 simple steps</span></h2>

                <div class="steps-grid">
                    <div class="steps-connector"></div>

                    <div class="step">
                        <div class="step-num step-gold">1</div>
                        <h3 class="step-title">Create Account</h3>
                        <p class="step-desc">Sign up in seconds. Verify your identity to unlock higher limits and premium features.</p>
                    </div>
                    <div class="step">
                        <div class="step-num step-silver">2</div>
                        <h3 class="step-title">Deposit Funds</h3>
                        <p class="step-desc">Fund your wallet via crypto transfer instantly with zero deposit fees.</p>
                    </div>
                    <div class="step">
                        <div class="step-num step-gold2">3</div>
                        <h3 class="step-title">Start Trading</h3>
                        <p class="step-desc">Access spot markets or our timed trading platform to multiply your portfolio.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- ══════════════════════════════════════════
             CTA
        ══════════════════════════════════════════ -->
        <section id="security" class="section section-alt cta-section">
            <div class="container text-center">
                <h2 class="section-title" style="font-size:clamp(2rem,5vw,3.5rem);">Ready to dominate the market?</h2>
                <p class="section-sub">Join millions of users on the fastest-growing crypto platform.</p>
                <RouterLink to="/register" class="cta-btn-large">Create Free Account</RouterLink>
            </div>
        </section>

        <!-- ══════════════════════════════════════════
             FOOTER
        ══════════════════════════════════════════ -->
        <footer class="footer">
            <div class="container footer-grid">
                <div>
                    <div class="footer-logo"><span class="logo-rune">ᛏ</span>MyCOINFLIP</div>
                    <p class="footer-tagline">The premier platform for professional crypto trading.</p>
                    <p class="footer-copy">&copy; 2024 MyCOINFLIP. All rights reserved.</p>
                </div>
                <div>
                    <h4 class="footer-head">Products</h4>
                    <ul class="footer-list">
                        <li><a href="#">Spot Trading</a></li>
                        <li><a href="#">Timed Trading</a></li>
                        <li><a href="#">Wallet</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="footer-head">Support</h4>
                    <ul class="footer-list">
                        <li><a href="#">Help Center</a></li>
                        <li><a href="#">Fees</a></li>
                        <li><a href="#">API Docs</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="footer-head">Legal</h4>
                    <ul class="footer-list">
                        <li><a href="#">Terms of Service</a></li>
                        <li><a href="#">Privacy Policy</a></li>
                        <li><a href="#">KYC/AML</a></li>
                    </ul>
                </div>
            </div>
        </footer>

        <!-- ══════════════════════════════════════════
             TRANSACTION POPUPS
        ══════════════════════════════════════════ -->
        <div class="popup-area">
            <TransitionGroup name="popup">
                <div v-for="popup in popups" :key="popup.id" class="popup-card">
                    <div class="popup-icon" :class="popup.type === 'WIN' ? 'popup-icon--green' : 'popup-icon--gold'">
                        <span class="popup-badge-type" :class="popup.type === 'WIN' ? 'text-green-win' : 'text-gold-win'">
                            {{ popup.type }}
                        </span>
                    </div>
                    <div class="popup-body">
                        <p class="popup-user">{{ popup.user }} <span class="popup-from">from {{ popup.city }}, USA</span></p>
                        <p class="popup-msg">
                            {{ popup.action }}
                            <strong :class="popup.type === 'WIN' ? 'text-green-win' : 'text-gold-win'">{{ popup.amount }}</strong>
                            on {{ popup.coin }} trade
                        </p>
                    </div>
                </div>
            </TransitionGroup>
        </div>

    </div>
</template>

<style scoped>
/* ═══════════════════════════════════════════════════════
   ROOT & SCROLL
═══════════════════════════════════════════════════════ */
.lp-root {
    height: 100vh;
    overflow-y: auto;
    overflow-x: hidden;
    background-color: var(--lp-bg-primary);
    color: var(--lp-text-primary);
    font-family: 'Inter', system-ui, sans-serif;
    transition: background-color .35s, color .35s;
    scroll-behavior: smooth;
    -ms-overflow-style: none;
    scrollbar-width: none;
}
.lp-root::-webkit-scrollbar { display: none; }

/* Light mode override card background */
.lp-light .calc-card { background: #ffffff; border-color: #e5e7eb; }
.lp-light .calc-input-wrap { background: #f3f4f6; border-color: #d1d5db; }
.lp-light .preset-btn { background: #f3f4f6; border-color: #d1d5db; color: #4b5563; }
.lp-light .roi-track { background: #e5e7eb; }
.lp-light .ann-bar { background: #f9fafb; border-bottom-color: #e5e7eb; }
.lp-light .navbar { background: rgba(249,250,251,0.95); border-bottom-color: #e5e7eb; }

/* ═══════════════════════════════════════════════════════
   UTILITIES
═══════════════════════════════════════════════════════ */
.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 1.5rem;
}
.gold   { color: var(--gold-500); }
.green  { color: #22c55e; }
.red    { color: #ef4444; }
.text-center { text-align: center; }
.icon-sm { width: 1rem; height: 1rem; }
.icon-md { width: 1.5rem; height: 1.5rem; }
.icon-lg { width: 1.75rem; height: 1.75rem; }

/* ═══════════════════════════════════════════════════════
   ANNOUNCEMENT BAR
═══════════════════════════════════════════════════════ */
.ann-bar {
    background: #080a10;
    border-bottom: 1px solid rgba(255,255,255,.06);
    height: 32px;
    overflow: hidden;
    display: flex;
    align-items: center;
}
.ann-track {
    display: flex;
    gap: 0;
    white-space: nowrap;
    animation: tickerScroll 35s linear infinite;
}
.ann-item {
    display: inline-flex;
    align-items: center;
    gap: .5rem;
    padding: 0 .5rem;
    font-size: .7rem;
    font-weight: 600;
}
.ann-tag {
    display: inline-block;
    padding: .1rem .45rem;
    border-radius: .25rem;
    font-size: .6rem;
    font-weight: 900;
    color: #000;
    flex-shrink: 0;
}
.ann-tag--gold  { background: var(--gold-500); }
.ann-tag--green { background: #22c55e; }
.ann-text { color: var(--lp-text-secondary); }
.ann-highlight { color: var(--gold-500); font-weight: 700; }
.ann-sep { color: rgba(255,255,255,.2); margin-left: 1.5rem; }

/* ═══════════════════════════════════════════════════════
   NAVBAR
═══════════════════════════════════════════════════════ */
.navbar {
    position: sticky;
    top: 0;
    z-index: 100;
    background: rgba(8,10,16,.93);
    border-bottom: 1px solid var(--lp-border);
    backdrop-filter: blur(20px);
}
.navbar-inner {
    max-width: 1200px;
    margin: 0 auto;
    padding: .75rem 1.5rem;
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.logo {
    font-size: 1.1rem;
    font-weight: 900;
    letter-spacing: -.02em;
    text-decoration: none;
    color: var(--lp-text-primary);
    display: flex;
    align-items: center;
    gap: .2rem;
}
.logo-rune { color: var(--gold-500); font-size: 1.2rem; }

.nav-links {
    display: none;
    align-items: center;
    gap: 1.75rem;
}
@media (min-width: 768px) { .nav-links { display: flex; } }
.nav-link {
    font-size: .7rem;
    font-weight: 700;
    letter-spacing: .1em;
    text-transform: uppercase;
    color: var(--lp-text-secondary);
    text-decoration: none;
    transition: color .2s;
}
.nav-link:hover { color: var(--gold-500); }

.nav-actions {
    display: none;
    align-items: center;
    gap: .75rem;
}
@media (min-width: 768px) { .nav-actions { display: flex; } }

.theme-btn {
    background: none;
    border: none;
    cursor: pointer;
    padding: .4rem;
    border-radius: 999px;
    color: var(--lp-text-secondary);
    transition: background .2s, color .2s;
    display: flex;
    align-items: center;
}
.theme-btn:hover { background: rgba(255,255,255,.06); color: var(--lp-text-primary); }

.login-btn {
    font-size: .8rem;
    font-weight: 700;
    color: var(--lp-text-primary);
    text-decoration: none;
    transition: color .2s;
}
.login-btn:hover { color: var(--gold-500); }

.cta-btn {
    padding: .5rem 1.25rem;
    background: var(--gradient-gold);
    color: #000;
    font-size: .8rem;
    font-weight: 900;
    border-radius: .5rem;
    text-decoration: none;
    box-shadow: 0 4px 18px rgba(255,215,0,.3);
    transition: transform .2s, filter .2s;
}
.cta-btn:hover { transform: scale(1.04); filter: brightness(1.1); }

.hamburger {
    display: flex;
    background: none;
    border: none;
    cursor: pointer;
    color: var(--gold-500);
    padding: .4rem;
}
@media (min-width: 768px) { .hamburger { display: none; } }

/* ─── Mobile Overlay ── */
.mobile-overlay {
    position: fixed;
    inset: 0;
    z-index: 9999;
    background: var(--lp-bg-primary);
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
}
.mobile-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2.5rem;
}
.mobile-links {
    display: flex;
    flex-direction: column;
    gap: 1.25rem;
    text-align: center;
}
.mob-link {
    font-size: .75rem;
    font-weight: 700;
    letter-spacing: .1em;
    text-transform: uppercase;
    color: var(--lp-text-secondary);
    text-decoration: none;
}
.mob-divider { height: 1px; background: var(--lp-border); margin: .5rem 0; }
.mob-btn {
    padding: .85rem;
    border-radius: .75rem;
    font-weight: 700;
    font-size: .9rem;
    text-decoration: none;
    text-align: center;
}
.mob-btn--outline { border: 1px solid var(--lp-border); color: var(--lp-text-primary); }
.mob-btn--gold    { background: var(--gradient-gold); color: #000; }

/* ═══════════════════════════════════════════════════════
   HERO
═══════════════════════════════════════════════════════ */
.hero {
    position: relative;
    padding: 4rem 0 5rem;
    min-height: calc(100vh - 88px);
    display: flex;
    align-items: center;
    overflow: hidden;
}
.glow {
    position: absolute;
    border-radius: 50%;
    pointer-events: none;
    filter: blur(90px);
    opacity: .07;
}
.glow-gold   { width: 500px; height: 500px; background: var(--gold-500); top: 5%; left: 5%;  }
.glow-purple { width: 400px; height: 400px; background: #6366f1;         bottom: 5%; right: 5%; }

.hero-grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: 3rem;
    align-items: center;
    width: 100%;
}
@media (min-width: 768px) {
    .hero-grid { grid-template-columns: 1fr 1fr; gap: 4rem; }
}
@media (min-width: 1280px) {
    .hero-grid { gap: 5rem; }
}

/* Badge */
.badge {
    display: inline-flex;
    align-items: center;
    gap: .5rem;
    padding: .35rem .9rem;
    border-radius: 999px;
    font-size: .7rem;
    font-weight: 700;
    margin-bottom: 1.5rem;
}
.badge-green {
    background: rgba(34,197,94,.08);
    border: 1px solid rgba(34,197,94,.25);
    color: #22c55e;
}
.badge-dot  { width: .5rem; height: .5rem; border-radius: 50%; background: #22c55e; animation: pulse 2s infinite; }
.badge-sep  { font-weight: 400; opacity: .7; }
.badge-pipe { width: 1px; height: .75rem; background: rgba(34,197,94,.35); }
.badge-count{ font-weight: 900; }

/* Heading */
.hero-heading {
    font-size: clamp(2.4rem, 5vw, 4rem);
    font-weight: 900;
    line-height: 1.06;
    letter-spacing: -.03em;
    margin: 0 0 1.25rem;
}
.heading-gold {
    background: linear-gradient(135deg, #FFD700 0%, #DAA520 55%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}
.heading-gold-dim {
    background: linear-gradient(135deg, #DAA520 0%, rgba(218,165,32,.55) 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.hero-sub {
    font-size: .95rem;
    color: var(--lp-text-secondary);
    line-height: 1.7;
    max-width: 420px;
    margin-bottom: 2rem;
}

/* CTA row */
.hero-cta-row { display: flex; flex-wrap: wrap; gap: .75rem; margin-bottom: 3rem; }

.btn-gold-hero {
    display: inline-flex;
    align-items: center;
    gap: .5rem;
    padding: .75rem 1.5rem;
    background: var(--gradient-gold);
    color: #000;
    font-weight: 900;
    font-size: .875rem;
    border-radius: .6rem;
    text-decoration: none;
    box-shadow: 0 4px 22px rgba(255,215,0,.3);
    transition: transform .2s, filter .2s;
}
.btn-gold-hero:hover { transform: scale(1.04); filter: brightness(1.08); }

.btn-outline-hero {
    display: inline-flex;
    align-items: center;
    padding: .75rem 1.5rem;
    border: 1px solid var(--lp-border);
    border-radius: .6rem;
    color: var(--lp-text-primary);
    font-weight: 700;
    font-size: .875rem;
    text-decoration: none;
    transition: border-color .2s, background .2s;
}
.btn-outline-hero:hover { border-color: rgba(255,215,0,.35); background: rgba(255,255,255,.04); }

/* Stats */
.hero-stats { display: flex; align-items: center; gap: 1.5rem; flex-wrap: wrap; }
.stat-sep   { width: 1px; height: 2.5rem; background: var(--lp-border); }
.stat-value { font-size: 1.5rem; font-weight: 900; }
.stat-gold  { color: var(--gold-500); }
.stat-label { font-size: .65rem; font-weight: 700; letter-spacing: .12em; text-transform: uppercase; color: var(--lp-text-muted); margin-top: .15rem; }

/* ─── Profit Calculator ── */
.calc-card {
    background: rgba(255,255,255,.03);
    border: 1px solid var(--lp-border);
    border-radius: 1.25rem;
    padding: 1.75rem;
    box-shadow: 0 10px 50px rgba(0,0,0,.45);
    transition: background .35s, border-color .35s;
}
.calc-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 1.25rem;
}
.calc-brand {
    font-size: .65rem;
    font-weight: 900;
    letter-spacing: .15em;
    text-transform: uppercase;
    color: var(--gold-500);
    margin-bottom: .2rem;
}
.calc-title { font-size: 1.25rem; font-weight: 900; }

.payout-badge {
    display: inline-flex;
    align-items: center;
    gap: .4rem;
    padding: .3rem .75rem;
    border-radius: 999px;
    font-size: .7rem;
    font-weight: 700;
    background: rgba(34,197,94,.1);
    border: 1px solid rgba(34,197,94,.25);
    color: #22c55e;
}
.payout-dot { width: .45rem; height: .45rem; border-radius: 50%; background: #22c55e; animation: pulse 2s infinite; }

.field-label {
    font-size: .65rem;
    font-weight: 700;
    letter-spacing: .12em;
    text-transform: uppercase;
    color: var(--lp-text-muted);
    margin-bottom: .5rem;
    display: block;
}

.calc-input-wrap {
    display: flex;
    align-items: center;
    gap: .5rem;
    background: rgba(255,255,255,.05);
    border: 1px solid var(--lp-border);
    border-radius: .6rem;
    padding: .7rem 1rem;
    margin-bottom: .75rem;
    transition: border-color .2s;
}
.calc-input-wrap:focus-within { border-color: rgba(255,215,0,.4); }
.calc-dollar { font-size: 1.1rem; font-weight: 700; color: var(--lp-text-secondary); }
.calc-input {
    flex: 1;
    background: transparent;
    border: none;
    outline: none;
    font-size: 1.1rem;
    font-weight: 700;
    color: var(--lp-text-primary);
    font-family: inherit;
}
/* Remove number arrows */
.calc-input::-webkit-inner-spin-button,
.calc-input::-webkit-outer-spin-button { -webkit-appearance: none; margin: 0; }
.calc-input { -moz-appearance: textfield; }

.calc-presets {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: .5rem;
    margin-bottom: 1.25rem;
}
.preset-btn {
    padding: .45rem .25rem;
    border-radius: .45rem;
    border: 1px solid var(--lp-border);
    background: rgba(255,255,255,.04);
    color: var(--lp-text-secondary);
    font-size: .75rem;
    font-weight: 700;
    cursor: pointer;
    transition: all .2s;
}
.preset-btn:hover { border-color: rgba(255,215,0,.3); color: var(--gold-500); }
.preset-btn--active {
    background: var(--gradient-gold) !important;
    color: #000 !important;
    border-color: transparent !important;
    transform: scale(1.04);
}

.earnings-row {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: .5rem;
    margin-bottom: 1.25rem;
}
.earning-cell { text-align: center; }
.earning-value { font-size: 1.1rem; font-weight: 900; color: #22c55e; }
.earning-label {
    font-size: .6rem;
    font-weight: 700;
    letter-spacing: .1em;
    text-transform: uppercase;
    color: var(--lp-text-muted);
    margin-top: .2rem;
}

.roi-section { margin-bottom: .75rem; }
.roi-header  { display: flex; justify-content: space-between; align-items: center; margin-bottom: .5rem; }
.roi-pct     { font-size: .875rem; font-weight: 900; color: #22c55e; }
.roi-track   { height: .45rem; border-radius: 999px; background: rgba(255,255,255,.08); overflow: hidden; }
.roi-fill    { height: 100%; border-radius: 999px; background: linear-gradient(90deg, #22c55e, #16a34a); transition: width .5s cubic-bezier(.4,0,.2,1); }

.calc-disclaimer { font-size: .65rem; color: var(--lp-text-muted); margin-bottom: 1rem; line-height: 1.5; }

.calc-cta {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: .5rem;
    width: 100%;
    padding: 1rem;
    background: var(--gradient-gold);
    color: #000;
    font-weight: 900;
    font-size: .9rem;
    border-radius: .75rem;
    text-decoration: none;
    box-shadow: 0 4px 20px rgba(255,215,0,.25);
    transition: transform .2s, filter .2s;
}
.calc-cta:hover { transform: scale(1.02); filter: brightness(1.08); }

/* ═══════════════════════════════════════════════════════
   MARKET TICKER
═══════════════════════════════════════════════════════ */
.ticker-bar {
    border-top: 1px solid var(--lp-border);
    border-bottom: 1px solid var(--lp-border);
    background: var(--lp-bg-navbar);
    height: 44px;
    overflow: hidden;
    display: flex;
    align-items: center;
}
.ticker-track { display: flex; animation: tickerScroll 30s linear infinite; white-space: nowrap; }
.ticker-set   { display: flex; gap: 2rem; padding: 0 1rem; align-items: center; }
.ticker-item  { display: flex; align-items: center; gap: .5rem; flex-shrink: 0; }
.ticker-img   { width: 1.1rem; height: 1.1rem; border-radius: 50%; }
.ticker-sym   { font-size: .8rem; font-weight: 700; }
.ticker-price { font-size: .8rem; font-family: monospace; color: var(--lp-text-secondary); }
.ticker-chg   { font-size: .7rem; font-weight: 700; }
.ticker-loading { text-align: center; width: 100%; font-size: .8rem; color: var(--lp-text-muted); }

/* ═══════════════════════════════════════════════════════
   SECTIONS
═══════════════════════════════════════════════════════ */
.section { padding: 6rem 0; position: relative; }
.section-alt { background-color: var(--lp-bg-secondary); }
.cta-section { border-top: 1px solid var(--lp-border); text-align: center; }

.section-head  { text-align: center; margin-bottom: 4rem; }
.section-title { font-size: clamp(1.75rem, 4vw, 3rem); font-weight: 900; letter-spacing: -.02em; margin-bottom: .75rem; }
.section-sub   { font-size: 1rem; color: var(--lp-text-secondary); margin-top: .75rem; }

/* ─── Features Bento ── */
.bento-grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: 1.25rem;
    max-width: 900px;
    margin: 0 auto;
}
@media (min-width: 768px) {
    .bento-grid { grid-template-columns: repeat(3, 1fr); }
}

.bento-card {
    background: var(--lp-bg-card);
    border: 1px solid var(--lp-border);
    border-radius: 1.5rem;
    padding: 2rem;
    transition: border-color .25s, transform .25s;
}
.bento-card:hover { transform: translateY(-3px); }
.bento-wide { grid-column: span 1; }
@media (min-width: 768px) { .bento-wide { grid-column: span 2; } }

.hover-gold:hover   { border-color: rgba(255,215,0,.4); }
.hover-silver:hover { border-color: rgba(192,192,192,.35); }

.bento-glow { position: relative; overflow: hidden; }
.bento-glow-layer {
    position: absolute;
    inset: 0;
    background: var(--gradient-gold);
    opacity: .05;
    pointer-events: none;
}

.feature-icon {
    width: 3.25rem; height: 3.25rem;
    border-radius: 1rem;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 1.25rem;
}
.gold-icon   { background: var(--gradient-gold-soft); color: var(--gold-500); }
.silver-icon { background: rgba(192,192,192,.1); color: #c0c0c0; }

.feat-title { font-size: 1.2rem; font-weight: 800; margin-bottom: .6rem; }
.feat-desc  { font-size: .875rem; color: var(--lp-text-secondary); line-height: 1.65; }

/* ─── Steps ── */
.steps-grid {
    display: grid;
    grid-template-columns: 1fr;
    gap: 2.5rem;
    margin-top: 3.5rem;
    position: relative;
}
@media (min-width: 768px) {
    .steps-grid { grid-template-columns: repeat(3, 1fr); }
}
.steps-connector {
    display: none;
}
@media (min-width: 768px) {
    .steps-connector {
        display: block;
        position: absolute;
        top: 3rem;
        left: 18%; right: 18%;
        height: 2px;
        border-top: 2px dashed var(--lp-border);
    }
}
.step { text-align: center; position: relative; z-index: 1; }
.step-num {
    width: 5.5rem; height: 5.5rem;
    margin: 0 auto 1.25rem;
    border-radius: 50%;
    border: 4px solid;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.75rem;
    font-weight: 900;
}
.step-gold   { border-color: var(--gold-500);  color: var(--gold-500);  background: rgba(255,215,0,.05);  }
.step-silver { border-color: #c0c0c0;          color: #a8a8a8;          background: rgba(192,192,192,.05); }
.step-gold2  { border-color: var(--gold-600);  color: var(--gold-600);  background: rgba(218,165,32,.05); }
.step-title  { font-size: 1.1rem; font-weight: 800; margin-bottom: .5rem; }
.step-desc   { font-size: .85rem; color: var(--lp-text-secondary); line-height: 1.65; }

.cta-btn-large {
    display: inline-block;
    margin-top: 2rem;
    padding: 1.1rem 3rem;
    background: var(--gradient-gold);
    color: #000;
    font-weight: 900;
    font-size: 1rem;
    border-radius: 999px;
    text-decoration: none;
    box-shadow: var(--shadow-gold);
    transition: transform .2s, filter .2s;
}
.cta-btn-large:hover { transform: scale(1.05); filter: brightness(1.08); }

/* ═══════════════════════════════════════════════════════
   FOOTER
═══════════════════════════════════════════════════════ */
.footer {
    border-top: 1px solid var(--lp-border);
    background: var(--lp-bg-navbar);
    padding: 3rem 0;
}
.footer-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 2rem;
}
@media (min-width: 768px) { .footer-grid { grid-template-columns: repeat(4, 1fr); } }
.footer-logo    { font-size: 1.1rem; font-weight: 900; margin-bottom: .75rem; color: var(--lp-text-primary); }
.footer-tagline { font-size: .8rem; color: var(--lp-text-muted); margin-bottom: .5rem; line-height: 1.6; }
.footer-copy    { font-size: .75rem; color: var(--lp-text-muted); }
.footer-head    { font-size: .65rem; font-weight: 700; letter-spacing: .12em; text-transform: uppercase; color: var(--lp-text-primary); margin-bottom: .85rem; }
.footer-list    { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: .5rem; }
.footer-list a  { font-size: .8rem; color: var(--lp-text-muted); text-decoration: none; transition: color .2s; }
.footer-list a:hover { color: var(--gold-500); }

/* ═══════════════════════════════════════════════════════
   TRANSACTION POPUPS
═══════════════════════════════════════════════════════ */
.popup-area {
    position: fixed;
    bottom: 1.5rem;
    left: 1.5rem;
    z-index: 9999;
    display: flex;
    flex-direction: column;
    gap: .6rem;
    pointer-events: none;
}
.popup-card {
    display: flex;
    align-items: flex-start;
    gap: .75rem;
    padding: .85rem 1rem;
    border-radius: .85rem;
    border: 1px solid;
    backdrop-filter: blur(16px);
    max-width: 17rem;
    background: var(--popup-bg);
    border-color: var(--popup-border);
    box-shadow: 0 8px 30px rgba(0,0,0,.4);
}
.popup-icon {
    flex-shrink: 0;
    width: 2.25rem; height: 2.25rem;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}
.popup-icon--green { background: rgba(34,197,94,.15); }
.popup-icon--gold  { background: rgba(255,215,0,.12);  }
.popup-badge-type  { font-size: .6rem; font-weight: 900; letter-spacing: .05em; }
.text-green-win { color: #22c55e; }
.text-gold-win  { color: var(--gold-500); }
.popup-body  { flex: 1; }
.popup-user  { font-size: .7rem; font-weight: 700; color: var(--lp-text-primary); margin-bottom: .15rem; }
.popup-from  { font-weight: 400; color: var(--lp-text-secondary); }
.popup-msg   { font-size: .7rem; color: var(--lp-text-secondary); line-height: 1.4; }

/* ═══════════════════════════════════════════════════════
   ANIMATIONS
═══════════════════════════════════════════════════════ */
@keyframes tickerScroll {
    from { transform: translateX(0); }
    to   { transform: translateX(-33.333%); }
}
@keyframes pulse {
    0%, 100% { opacity: 1; }
    50%       { opacity: .4; }
}

/* Popup transitions */
.popup-enter-active, .popup-leave-active { transition: all .4s cubic-bezier(.16,1,.3,1); }
.popup-enter-from  { opacity: 0; transform: translateX(-40px) scale(.95); }
.popup-leave-to    { opacity: 0; transform: translateX(-40px) scale(.9); }

/* Mobile menu fade */
.fade-enter-active, .fade-leave-active { transition: opacity .3s; }
.fade-enter-from, .fade-leave-to       { opacity: 0; }
</style>
