// Singleton that holds the Socket.IO instance so any module can emit events
let _io = null;

module.exports = {
    init(io) {
        _io = io;
    },
    emitToAdmins(event, data) {
        if (_io) {
            _io.of('/chat').to('admin').emit(event, data);
        }
    },
    emitToUser(userId, event, data) {
        if (_io) {
            _io.of('/chat').to(`user:${userId}`).emit(event, data);
        }
    }
};
