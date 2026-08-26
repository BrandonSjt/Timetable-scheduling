import * as fs from 'fs';
import * as path from 'path';

export interface ParsedSchedule {
  trainNumber: string;
  route: string;
  stationCode: string;
  arrivalTime: string;
  departureTime: string;
}

export function parseRawSchedule(filePath: string): ParsedSchedule[] {
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n').map(l => l.trim()).filter(l => l.length > 0);

  let currentHeader: string[] = [];
  const results: ParsedSchedule[] = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // If line doesn't start with a number, it might be a header or garbage
    if (!/^\d/.test(line)) {
      // Very basic heuristic for header: split by space, if they look like station codes (all uppercase or mostly caps)
      const parts = line.split(/\s+/);
      if (parts.length > 2 && parts.every(p => /^[A-Z]{2,4}$/.test(p) || p === 'KETERANGAN' || p === 'NO' || p === 'LOOP' || p === 'NOMOR' || p === 'KA' || p === 'RELASI' || p === 'STASIUN')) {
        // It's a header line, extract station codes
        currentHeader = parts.filter(p => /^[A-Z]{2,4}$/.test(p) && p !== 'NO' && p !== 'LOOP' && p !== 'KA');
        continue;
      }
    } else {
      // Data line: e.g. "1 46 5000 Bks-Ckr 04:12 04:14 04:21 ..."
      // Format: NO LOOP NOMOR_KA RELASI [Times...]
      const parts = line.split(/\s+/);
      if (parts.length < 4) continue; // too short

      const trainNumber = parts[2];
      const route = parts[3];

      let timeIndex = 4;
      for (let h = 0; h < currentHeader.length; h++) {
        if (timeIndex >= parts.length) break;

        const timeStr = parts[timeIndex];
        // Valid time formats: 04:12, Ls (Langsung), or it might be missing if OCR merged it
        if (/^\d{2}:\d{2}$/.test(timeStr)) {
          results.push({
            trainNumber,
            route,
            stationCode: currentHeader[h],
            arrivalTime: timeStr,
            departureTime: timeStr, // simplified
          });
          timeIndex++;
        } else if (timeStr === 'Ls' || timeStr === '-') {
          timeIndex++;
        } else if (timeStr.includes('Batal') || timeStr.includes('Racket')) {
          // It's a KETERANGAN note
          break;
        } else {
           // Might be a weird OCR glitch, just skip
        }
      }
    }
  }

  return results;
}
