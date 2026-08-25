const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const prisma = require('../db');
const { sendPasswordResetEmail } = require('../services/emailService');

const RESET_TOKEN_TTL = '15m';
const FRONTEND_URL = process.env.FRONTEND_URL || 'https://mcfoption.com';

const forgotPassword = async (req, res) => {
  try {
    const email = String(req.body?.email || '').trim().toLowerCase();
    if (!email) return res.status(400).json({ error: 'Email is required' });

    const genericResponse = {
      success: true,
      message: 'If that email is registered, a password reset link has been sent.'
    };

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) return res.json(genericResponse);

    const token = jwt.sign(
      {
        purpose: 'password-reset',
        userId: user.id,
        email: user.email,
        tokenVersion: user.tokenVersion ?? 0
      },
      process.env.JWT_SECRET,
      { expiresIn: RESET_TOKEN_TTL }
    );

    const resetUrl = `${FRONTEND_URL.replace(/\/$/, '')}/reset-password?token=${encodeURIComponent(token)}`;

    await sendPasswordResetEmail({
      to: user.email,
      name: user.name,
      resetUrl
    });

    return res.json(genericResponse);
  } catch (error) {
    console.error('Forgot password error:', error.message);
    return res.status(500).json({ error: 'Unable to process password reset request' });
  }
};

const resetPassword = async (req, res) => {
  try {
    const token = String(req.body?.token || '');
    const newPassword = String(req.body?.newPassword || '');

    if (!token || !newPassword) {
      return res.status(400).json({ error: 'Reset token and new password are required' });
    }
    if (newPassword.length < 8) {
      return res.status(400).json({ error: 'Password must be at least 8 characters' });
    }

    let payload;
    try {
      payload = jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      return res.status(400).json({ error: 'Reset link is invalid or has expired' });
    }

    if (payload.purpose !== 'password-reset' || !payload.userId) {
      return res.status(400).json({ error: 'Invalid reset token' });
    }

    const user = await prisma.user.findUnique({ where: { id: payload.userId } });
    if (!user || user.email !== payload.email || (user.tokenVersion ?? 0) !== (payload.tokenVersion ?? 0)) {
      return res.status(400).json({ error: 'Reset link is no longer valid' });
    }

    const salt = await bcrypt.genSalt(12);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    await prisma.$transaction([
      prisma.user.update({
        where: { id: user.id },
        data: {
          password: hashedPassword,
          tokenVersion: { increment: 1 }
        }
      }),
      prisma.session.deleteMany({ where: { userId: user.id } })
    ]);

    return res.json({ success: true, message: 'Password has been reset successfully' });
  } catch (error) {
    console.error('Reset password error:', error);
    return res.status(500).json({ error: 'Unable to reset password' });
  }
};

module.exports = { forgotPassword, resetPassword };
