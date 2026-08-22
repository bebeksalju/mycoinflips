<script setup>
import { ref, reactive } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import { useMarketStore } from '../stores/market';
import logoUrl from '../assets/mcfoption-logo.svg';

const router = useRouter();
const authStore = useAuthStore();
const marketStore = useMarketStore();

const form = reactive({
    firstName: '',
    lastName: '',
    email: '',
    password: '',
    confirmPassword: '',
    dob: '',
    pob: '',
    phone: '',
    address: ''
});

const isLoading = ref(false);

const handleRegister = async () => {
    if (form.password !== form.confirmPassword) {
        marketStore.showToast('Error', 'Passwords do not match', 'error');
        return;
    }

    isLoading.value = true;

    const success = await authStore.register({
        firstName: form.firstName,
        lastName: form.lastName,
        email: form.email,
        password: form.password,
        dob: form.dob,
        pob: form.pob,
        phone: form.phone,
        address: form.address
    });

    if (success) {
        marketStore.showToast('Success', 'Account created! Please login.', 'success');
        router.push('/login');
    } else {
        marketStore.showToast('Error', 'Registration failed', 'error');
    }
    isLoading.value = false;
};
</script>

<template>
    <main class="register-page">
        <div class="register-glow"></div>
        <RouterLink to="/" class="back-home">← Back to home</RouterLink>

        <section class="register-card">
            <header class="register-header">
                <img :src="logoUrl" alt="MCFOPTION" />
                <p class="eyebrow">TRADE • FLIP • GROW</p>
                <h1>Create your MCFOPTION account</h1>
                <p>Set up your profile and continue to the trading workspace.</p>
            </header>

            <form @submit.prevent="handleRegister" class="register-form">
                <div class="form-grid">
                    <label class="field">
                        <span>First Name</span>
                        <input id="firstName" autocomplete="given-name" required v-model="form.firstName" type="text" placeholder="John" />
                    </label>
                    <label class="field">
                        <span>Last Name</span>
                        <input id="lastName" autocomplete="family-name" required v-model="form.lastName" type="text" placeholder="Doe" />
                    </label>
                    <label class="field">
                        <span>Email Address</span>
                        <input id="email" autocomplete="email" required v-model="form.email" type="email" placeholder="john@example.com" />
                    </label>
                    <label class="field">
                        <span>Phone Number</span>
                        <input id="phone" autocomplete="tel" required v-model="form.phone" type="tel" placeholder="+1 234 567 890" />
                    </label>
                    <label class="field">
                        <span>Date of Birth</span>
                        <input id="dob" autocomplete="bday" required v-model="form.dob" type="date" />
                    </label>
                    <label class="field">
                        <span>Place of Birth</span>
                        <input id="pob" autocomplete="address-level2" required v-model="form.pob" type="text" placeholder="City, Country" />
                    </label>
                </div>

                <label class="field">
                    <span>Residential Address</span>
                    <textarea id="address" autocomplete="street-address" required v-model="form.address" rows="3" placeholder="Full residential address"></textarea>
                </label>

                <div class="form-grid">
                    <label class="field">
                        <span>Password</span>
                        <input id="password" autocomplete="new-password" required v-model="form.password" type="password" placeholder="••••••••" />
                    </label>
                    <label class="field">
                        <span>Confirm Password</span>
                        <input id="confirmPassword" autocomplete="new-password" required v-model="form.confirmPassword" type="password" placeholder="••••••••" />
                    </label>
                </div>

                <button type="submit" class="register-btn" :disabled="isLoading">
                    <svg v-if="isLoading" class="spinner" viewBox="0 0 24 24" aria-hidden="true">
                        <circle cx="12" cy="12" r="9" fill="none" stroke="currentColor" stroke-width="3" opacity=".25" />
                        <path d="M21 12a9 9 0 0 0-9-9" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" />
                    </svg>
                    <span>{{ isLoading ? 'Creating account...' : 'Create Account' }}</span>
                    <span v-if="!isLoading">→</span>
                </button>
            </form>

            <p class="signin-copy">Already have an account? <RouterLink to="/login">Sign in</RouterLink></p>
        </section>
    </main>
</template>

<style scoped>
.register-page { min-height: 100vh; background: #07080b; color: #f6f5f2; padding: 76px 20px 48px; position: relative; overflow: hidden; font-family: Inter, system-ui, sans-serif; }
.register-glow { position: absolute; width: 560px; height: 560px; border-radius: 50%; background: rgba(204,155,35,.12); filter: blur(115px); top: -250px; left: 50%; transform: translateX(-50%); }
.back-home { position: absolute; top: 24px; left: 28px; color: #858890; text-decoration: none; font-size: 13px; font-weight: 700; z-index: 2; }
.back-home:hover { color: #e1b748; }
.register-card { position: relative; z-index: 1; width: min(780px, 100%); margin: 0 auto; border: 1px solid rgba(226,182,67,.2); border-radius: 26px; background: linear-gradient(155deg, rgba(18,19,23,.98), rgba(11,12,15,.98)); box-shadow: 0 35px 100px rgba(0,0,0,.48); padding: 44px; }
.register-header { text-align: center; margin-bottom: 34px; }
.register-header img { width: 285px; max-width: 80%; margin: 0 auto 14px; }
.eyebrow { color: #c89b31; font-size: 10px; letter-spacing: .2em; font-weight: 850; margin: 4px 0 12px; }
.register-header h1 { font-family: Manrope, Inter, sans-serif; font-size: 34px; letter-spacing: -.035em; margin: 0; }
.register-header > p:last-child { color: #777b83; font-size: 13px; margin-top: 10px; }
.register-form { display: grid; gap: 20px; }
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
.field { display: grid; gap: 8px; }
.field > span { color: #b8bac0; font-size: 11px; font-weight: 750; }
.field input, .field textarea { width: 100%; box-sizing: border-box; border-radius: 11px; border: 1px solid #2a2c31; background: #14161b; color: #f5f4f0; padding: 0 14px; font: inherit; outline: none; transition: border-color .2s, box-shadow .2s, background .2s; }
.field input { height: 50px; }.field textarea { padding-top: 13px; resize: vertical; min-height: 88px; }
.field input:focus, .field textarea:focus { border-color: #c99b31; box-shadow: 0 0 0 3px rgba(201,155,49,.1); background: #17191e; }
.field input::placeholder, .field textarea::placeholder { color: #555860; }
.register-btn { min-height: 54px; margin-top: 4px; border: 0; border-radius: 11px; background: linear-gradient(135deg, #f5ce5e, #b67a17); color: #12100a; font-weight: 900; display: flex; align-items: center; justify-content: center; gap: 10px; cursor: pointer; }
.register-btn:disabled { opacity: .7; cursor: wait; }.spinner { width: 18px; height: 18px; animation: spin .8s linear infinite; } @keyframes spin { to { transform: rotate(360deg); } }
.signin-copy { text-align: center; color: #73767d; font-size: 13px; margin: 24px 0 0; }.signin-copy a { color: #d7ac43; font-weight: 800; text-decoration: none; }
@media (max-width: 620px) { .register-page { padding: 68px 14px 24px; }.back-home { left: 18px; top: 20px; }.register-card { padding: 30px 20px; border-radius: 20px; }.form-grid { grid-template-columns: 1fr; gap: 16px; }.register-header h1 { font-size: 28px; }.register-header img { width: 245px; } }
</style>
