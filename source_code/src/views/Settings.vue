<script setup>
import { reactive, onMounted, ref } from 'vue';
import { useMarketStore } from '../stores/market';
import { useAuthStore } from '../stores/auth';
import api from '../api/axios';

const marketStore = useMarketStore();
const authStore = useAuthStore();

const SETTINGS_KEY = 'mycoinflip_settings';

const settings = reactive({
    soundEnabled: true,
    notifications: true,
    compactMode: false
});

// Load saved settings from localStorage
onMounted(() => {
    try {
        const saved = localStorage.getItem(SETTINGS_KEY);
        if (saved) {
            const parsed = JSON.parse(saved);
            settings.soundEnabled = parsed.soundEnabled ?? true;
            settings.notifications = parsed.notifications ?? true;
            settings.compactMode = parsed.compactMode ?? false;
        }
    } catch (e) {
        console.error('Failed to load settings:', e);
    }
});

function saveSettings() {
    try {
        localStorage.setItem(SETTINGS_KEY, JSON.stringify({
            soundEnabled: settings.soundEnabled,
            notifications: settings.notifications,
            compactMode: settings.compactMode
        }));
        marketStore.showToast('Settings Saved', 'Your preferences have been updated.', 'success');
    } catch (e) {
        marketStore.showToast('Error', 'Failed to save settings.', 'error');
    }
}

// Change Password
const passwordForm = reactive({
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
});
const isChangingPassword = ref(false);

async function changePassword() {
    if (!passwordForm.currentPassword || !passwordForm.newPassword || !passwordForm.confirmPassword) {
        marketStore.showToast('Error', 'Please fill all password fields', 'error');
        return;
    }
    if (passwordForm.newPassword.length < 8) {
        marketStore.showToast('Error', 'New password must be at least 8 characters', 'error');
        return;
    }
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
        marketStore.showToast('Error', 'New passwords do not match', 'error');
        return;
    }

    isChangingPassword.value = true;
    try {
        await api.put('/auth/change-password', {
            currentPassword: passwordForm.currentPassword,
            newPassword: passwordForm.newPassword
        });
        marketStore.showToast('Success', 'Password changed successfully', 'success');
        passwordForm.currentPassword = '';
        passwordForm.newPassword = '';
        passwordForm.confirmPassword = '';
    } catch (error) {
        const msg = error.response?.data?.error || 'Failed to change password';
        marketStore.showToast('Error', msg, 'error');
    } finally {
        isChangingPassword.value = false;
    }
}
</script>

<template>
    <div class="p-4 md:p-8 max-w-2xl mx-auto w-full space-y-6 pb-24">
        <h2 class="text-2xl font-bold flex items-center gap-2">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-8 h-8 text-yellow-500">
              <path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 011.37.49l1.296 2.247a1.125 1.125 0 01-.26 1.431l-1.003.827c-.293.24-.438.613-.431.992a6.759 6.759 0 010 .255c-.007.378.138.75.43.99l1.005.828c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 01-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 01-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.02-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 01-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 01-1.369-.49l-1.297-2.247a1.125 1.125 0 01.26-1.431l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 010-.255c.007-.378-.138-.75-.43-.99l-1.004-.828a1.125 1.125 0 01-.26-1.43l1.297-2.247a1.125 1.125 0 011.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281z" />
              <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            </svg>
            Settings
        </h2>

        <!-- Preferences -->
        <div class="bg-gray-900 border border-gray-800 rounded-xl p-6 space-y-5">
            <h3 class="font-bold text-lg pb-2 border-b border-gray-800 text-gray-300">Audio & Notifications</h3>

            <div class="space-y-3">
                <div class="flex items-center justify-between p-3 bg-gray-800/30 rounded-lg">
                    <div>
                        <p class="font-medium text-white">Sound Effects</p>
                        <p class="text-xs text-gray-500">Play sounds for trade execution and results</p>
                    </div>
                    <label class="relative inline-flex items-center cursor-pointer">
                        <input type="checkbox" v-model="settings.soundEnabled" class="sr-only peer">
                        <div class="w-11 h-6 bg-gray-700 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-yellow-500"></div>
                    </label>
                </div>

                <div class="flex items-center justify-between p-3 bg-gray-800/30 rounded-lg">
                    <div>
                        <p class="font-medium text-white">Toast Notifications</p>
                        <p class="text-xs text-gray-500">Show popup notifications for events</p>
                    </div>
                    <label class="relative inline-flex items-center cursor-pointer">
                        <input type="checkbox" v-model="settings.notifications" class="sr-only peer">
                        <div class="w-11 h-6 bg-gray-700 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-yellow-500"></div>
                    </label>
                </div>
            </div>

            <button @click="saveSettings"
                class="w-full py-3 bg-yellow-500 hover:bg-yellow-400 text-gray-900 font-bold rounded-lg transition-colors shadow-lg shadow-yellow-500/10">
                Save Preferences
            </button>
        </div>

        <!-- Change Password -->
        <div class="bg-gray-900 border border-gray-800 rounded-xl p-6 space-y-5">
            <h3 class="font-bold text-lg pb-2 border-b border-gray-800 text-gray-300 flex items-center gap-2">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 text-yellow-500">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 10-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 002.25-2.25v-6.75a2.25 2.25 0 00-2.25-2.25H6.75a2.25 2.25 0 00-2.25 2.25v6.75a2.25 2.25 0 002.25 2.25z" />
                </svg>
                Change Password
            </h3>

            <div class="space-y-4">
                <div>
                    <label class="block text-xs uppercase font-bold text-gray-500 mb-2">Current Password</label>
                    <input type="password" v-model="passwordForm.currentPassword"
                        placeholder="Enter current password"
                        class="w-full bg-gray-800 border border-gray-700 rounded-lg p-3 text-white focus:outline-none focus:border-yellow-500 focus:ring-1 focus:ring-yellow-500 transition-all">
                </div>
                <div>
                    <label class="block text-xs uppercase font-bold text-gray-500 mb-2">New Password</label>
                    <input type="password" v-model="passwordForm.newPassword"
                        placeholder="Min. 8 characters"
                        class="w-full bg-gray-800 border border-gray-700 rounded-lg p-3 text-white focus:outline-none focus:border-yellow-500 focus:ring-1 focus:ring-yellow-500 transition-all">
                </div>
                <div>
                    <label class="block text-xs uppercase font-bold text-gray-500 mb-2">Confirm New Password</label>
                    <input type="password" v-model="passwordForm.confirmPassword"
                        placeholder="Repeat new password"
                        class="w-full bg-gray-800 border border-gray-700 rounded-lg p-3 text-white focus:outline-none focus:border-yellow-500 focus:ring-1 focus:ring-yellow-500 transition-all">
                    <p v-if="passwordForm.confirmPassword && passwordForm.newPassword !== passwordForm.confirmPassword"
                        class="text-xs text-red-400 mt-1.5">Passwords do not match</p>
                </div>
            </div>

            <button @click="changePassword" :disabled="isChangingPassword"
                class="w-full py-3 bg-gray-700 hover:bg-gray-600 disabled:opacity-60 disabled:cursor-not-allowed text-white font-bold rounded-lg transition-colors flex items-center justify-center gap-2">
                <svg v-if="isChangingPassword" class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
                </svg>
                {{ isChangingPassword ? 'Updating...' : 'Update Password' }}
            </button>
        </div>

        <!-- Account Info -->
        <div class="bg-gray-900 border border-gray-800 rounded-xl p-6">
            <h3 class="font-bold text-lg pb-2 border-b border-gray-800 text-gray-300 mb-4">Account Info</h3>
            <div class="space-y-3">
                <div class="flex justify-between items-center py-2">
                    <span class="text-gray-500 text-sm">Email</span>
                    <span class="text-white text-sm font-mono">{{ authStore.user.email }}</span>
                </div>
                <div class="flex justify-between items-center py-2">
                    <span class="text-gray-500 text-sm">Role</span>
                    <span class="text-yellow-500 font-bold text-sm">{{ authStore.user.role }}</span>
                </div>
                <div class="flex justify-between items-center py-2">
                    <span class="text-gray-500 text-sm">KYC Status</span>
                    <span class="text-sm font-bold"
                        :class="authStore.user.kycStatus === 'approved' ? 'text-green-400' : authStore.user.kycStatus === 'pending' ? 'text-yellow-400' : 'text-orange-400'">
                        {{ authStore.user.kycStatus || 'Not submitted' }}
                    </span>
                </div>
            </div>
        </div>
    </div>
</template>
