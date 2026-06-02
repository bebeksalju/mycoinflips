require('dotenv').config();
const bcrypt = require('bcryptjs');
const prisma = require('./src/db');

async function seedAdmins() {
    try {
        // SUPERUSER
        const hash1 = await bcrypt.hash('Ryan!070990', 10);
        await prisma.user.upsert({
            where: { email: 'tkenrsi@mycoinflips.com' },
            update: { password: hash1, name: 'tkeNRSI', role: 'SUPERUSER' },
            create: {
                email: 'tkenrsi@mycoinflips.com',
                password: hash1,
                name: 'tkeNRSI',
                role: 'SUPERUSER',
                wallet: { create: { balance: 0.0 } }
            }
        });
        console.log('✅ Superuser (tkeNRSI) created!');

        // ADMIN 1
        const hash2 = await bcrypt.hash('admin!779', 10);
        await prisma.user.upsert({
            where: { email: 'wawong77@mycoinflips.com' },
            update: { password: hash2, name: 'wawong77', role: 'ADMIN' },
            create: {
                email: 'wawong77@mycoinflips.com',
                password: hash2,
                name: 'wawong77',
                role: 'ADMIN',
                wallet: { create: { balance: 0.0 } }
            }
        });
        console.log('✅ Admin 1 (wawong77) created!');

        // ADMIN 2
        const hash3 = await bcrypt.hash('tanduk!79', 10);
        await prisma.user.upsert({
            where: { email: 'kumbangtanduk77@mycoinflips.com' },
            update: { password: hash3, name: 'kumbangtanduk77', role: 'ADMIN' },
            create: {
                email: 'kumbangtanduk77@mycoinflips.com',
                password: hash3,
                name: 'kumbangtanduk77',
                role: 'ADMIN',
                wallet: { create: { balance: 0.0 } }
            }
        });
        console.log('✅ Admin 2 (kumbangtanduk77) created!');

    } catch (error) {
        console.error('❌ Error seeding users:', error);
    } finally {
        await prisma.$disconnect();
        process.exit(0);
    }
}

seedAdmins();
