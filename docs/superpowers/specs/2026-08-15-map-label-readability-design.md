# Map Label Readability Design

## Goal

Make station names, nodes, and route lines easier to read on the schematic map while preserving the established topology and layout.

## Visual scale

- Regular station labels increase from 9 px to 12 px.
- Transit station labels increase from 10 px to 14 px.
- Names inside major and merged station hubs increase from 10 px to 12 px.
- The white text outline increases from 2.5 px to 3 px.
- KRL line width remains 8 px.
- MRT and LRT line widths increase from 6 px to 7 px.
- Regular coded MRT/LRT nodes increase from radius 10 to 12.
- Transit coded MRT/LRT nodes increase from radius 12 to 14.
- Existing KRL node sizes remain unchanged: regular 12 and transit 15.

## Collision handling

- Label distance from a regular node increases to match the larger font and node.
- Transit labels receive a larger offset than regular labels.
- The occupied-area calculation uses the actual rendered node radius instead of the previous fixed radius.
- Dense horizontal sections may alternate labels above and below the line.
- `Lebak Bulus` remains left of its node.
- `Fatmawati` moves above its node so its name no longer lies across the MRT segment.
- No station position is changed to solve a label collision.

## Geometry constraints

The following remain unchanged:

- `StationData.position` for every node and waypoint.
- Station order in every line.
- Map canvas width and height.
- Walking connections and merged station pairs.
- Initial map zoom and existing route shape.

## Validation

- Add tests for the new label, hub, node, and non-KRL line sizes.
- Keep the existing geometry fingerprint test passing.
- Render the affected MRT section and inspect it for label/node collisions.
- Run `flutter analyze`, the complete Flutter test suite, and rebuild the debug APK.
