const requireAdmin = (req, res, next) => {
    // Check if the user is authenticated and has a role
    if (!req.user || !req.user.role) {
        return res.status(403).json({ error: 'Access denied: Authentication required' });
    }

    // Check if the role is ADMIN or SUPERUSER
    if (req.user.role !== 'ADMIN' && req.user.role !== 'SUPERUSER') {
        return res.status(403).json({ error: 'Access denied: Admin privileges required' });
    }

    // Role is valid, proceed to the next middleware or route handler
    next();
};

module.exports = { requireAdmin };
