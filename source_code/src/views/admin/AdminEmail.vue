<script setup>
import { computed, reactive, ref } from 'vue';
import api from '../../api/axios';

const senders = [
  { value: 'support@mcfoption.com', label: 'MCFOPTION Support', hint: 'Recommended for customer replies' },
  { value: 'admin@mcfoption.com', label: 'MCFOPTION Admin', hint: 'Administrative communication' },
  { value: 'no-reply@mcfoption.com', label: 'MCFOPTION No-Reply', hint: 'Notifications that do not need a reply' }
];

const form = reactive({
  from: 'support@mcfoption.com',
  to: '',
  subject: '',
  message: ''
});

const isSending = ref(false);
const successMessage = ref('');
const errorMessage = ref('');
const lastMessageId = ref('');

const selectedSender = computed(() => senders.find((item) => item.value === form.from));
const canSend = computed(() => {
  return form.to.trim() && form.subject.trim() && form.message.trim() && !isSending.value;
});

const resetForm = () => {
  form.to = '';
  form.subject = '';
  form.message = '';
  successMessage.value = '';
  errorMessage.value = '';
  lastMessageId.value = '';
};

const sendEmail = async () => {
  successMessage.value = '';
  errorMessage.value = '';
  lastMessageId.value = '';

  if (!canSend.value) return;

  isSending.value = true;
  try {
    const response = await api.post('/admin/email/send', {
      from: form.from,
      to: form.to.trim(),
      subject: form.subject.trim(),
      message: form.message.trim()
    });

    successMessage.value = response.data?.message || 'Email sent successfully.';
    lastMessageId.value = response.data?.id || '';
  } catch (error) {
    errorMessage.value = error.response?.data?.error || 'Unable to send email. Please try again.';
  } finally {
    isSending.value = false;
  }
};
</script>

<template>
  <div class="max-w-6xl mx-auto">
    <div class="mb-8">
      <p class="text-xs font-bold tracking-[0.22em] text-yellow-500 uppercase mb-2">MCFOPTION Mail</p>
      <h1 class="text-3xl font-bold text-white">Email Sender</h1>
      <p class="text-gray-400 mt-2 max-w-2xl">
        Send one-to-one operational or support emails through the verified MCFOPTION domain using Resend.
      </p>
    </div>

    <div class="grid grid-cols-1 xl:grid-cols-[1.15fr_.85fr] gap-6">
      <section class="bg-gray-800 border border-gray-700 rounded-2xl p-5 md:p-7 shadow-xl">
        <form class="space-y-5" @submit.prevent="sendEmail">
          <div>
            <label class="block text-sm font-semibold text-gray-300 mb-2">From</label>
            <select
              v-model="form.from"
              class="w-full h-12 rounded-xl border border-gray-600 bg-gray-900 px-4 text-white outline-none focus:border-yellow-500 focus:ring-2 focus:ring-yellow-500/20"
            >
              <option v-for="sender in senders" :key="sender.value" :value="sender.value">
                {{ sender.label }} &lt;{{ sender.value }}&gt;
              </option>
            </select>
            <p class="text-xs text-gray-500 mt-2">{{ selectedSender?.hint }}</p>
          </div>

          <div>
            <label class="block text-sm font-semibold text-gray-300 mb-2">To</label>
            <input
              v-model="form.to"
              type="email"
              maxlength="254"
              required
              placeholder="customer@example.com"
              class="w-full h-12 rounded-xl border border-gray-600 bg-gray-900 px-4 text-white placeholder:text-gray-600 outline-none focus:border-yellow-500 focus:ring-2 focus:ring-yellow-500/20"
            />
          </div>

          <div>
            <div class="flex items-center justify-between gap-4 mb-2">
              <label class="text-sm font-semibold text-gray-300">Subject</label>
              <span class="text-xs text-gray-500">{{ form.subject.length }}/180</span>
            </div>
            <input
              v-model="form.subject"
              type="text"
              maxlength="180"
              required
              placeholder="MCFOPTION account update"
              class="w-full h-12 rounded-xl border border-gray-600 bg-gray-900 px-4 text-white placeholder:text-gray-600 outline-none focus:border-yellow-500 focus:ring-2 focus:ring-yellow-500/20"
            />
          </div>

          <div>
            <div class="flex items-center justify-between gap-4 mb-2">
              <label class="text-sm font-semibold text-gray-300">Message</label>
              <span class="text-xs text-gray-500">{{ form.message.length.toLocaleString() }}/20,000</span>
            </div>
            <textarea
              v-model="form.message"
              maxlength="20000"
              required
              rows="12"
              placeholder="Write your message here..."
              class="w-full rounded-xl border border-gray-600 bg-gray-900 px-4 py-3 text-white placeholder:text-gray-600 outline-none resize-y focus:border-yellow-500 focus:ring-2 focus:ring-yellow-500/20"
            ></textarea>
            <p class="text-xs text-gray-500 mt-2">The message is sent as plain text inside the MCFOPTION branded email template.</p>
          </div>

          <div v-if="successMessage" class="rounded-xl border border-emerald-500/30 bg-emerald-500/10 p-4 text-sm text-emerald-300">
            <p class="font-semibold">{{ successMessage }}</p>
            <p v-if="lastMessageId" class="mt-1 text-xs text-emerald-400/70 break-all">Resend ID: {{ lastMessageId }}</p>
          </div>

          <div v-if="errorMessage" class="rounded-xl border border-red-500/30 bg-red-500/10 p-4 text-sm text-red-300">
            {{ errorMessage }}
          </div>

          <div class="flex flex-col sm:flex-row gap-3 pt-1">
            <button
              type="submit"
              :disabled="!canSend"
              class="inline-flex min-h-12 flex-1 items-center justify-center gap-2 rounded-xl bg-yellow-500 px-5 font-bold text-gray-950 transition hover:bg-yellow-400 disabled:cursor-not-allowed disabled:opacity-50"
            >
              <svg v-if="isSending" class="h-5 w-5 animate-spin" viewBox="0 0 24 24" fill="none">
                <circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="3" opacity=".25" />
                <path d="M21 12a9 9 0 0 0-9-9" stroke="currentColor" stroke-width="3" stroke-linecap="round" />
              </svg>
              <span>{{ isSending ? 'Sending...' : 'Send Email' }}</span>
            </button>
            <button
              type="button"
              @click="resetForm"
              class="min-h-12 rounded-xl border border-gray-600 px-5 font-semibold text-gray-300 transition hover:border-gray-500 hover:bg-gray-700"
            >
              Clear
            </button>
          </div>
        </form>
      </section>

      <aside class="space-y-6">
        <section class="bg-gray-800 border border-gray-700 rounded-2xl p-5 md:p-6">
          <p class="text-xs font-bold tracking-[0.2em] text-gray-500 uppercase">Preview</p>
          <div class="mt-5 overflow-hidden rounded-xl border border-gray-700 bg-[#111318]">
            <div class="border-b border-gray-700 px-5 py-4">
              <p class="font-extrabold tracking-wider"><span class="text-yellow-500">MCF</span><span class="text-gray-100">OPTION</span></p>
            </div>
            <div class="px-5 py-5">
              <p class="text-xs text-gray-500">FROM</p>
              <p class="text-sm text-gray-300 break-all">{{ form.from }}</p>
              <p class="text-xs text-gray-500 mt-4">TO</p>
              <p class="text-sm text-gray-300 break-all">{{ form.to || 'recipient@example.com' }}</p>
              <h2 class="text-lg font-bold text-white mt-6 break-words">{{ form.subject || 'Email subject' }}</h2>
              <p class="text-sm leading-7 text-gray-400 mt-4 whitespace-pre-wrap break-words">{{ form.message || 'Your message preview will appear here.' }}</p>
            </div>
          </div>
        </section>

        <section class="rounded-2xl border border-yellow-500/20 bg-yellow-500/5 p-5 md:p-6">
          <h3 class="font-bold text-yellow-400">Delivery & security</h3>
          <ul class="mt-3 space-y-2 text-sm leading-6 text-gray-400">
            <li>• API key stays on the backend and is never exposed to the browser.</li>
            <li>• Sender is restricted to approved MCFOPTION addresses.</li>
            <li>• Sending is rate-limited to reduce accidental or abusive use.</li>
            <li>• Successful sends are recorded in the admin activity log without storing the email body.</li>
          </ul>
        </section>

        <section v-if="form.from === 'no-reply@mcfoption.com'" class="rounded-2xl border border-orange-500/20 bg-orange-500/5 p-5 text-sm text-orange-200/80">
          You selected <strong>no-reply@mcfoption.com</strong>. Use Support or Admin instead when you expect the recipient to reply.
        </section>
      </aside>
    </div>
  </div>
</template>
