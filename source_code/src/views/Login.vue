<script setup>
import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { useRouter } from 'vue-router';
import { useMarketStore } from '../stores/market';
import logoUrl from '../assets/mcfoption-logo.svg';

const authStore = useAuthStore();
const router = useRouter();
const marketStore = useMarketStore();

const email = ref('');
const password = ref('');
const isLoading = ref(false);
const showPassword = ref(false);

const handleLogin = async () => {
    if (!email.value || !password.value) {
        marketStore.showToast('Error', 'Please enter email and password', 'error');
        return;
    }

    isLoading.value = true;
    const result = await authStore.login(email.value, password.value);

    if (result.success) {
        marketStore.showToast('Success', 'Welcome back!', 'success');
        router.push('/home');
    } else if (result.banned) {
        router.push('/banned');
    } else {
        marketStore.showToast('Error', result.error || 'Invalid credentials', 'error');
    }

    isLoading.value = false;
};
</script>

<template>
    <main class="login-page">
        <div class="ambient ambient-one"></div>
        <div class="ambient ambient-two"></div>

        <RouterLink to="/" class="back-home" aria-label="Back to MCFOPTION home">
            <span>←</span>
            Back to home
        </RouterLink>

        <section class="login-shell">
            <aside class="brand-panel">
                <div class="brand-panel-inner">
                    <img :src="logoUrl" alt="MCFOPTION" class="brand-logo" />

                    <div class="brand-copy">
                        <p class="eyebrow">TRADE • FLIP • GROW</p>
                        <h1>Built for decisions that move at market speed.</h1>
                        <p>
                            Access live markets, timed trading, wallet management, and real-time support from one secure workspace.
                        </p>
                    </div>

                    <div class="market-visual" aria-hidden="true">
                        <div class="grid-lines"></div>
                        <svg viewBox="0 0 560 210" preserveAspectRatio="none">
                            <defs>
                                <linearGradient id="lineGold" x1="0" y1="0" x2="1" y2="0">
                                    <stop offset="0" stop-color="#8d5b0b" />
                                    <stop offset="0.5" stop-color="#f1c54f" />
                                    <stop offset="1" stop-color="#fff0a3" />
                                </linearGradient>
                            </defs>
                            <path d="M0 170 C55 150 76 178 125 140 S203 118 238 131 S311 92 350 105 S430 48 560 27" fill="none" stroke="url(#lineGold)" stroke-width="4" stroke-linecap="round" />
                        </svg>
                        <div class="candle c1"><span></span></div>
                        <div class="candle c2"><span></span></div>
                        <div class="candle c3"><span></span></div>
                        <div class="candle c4"><span></span></div>
                    </div>

                    <div class="trust-row">
                        <span>SECURE</span>
                        <i></i>
                        <span>TRUSTED</span>
                        <i></i>
                        <span>RELIABLE</span>
                    </div>
                </div>
            </aside>

            <section class="form-panel">
                <div class="form-wrap">
                    <img :src="logoUrl" alt="MCFOPTION" class="mobile-logo" />

                    <div class="form-heading">
                        <p class="eyebrow">WELCOME BACK</p>
                        <h2>Sign in to MCFOPTION</h2>
                        <p>Continue to your trading workspace.</p>
                    </div>

                    <form @submit.prevent="handleLogin" class="login-form">
                        <label class="field">
                            <span>Email address</span>
                            <input
                                v-model="email"
                                type="email"
                                autocomplete="email"
                                placeholder="name@example.com"
                                required
                            />
                        </label>

                        <label class="field">
                            <span>Password</span>
                            <div class="password-wrap">
                                <input
                                    v-model="password"
                                    :type="showPassword ? 'text' : 'password'"
                                    autocomplete="current-password"
                                    placeholder="••••••••"
                                    required
                                />
                                <button
                                    type="button"
                                    class="password-toggle"
                                    @click="showPassword = !showPassword"
                                    :aria-label="showPassword ? 'Hide password' : 'Show password'"
                                >
                                    {{ showPassword ? 'Hide' : 'Show' }}
                                </button>
                            </div>
                        </label>

                        <div class="form-meta">
                            <span>Protected account access</span>
                            <a href="mailto:admin@mcfoption.com">Forgot password?</a>
                        </div>

                        <button type="submit" class="submit-btn" :disabled="isLoading">
                            <svg v-if="isLoading" class="spinner" viewBox="0 0 24 24" aria-hidden="true">
                                <circle cx="12" cy="12" r="9" fill="none" stroke="currentColor" stroke-width="3" opacity=".25" />
                                <path d="M21 12a9 9 0 0 0-9-9" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" />
                            </svg>
                            <span>{{ isLoading ? 'Signing in...' : 'Sign in' }}</span>
                            <span v-if="!isLoading" aria-hidden="true">→</span>
                        </button>
                    </form>

                    <p class="register-copy">
                        New to MCFOPTION?
                        <RouterLink to="/register">Create an account</RouterLink>
                    </p>
                </div>
            </section>
        </section>
    </main>
</template>

<style scoped>
.login-page {
    min-height: 100vh;
    background-color: #07080b;
    background-image: linear-gradient(180deg, rgba(7, 8, 11, 0.72) 0%, rgba(7, 8, 11, 0.85) 100%), url('/crypto-bg.png');
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    background-attachment: fixed;
    color: #f7f7f5;
    position: relative;
    overflow: hidden;
    display: grid;
    place-items: center;
    padding: 32px;
    font-family: Inter, system-ui, sans-serif;
}

.ambient { position: absolute; border-radius: 999px; filter: blur(90px); opacity: .18; pointer-events: none; }
.ambient-one { width: 420px; height: 420px; background: #d7a72b; top: -180px; left: -120px; }
.ambient-two { width: 360px; height: 360px; background: #7c621e; bottom: -180px; right: -120px; }

.back-home {
    position: absolute; top: 26px; left: 30px; z-index: 5; display: inline-flex; align-items: center; gap: 9px;
    color: #8f9299; text-decoration: none; font-size: 13px; font-weight: 600; transition: color .2s ease;
}
.back-home:hover { color: #f2ca59; }

.login-shell {
    width: min(1120px, 100%);
    min-height: 660px;
    display: grid;
    grid-template-columns: 1.08fr .92fr;
    background: rgba(14, 15, 19, .94);
    border: 1px solid rgba(241, 197, 79, .2);
    border-radius: 28px;
    overflow: hidden;
    box-shadow: 0 34px 100px rgba(0, 0, 0, .52);
    position: relative;
    z-index: 2;
}

.brand-panel {
    position: relative;
    background:
        radial-gradient(circle at 75% 18%, rgba(241, 197, 79, .11), transparent 28%),
        linear-gradient(145deg, #0a0b0e 0%, #111216 100%);
    border-right: 1px solid rgba(255,255,255,.07);
}
.brand-panel-inner { min-height: 100%; padding: 58px; display: flex; flex-direction: column; }
.brand-logo { width: 310px; max-width: 86%; height: auto; }
.brand-copy { margin-top: 76px; max-width: 500px; }
.eyebrow { color: #d7ad3f; font-size: 11px; font-weight: 800; letter-spacing: .22em; margin: 0 0 14px; }
.brand-copy h1 { font-family: Manrope, Inter, sans-serif; font-size: clamp(34px, 4vw, 55px); line-height: 1.04; letter-spacing: -.045em; margin: 0; color: #f5f4f0; }
.brand-copy > p:last-child { color: #9699a1; line-height: 1.75; font-size: 14px; max-width: 440px; margin-top: 22px; }

.market-visual { position: relative; height: 190px; margin-top: 38px; overflow: hidden; border-radius: 18px; border: 1px solid rgba(255,255,255,.06); background: linear-gradient(180deg, rgba(255,255,255,.025), rgba(255,255,255,.005)); }
.grid-lines { position: absolute; inset: 0; background-image: linear-gradient(rgba(255,255,255,.04) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,.04) 1px, transparent 1px); background-size: 44px 44px; mask-image: linear-gradient(to bottom, transparent, #000 22%, #000 80%, transparent); }
.market-visual svg { position: absolute; inset: 18px 0 0; width: 100%; height: 150px; }
.candle { position: absolute; width: 9px; background: linear-gradient(#ffd766, #ad7418); border-radius: 2px; }
.candle::before, .candle::after { content: ''; position: absolute; left: 4px; width: 1px; background: #eac356; }
.candle::before { height: 13px; top: -13px; }
.candle::after { height: 13px; bottom: -13px; }
.c1 { left: 18%; top: 112px; height: 30px; }
.c2 { left: 43%; top: 82px; height: 38px; }
.c3 { left: 66%; top: 62px; height: 31px; }
.c4 { left: 82%; top: 40px; height: 44px; }

.trust-row { margin-top: auto; padding-top: 28px; display: flex; align-items: center; gap: 14px; color: #74777e; font-size: 10px; font-weight: 800; letter-spacing: .18em; }
.trust-row i { width: 3px; height: 3px; border-radius: 999px; background: #b88b24; }

.form-panel { display: flex; align-items: center; justify-content: center; background: #0d0f13; }
.form-wrap { width: min(410px, 100%); padding: 58px 38px; }
.mobile-logo { display: none; width: 240px; margin: 0 auto 42px; }
.form-heading h2 { font-family: Manrope, Inter, sans-serif; margin: 0; font-size: 32px; letter-spacing: -.035em; color: #faf9f6; }
.form-heading > p:last-child { color: #777b84; font-size: 14px; margin-top: 10px; }
.login-form { margin-top: 38px; display: grid; gap: 22px; }
.field { display: grid; gap: 9px; }
.field > span { color: #c4c5c7; font-size: 12px; font-weight: 700; }
.field input { width: 100%; height: 52px; box-sizing: border-box; border-radius: 12px; border: 1px solid #2a2c32; background: #14161b; color: #f6f6f4; padding: 0 15px; font: inherit; outline: none; transition: border-color .2s, box-shadow .2s, background .2s; }
.field input::placeholder { color: #555861; }
.field input:focus { border-color: #c99b31; box-shadow: 0 0 0 3px rgba(201,155,49,.11); background: #17191e; }
.password-wrap { position: relative; }
.password-wrap input { padding-right: 72px; }
.password-toggle { position: absolute; right: 12px; top: 50%; transform: translateY(-50%); border: 0; background: transparent; color: #b89239; font-size: 11px; font-weight: 800; cursor: pointer; }
.form-meta { display: flex; justify-content: space-between; gap: 14px; margin-top: -8px; color: #5e626b; font-size: 11px; }
.form-meta a { color: #c99b31; text-decoration: none; font-weight: 700; }
.form-meta a:hover { color: #f1c54f; }
.submit-btn { height: 54px; border: 0; border-radius: 12px; display: flex; align-items: center; justify-content: center; gap: 10px; background: linear-gradient(135deg, #f5ce5e, #b67a17); color: #11100d; font-weight: 900; letter-spacing: .015em; cursor: pointer; box-shadow: 0 12px 30px rgba(183,122,23,.18); transition: transform .2s ease, filter .2s ease; }
.submit-btn:hover:not(:disabled) { transform: translateY(-1px); filter: brightness(1.08); }
.submit-btn:disabled { opacity: .72; cursor: wait; }
.spinner { width: 18px; height: 18px; animation: spin .8s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.register-copy { color: #6e7179; text-align: center; font-size: 13px; margin-top: 28px; }
.register-copy a { color: #e0b648; font-weight: 800; text-decoration: none; margin-left: 4px; }
.register-copy a:hover { color: #f4d36d; }

@media (max-width: 900px) {
    .login-page { padding: 76px 20px 28px; }
    .login-shell { grid-template-columns: 1fr; min-height: auto; max-width: 560px; }
    .brand-panel { display: none; }
    .form-panel { min-height: 650px; }
    .mobile-logo { display: block; }
    .form-wrap { padding: 50px 34px; }
}

@media (max-width: 520px) {
    .login-page { padding: 68px 14px 18px; place-items: start center; }
    .back-home { top: 22px; left: 18px; }
    .login-shell { border-radius: 20px; }
    .form-panel { min-height: 0; }
    .form-wrap { padding: 38px 22px 34px; }
    .mobile-logo { width: 210px; margin-bottom: 36px; }
    .form-heading h2 { font-size: 27px; }
    .form-meta { align-items: center; }
}
</style>
