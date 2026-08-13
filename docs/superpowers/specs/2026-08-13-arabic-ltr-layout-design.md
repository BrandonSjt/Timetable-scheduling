# Arabic Translation with a Stable LTR Layout

## Goal

Keep Arabic translations active without mirroring the application's layout. Buttons, navigation bars, icons, component order, and directional spacing must remain in the same positions used by Indonesian, English, and Simplified Chinese.

## Scope

The change applies globally when `AppLocale.arabic` is active. It changes presentation direction only. It does not change translation catalogs, locale persistence, routing, data models, or backend behavior.

## Design

`MaterialApp.router` continues to receive the Arabic locale so Flutter loads the Arabic localization catalog and locale-aware services. Its application subtree receives an explicit `Directionality` with `TextDirection.ltr`. This override prevents Flutter's Arabic locale delegate from mirroring directional widgets and geometry.

The override belongs at the application boundary rather than individual pages. This keeps all current and future screens consistent and avoids page-specific exceptions. Arabic strings remain Arabic. Unicode bidirectional processing continues to shape and order each Arabic character run from right to left, while widget geometry and paragraph placement use the application's fixed LTR direction.

## Expected Behavior

- Selecting Arabic still loads Arabic labels and messages.
- Arabic character runs remain readable from right to left.
- Bottom navigation items keep their existing order and positions.
- Back buttons and other directional icons keep their LTR orientation.
- Rows, alignment, directional padding, drawers, and transitions do not mirror.
- Indonesian, English, and Simplified Chinese behavior does not change.

## Testing

Update the existing Arabic locale widget test to expect `TextDirection.ltr` on both the language page and the home page. Assert that the LTR back icon remains visible. Keep the existing checks that Arabic translations load and locale persistence errors remain localized.

Run the focused locale tests, the full Flutter test suite, and static analysis. Finally, install the debug build on the Pixel 9 emulator and inspect the Arabic language page and main navigation.

## Non-goals

- Adding a user-selectable RTL/LTR preference.
- Rewriting individual widgets or translation strings.
- Changing station names, transport line names, or numeric formatting.
- Modifying backend services or API payloads.
