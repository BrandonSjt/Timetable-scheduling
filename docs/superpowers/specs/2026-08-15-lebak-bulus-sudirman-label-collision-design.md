# Lebak Bulus and Sudirman Label Collision Design

## Goal

Remove the two reported station-label collisions after station names increased to 16 px bold, without changing schematic geometry or global typography.

## Root Cause

- `Lebak Bulus Bank Syariah Indonesia` is forced to the left of its node. At 16 px bold, the long label reaches the nearby MRT route-identity badge `M`.
- `Sudirman` is forced above its node. Centering the larger label there places part of the text across the adjacent vertical Cikarang route segment.
- Existing collision checks cover station nodes, station-code badges, and previously placed labels. They do not treat route segments or route-identity badges as occupied rectangles.

## Placement Change

- Change `lebak_bulus` preferred label position from `LabelPos.left` to `LabelPos.top`.
- Change `sudirman` preferred label position from `LabelPos.top` to `LabelPos.right`.
- Station-code badges continue using the existing opposite-side placement rule, so they automatically move with each label direction.
- Keep existing collision fallback logic active.

## Preserved Design

- All station labels remain 16 px and `FontWeight.w700`.
- Label offsets, node sizes, line widths, station coordinates, waypoints, route shapes, canvas size, walking connections, and initial zoom remain unchanged.
- No generalized line-collision engine is added because it could move unrelated labels and alter the established map composition.

## Validation

- Add a contract test for the preferred positions of `lebak_bulus` and `sudirman`.
- Keep the schematic geometry fingerprint `721664269` unchanged.
- Run formatter, focused map tests, `flutter analyze`, and the complete Flutter test suite.
- Rebuild and verify the debug APK.
