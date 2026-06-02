<script setup>
import { useRouter } from 'vue-router';

const router = useRouter();

const goToLogin = () => {
    router.push('/login');
};
</script>

<template>
    <div class="min-h-screen bg-gray-950 flex items-center justify-center p-4">
        <div class="max-w-md w-full text-center">
            <!-- Ban Icon -->
            <div class="mb-8">
                <div
                    class="w-24 h-24 mx-auto bg-red-500/10 rounded-full flex items-center justify-center border-2 border-red-500/30">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                        stroke="currentColor" class="w-12 h-12 text-red-500">
                        <path stroke-linecap="round" stroke-linejoin="round"
                            d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" />
                    </svg>
                </div>
            </div>

            <!-- Message -->
            <h1 class="text-3xl font-bold text-white mb-3">Account Suspended</h1>
            <p class="text-gray-400 mb-8 leading-relaxed">
                Your account has been suspended due to a violation of our terms of service.
                If you believe this is an error, please contact our customer support team.
            </p>

            <!-- Contact Info -->
            <div class="bg-gray-900 border border-gray-800 rounded-xl p-6 mb-8">
                <h3 class="text-sm font-bold text-gray-400 uppercase mb-4">Contact Customer Support</h3>
                <div class="space-y-3">
                    <a href="mailto:admin@mycoinflips.com"
                        class="flex items-center justify-center gap-2 text-yellow-500 hover:text-yellow-400 transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                            stroke="currentColor" class="w-5 h-5">
                            <path stroke-linecap="round" stroke-linejoin="round"
                                d="M21.75 6.75v10.5a2.25 2.25 0 01-2.25 2.25h-15a2.25 2.25 0 01-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0019.5 4.5h-15a2.25 2.25 0 00-2.25 2.25m19.5 0v.243a2.25 2.25 0 01-1.07 1.916l-7.5 4.615a2.25 2.25 0 01-2.36 0L3.32 8.91a2.25 2.25 0 01-1.07-1.916V6.75" />
                        </svg>
                        admin@mycoinflips.com
                    </a>
                </div>
            </div>

            <!-- Back to Login -->
            <button @click="goToLogin" class="text-gray-500 hover:text-white text-sm transition-colors">
                &larr; Back to Login
            </button>
        </div>
    </div>
</template>
