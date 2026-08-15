# Uniform Bold Station Labels Design

## Goal

Make every station name easier to read and remove the unexplained typography difference between regular and transit stations.

## Typography

- Every station label uses 16 px and `FontWeight.w700`.
- Transit status no longer changes station label size or weight.
- Names inside major and merged station hubs increase from 12 px to 14 px and retain their existing heavy weight.
- The white label outline increases from 3 px to 3.5 px to keep bold text legible over route lines.
- Selected and route-origin stations keep their existing color treatment; font weight stays consistent with other station labels.

## Spacing

- Regular label offset increases from 24 px to 32 px.
- Transit label offset increases from 30 px to 40 px because transit nodes remain physically larger.
- Existing collision placement logic remains active.

## Preserved Map Design

- Transit nodes remain visually different from regular nodes.
- Node sizes and route line widths remain unchanged.
- Every station and waypoint position remains unchanged.
- Station order, route geometry, canvas size, walking connections, merged station pairs, and initial zoom remain unchanged.

## Validation

- Update contract tests for uniform label size and weight, hub size, outline width, and offsets.
- Keep the existing geometry fingerprint unchanged.
- Run formatter, focused tests, `flutter analyze`, and the complete Flutter test suite.
- Rebuild the debug APK after verification.
