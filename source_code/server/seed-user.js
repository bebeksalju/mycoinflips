require('dotenv').config();
const bcrypt = require('bcryptjs');
const prisma = require('./src/db');

async function seedUser() {
    try {
        const hash = await bcrypt.hash('user123', 10);
        const user = await prisma.user.create({
            data: {
                email: 'user@myflipcoin.com',
                password: hash,
                name: 'Test User',
                role: 'USER',
                status: 'active'
            }
        });
        await prisma.wallet.create({ data: { userId: user.id, balance: 1000 } });
        console.log('✅ Regular user created!');
        console.log(`   Email: user@myflipcoin.com`);
        console.log(`   Password: user123`);
        console.log(`   Role: USER`);
    } catch (error) {
        if (error.code === 'P2002') {
            console.log('⚠️  User already exists!');
        } else {
            console.error('❌ Error:', error.message);
        }
    } finally {
        await prisma.$disconnect();
        process.exit(0);
    }
}

seedUser();
