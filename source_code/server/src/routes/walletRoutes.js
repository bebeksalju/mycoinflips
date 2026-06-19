const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { getBalance, deposit, withdraw, getTransactions } = require('../controllers/walletController');
const { authenticateToken } = require('../middleware/authMiddleware');

const router = express.Router();

// Multer config for proof uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadPath = path.join(__dirname, '../../uploads/proofs');
        if (!fs.existsSync(uploadPath)) {
            fs.mkdirSync(uploadPath, { recursive: true });
        }
        cb(null, uploadPath);
    },
    filename: (req, file, cb) => {
        const ext = path.extname(file.originalname);
        cb(null, `proof-${Date.now()}-${Math.random().toString(36).slice(2)}${ext}`);
    }
});
const fileFilter = (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/jpg', 'application/pdf'];
    if (allowedTypes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error('Invalid file type. Only JPEG, PNG and PDF are allowed.'), false);
    }
};

const upload = multer({ storage, fileFilter, limits: { fileSize: 5 * 1024 * 1024 } });

router.use(authenticateToken);

router.get('/', getBalance);
router.post('/deposit', upload.single('proof'), deposit);
router.post('/withdraw', withdraw);
router.get('/transactions', getTransactions);

module.exports = router;
