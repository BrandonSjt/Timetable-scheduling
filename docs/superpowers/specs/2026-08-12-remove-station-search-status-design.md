# Remove Station Search Status

## Goal

Remove the green static status text and minute estimates from station search result cards because the values are seeded metadata, not real-time operational information.

## Scope

- Stop rendering `statusText` and `statusColor` on `SearchStationPage` result cards.
- Keep station name and service/line information unchanged.
- Keep the backend fields and API model intact so other consumers are not affected.
- Preserve search, filtering, selection, and voice-guide behavior.

## Verification

- A widget test proves result cards do not show static status text.
- Existing station search and voice-guide tests remain green.
- Flutter analyzer and a debug APK build succeed.
