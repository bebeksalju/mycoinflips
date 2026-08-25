<script setup>
import { computed, ref } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import api from '../api/axios';
import logoUrl from '../assets/branding/mcfoption-logo-horizontal.png';

const route = useRoute();
const router = useRouter();
const token = computed(() => String(route.query.token || ''));
const password = ref('');
const confirmPassword = ref('');
const isLoading = ref(false);
const error = ref('');
const success = ref(false);

const submit = async () => {
  error.value = '';
  if (!token.value) {
    error.value = 'This reset link is invalid.';
    return;
  }
  if (password.value.length < 8) {
    error.value = 'Password must be at least 8 characters.';
    return;
  }
  if (password.value !== confirmPassword.value) {
    error.value = 'Passwords do not match.';
    return;
  }

  isLoading.value = true;
  try {
    await api.post('/auth/reset-password', {
      token: token.value,
      newPassword: password.value
    });
    success.value = true;
    setTimeout(() => router.push('/login'), 1800);
  } catch (err) {
    error.value = err.response?.data?.error || 'Unable to reset password.';
  } finally {
    isLoading.value = false;
  }
};
</script>

<template>
  <main class="auth-page">
    <RouterLink to="/login" class="back-link">← Back to login</RouterLink>
    <section class="auth-card">
      <img :src="logoUrl" alt="MCFOPTION" class="logo" />
      <p class="eyebrow">SECURE PASSWORD RESET</p>
      <h1>Create a new password</h1>
      <p class="intro">Use at least 8 characters. Completing this reset will sign out all existing sessions for the account.</p>

      <div v-if="success" class="success-box">
        <strong>Password updated</strong>
        <p>Your password has been reset. Redirecting you to login…</p>
      </div>

      <form v-else @submit.prevent="submit" class="form">
        <label>
          <span>New password</span>
          <input v-model="password" type="password" autocomplete="new-password" placeholder="••••••••" required />
        </label>
        <label>
          <span>Confirm new password</span>
          <input v-model="confirmPassword" type="password" autocomplete="new-password" placeholder="••••••••" required />
        </label>
        <p v-if="error" class="error">{{ error }}</p>
        <button type="submit" :disabled="isLoading || !token">{{ isLoading ? 'Updating...' : 'Reset password' }}</button>
      </form>
    </section>
  </main>
</template>

<style scoped>
.auth-page { min-height:100vh; display:grid; place-items:center; padding:72px 20px 36px; box-sizing:border-box; background:linear-gradient(180deg,rgba(7,8,11,.76),rgba(7,8,11,.92)),url('/crypto-bg.png') center/cover fixed; color:#f6f5f2; font-family:Inter,system-ui,sans-serif; position:relative; }
.back-link { position:absolute; top:24px; left:28px; color:#9a9da5; text-decoration:none; font-size:13px; }
.back-link:hover { color:#e9be51; }
.auth-card { width:min(500px,100%); background:rgba(14,15,19,.96); border:1px solid rgba(232,185,63,.22); border-radius:24px; padding:36px; box-sizing:border-box; box-shadow:0 30px 90px rgba(0,0,0,.5); }
.logo { width:240px; max-width:78%; display:block; margin-bottom:28px; }
.eyebrow { color:#c99c32; font-size:10px; font-weight:900; letter-spacing:.2em; margin:0 0 12px; }
h1 { margin:0; font:800 34px/1.1 Manrope,Inter,sans-serif; letter-spacing:-.035em; }
.intro { color:#8d9098; line-height:1.7; font-size:14px; margin:14px 0 28px; }
.form { display:grid; gap:18px; }
label { display:grid; gap:8px; }
label span { font-size:12px; font-weight:700; color:#c9cacc; }
input { height:52px; border:1px solid #2b2d33; border-radius:12px; background:#15171c; color:#fff; padding:0 15px; font:inherit; outline:none; }
input:focus { border-color:#c99b31; box-shadow:0 0 0 3px rgba(201,155,49,.11); }
button { height:52px; border:0; border-radius:12px; background:linear-gradient(135deg,#f2cc5d,#b87a17); color:#12100c; font-weight:900; cursor:pointer; }
button:disabled { opacity:.65; cursor:not-allowed; }
.error { color:#ef7b83; font-size:13px; margin:0; }
.success-box { border:1px solid rgba(69,201,130,.22); background:rgba(69,201,130,.06); border-radius:14px; padding:20px; }
.success-box strong { color:#75d9a4; }
.success-box p { color:#9da0a7; line-height:1.6; font-size:14px; margin-bottom:0; }
@media(max-width:600px){ .auth-card{padding:28px 22px}.back-link{left:18px}.auth-page{background-attachment:scroll} }
</style>
