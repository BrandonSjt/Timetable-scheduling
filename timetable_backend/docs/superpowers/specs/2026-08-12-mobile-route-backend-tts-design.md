# Mobile Route Backend and Native TTS Design

## Scope

Connect the existing Flutter route-result flow to the backend route graph. Preserve the current mobile appearance while replacing all route-result dummy calculations with backend data. Add native text-to-speech guidance for the accessibility mode. Ticket and payment integration are outside this scope.

## User Flow

1. The user selects origin and destination stations from the backend station catalog.
2. Mobile passes stable station slugs to the route-result page; station names remain display labels.
3. The route-result page requests `POST /api/v1/routes/plan`.
4. The backend resolves the stations and runs Dijkstra on the existing mobile-aligned node topology.
5. Mobile renders travel time, fare, stop count, service lines, transfer steps, station sequence, and destination information from the response.
6. The existing ticket button continues receiving the route summary but ticket/payment behavior is not changed in this phase.

## Route Modes

### Fastest

Dijkstra minimizes total route weight in minutes. This is the initial and default mode.

### Minimum Transfers

The route algorithm minimizes transfer edges first and travel time second. Mobile sends a route preference to the same endpoint. The response contract remains identical to the fastest mode.

### Accessible

Accessible mode is not a separate graph algorithm. It uses the fastest route and activates project-owned native text-to-speech controls through a Flutter platform channel. The visible route remains fully available for screen readers.

TTS narration includes:

- origin and destination;
- estimated travel time and fare;
- line used at departure;
- transfer station and destination line;
- ordered journey steps;
- arrival at destination.

Controls: speak, repeat, pause, and stop. Android implements pause as a safe stop because `TextToSpeech` has no native pause API; pressing speak or repeat starts narration again. Speech stops when the page is disposed. Language follows the application locale.

## Native TTS Boundary

- Dart owns narration text, accessibility state, and the `RouteSpeechService` interface.
- `NativeRouteSpeechService` calls the `kai_access/native_tts` method channel.
- Android `MainActivity` owns one `android.speech.tts.TextToSpeech` instance and implements `speak`, `pause`, and `stop`.
- Native initialization is asynchronous. A speech request received before initialization is queued once; initialization failure is returned as a platform error.
- A pending Dart `speak` future completes on native `onDone`, `onError`, or cancellation, so the UI speaking state remains accurate.
- `TextToSpeech.stop()` and `shutdown()` run when the activity is destroyed.
- Unsupported platforms return a controlled no-op until an equivalent native bridge is added; no third-party TTS plugin is reintroduced.

The `flutter_tts` dependency is removed. This avoids carrying a plugin that applies a legacy Kotlin Gradle Plugin inside an AGP 9 build.

## Android Toolchain

The project retains its original modern Android toolchain:

- Gradle `9.1.0`;
- Android Gradle Plugin `9.0.1`;
- Kotlin `2.3.20`;
- Flutter `3.44.x` and Android API 36.

The app migrates to AGP 9 built-in Kotlin where required instead of downgrading the project toolchain. The route API remains available at `http://10.0.2.2:3000/api/v1` for Android emulator debug builds.

## Mobile Architecture

The feature follows the existing layered Flutter structure:

- domain entities describe route plans, steps, station sequence, and line metadata;
- a repository interface exposes route planning;
- the remote data source performs the HTTP request and parses the API envelope;
- the repository implementation maps API models to domain entities;
- `RouteController` owns loading, success, error, selected route mode, and TTS state;
- `NativeRouteSpeechService` isolates the Flutter platform-channel boundary;
- `RouteResultPage` only renders controller state and sends user actions.

The existing inline `_calculateRoute` dummy engine is removed from runtime use.

## Backend Contract

`POST /api/v1/routes/plan`

Request:

```json
{
  "from": "bogor",
  "to": "tangerang",
  "passengerCount": 1,
  "preference": "FASTEST"
}
```

`preference` accepts `FASTEST` and `MIN_TRANSFERS`. Omitting it remains backward compatible and means `FASTEST`.

The response continues using `{ "success": true, "data": ... }`. Existing route fields remain stable. The backend adds explicit transfer count and preference metadata where useful without removing current fields.

## Errors and Recovery

Connection failure, timeout, HTTP failure, invalid response, and backend route errors use one mobile message:

> Tidak dapat memuat rute. Periksa koneksi dan coba lagi.

The page offers a `Coba Lagi` action. It does not generate or display a dummy route. Same-origin input is prevented in station selection and remains validated by the backend.

## Compatibility

- Node identities, coordinates, connections, directions, and line shapes remain unchanged.
- Human-readable station names may continue in URLs during transition, but new navigation passes station slugs.
- Existing backend callers that do not send `preference` retain fastest-route behavior.
- The current visual layout is retained; only loading, error/retry, and accessible narration controls are added.

## Verification

Backend tests cover fastest routing, minimum-transfer tie-breaking, invalid preference, connected routes, and disconnected routes. Flutter tests cover JSON mapping, repository request payloads, controller states, retry behavior, filter changes, TTS narration construction, method-channel calls, and page loading/error/success rendering. Android verification builds with Gradle 9.1.0, installs on the emulator, confirms selection-to-result navigation, and verifies Indonesian TTS initialization and utterance dispatch in device logs.
