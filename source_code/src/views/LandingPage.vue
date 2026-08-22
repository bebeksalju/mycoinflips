<script setup>
import { RouterLink } from 'vue-router';
import { computed, onMounted, ref } from 'vue';
import { useMarketStore } from '../stores/market';
import logoUrl from '../assets/mcfoption-logo.svg';
import markUrl from '../assets/mcfoption-mark.svg';

const marketStore = useMarketStore();
const isMobileMenuOpen = ref(false);

onMounted(() => {
    marketStore.fetchMarketOverview();
});

const topCoins = computed(() => marketStore.marketOverview || []);

const formatPrice = (value) => {
    if (value === null || value === undefined) return '—';
    const digits = value < 1 ? 4 : value < 100 ? 2 : 0;
    return Number(value).toLocaleString('en-US', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: digits,
        maximumFractionDigits: digits,
    });
};

const marketRows = computed(() => topCoins.value.slice(0, 6));

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

                        <img :src="markUrl" alt="MCFOPTION mark" class="hero-mark" />
                        <p class="hero-kicker">TRADE • FLIP • GROW</p>
                        <h1>Trade smarter.<br /><span>Move with the market.</span></h1>
                        <p class="hero-lead">
                            A focused trading experience for live crypto markets, timed opportunities, wallet management, and real-time account support.
                        </p>

                        <div class="hero-actions">
                            <RouterLink to="/register" class="btn btn-gold btn-large">
                                Start Trading
                                <span>→</span>
                            </RouterLink>
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

                    <div class="hero-terminal-wrap">
                        <div class="terminal-card">
                            <div class="terminal-topline">
                                <div>
                                    <p>MCFOPTION TERMINAL</p>
                                    <strong>Live Market</strong>
                                </div>
                                <span class="market-status"><i></i> Online</span>
                            </div>

                            <div class="terminal-symbol">
                                <div class="symbol-name">
                                    <span class="coin-orb">₿</span>
                                    <div><strong>BTC / USDT</strong><small>Bitcoin</small></div>
                                </div>
                                <div class="symbol-price">
                                    <strong>{{ marketRows[0] ? formatPrice(marketRows[0].current_price) : '$—' }}</strong>
                                    <span v-if="marketRows[0]" :class="marketRows[0].price_change_percentage_24h >= 0 ? 'positive' : 'negative'">
                                        {{ marketRows[0].price_change_percentage_24h >= 0 ? '+' : '' }}{{ marketRows[0].price_change_percentage_24h?.toFixed(2) }}%
                                    </span>
                                </div>
                            </div>

                            <div class="chart-panel" aria-hidden="true">
                                <div class="chart-grid"></div>
                                <svg viewBox="0 0 620 250" preserveAspectRatio="none">
                                    <defs>
                                        <linearGradient id="chartGold" x1="0" y1="0" x2="1" y2="0">
                                            <stop offset="0" stop-color="#8c5d12" />
                                            <stop offset="0.45" stop-color="#e8b93f" />
                                            <stop offset="1" stop-color="#ffe177" />
                                        </linearGradient>
                                        <linearGradient id="chartFill" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="0" stop-color="#e8b93f" stop-opacity=".25" />
                                            <stop offset="1" stop-color="#e8b93f" stop-opacity="0" />
                                        </linearGradient>
                                    </defs>
                                    <path d="M0 216 C40 202 63 214 98 180 S157 191 194 152 S252 168 291 125 S356 145 397 98 S456 112 494 76 S552 65 620 31 L620 250 L0 250 Z" fill="url(#chartFill)" />
                                    <path d="M0 216 C40 202 63 214 98 180 S157 191 194 152 S252 168 291 125 S356 145 397 98 S456 112 494 76 S552 65 620 31" fill="none" stroke="url(#chartGold)" stroke-width="4" stroke-linecap="round" />
                                </svg>
                                <div class="candle candle-a"><span></span></div>
                                <div class="candle candle-b"><span></span></div>
                                <div class="candle candle-c"><span></span></div>
                                <div class="candle candle-d"><span></span></div>
                            </div>

                            <div class="terminal-actions">
                                <RouterLink to="/register" class="trade-button up">CALL <span>↗</span></RouterLink>
                                <RouterLink to="/register" class="trade-button down">PUT <span>↘</span></RouterLink>
                            </div>

                            <div class="terminal-footer">
                                <span>Powered by real-time market data</span>
                                <strong>MCFOPTION</strong>
                            </div>
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
                        <div v-if="marketRows.length" v-for="coin in marketRows" :key="coin.id" class="market-row">
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
                        <div v-else class="market-loading">Loading live markets…</div>
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
                            <div class="pillar-icon trade-icon">
                                <span></span><span></span><span></span><span></span>
                            </div>
                            <p>01</p>
                            <h3>TRADE</h3>
                            <span>Smart market tools for faster, more informed decisions.</span>
                        </article>
                        <article class="pillar-card featured">
                            <div class="pillar-icon flip-icon">↻</div>
                            <p>02</p>
                            <h3>FLIP</h3>
                            <span>Act on timed market opportunities from a clean trading workflow.</span>
                        </article>
                        <article class="pillar-card">
                            <div class="pillar-icon grow-icon">↗</div>
                            <p>03</p>
                            <h3>GROW</h3>
                            <span>Track your account and build your strategy with confidence.</span>
                        </article>
                    </div>
                </div>
            </section>

            <section id="features" class="features-section section-pad">
                <div class="container feature-layout">
                    <div class="feature-copy">
                        <p class="section-kicker">ONE WORKSPACE</p>
                        <h2>Everything important stays within reach.</h2>
                        <p>
                            MCFOPTION brings live trading, wallet operations, account verification, and support into one coherent interface across desktop and mobile.
                        </p>
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
                    <div class="security-points">
                        <span>Account Sessions</span>
                        <span>KYC Workflow</span>
                        <span>Transaction Approval</span>
                    </div>
                </div>
            </section>

            <section class="support-section">
                <div class="container support-inner">
                    <div>
                        <p class="section-kicker">REAL-TIME SUPPORT</p>
                        <h2>Here when you need us.</h2>
                    </div>
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
                <div class="footer-brand">
                    <img :src="logoUrl" alt="MCFOPTION" />
                    <p>Trade • Flip • Grow</p>
                </div>
                <div class="footer-links">
                    <a href="#markets">Markets</a>
                    <a href="#features">Features</a>
                    <a href="#security">Security</a>
                    <RouterLink to="/login">Log In</RouterLink>
                </div>
                <p class="copyright">© {{ new Date().getFullYear() }} MCFOPTION. All rights reserved.</p>
            </div>
        </footer>
    </div>
</template>

<style scoped>
:global(html) { scroll-behavior: smooth; }
:global(body) { margin: 0; background: #07080b; }
:global(*) { box-sizing: border-box; }

.landing-page {
    height: 100%;
    width: 100%;
    max-width: 100%;
    overflow-x: hidden;
    overflow-y: auto;
    background-color: #07080b;
    background-image: linear-gradient(180deg, rgba(7, 8, 11, 0.82) 0%, rgba(7, 8, 11, 0.88) 100%), url('/crypto-bg.png');
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    background-attachment: fixed;
    color: #f4f4f2;
    font-family: Inter, system-ui, sans-serif;
}
.container { width: min(1180px, calc(100% - 40px)); max-width: 100%; margin: 0 auto; box-sizing: border-box; }

.site-header {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 50;
    background: rgba(7, 8, 11, .78);
    backdrop-filter: blur(18px);
    border-bottom: 1px solid rgba(255,255,255,.07);
}
.header-inner { height: 78px; display: flex; align-items: center; gap: 28px; }
.brand-link { display: flex; align-items: center; flex: 0 0 auto; }
.brand-link img { width: 230px; height: auto; display: block; }
.desktop-nav { margin-left: auto; display: flex; align-items: center; gap: 27px; }
.desktop-nav a { color: #8f9299; text-decoration: none; font-size: 13px; font-weight: 650; transition: color .2s; white-space: nowrap; }
.desktop-nav a:hover { color: #f0c654; }
.desktop-actions { display: flex; gap: 9px; }
.btn { min-height: 42px; padding: 0 18px; border-radius: 10px; display: inline-flex; align-items: center; justify-content: center; gap: 10px; text-decoration: none; font-size: 13px; font-weight: 800; border: 1px solid transparent; transition: transform .2s, border-color .2s, color .2s, filter .2s, background .2s; }
.btn:hover { transform: translateY(-1px); }
.btn-gold { color: #15120a; background: linear-gradient(135deg, #f5ce5e 0%, #b77816 100%); box-shadow: 0 10px 28px rgba(183,120,22,.14); }
.btn-gold:hover { filter: brightness(1.08); }
.btn-ghost { color: #d4d5d7; border-color: #303238; background: rgba(255,255,255,.025); }
.btn-ghost:hover { border-color: #8a6b24; color: #f0ca5b; }
.btn-large { min-height: 54px; padding: 0 24px; font-size: 14px; }
.menu-button { display: none; margin-left: auto; width: 44px; height: 44px; border: 1px solid #2b2d31; background: #111216; border-radius: 10px; padding: 11px; }
.menu-button span { display: block; height: 2px; background: #d9d9d6; margin: 4px 0; border-radius: 2px; }
.mobile-menu { display: none; }
.menu-fade-enter-active, .menu-fade-leave-active { transition: opacity .2s ease; }
.menu-fade-enter-from, .menu-fade-leave-to { opacity: 0; }

.hero-section { position: relative; min-height: 810px; padding: 150px 0 88px; display: flex; align-items: center; }
.hero-grid-overlay { position: absolute; inset: 0; opacity: .36; background-image: linear-gradient(rgba(255,255,255,.028) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,.028) 1px, transparent 1px); background-size: 52px 52px; mask-image: linear-gradient(to bottom, #000 0, rgba(0,0,0,.8) 60%, transparent 100%); }
.hero-glow { position: absolute; border-radius: 999px; filter: blur(120px); pointer-events: none; }
.hero-glow-a { width: 520px; height: 520px; background: rgba(203,149,27,.12); left: -190px; top: 40px; }
.hero-glow-b { width: 470px; height: 470px; background: rgba(181,139,40,.10); right: -180px; top: 180px; }
.hero-grid { position: relative; z-index: 2; display: grid; grid-template-columns: .95fr 1.05fr; gap: 74px; align-items: center; }
.hero-copy { max-width: 570px; }
.live-pill { display: inline-flex; align-items: center; gap: 8px; padding: 8px 11px; border: 1px solid rgba(206,162,53,.24); border-radius: 999px; color: #aa8a3d; background: rgba(202,151,31,.055); font-size: 10px; font-weight: 850; letter-spacing: .13em; }
.live-dot { width: 6px; height: 6px; background: #47c982; border-radius: 50%; box-shadow: 0 0 0 5px rgba(71,201,130,.09); }
.hero-mark { width: 300px; max-width: 72%; margin: 29px 0 0 -14px; }
.hero-kicker, .section-kicker { margin: 5px 0 14px; color: #c99e36; font-size: 11px; letter-spacing: .22em; font-weight: 850; }
.hero-copy h1 { font-family: Manrope, Inter, sans-serif; font-size: clamp(48px, 5vw, 74px); line-height: .99; letter-spacing: -.055em; margin: 0; color: #f7f6f3; }
.hero-copy h1 span { color: #a8a9ad; }
.hero-lead { max-width: 545px; margin: 25px 0 0; color: #8d9098; font-size: 16px; line-height: 1.75; }
.hero-actions { margin-top: 32px; display: flex; flex-wrap: wrap; gap: 11px; }
.trust-strip { margin-top: 44px; display: flex; align-items: center; gap: 22px; }
.trust-strip > div { display: grid; gap: 4px; }
.trust-strip strong { font-family: Manrope, Inter, sans-serif; color: #e8e8e5; font-size: 18px; }
.trust-strip span { color: #5f6269; font-size: 10px; letter-spacing: .05em; text-transform: uppercase; }
.trust-strip i { width: 1px; height: 34px; background: #292b30; }

.hero-terminal-wrap { position: relative; }
.hero-terminal-wrap::before { content: ''; position: absolute; inset: 10% -8% -7% 15%; background: radial-gradient(circle, rgba(212,164,42,.16), transparent 62%); filter: blur(35px); }
.terminal-card { position: relative; background: linear-gradient(155deg, rgba(20,21,25,.97), rgba(10,11,14,.98)); border: 1px solid rgba(228,185,70,.24); border-radius: 24px; padding: 26px; box-shadow: 0 40px 110px rgba(0,0,0,.52), inset 0 1px 0 rgba(255,255,255,.04); }
.terminal-topline { display: flex; justify-content: space-between; align-items: flex-start; padding-bottom: 20px; border-bottom: 1px solid #22242a; }
.terminal-topline p { margin: 0 0 7px; color: #6b6e75; font-size: 9px; font-weight: 850; letter-spacing: .18em; }
.terminal-topline strong { font-family: Manrope, Inter, sans-serif; font-size: 20px; }
.market-status { display: inline-flex; align-items: center; gap: 7px; color: #8f9398; border: 1px solid #292b30; background: #111318; border-radius: 999px; padding: 7px 10px; font-size: 10px; }
.market-status i { width: 6px; height: 6px; border-radius: 50%; background: #40c77d; }
.terminal-symbol { display: flex; justify-content: space-between; align-items: center; padding: 22px 0 13px; }
.symbol-name { display: flex; align-items: center; gap: 12px; }
.coin-orb { display: grid; place-items: center; width: 42px; height: 42px; border-radius: 50%; background: radial-gradient(circle at 35% 30%, #ffe585, #c38218 72%); color: #17120a; font-weight: 900; font-size: 22px; }
.symbol-name div { display: grid; gap: 3px; }
.symbol-name strong { font-size: 13px; }
.symbol-name small { color: #63666d; font-size: 10px; }
.symbol-price { text-align: right; display: grid; gap: 5px; }
.symbol-price strong { font-family: Manrope, Inter, sans-serif; font-size: 20px; }
.symbol-price span { font-size: 11px; font-weight: 800; }
.positive { color: #45c982 !important; }
.negative { color: #ed6671 !important; }
.chart-panel { height: 270px; border: 1px solid #24262b; border-radius: 14px; overflow: hidden; position: relative; background: #0b0d11; }
.chart-grid { position: absolute; inset: 0; background-image: linear-gradient(rgba(255,255,255,.035) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,.035) 1px, transparent 1px); background-size: 46px 46px; }
.chart-panel svg { position: absolute; left: 0; right: 0; bottom: 0; width: 100%; height: 235px; }
.candle { position: absolute; width: 8px; border-radius: 2px; background: linear-gradient(#ffe475, #b17414); }
.candle::before, .candle::after { content: ''; position: absolute; left: 3.5px; width: 1px; height: 13px; background: #dfb43d; }
.candle::before { top: -13px; } .candle::after { bottom: -13px; }
.candle-a { left: 31%; top: 133px; height: 34px; }.candle-b { left: 49%; top: 103px; height: 41px; }.candle-c { left: 67%; top: 81px; height: 31px; }.candle-d { left: 82%; top: 56px; height: 42px; }
.terminal-actions { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-top: 14px; }
.trade-button { min-height: 48px; border-radius: 10px; text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 9px; font-size: 12px; font-weight: 900; letter-spacing: .08em; }
.trade-button.up { color: #d9f8e7; border: 1px solid rgba(65,199,126,.22); background: rgba(65,199,126,.09); }
.trade-button.down { color: #ffdce0; border: 1px solid rgba(237,102,113,.2); background: rgba(237,102,113,.075); }
.terminal-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 18px; padding-top: 18px; border-top: 1px solid #202227; color: #55585f; font-size: 9px; text-transform: uppercase; letter-spacing: .09em; }
.terminal-footer strong { color: #ac8937; }

.section-pad { padding: 105px 0; }
.market-section { background: #0a0b0e; border-top: 1px solid #17191d; border-bottom: 1px solid #17191d; }
.section-heading { margin-bottom: 38px; }
.heading-row { display: flex; justify-content: space-between; gap: 24px; align-items: end; }
.section-heading h2, .feature-copy h2, .security-copy h2, .support-inner h2, .final-card h2 { font-family: Manrope, Inter, sans-serif; font-size: clamp(34px, 4vw, 50px); line-height: 1.08; letter-spacing: -.045em; margin: 0; }
.section-heading > p:last-child, .feature-copy > p, .security-copy > p, .support-inner > p, .final-card > p { color: #80838a; line-height: 1.7; }
.centered { text-align: center; max-width: 650px; margin-left: auto; margin-right: auto; }
.text-link { color: #cda23d; text-decoration: none; font-size: 12px; font-weight: 800; }
.market-table { border: 1px solid #24262c; border-radius: 18px; overflow: hidden; background: #0d0f13; }
.market-head, .market-row { display: grid; grid-template-columns: 2fr 1.25fr 1fr .6fr; align-items: center; gap: 16px; padding: 0 24px; }
.market-head { min-height: 44px; color: #555860; font-size: 9px; font-weight: 850; letter-spacing: .12em; text-transform: uppercase; background: #111318; }
.market-row { min-height: 78px; border-top: 1px solid #202228; }
.asset-cell { display: flex; align-items: center; gap: 13px; min-width: 0; }
.asset-cell img { width: 34px; height: 34px; border-radius: 50%; }
.asset-cell div { display: grid; gap: 3px; min-width: 0; }
.asset-cell strong { font-size: 13px; }.asset-cell small { color: #64676e; font-size: 10px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.price-cell { font-size: 13px; }
.change-pill { justify-self: start; font-size: 11px; font-weight: 850; }
.mini-trade { justify-self: end; color: #d5ae4a; text-decoration: none; font-size: 11px; font-weight: 850; }
.market-loading { padding: 34px; color: #686b72; text-align: center; }

.pillars-section { background: #07080b; }
.pillar-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-top: 42px; }
.pillar-card { min-height: 335px; padding: 34px; border-radius: 20px; border: 1px solid #23252a; background: linear-gradient(155deg, #101216, #0b0c10); position: relative; overflow: hidden; }
.pillar-card.featured { border-color: rgba(215,171,60,.3); background: radial-gradient(circle at 50% 10%, rgba(212,166,47,.12), transparent 36%), linear-gradient(155deg, #12120f, #0c0d10); }
.pillar-card > p { color: #5e6168; font-size: 10px; font-weight: 850; letter-spacing: .15em; margin: 42px 0 13px; }
.pillar-card h3 { font-family: Manrope, Inter, sans-serif; color: #eac659; letter-spacing: .08em; margin: 0 0 12px; font-size: 24px; }
.pillar-card > span { display: block; color: #777a81; font-size: 13px; line-height: 1.65; max-width: 280px; }
.pillar-icon { width: 74px; height: 74px; border-radius: 18px; border: 1px solid rgba(208,164,49,.22); background: rgba(208,164,49,.055); display: flex; align-items: center; justify-content: center; color: #e9bd4d; font-size: 38px; }
.trade-icon { gap: 5px; align-items: end; padding: 16px; }
.trade-icon span { width: 7px; border-radius: 2px; background: linear-gradient(#f2cf69, #9c6410); }.trade-icon span:nth-child(1){height:22px}.trade-icon span:nth-child(2){height:34px}.trade-icon span:nth-child(3){height:27px}.trade-icon span:nth-child(4){height:43px}

.features-section { background: #0a0b0e; border-top: 1px solid #17191d; border-bottom: 1px solid #17191d; }
.feature-layout { display: grid; grid-template-columns: .8fr 1.2fr; gap: 82px; align-items: start; }
.feature-copy { position: sticky; top: 120px; }
.feature-copy > p { margin: 23px 0 28px; max-width: 430px; }
.feature-grid { display: grid; grid-template-columns: 1fr 1fr; border: 1px solid #24262b; border-radius: 20px; overflow: hidden; }
.feature-grid article { min-height: 230px; padding: 30px; background: #0e1014; }
.feature-grid article:nth-child(1), .feature-grid article:nth-child(2) { border-bottom: 1px solid #24262b; }
.feature-grid article:nth-child(odd) { border-right: 1px solid #24262b; }
.feature-grid article > span { color: #735d27; font-size: 10px; font-weight: 850; letter-spacing: .15em; }
.feature-grid h3 { margin: 38px 0 11px; font-family: Manrope, Inter, sans-serif; font-size: 18px; }
.feature-grid p { margin: 0; color: #72757c; font-size: 12px; line-height: 1.65; }

.security-section { background: #07080b; }
.security-card { border: 1px solid rgba(211,166,49,.23); border-radius: 24px; padding: 50px; display: grid; grid-template-columns: auto 1fr auto; gap: 36px; align-items: center; background: radial-gradient(circle at 0 50%, rgba(208,163,46,.1), transparent 25%), linear-gradient(135deg, #101115, #0b0c0f); }
.security-emblem { width: 82px; height: 82px; display: grid; place-items: center; border-radius: 20px; color: #e5bb4e; border: 1px solid rgba(210,166,52,.24); background: rgba(210,166,52,.05); font-size: 42px; }
.security-copy h2 { font-size: 34px; }
.security-copy > p { margin: 14px 0 0; max-width: 650px; font-size: 13px; }
.security-points { display: grid; gap: 9px; }
.security-points span { color: #96999f; font-size: 11px; padding: 9px 12px; border: 1px solid #292b30; border-radius: 9px; background: #111317; white-space: nowrap; }

.support-section { border-top: 1px solid #1b1d22; border-bottom: 1px solid #1b1d22; background: #0b0c10; }
.support-inner { min-height: 170px; display: grid; grid-template-columns: 1.2fr 1fr auto; align-items: center; gap: 35px; }
.support-inner h2 { font-size: 31px; }
.support-inner > p { font-size: 13px; margin: 0; }
.final-cta { background: #07080b; }
.final-card { min-height: 470px; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; border: 1px solid #24262b; border-radius: 26px; background: radial-gradient(circle at 50% 20%, rgba(209,164,48,.13), transparent 33%), linear-gradient(#0e1014, #090a0d); }
.final-card img { width: 230px; max-width: 56%; margin-bottom: 5px; }
.final-card h2 { max-width: 650px; }
.final-card > p { max-width: 600px; margin: 16px auto 0; }
.final-actions { justify-content: center; }

.site-footer { border-top: 1px solid #191b1f; background: #08090c; }
.footer-grid { min-height: 190px; display: grid; grid-template-columns: 1fr auto; align-items: center; gap: 24px; position: relative; padding-bottom: 40px; }
.footer-brand img { width: 230px; }.footer-brand p { margin: 8px 0 0; color: #5b5e65; font-size: 10px; letter-spacing: .18em; text-transform: uppercase; }
.footer-links { display: flex; gap: 25px; }.footer-links a { color: #7c7f86; text-decoration: none; font-size: 12px; }.footer-links a:hover { color: #d8ad45; }
.copyright { position: absolute; left: 0; bottom: 28px; margin: 0; color: #3f4249; font-size: 10px; }

@media (max-width: 1050px) {
    .brand-link img { width: 200px; }
    .desktop-nav { gap: 18px; }.desktop-nav a { font-size: 12px; }
    .desktop-actions .btn { padding: 0 13px; }
    .hero-grid { gap: 36px; }.hero-copy h1 { font-size: clamp(45px, 6vw, 64px); }
    .feature-layout { gap: 45px; }.security-card { grid-template-columns: auto 1fr; }.security-points { grid-column: 2; grid-template-columns: repeat(3, 1fr); }
}

@media (max-width: 860px) {
    .container { width: min(100% - 30px, 700px); }
    .header-inner { height: 70px; }.brand-link img { width: 205px; }
    .desktop-nav, .desktop-actions { display: none; }.menu-button { display: block; }
    .mobile-menu { display: block; border-top: 1px solid #1e2025; background: rgba(9,10,13,.98); }
    .mobile-menu-inner { padding-top: 16px; padding-bottom: 22px; display: grid; gap: 2px; }
    .mobile-menu-inner > a { color: #a3a5aa; text-decoration: none; font-weight: 700; padding: 13px 4px; border-bottom: 1px solid #17191d; }
    .mobile-actions { display: grid; grid-template-columns: 1fr 1fr; gap: 9px; margin-top: 16px; }
    .hero-section { padding-top: 125px; }.hero-grid { grid-template-columns: 1fr; gap: 55px; }.hero-copy { max-width: 660px; }.hero-terminal-wrap { max-width: 650px; }
    .pillar-grid { grid-template-columns: 1fr; }.pillar-card { min-height: 250px; }
    .feature-layout { grid-template-columns: 1fr; }.feature-copy { position: static; }.feature-copy > p { max-width: 600px; }.feature-grid { margin-top: 8px; }
    .security-card { grid-template-columns: auto 1fr; padding: 35px; }.security-points { grid-column: 1 / -1; grid-template-columns: repeat(3, 1fr); }
    .support-inner { grid-template-columns: 1fr auto; padding: 30px 0; }.support-inner > p { grid-column: 1 / -1; grid-row: 2; }
    .footer-grid { grid-template-columns: 1fr; padding-top: 45px; padding-bottom: 65px; }.footer-links { flex-wrap: wrap; }
}

@media (max-width: 620px) {
    .container { width: calc(100% - 28px); }
    .section-pad { padding: 78px 0; }
    .hero-section { min-height: 0; padding: 114px 0 70px; }.hero-mark { width: 220px; max-width: 100%; margin-left: 0; }.hero-copy h1 { font-size: clamp(36px, 11vw, 58px); }.hero-lead { font-size: 14px; }.hero-actions { display: grid; grid-template-columns: 1fr; }.btn-large { width: 100%; }
    .trust-strip { gap: 13px; justify-content: space-between; flex-wrap: wrap; }.trust-strip i { height: 29px; }.trust-strip strong { font-size: 15px; }.trust-strip span { font-size: 8px; }
    .terminal-card { padding: 16px; border-radius: 18px; }.terminal-symbol { align-items: flex-end; }.chart-panel { height: 215px; }.chart-panel svg { height: 185px; }.terminal-footer span { display: none; }
    .heading-row { align-items: start; flex-direction: column; }.section-heading h2, .feature-copy h2, .final-card h2 { font-size: 34px; }
    .market-head { display: none; }.market-row { grid-template-columns: 1.5fr 1fr; min-height: 86px; padding: 12px 16px; gap: 8px 12px; }.asset-cell { grid-row: 1 / 3; }.price-cell { text-align: right; }.change-pill { justify-self: end; }.mini-trade { display: none; }
    .pillar-card { padding: 28px; }.feature-grid { grid-template-columns: 1fr; }.feature-grid article { min-height: 190px; border-right: 0 !important; border-bottom: 1px solid #24262b; }.feature-grid article:last-child { border-bottom: 0; }
    .security-card { grid-template-columns: 1fr; padding: 27px; }.security-emblem { width: 65px; height: 65px; }.security-points { grid-column: 1; grid-template-columns: 1fr; }.security-copy h2 { font-size: 29px; }
    .support-inner { grid-template-columns: 1fr; gap: 18px; padding: 35px 0; }.support-inner > p { grid-column: 1; grid-row: auto; }.support-inner .btn { justify-self: start; }
    .final-card { min-height: 430px; padding: 32px 20px; }.final-actions { width: 100%; max-width: 100%; }
    .footer-links { gap: 18px; }
}
</style>
