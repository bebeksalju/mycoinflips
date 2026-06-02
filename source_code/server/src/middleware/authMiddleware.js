const jwt = require('jsonwebtoken');

const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.sendStatus(401);

    jwt.verify(token, process.env.JWT_SECRET, async (err, decoded) => {
        if (err) return res.sendStatus(403);
        req.user = decoded;

        try {
            const prisma = require('../db');
            const user = await prisma.user.findUnique({
                where: { id: decoded.userId },
                select: { status: true, tokenVersion: true }
            });

            // Check if user is banned
            if (user?.status === 'banned') {
                return res.status(403).json({
                    error: 'Account suspended',
                    banned: true
                });
            }

            // Check tokenVersion — if the DB version is higher than the JWT's version,
            // the session was revoked via the CLI tool. Reject immediately.
            const dbVersion = user?.tokenVersion ?? 0;
            const jwtVersion = decoded.tokenVersion ?? 0;
            if (dbVersion > jwtVersion) {
                return res.status(401).json({ error: 'Session revoked. Please log in again.' });
            }
        } catch (dbError) {
            // DB error should NOT block the request - just log and continue
            console.error('Auth check failed (non-critical):', dbError.message);
        }

        next();
    });
};

module.exports = { authenticateToken };
