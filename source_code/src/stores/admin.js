import { defineStore } from 'pinia';
import { ref, reactive } from 'vue';
import axios from '../api/axios';

export const useAdminStore = defineStore('admin', () => {
    
    // Platform Stats — extended with informative metrics
    const platformStats = reactive({
        totalUsers: 0,
        newUsersToday: 0,
        totalDeposits: 0,
        totalWithdrawals: 0,
        pendingWithdrawals: 0,
        pendingWithdrawalAmount: 0,
        pendingKyc: 0,
        totalTrades: 0,
        winCount: 0,
        lossCount: 0,
        revenue: 0,
        recentActivity: []
    });

    const isLoading = ref(false);
    const transactions = ref([]);
    const kycRequests = ref([]);

    // Fetch Admin Dashboard Stats
    async function fetchPlatformStats() {
        isLoading.value = true;
        try {
            const response = await axios.get('/trade/admin/stats');
            const data = response.data;
            platformStats.totalUsers = data.totalUsers ?? 0;
            platformStats.newUsersToday = data.newUsersToday ?? 0;
            platformStats.totalDeposits = data.totalDeposits ?? 0;
            platformStats.totalWithdrawals = data.totalWithdrawals ?? 0;
            platformStats.pendingWithdrawals = data.pendingWithdrawals ?? 0;
            platformStats.pendingWithdrawalAmount = data.pendingWithdrawalAmount ?? 0;
            platformStats.pendingKyc = data.pendingKyc ?? 0;
            platformStats.totalTrades = data.totalTrades ?? 0;
            platformStats.winCount = data.winCount ?? 0;
            platformStats.lossCount = data.lossCount ?? 0;
            platformStats.revenue = data.revenue ?? 0;
            platformStats.recentActivity = data.recentActivity || [];
        } catch (error) {
            console.error('Failed to fetch admin stats:', error);
        } finally {
            isLoading.value = false;
        }
    }

    // Finance: Fetch transactions
    async function fetchTransactions() {
        try {
            const response = await axios.get('/admin/transactions');
            transactions.value = response.data;
        } catch (error) {
            console.error('Failed to fetch transactions:', error);
        }
    }

    // Finance: Update transaction status (approve/reject)
    async function updateTransactionStatus(id, newStatus) {
        try {
            await axios.put(`/admin/transactions/${id}/status`, { status: newStatus });
            // Update local state
            const tx = transactions.value.find(t => t.id === id);
            if (tx) tx.status = newStatus;
        } catch (error) {
            console.error('Failed to update transaction:', error);
        }
    }

    // KYC: Fetch requests
    async function fetchKycRequests() {
        try {
            const response = await axios.get('/admin/kyc');
            kycRequests.value = response.data;
        } catch (error) {
            console.error('Failed to fetch KYC requests:', error);
        }
    }

    // KYC: Add a single new request (from socket)
    function addKycRequest(kyc) {
        if (!kycRequests.value.find(k => k.id === kyc.id)) {
            kycRequests.value.unshift(kyc);
        }
    }

    // KYC: Update status (approve/reject)
    async function updateKYCStatus(id, newStatus) {
        try {
            // Map frontend status to backend expected value
            const apiStatus = newStatus === 'verified' ? 'approved' : newStatus;
            await axios.put(`/admin/kyc/${id}/status`, { status: apiStatus });
            // Update local state
            const req = kycRequests.value.find(k => k.id === id);
            if (req) req.status = newStatus;
        } catch (error) {
            console.error('Failed to update KYC:', error);
        }
    }

    return {
        platformStats,
        isLoading,
        transactions,
        kycRequests,
        fetchPlatformStats,
        fetchTransactions,
        updateTransactionStatus,
        fetchKycRequests,
        updateKYCStatus,
        addKycRequest
    };
});
