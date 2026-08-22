<script setup>
import { RouterLink } from 'vue-router';
import { computed, onMounted, onUnmounted, ref } from 'vue';
import { useMarketStore } from '../stores/market';
import logoUrl from '../assets/mcfoption-logo.svg';
import markUrl from '../assets/mcfoption-mark.svg';

const marketStore = useMarketStore();
const isMobileMenuOpen = ref(false);

// Profit calculator — ported from main branch.
const depositAmount = ref(500);
const selectedPreset = ref(500);
const presets = [100, 500, 1000, 5000];

const setPreset = (amount) => {
    selectedPreset.value = amount;
    depositAmount.value = amount;
};

const dailyProfit = computed(() => {
    const amount = Number(depositAmount.value) || 0;
    const stake = amount * 0.1;
    return (3 * 0.70 * stake * 0.85) - (3 * 0.30 * stake);
});
const weeklyProfit = computed(() => dailyProfit.value * 7);
const monthlyProfit = computed(() => dailyProfit.value * 30);
const monthlyROI = computed(() => {
    const amount = Number(depositAmount.value) || 0;
    return amount > 0 ? (monthlyProfit.value / amount) * 100 : 0;
});

const formatProfit = (value) => {
    const val = Number(value) || 0;
    return val >= 1000 ? `$${(val / 1000).toFixed(2)}K` : `$${val.toFixed(2)}`;
};

// Transaction notification popups — ported from main branch.
const popups = ref([]);
let popupId = 0;
let popupInterval = null;
let popupStartTimer = null;

const cities = [
    'San Antonio', 'Los Angeles', 'New York', 'Chicago', 'Miami', 'Houston',
    'Phoenix', 'Philadelphia', 'San Diego', 'Dallas', 'Austin', 'Seattle',
    'Denver', 'Las Vegas', 'Portland', 'Nashville', 'Atlanta', 'Boston',
    'Detroit', 'Minneapolis'
];
const coinSymbols = ['BTC', 'ETH', 'SOL', 'BNB', 'XRP', 'ADA', 'DOGE', 'AVAX'];

const createPopup = () => {
    if (popups.value.length >= 2) popups.value.shift();

    const coin = coinSymbols[Math.floor(Math.random() * coinSymbols.length)];
    const hash = Math.random().toString(36).substring(2, 6).toUpperCase();
    const city = cities[Math.floor(Math.random() * cities.length)];
    const isWin = Math.random() > 0.35;
    const amount = isWin
        ? `+$${(Math.random() * 2000 + 50).toFixed(0)}`
        : `$${(Math.random() * 1.5 + 0.3).toFixed(1)}K`;

    const popup = {
        id: popupId++,
        type: isWin ? 'WIN' : 'WITHDRAW',
        user: `trader***${hash}`,
        city,
        amount,
        coin,
        action: isWin ? 'just earned' : 'withdrew'
    };

    popups.value.push(popup);
    setTimeout(() => {
        popups.value = popups.value.filter((item) => item.id !== popup.id);
    }, 4500);
};

onMounted(() => {
    marketStore.fetchMarketOverview();

    popupStartTimer = setTimeout(() => {
        createPopup();
        popupInterval = setInterval(() => {
            if (Math.random() > 0.3) createPopup();
        }, 7000);
    }, 2000);
});

onUnmounted(() => {
    if (popupStartTimer) clearTimeout(popupStartTimer);
    if (popupInterval) clearInterval(popupInterval);
});

const topCoins = computed(() => marketStore.marketOverview || []);
const marketRows = computed(() => topCoins.value.slice(0, 6));

const formatPrice = (value) => {
    if (value === null || value === undefined) return '—';
    const digits = value < 1 ? 4 : value < 100 ? 2 : 0;
    return Number(value).toLocaleString('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: digits,
        maximumFractionDigits: digits
    });
};

const closeMenu = () => {
    isMobileMenuOpen.value = false;
};
</script>

<template>
    <div class="landing-page">
        <header class="site-header">
            <div class="header-inner container">
                <RouterLink to="/" class="brand-link" aria-label="MCFOPTION home">
                    <img :src="logoUrl" alt="MCFOPTION" />
                </RouterLink>

                <nav class="desktop-nav" aria-label="Primary navigation">
                    <a href="#markets">Markets</a>
                    <RouterLink to="/dashboard">Live Trade</RouterLink>
                    <a href="#how-it-works">How It Works</a>
                    <a href="#features">Features</a>
                    <a href="#security">Security</a>
                </nav>

                <div class="desktop-actions">
                    <RouterLink to="/login" class="btn btn-ghost">Log In</RouterLink>
                    <RouterLink to="/register" class="btn btn-gold">Start Trading</RouterLink>
                </div>

                <button
                    class="menu-button"
                    type="button"
                    @click="isMobileMenuOpen = !isMobileMenuOpen"
                    :aria-expanded="isMobileMenuOpen"
                    aria-label="Toggle navigation"
                >
                    <span></span><span></span><span></span>
                </button>
            </div>

            <Transition name="menu-fade">
                <div v-if="isMobileMenuOpen" class="mobile-menu">
                    <div class="container mobile-menu-inner">
                        <a href="#markets" @click="closeMenu">Markets</a>
                        <RouterLink to="/dashboard" @click="closeMenu">Live Trade</RouterLink>
                        <a href="#how-it-works" @click="closeMenu">How It Works</a>
                        <a href="#features" @click="closeMenu">Features</a>
                        <a href="#security" @click="closeMenu">Security</a>
                        <div class="mobile-actions">
                            <RouterLink to="/login" class="btn btn-ghost" @click="closeMenu">Log In</RouterLink>
                            <RouterLink to="/register" class="btn btn-gold" @click="closeMenu">Start Trading</RouterLink>
                        </div>
                    </div>
                </div>
            </Transition>
        </header>

        <main>
            <section class="hero-section">
                <div class="hero-grid-overlay"></div>
                <div class="hero-glow hero-glow-a"></div>
                <div class="hero-glow hero-glow-b"></div>

                <div class="container hero-grid">
                    <div class="hero-copy">
                        <div class="live-pill">
                            <span class="live-dot"></span>
                            LIVE MARKET ACCESS
                        </div>

                        <img :src="markUrl" alt="MCFOPTION" class="hero-mark" />
                        <p class="hero-kicker">TRADE • FLIP • GROW</p>
                        <h1>Trade smarter.<br /><span>Move with the market.</span></h1>
                        <p class="hero-lead">
                            A focused trading experience for live crypto markets, timed opportunities, wallet management, and real-time account support.
                        </p>

                        <div class="hero-actions">
                            <RouterLink to="/register" class="btn btn-gold btn-large">Start Trading <span>→</span></RouterLink>
                            <RouterLink to="/dashboard" class="btn btn-ghost btn-large">Explore Markets</RouterLink>
                        </div>

                        <div class="trust-strip">
                            <div><strong>24/7</strong><span>Market Access</span></div>
                            <i></i>
                            <div><strong>10+</strong><span>Digital Assets</span></div>
                            <i></i>
                            <div><strong>Real-time</strong><span>Trading Data</span></div>
                        </div>
                    </div>

                    <!-- Replaces the old Live Market terminal card from the screenshot. -->
                    <div class="calculator-wrap">
                        <div class="calc-card">
                            <div class="calc-header">
                                <div>
                                    <p class="calc-brand">MCFOPTION</p>
                                    <h2>Profit Calculator</h2>
                                </div>
                                <span class="payout-badge"><i></i>85% Payout</span>
                            </div>

                            <label class="field-label" for="deposit-input">DEPOSIT AMOUNT (USDT)</label>
                            <div class="calc-input-wrap">
                                <span>$</span>
                                <input
                                    id="deposit-input"
                                    v-model="depositAmount"
                                    type="number"
                                    min="10"
                                    @input="selectedPreset = null"
                                />
                            </div>

                            <div class="calc-presets">
                                <button
                                    v-for="preset in presets"
                                    :key="preset"
                                    type="button"
                                    :class="{ active: selectedPreset === preset }"
                                    @click="setPreset(preset)"
                                >
                                    {{ preset >= 1000 ? '$' + preset / 1000 + 'K' : '$' + preset }}
                                </button>
                            </div>

                            <div class="earnings-row">
                                <div><strong>{{ formatProfit(dailyProfit) }}</strong><span>DAILY</span></div>
                                <div><strong>{{ formatProfit(weeklyProfit) }}</strong><span>WEEKLY</span></div>
                                <div><strong>{{ formatProfit(monthlyProfit) }}</strong><span>MONTHLY</span></div>
                            </div>

                            <div class="roi-section">
                                <div class="roi-header">
                                    <span>EST. MONTHLY ROI</span>
                                    <strong>+{{ monthlyROI.toFixed(1) }}%</strong>
                                </div>
                                <div class="roi-track">
                                    <div class="roi-fill" :style="{ width: Math.min(100, monthlyROI / 10) + '%' }"></div>
                                </div>
                            </div>

                            <p class="calc-disclaimer">
                                * Estimation based on 85% payout rate & 70% win rate. Results may vary.
                            </p>

                            <RouterLink to="/register" class="calc-cta">Start Trading Now <span>→</span></RouterLink>
                        </div>
                    </div>
                </div>
            </section>

            <section id="markets" class="market-section section-pad">
                <div class="container">
                    <div class="section-heading heading-row">
                        <div>
                            <p class="section-kicker">LIVE MARKETS</p>
                            <h2>Follow the market in real time.</h2>
                        </div>
                        <RouterLink to="/dashboard" class="text-link">Open trading terminal →</RouterLink>
                    </div>

                    <div class="market-table">
                        <div class="market-head">
                            <span>Asset</span><span>Price</span><span>24H Change</span><span>Market</span>
                        </div>
                        <div v-for="coin in marketRows" :key="coin.id" class="market-row">
                            <div class="asset-cell">
                                <img :src="coin.image" :alt="coin.name" />
                                <div><strong>{{ coin.symbol.toUpperCase() }}</strong><small>{{ coin.name }}</small></div>
                            </div>
                            <strong class="price-cell">{{ formatPrice(coin.current_price) }}</strong>
                            <span :class="['change-pill', coin.price_change_percentage_24h >= 0 ? 'positive' : 'negative']">
                                {{ coin.price_change_percentage_24h >= 0 ? '+' : '' }}{{ coin.price_change_percentage_24h?.toFixed(2) }}%
                            </span>
                            <RouterLink to="/dashboard" class="mini-trade">Trade</RouterLink>
                        </div>
                        <div v-if="!marketRows.length" class="market-loading">Loading live markets…</div>
                    </div>
                </div>
            </section>

            <section id="how-it-works" class="pillars-section section-pad">
                <div class="container">
                    <div class="section-heading centered">
                        <p class="section-kicker">THE MCFOPTION WAY</p>
                        <h2>Trade. Flip. Grow.</h2>
                        <p>Three ideas, one focused trading experience.</p>
                    </div>

                    <div class="pillar-grid">
                        <article class="pillar-card">
                            <div class="pillar-icon trade-icon"><span></span><span></span><span></span><span></span></div>
                            <p>01</p><h3>TRADE</h3><span>Smart market tools for faster, more informed decisions.</span>
                        </article>
                        <article class="pillar-card featured">
                            <div class="pillar-icon flip-icon">↻</div>
                            <p>02</p><h3>FLIP</h3><span>Act on timed market opportunities from a clean trading workflow.</span>
                        </article>
                        <article class="pillar-card">
                            <div class="pillar-icon grow-icon">↗</div>
                            <p>03</p><h3>GROW</h3><span>Track your account and build your strategy with confidence.</span>
                        </article>
                    </div>
                </div>
            </section>

            <section id="features" class="features-section section-pad">
                <div class="container feature-layout">
                    <div class="feature-copy">
                        <p class="section-kicker">ONE WORKSPACE</p>
                        <h2>Everything important stays within reach.</h2>
                        <p>MCFOPTION brings live trading, wallet operations, account verification, and support into one coherent interface across desktop and mobile.</p>
                        <RouterLink to="/register" class="btn btn-gold">Create Account</RouterLink>
                    </div>
                    <div class="feature-grid">
                        <article><span>01</span><h3>Real-time Market</h3><p>Live market pricing and movement for supported digital assets.</p></article>
                        <article><span>02</span><h3>Timed Trading</h3><p>Structured CALL and PUT trading durations from the main terminal.</p></article>
                        <article><span>03</span><h3>Wallet Control</h3><p>Manage deposits, withdrawals, balances, and transaction status.</p></article>
                        <article><span>04</span><h3>Live Support</h3><p>Real-time customer support built directly into the platform.</p></article>
                    </div>
                </div>
            </section>

            <section id="security" class="security-section section-pad">
                <div class="container security-card">
                    <div class="security-emblem">◇</div>
                    <div class="security-copy">
                        <p class="section-kicker">SECURE • TRUSTED • RELIABLE</p>
                        <h2>Built around controlled account access.</h2>
                        <p>Role-based access, account sessions, identity verification workflows, and managed transaction approvals support the MCFOPTION trading experience.</p>
                    </div>
                    <div class="security-points"><span>Account Sessions</span><span>KYC Workflow</span><span>Transaction Approval</span></div>
                </div>
            </section>

            <section class="support-section">
                <div class="container support-inner">
                    <div><p class="section-kicker">REAL-TIME SUPPORT</p><h2>Here when you need us.</h2></div>
                    <p>Get account and transaction assistance through MCFOPTION support.</p>
                    <RouterLink to="/login" class="btn btn-ghost">Access Your Account</RouterLink>
                </div>
            </section>

            <section class="final-cta section-pad">
                <div class="container final-card">
                    <img :src="markUrl" alt="MCFOPTION" />
                    <p class="section-kicker">TRADE • FLIP • GROW</p>
                    <h2>Your next market move starts here.</h2>
                    <p>Enter the MCFOPTION trading workspace and follow the market from any device.</p>
                    <div class="hero-actions final-actions">
                        <RouterLink to="/register" class="btn btn-gold btn-large">Start Trading <span>→</span></RouterLink>
                        <RouterLink to="/login" class="btn btn-ghost btn-large">Log In</RouterLink>
                    </div>
                </div>
            </section>
        </main>

        <footer class="site-footer">
            <div class="container footer-grid">
                <div class="footer-brand"><img :src="logoUrl" alt="MCFOPTION" /><p>Trade • Flip • Grow</p></div>
                <div class="footer-links">
                    <a href="#markets">Markets</a><a href="#features">Features</a><a href="#security">Security</a><RouterLink to="/login">Log In</RouterLink>
                </div>
                <p class="copyright">© {{ new Date().getFullYear() }} MCFOPTION. All rights reserved.</p>
            </div>
        </footer>

        <div class="popup-area" aria-live="polite">
            <TransitionGroup name="popup">
                <div v-for="popup in popups" :key="popup.id" class="popup-card">
                    <div class="popup-icon" :class="popup.type === 'WIN' ? 'win' : 'withdraw'">{{ popup.type }}</div>
                    <div class="popup-body">
                        <p><strong>{{ popup.user }}</strong> <span>from {{ popup.city }}, USA</span></p>
                        <p>{{ popup.action }} <b :class="popup.type === 'WIN' ? 'green' : 'gold'">{{ popup.amount }}</b> on {{ popup.coin }} trade</p>
                    </div>
                </div>
            </TransitionGroup>
        </div>
    </div>
</template>

<style scoped>
:global(html) { scroll-behavior: smooth; }
:global(body) { margin: 0; background: #07080b; }
:global(*) { box-sizing: border-box; }

.landing-page {
    height: 100%; width: 100%; max-width: 100%; overflow-x: hidden; overflow-y: auto;
    background-color: #07080b;
    background-image: linear-gradient(180deg, rgba(7,8,11,.82), rgba(7,8,11,.9)), url('/crypto-bg.png');
    background-size: cover; background-position: center; background-repeat: no-repeat; background-attachment: fixed;
    color: #f4f4f2; font-family: Inter, system-ui, sans-serif;
}
.container { width: min(1180px, calc(100% - 40px)); max-width: 100%; margin: 0 auto; box-sizing: border-box; }

.site-header { position: fixed; inset: 0 0 auto; z-index: 50; background: rgba(7,8,11,.78); backdrop-filter: blur(18px); border-bottom: 1px solid rgba(255,255,255,.07); }
.header-inner { height: 78px; display: flex; align-items: center; gap: 28px; }
.brand-link { display: flex; align-items: center; flex: 0 0 auto; }
.brand-link img { width: 230px; height: auto; display: block; }
.desktop-nav { margin-left: auto; display: flex; align-items: center; gap: 27px; }
.desktop-nav a { color: #8f9299; text-decoration: none; font-size: 13px; font-weight: 650; white-space: nowrap; }
.desktop-nav a:hover { color: #f0c654; }
.desktop-actions { display: flex; gap: 9px; }
.btn { min-height: 42px; padding: 0 18px; border-radius: 10px; display: inline-flex; align-items: center; justify-content: center; gap: 10px; text-decoration: none; font-size: 13px; font-weight: 800; border: 1px solid transparent; transition: .2s ease; }
.btn:hover { transform: translateY(-1px); }
.btn-gold { color: #15120a; background: linear-gradient(135deg,#f5ce5e,#b77816); box-shadow: 0 10px 28px rgba(183,120,22,.14); }
.btn-ghost { color: #d4d5d7; border-color: #303238; background: rgba(255,255,255,.025); }
.btn-large { min-height: 54px; padding: 0 24px; font-size: 14px; }
.menu-button { display: none; margin-left: auto; width: 44px; height: 44px; border: 1px solid #2b2d31; background: #111216; border-radius: 10px; padding: 11px; }
.menu-button span { display: block; height: 2px; background: #d9d9d6; margin: 4px 0; border-radius: 2px; }
.mobile-menu { display: none; }
.menu-fade-enter-active,.menu-fade-leave-active { transition: opacity .2s ease; }
.menu-fade-enter-from,.menu-fade-leave-to { opacity: 0; }

.hero-section { position: relative; min-height: 810px; padding: 150px 0 88px; display: flex; align-items: center; }
.hero-grid-overlay { position: absolute; inset: 0; opacity: .36; background-image: linear-gradient(rgba(255,255,255,.028) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.028) 1px,transparent 1px); background-size: 52px 52px; mask-image: linear-gradient(to bottom,#000 0,rgba(0,0,0,.8) 60%,transparent 100%); }
.hero-glow { position: absolute; border-radius: 999px; filter: blur(120px); pointer-events: none; }
.hero-glow-a { width: 520px; height: 520px; background: rgba(203,149,27,.12); left: -190px; top: 40px; }
.hero-glow-b { width: 470px; height: 470px; background: rgba(181,139,40,.10); right: -180px; top: 180px; }
.hero-grid { position: relative; z-index: 2; display: grid; grid-template-columns: .95fr 1.05fr; gap: 74px; align-items: center; }
.hero-copy { max-width: 570px; }
.live-pill { display: inline-flex; align-items: center; gap: 8px; padding: 8px 11px; border: 1px solid rgba(206,162,53,.24); border-radius: 999px; color: #aa8a3d; background: rgba(202,151,31,.055); font-size: 10px; font-weight: 850; letter-spacing: .13em; }
.live-dot { width: 6px; height: 6px; background: #47c982; border-radius: 50%; box-shadow: 0 0 0 5px rgba(71,201,130,.09); }
.hero-mark { width: 300px; max-width: 72%; margin: 29px 0 0 -14px; }
.hero-kicker,.section-kicker { margin: 5px 0 14px; color: #c99e36; font-size: 11px; letter-spacing: .22em; font-weight: 850; }
.hero-copy h1 { font-family: Manrope,Inter,sans-serif; font-size: clamp(48px,5vw,74px); line-height: .99; letter-spacing: -.055em; margin: 0; color: #f7f6f3; }
.hero-copy h1 span { color: #a8a9ad; }
.hero-lead { max-width: 545px; margin: 25px 0 0; color: #8d9098; font-size: 16px; line-height: 1.75; }
.hero-actions { margin-top: 32px; display: flex; flex-wrap: wrap; gap: 11px; }
.trust-strip { margin-top: 44px; display: flex; align-items: center; gap: 22px; }
.trust-strip > div { display: grid; gap: 4px; }
.trust-strip strong { color: #e8e8e5; font-size: 18px; }
.trust-strip span { color: #5f6269; font-size: 10px; letter-spacing: .05em; text-transform: uppercase; }
.trust-strip i { width: 1px; height: 34px; background: #292b30; }

.calculator-wrap { position: relative; }
.calculator-wrap::before { content: ''; position: absolute; inset: 10% -8% -7% 15%; background: radial-gradient(circle,rgba(212,164,42,.16),transparent 62%); filter: blur(35px); }
.calc-card { position: relative; background: linear-gradient(155deg,rgba(20,21,25,.98),rgba(10,11,14,.99)); border: 1px solid rgba(228,185,70,.24); border-radius: 24px; padding: 28px; box-shadow: 0 40px 110px rgba(0,0,0,.52), inset 0 1px 0 rgba(255,255,255,.04); }
.calc-header { display: flex; justify-content: space-between; gap: 18px; align-items: flex-start; padding-bottom: 20px; border-bottom: 1px solid #22242a; }
.calc-brand { margin: 0 0 6px; color: #c99e36; font-size: 10px; font-weight: 900; letter-spacing: .18em; }
.calc-header h2 { margin: 0; font-size: 24px; }
.payout-badge { display: inline-flex; align-items: center; gap: 7px; color: #52d592; border: 1px solid rgba(82,213,146,.22); background: rgba(82,213,146,.08); border-radius: 999px; padding: 8px 11px; font-size: 11px; font-weight: 800; }
.payout-badge i { width: 7px; height: 7px; border-radius: 50%; background: #47c982; }
.field-label { display: block; margin: 22px 0 8px; color: #777b83; font-size: 10px; font-weight: 800; letter-spacing: .14em; }
.calc-input-wrap { display: flex; align-items: center; gap: 8px; border: 1px solid #2a2c31; background: #14161b; border-radius: 11px; padding: 0 14px; height: 54px; }
.calc-input-wrap > span { color: #888b91; font-weight: 800; }
.calc-input-wrap input { width: 100%; border: 0; outline: 0; background: transparent; color: #f5f4f0; font: inherit; font-size: 18px; font-weight: 800; }
.calc-presets { display: grid; grid-template-columns: repeat(4,1fr); gap: 9px; margin-top: 10px; }
.calc-presets button { height: 40px; border: 1px solid #2a2c31; background: #111318; color: #8d9098; border-radius: 9px; font-weight: 800; cursor: pointer; }
.calc-presets button.active { color: #161208; border-color: transparent; background: linear-gradient(135deg,#f5ce5e,#b77816); }
.earnings-row { display: grid; grid-template-columns: repeat(3,1fr); gap: 8px; margin-top: 24px; }
.earnings-row > div { text-align: center; padding: 14px 8px; border: 1px solid #22242a; border-radius: 11px; background: rgba(255,255,255,.018); }
.earnings-row strong { display: block; color: #4fd18a; font-size: 17px; }
.earnings-row span { display: block; margin-top: 5px; color: #666970; font-size: 9px; letter-spacing: .12em; }
.roi-section { margin-top: 22px; }
.roi-header { display: flex; justify-content: space-between; gap: 10px; color: #74777e; font-size: 10px; font-weight: 800; letter-spacing: .12em; }
.roi-header strong { color: #4fd18a; font-size: 13px; letter-spacing: 0; }
.roi-track { height: 7px; background: #202227; border-radius: 999px; overflow: hidden; margin-top: 9px; }
.roi-fill { height: 100%; border-radius: inherit; background: linear-gradient(90deg,#4fd18a,#258e59); transition: width .4s ease; }
.calc-disclaimer { color: #5f6269; font-size: 10px; line-height: 1.5; margin: 16px 0; }
.calc-cta { min-height: 52px; display: flex; align-items: center; justify-content: center; gap: 9px; color: #161208; text-decoration: none; font-size: 13px; font-weight: 900; border-radius: 11px; background: linear-gradient(135deg,#f5ce5e,#b77816); }

.section-pad { padding: 105px 0; }
.market-section { background: #0a0b0e; border-top: 1px solid #17191d; border-bottom: 1px solid #17191d; }
.section-heading { margin-bottom: 38px; }
.section-heading h2,.feature-copy h2,.security-copy h2,.support-inner h2,.final-card h2 { margin: 0; font-family: Manrope,Inter,sans-serif; font-size: 42px; letter-spacing: -.035em; }
.section-heading > p,.section-heading div > p:last-child { color: #73767e; }
.heading-row { display: flex; align-items: end; justify-content: space-between; gap: 24px; }
.centered { text-align: center; }
.text-link { color: #caa13d; text-decoration: none; font-size: 13px; font-weight: 800; }
.market-table { border: 1px solid #24262b; border-radius: 18px; overflow: hidden; background: rgba(12,13,16,.9); }
.market-head,.market-row { display: grid; grid-template-columns: 1.6fr 1fr 1fr .65fr; align-items: center; gap: 18px; padding: 0 22px; }
.market-head { height: 46px; color: #5f6269; font-size: 10px; letter-spacing: .12em; text-transform: uppercase; border-bottom: 1px solid #24262b; }
.market-row { min-height: 78px; border-bottom: 1px solid #202227; }
.market-row:last-child { border-bottom: 0; }
.asset-cell { display: flex; align-items: center; gap: 12px; }
.asset-cell img { width: 34px; height: 34px; border-radius: 50%; }
.asset-cell div { display: grid; gap: 4px; }.asset-cell small { color: #666970; }.price-cell { font-size: 14px; }.change-pill { font-size: 12px; font-weight: 850; }.positive { color: #45c982 !important; }.negative { color: #ed6671 !important; }
.mini-trade { justify-self: end; color: #c69b35; text-decoration: none; border: 1px solid #3a3020; border-radius: 8px; padding: 8px 12px; font-size: 11px; font-weight: 800; }
.market-loading { padding: 26px; text-align: center; color: #777b83; }

.pillars-section { background: #08090c; }
.pillar-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 18px; margin-top: 42px; }
.pillar-card { min-height: 300px; border: 1px solid #25272c; border-radius: 18px; background: #0f1014; padding: 34px; }
.pillar-card.featured { border-color: rgba(213,171,61,.3); background: linear-gradient(160deg,rgba(211,164,45,.07),#0f1014 48%); }
.pillar-card > p { color: #66552a; font-size: 10px; font-weight: 900; }.pillar-card h3 { font-size: 24px; margin: 14px 0 10px; }.pillar-card > span { color: #777b83; line-height: 1.65; }
.pillar-icon { width: 52px; height: 52px; border: 1px solid #35312a; border-radius: 13px; display: grid; place-items: center; color: #d5a937; font-size: 26px; }
.trade-icon { display: flex; align-items: end; justify-content: center; gap: 3px; padding: 12px; }.trade-icon span { width: 5px; background: #cda23a; }.trade-icon span:nth-child(1){height:15px}.trade-icon span:nth-child(2){height:27px}.trade-icon span:nth-child(3){height:20px}.trade-icon span:nth-child(4){height:32px}

.features-section { background: #0b0c0f; }.feature-layout { display: grid; grid-template-columns: .8fr 1.2fr; gap: 70px; align-items: center; }.feature-copy > p:not(.section-kicker) { color: #777b83; line-height: 1.75; margin: 22px 0 27px; }.feature-grid { display: grid; grid-template-columns: 1fr 1fr; border: 1px solid #25272c; border-radius: 19px; overflow: hidden; }.feature-grid article { padding: 29px; min-height: 220px; background: #101115; border-right: 1px solid #25272c; border-bottom: 1px solid #25272c; }.feature-grid article:nth-child(2n){border-right:0}.feature-grid article:nth-last-child(-n+2){border-bottom:0}.feature-grid article > span { color: #796129; font-size: 10px; font-weight: 900; }.feature-grid h3 { margin: 48px 0 10px; font-size: 17px; }.feature-grid p { color: #6f7279; line-height: 1.6; font-size: 13px; }
.security-section { background: #08090c; }.security-card { display: grid; grid-template-columns: 90px 1fr; gap: 27px 35px; border: 1px solid rgba(206,165,57,.2); border-radius: 22px; padding: 43px; background: radial-gradient(circle at 10% 10%,rgba(205,158,38,.08),transparent 32%),#0e0f12; }.security-emblem { width: 82px; height: 82px; border-radius: 50%; border: 1px solid #4a3a18; display: grid; place-items: center; color: #ddb54a; font-size: 37px; }.security-copy p:last-child { color: #777b83; line-height: 1.7; max-width: 690px; }.security-points { grid-column: 2; display: grid; grid-template-columns: repeat(3,1fr); gap: 9px; }.security-points span { border-top: 1px solid #27292e; padding-top: 14px; color: #979aa1; font-size: 11px; }
.support-section { border-top: 1px solid #1b1d21; border-bottom: 1px solid #1b1d21; background: #0b0c0f; }.support-inner { min-height: 200px; display: grid; grid-template-columns: 1fr 1fr auto; gap: 30px; align-items: center; }.support-inner > p { color: #777b83; line-height: 1.65; }.final-cta { background: #07080b; }.final-card { min-height: 460px; border: 1px solid rgba(218,176,65,.2); border-radius: 24px; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; padding: 48px; background: radial-gradient(circle at 50% 0,rgba(202,155,42,.13),transparent 40%),#0d0e11; }.final-card img { width: 160px; margin-bottom: 4px; }.final-card > p:not(.section-kicker) { color: #74777e; }.final-actions { justify-content: center; }
.site-footer { background: #08090b; border-top: 1px solid #1c1e22; padding: 35px 0; }.footer-grid { display: grid; grid-template-columns: auto 1fr auto; gap: 35px; align-items: center; }.footer-brand img { width: 180px; }.footer-brand p,.copyright { color: #5f6269; font-size: 10px; }.footer-links { display: flex; justify-content: center; gap: 28px; }.footer-links a { color: #757880; text-decoration: none; font-size: 11px; }

.popup-area { position: fixed; left: 18px; bottom: 18px; z-index: 9999; display: flex; flex-direction: column; gap: 9px; pointer-events: none; }
.popup-card { display: flex; align-items: flex-start; gap: 11px; width: min(310px, calc(100vw - 36px)); padding: 12px 14px; border-radius: 13px; border: 1px solid #2b2d32; background: rgba(14,15,19,.93); backdrop-filter: blur(16px); box-shadow: 0 12px 36px rgba(0,0,0,.42); }
.popup-icon { flex: 0 0 auto; width: 44px; height: 44px; border-radius: 50%; display: grid; place-items: center; font-size: 8px; font-weight: 900; letter-spacing: .04em; }
.popup-icon.win { background: rgba(69,201,130,.12); color: #45c982; }.popup-icon.withdraw { background: rgba(213,169,55,.12); color: #d5a937; }
.popup-body p { margin: 0; color: #8d9098; font-size: 11px; line-height: 1.45; }.popup-body p + p { margin-top: 3px; }.popup-body strong { color: #eee; }.popup-body span { color: #666970; }.popup-body .green { color: #45c982; }.popup-body .gold { color: #d5a937; }
.popup-enter-active,.popup-leave-active { transition: all .4s cubic-bezier(.16,1,.3,1); }.popup-enter-from { opacity: 0; transform: translateX(-36px) scale(.96); }.popup-leave-to { opacity: 0; transform: translateX(-36px) scale(.92); }

@media (max-width: 980px) {
    .desktop-nav { display: none; }.desktop-actions { display: none; }.menu-button { display: block; }.mobile-menu { display: block; border-top: 1px solid #1e2024; background: rgba(8,9,12,.98); }.mobile-menu-inner { padding: 16px 0 20px; display: grid; gap: 15px; }.mobile-menu a { color: #b8babf; text-decoration: none; font-weight: 750; }.mobile-actions { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-top: 7px; }
    .hero-grid { grid-template-columns: 1fr; gap: 48px; }.hero-copy { max-width: 700px; }.calculator-wrap { max-width: 700px; width: 100%; }
    .feature-layout { grid-template-columns: 1fr; }.support-inner { grid-template-columns: 1fr 1fr; }.support-inner .btn { justify-self: end; }.footer-grid { grid-template-columns: 1fr; text-align: center; }.footer-links { flex-wrap: wrap; }.footer-brand img { margin: 0 auto; }
}

@media (max-width: 620px) {
    .container { width: calc(100% - 28px); }.section-pad { padding: 78px 0; }
    .hero-section { min-height: 0; padding: 114px 0 70px; }.hero-mark { width: 220px; max-width: 100%; margin-left: 0; }.hero-copy h1 { font-size: clamp(36px,11vw,58px); }.hero-lead { font-size: 14px; }.hero-actions { display: grid; grid-template-columns: 1fr; }.btn-large { width: 100%; }
    .trust-strip { gap: 13px; justify-content: space-between; flex-wrap: wrap; }.trust-strip i { height: 29px; }.trust-strip strong { font-size: 15px; }.trust-strip span { font-size: 8px; }
    .calc-card { padding: 18px; border-radius: 18px; }.calc-header { align-items: center; }.calc-header h2 { font-size: 21px; }.payout-badge { font-size: 9px; padding: 7px 9px; }.calc-presets { grid-template-columns: repeat(2,1fr); }.earnings-row { grid-template-columns: 1fr; }
    .heading-row { align-items: start; flex-direction: column; }.section-heading h2,.feature-copy h2,.final-card h2 { font-size: 34px; }
    .market-head { display: none; }.market-row { grid-template-columns: 1.5fr 1fr; min-height: 86px; padding: 12px 16px; gap: 8px 12px; }.asset-cell { grid-row: 1 / 3; }.price-cell { text-align: right; }.change-pill { justify-self: end; }.mini-trade { display: none; }
    .pillar-grid { grid-template-columns: 1fr; }.pillar-card { padding: 28px; }.feature-grid { grid-template-columns: 1fr; }.feature-grid article { min-height: 190px; border-right: 0 !important; border-bottom: 1px solid #24262b; }.feature-grid article:last-child { border-bottom: 0; }
    .security-card { grid-template-columns: 1fr; padding: 27px; }.security-emblem { width: 65px; height: 65px; }.security-points { grid-column: 1; grid-template-columns: 1fr; }.security-copy h2 { font-size: 29px; }
    .support-inner { grid-template-columns: 1fr; gap: 18px; padding: 35px 0; }.support-inner .btn { justify-self: start; }
    .final-card { min-height: 430px; padding: 32px 20px; }.final-actions { width: 100%; max-width: 100%; }
    .popup-area { left: 12px; bottom: 12px; }.popup-card { width: min(300px, calc(100vw - 24px)); }
}
</style>
