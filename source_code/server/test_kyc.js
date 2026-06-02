const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const kycs = await prisma.kyc.findMany({
    include: { user: { select: { name: true, email: true } } }
  });
  console.log('All KYCs:');
  console.log(JSON.stringify(kycs, null, 2));

  // Simulating adminController logic:
  try {
    const result = kycs.map(k => ({
        id: k.id,
        user: k.user?.name || 'Unknown',
        email: k.user?.email,
        status: k.status.toLowerCase(),
        date: k.createdAt,
        fullName: k.fullName,
        idNumber: k.idNumber,
        documentUrl: k.documentUrl,
        documentUrlBack: k.documentUrlBack
    }));
    console.log('\nAdmin Controller Mapped Result:');
    console.log(JSON.stringify(result, null, 2));
  } catch (err) {
    console.error('Error during mapping:', err);
  }
}

main()
  .catch(e => console.error(e))
  .finally(() => prisma.$disconnect());
