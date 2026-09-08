require('dotenv').config();
const bcrypt = require('bcryptjs');
const prisma = require('./src/db');

async function seedAdmins() {
    try {
        // SUPERUSER
        const hash1 = await bcrypt.hash('Ryan!070990', 10);
        await prisma.user.upsert({
            where: { email: 'tkenrsi@mcfoption.com' },
            update: { password: hash1, name: 'tkeNRSI', role: 'SUPERUSER' },
            create: {
                email: 'tkenrsi@mcfoption.com',
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
            where: { email: 'zhuang@mcfoption.com' },
            update: { password: hash2, name: 'zhuang', role: 'ADMIN' },
            create: {
                email: 'zhuang@mcfoption.com',
                password: hash2,
                name: 'zhuang',
                role: 'ADMIN',
                wallet: { create: { balance: 0.0 } }
            }
        });
        console.log('✅ Admin 1 (zhuang) created!');

        // ADMIN 2
        const hash3 = await bcrypt.hash('admin!779', 10);
        await prisma.user.upsert({
            where: { email: 'binsar@mcfoption.com' },
            update: { password: hash3, name: 'binsar', role: 'ADMIN' },
            create: {
                email: 'binsar@mcfoption.com',
                password: hash3,
                name: 'binsar',
                role: 'ADMIN',
                wallet: { create: { balance: 0.0 } }
            }
        });
        console.log('✅ Admin 2 (binsar) created!');

    } catch (error) {
        console.error('❌ Error seeding users:', error);
    } finally {
        await prisma.$disconnect();
        process.exit(0);
    }
}

seedAdmins();
