export const stationDisplayName = (station: {
  name: string;
  officialName?: string | null;
}) => station.officialName?.trim() || station.name;

export const publicCodeForLine = (
  station: { publicCodes: Array<{ lineId: string; code: string }> },
  lineId: string,
) => station.publicCodes.find((item) => item.lineId === lineId)?.code ?? null;
