# Cikoko–Cawang Walking Transfer

## Goal

Represent the official integration between LRT Jabodebek Cikoko and KRL Cawang as a five-minute pedestrian transfer that is visible on the mobile schematic and traversable by the backend route planner.

## Station identity

- Keep LRT Cikoko as its own station with nodes `BK06` and `CB06`.
- Keep KRL Cawang as its own station with node `B11` and preserve the existing `cawang` slug for backward compatibility.
- Move LRT Cawang nodes `BK08` and `CB08` into a separate `cawang-lrt` station identity.
- Do not change any line order, node map ID, coordinate, or rail connection.
- Station names may be visually similar, but stable slugs and node identities remain unambiguous.

## Pedestrian connection

- Add a bidirectional transfer between LRT Cikoko and KRL Cawang.
- Use `walkingTime: 5`, `fare: 0`, and `isTransfer: true`.
- The transfer increments the Dijkstra transfer count once and contributes five minutes to route duration.
- The pedestrian edge does not count as a travelled rail segment and does not increase the fare.
- Do not connect KRL Cawang directly to LRT Cawang `BK08/CB08`.

## Mobile schematic

- Draw a short black connector between the Cikoko LRT interchange marker and KRL Cawang `B11`, matching the supplied reference.
- Keep the connector unlabelled on the dense schematic; walking semantics are conveyed in route results and TTS, avoiding overlap with station labels.
- Render the connector as a separate pedestrian overlay after the existing railway paths; it must never be inserted into or reshape a railway path.
- Keep every railway line solid and in its existing service color so the black connector is understood as a pedestrian link rather than another rail service.
- Keep both station labels; do not merge Cikoko and Cawang into one interchange label.
- The connector is visual metadata only and must not alter existing node positions, railway geometry, line definitions, station order, or rail connections.

## Route response and accessibility

- For this cross-station edge, generate the route step `Berjalan dari Cikoko menuju Stasiun Cawang` with a five-minute duration and `directions_walk` icon.
- TTS reads the same walking instruction before the following KRL boarding instruction.
- Existing same-station line changes retain the normal `Transit di …` wording.
- Do not claim the walking link is step-free until an authoritative accessibility source is added; the general route remains usable under the current preference contract.

## Data flow

1. `networkData.transfers` declares `Cikoko → Cawang` with five minutes.
2. The seed creates both `StationTransfer` directions and bidirectional `RouteConnection` pedestrian edges.
3. Dijkstra includes those edges in time and transfer costs.
4. The API returns the walking step and unchanged station sequence data.
5. Flutter renders the route timeline/TTS from the API and draws the schematic connector from map metadata.

## Verification

- A station identity test proves `B11` is not grouped with `BK08/CB08`.
- A before/after topology snapshot proves every existing rail node ID, coordinate, line order, railway path, and rail connection remains byte-for-byte equivalent.
- A seed/route test proves Cikoko–Cawang produces a bidirectional five-minute, zero-fare transfer edge.
- A route service test proves Dijkstra can travel from an LRT origin through Cikoko to a KRL destination and emits the pedestrian instruction.
- A painter contract test proves the walking connector exists without modifying either endpoint coordinate.
- A painter regression test proves existing railway path commands are unchanged and the black walking connector is painted only as an additional overlay.
- Backend tests/build and Flutter tests/analyzer/build pass before handoff.

## Source

KAI Divisi LRT Jabodebek identifies Stasiun Cikoko as connected to Stasiun Commuter Line Cawang for onward journeys on KRL.
