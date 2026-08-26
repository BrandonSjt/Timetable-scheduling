const fs = require('fs');
const path = require('path');

const transcriptPath = 'C:\\Users\\riyadh\\.gemini\\antigravity-ide\\brain\\5866d39f-9f27-4080-9fdc-bdd5e109df28\\.system_generated\\logs\\transcript_full.jsonl';
const outPath = 'C:\\Users\\riyadh\\Downloads\\timetable_backend\\prisma\\data\\raw_schedule.txt';

if (!fs.existsSync(path.dirname(outPath))) {
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
}

const content = fs.readFileSync(transcriptPath, 'utf-8');
const lines = content.split('\n');

let extracted = [];

for (const line of lines) {
  if (!line) continue;
  try {
    const json = JSON.parse(line);
    if (json.type === 'USER_INPUT' && json.content) {
      let text = typeof json.content === 'string' ? json.content : JSON.stringify(json.content);
      const sublines = text.split(/\\n|\n/);
      let isOcr = false;
      for (const sl of sublines) {
        if (sl.includes('==Start of OCR')) { isOcr = true; continue; }
        if (sl.includes('==End of OCR')) { isOcr = false; continue; }
        if (isOcr && !sl.includes('==Screenshot')) {
          extracted.push(sl.replace(/\\"/g, '"').replace(/\\\\/g, '\\').trim());
        }
      }
    }
  } catch (e) {
  }
}

fs.writeFileSync(outPath, extracted.join('\n'));
console.log('Extracted ' + extracted.length + ' lines of OCR to ' + outPath);
