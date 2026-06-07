const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const prisma = require('../db');
const { authenticateToken } = require('../middleware/authMiddleware');
const socketEmitter = require('../socketEmitter');

const register = async (req, res) => {
  try {
    const { email, password, name } = req.body;

    // Check if user exists
    const existingUser = await prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Store password as plaintext (User Request: "biarain ga secure gapapa")
    const hashedPassword = password;

    // Create user and wallet
    const user = await prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        name,
        wallet: {
          create: {
            balance: 0.0,
          },
        },
      },
      include: {
        wallet: true,
      },
    });

    // Generate token
    const token = jwt.sign({ userId: user.id, email: user.email, role: user.role }, process.env.JWT_SECRET, {
      expiresIn: '24h',
    });

    res.status(201).json({ user, token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Something went wrong' });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await prisma.user.findUnique({
      where: { email },
      include: { kyc: true },
    });

    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    let validPassword = false;
    if (password === user.password) {
      validPassword = true;
    } else {
      // Fallback for older hashed passwords
      try {
        validPassword = await bcrypt.compare(password, user.password);
      } catch (e) {
        validPassword = false;
      }
    }

    if (!validPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check if user is banned
    if (user.status === 'banned') {
      return res.status(403).json({
        error: 'Your account has been suspended. Please contact customer support.',
        banned: true
      });
    }

    // --- SESSION LIMITS LOGIC ---
    // 1. Delete expired sessions for this user
    await prisma.session.deleteMany({
      where: {
        userId: user.id,
        expiresAt: { lt: new Date() }
      }
    });

    // 2. Count remaining active sessions
    const activeSessions = await prisma.session.count({
      where: { userId: user.id }
    });

    // 3. Enforce device limits based on role (excluding developer account admin@myflipcoin.com)
    if (user.email !== 'admin@myflipcoin.com') {
      if (user.role === 'SUPERUSER' && activeSessions >= 1) {
        return res.status(403).json({ error: 'Maximum sessions (1) reached. Please logout from other devices.' });
      }
      if (user.role === 'ADMIN' && activeSessions >= 3) {
        return res.status(403).json({ error: 'Maximum sessions (3) reached. Please logout from other devices.' });
      }
    }


    const token = jwt.sign(
      { userId: user.id, email: user.email, role: user.role, tokenVersion: user.tokenVersion ?? 0 },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    // 4. Save the new session to the Database
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24); // 24 hours from now

    await prisma.session.create({
      data: {
        userId: user.id,
        token: token,
        expiresAt: expiresAt
      }
    });

    res.json({ user, token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Something went wrong' });
  }
};

const logout = async (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
      await prisma.session.deleteMany({
        where: { token: token }
      });
    }

    res.json({ success: true, message: 'Logged out successfully' });
  } catch (error) {
    console.error('Logout Error:', error);
    res.status(500).json({ error: 'Failed to logout' });
  }
};

const submitKyc = async (req, res) => {
  try {
    const userId = req.user.userId;

    // Check if KYC already exists
    const existing = await prisma.kyc.findUnique({ where: { userId } });
    if (existing) {
      return res.status(400).json({ error: 'KYC already submitted' });
    }

    const frontFile = req.files?.front?.[0];
    const backFile = req.files?.back?.[0];

    const kyc = await prisma.kyc.create({
      data: {
        userId,
        status: 'PENDING',
        fullName: req.body.fullName || null,
        idNumber: req.body.idNumber || null,
        documentUrl: frontFile ? `/uploads/kyc/${frontFile.filename}` : null,
        documentUrlBack: backFile ? `/uploads/kyc/${backFile.filename}` : null,
      },
      include: { user: { select: { name: true, email: true } } }
    });

    const formattedKyc = {
        id: kyc.id,
        user: kyc.user.name || 'Unknown',
        email: kyc.user.email,
        status: kyc.status.toLowerCase(),
        date: kyc.createdAt,
        fullName: kyc.fullName,
        idNumber: kyc.idNumber,
        documentUrl: kyc.documentUrl,
        documentUrlBack: kyc.documentUrlBack
    };

    socketEmitter.emitToAdmins('kyc:new-request', formattedKyc);

    res.status(201).json({ success: true, kyc });
  } catch (error) {
    console.error('KYC submit error:', error);
    res.status(500).json({ error: 'Something went wrong' });
  }
};

const me = async (req, res) => {
  try {
    const userId = req.user.userId;
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { kyc: true },
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Strip sensitive fields
    const { password, ...safeUser } = user;
    
    res.json({
        user: safeUser,
        kycStatus: safeUser.kyc?.status?.toLowerCase() || 'unverified'
    });
  } catch (error) {
    console.error('Auth me error:', error);
    res.status(500).json({ error: 'Something went wrong' });
  }
};

const changePassword = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({ error: 'Current and new password are required' });
    }
    if (newPassword.length < 8) {
      return res.status(400).json({ error: 'New password must be at least 8 characters' });
    }

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Verify current password (plaintext or bcrypt fallback)
    let valid = currentPassword === user.password;
    if (!valid) {
      try { valid = await bcrypt.compare(currentPassword, user.password); } catch (e) { valid = false; }
    }
    if (!valid) {
      return res.status(401).json({ error: 'Current password is incorrect' });
    }

    // Save new password as plaintext (consistent with system)
    await prisma.user.update({
      where: { id: userId },
      data: { password: newPassword }
    });

    // Invalidate all other sessions
    const authHeader = req.headers['authorization'];
    const currentToken = authHeader && authHeader.split(' ')[1];
    await prisma.session.deleteMany({
      where: { userId, NOT: { token: currentToken } }
    });

    res.json({ success: true, message: 'Password changed successfully' });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({ error: 'Something went wrong' });
  }
};

module.exports = { register, login, logout, submitKyc, me, changePassword };

