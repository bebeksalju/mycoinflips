const express = require('express');
const router = express.Router();
const tradeController = require('../controllers/tradeController');
const { authenticateToken } = require('../middleware/authMiddleware');
const prisma = require('../db');

router.post('/', authenticateToken, tradeController.executeTrade);
router.post('/open', authenticateToken, tradeController.openGame);
router.post('/settle', authenticateToken, tradeController.settleGame);
router.get('/stats', authenticateToken, tradeController.getStats);
router.get('/admin/stats', authenticateToken, tradeController.getAdminStats);

// Public endpoint for user trade form — fetch available durations with percentages
router.get('/durations', authenticateToken, async (req, res) => {
    try {
        const durations = await prisma.tradingDuration.findMany({
            select: { seconds: true, percentage: true, minBalance: true },
            orderBy: { seconds: 'asc' }
        });
        res.json(durations);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
