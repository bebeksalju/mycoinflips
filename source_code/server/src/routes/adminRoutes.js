const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { authenticateToken } = require('../middleware/authMiddleware');
const { requireAdmin } = require('../middleware/roleMiddleware');
const { auditLogger } = require('../middleware/auditLogger');

// All routes require authentication
router.use(authenticateToken);

// Public endpoints (requires auth, but not admin)
router.get('/wallets/public', adminController.getPublicWallets);
router.get('/durations/public', adminController.getPublicDurations);

// The rest requires Admin/Superuser role
router.use(requireAdmin);
router.use(auditLogger);

// User Management
router.get('/users', adminController.getUsers);
router.put('/users/:id/balance', adminController.updateUserBalance);
router.put('/users/:id/password', adminController.updateUserPassword);
router.put('/users/:id/profit-mode', adminController.updateUserProfitMode);
router.put('/users/:id/ban', adminController.toggleUserBan);
router.delete('/users/:id', adminController.deleteUser);

// Finance (Transactions)
router.get('/transactions', adminController.getTransactions);
router.put('/transactions/:id/status', adminController.updateTransactionStatus);

// KYC
router.get('/kyc', adminController.getKycRequests);
router.put('/kyc/:id/status', adminController.updateKycStatus);

// Admin Profile
router.put('/password', adminController.changePassword);

// Admin Management
router.get('/admins', adminController.getAdmins);
router.post('/admins', adminController.createAdmin);
router.delete('/admins/:id', adminController.deleteAdmin);

// Admin Wallet (deposit addresses)
router.get('/wallets', adminController.getWallets);
router.put('/wallets', adminController.updateWallets);

// Trading Durations
router.get('/durations', adminController.getDurations);
router.post('/durations', adminController.addDuration);
router.delete('/durations/:id', adminController.deleteDuration);

// Session Management (SUPERUSER ONLY)
router.get('/sessions', adminController.getSessions);
router.delete('/sessions/user/:userId', adminController.deleteUserSessions);
router.delete('/sessions/:id', adminController.deleteSession);

// User Activity (all transaction types)
router.get('/user-activity', adminController.getAllUserActivity);

// Audit Logs
router.get('/audit-logs', adminController.getAuditLogs);

module.exports = router;

