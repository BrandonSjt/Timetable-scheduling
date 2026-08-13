import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const updates = [
    { name: 'Kampung Bandan', nodeCode: 'C07, TP02' },
    { name: 'Kp. Bandan', nodeCode: 'C07, TP02' },
    { name: 'Manggarai', nodeCode: 'B09, C13' },
    { name: 'Dukuh Atas LRT', nodeCode: 'BK01, CB01' },
    { name: 'Setiabudi LRT', nodeCode: 'BK02, CB02' },
    { name: 'Rasuna Said', nodeCode: 'BK03, CB03' },
    { name: 'Kuningan', nodeCode: 'BK04, CB04' },
    { name: 'Pancoran', nodeCode: 'BK05, CB05' },
    { name: 'Cikoko', nodeCode: 'BK06, CB06' },
    { name: 'Ciliwung', nodeCode: 'BK07, CB07' },
    { name: 'Cawang', nodeCode: 'BK08, CB08' },
  ];

  for (const update of updates) {
    await prisma.station.updateMany({
      where: { name: update.name },
      data: { nodeCode: update.nodeCode }
    });
    console.log(`Updated ${update.name} -> ${update.nodeCode}`);
  }
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
