import { execFileSync } from 'node:child_process';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { PrismaClient } = require('@prisma/client');

const run = (command, args) => execFileSync(command, args, { stdio: 'inherit' });

run('npx', ['prisma', 'migrate', 'deploy']);

const prisma = new PrismaClient();
let hasBundledTimetable;
try {
  hasBundledTimetable = await prisma.timetableDataset.findUnique({
    where: { version: '2026-02' },
    select: { id: true },
  });
} finally {
  await prisma.$disconnect();
}

if (hasBundledTimetable) {
  console.log('Bundled timetable is already present; skipping seed and import.');
} else {
  run('npx', ['prisma', 'db', 'seed']);
  run('npm', ['run', 'timetable:import', '--', 'prisma/data/commuter-2026-02.json']);
}
