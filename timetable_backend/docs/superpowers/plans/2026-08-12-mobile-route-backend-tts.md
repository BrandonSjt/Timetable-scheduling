# Mobile Route Backend and Native TTS Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Flutter route-result dummy calculator with real backend Dijkstra results, add minimum-transfer routing, and provide native text-to-speech guidance in accessible mode.

**Architecture:** The backend accepts a route preference and runs one lexicographic Dijkstra implementation over the unchanged mobile topology. Flutter uses domain entities, an HTTP data source, repository, `ChangeNotifier` controller, and an injected TTS service; the page renders loading/error/success states without calculating routes locally.

**Tech Stack:** Express 5, TypeScript, Zod, Prisma/PostgreSQL, Node test runner, Flutter/Dart, `http`, `flutter_tts`, Flutter test.

**Repository note:** This workspace has no `.git` directory, so commit steps are intentionally omitted. All CLI commands must run through `rtk`.

---

## File Structure

Backend:

- Modify `src/domain/services/routeService.ts`: route preference type and lexicographic Dijkstra cost.
- Modify `src/presentation/controllers/routeController.ts`: validate and forward `preference`.
- Modify `src/presentation/routes/routeRoutes.ts`: document the request preference.
- Modify `tests/routeService.test.ts`: fastest and minimum-transfer behavior.
- Create `tests/routeController.test.ts`: request validation and default preference.

Flutter:

- Modify `pubspec.yaml` and platform-generated dependency metadata: add native `flutter_tts`.
- Create `lib/features/route_result/domain/entities/route_plan.dart`: immutable route domain types and preference enum.
- Create `lib/features/route_result/domain/repositories/route_repository.dart`: planning interface.
- Create `lib/features/route_result/data/models/route_plan_model.dart`: backend JSON mapping.
- Create `lib/features/route_result/data/datasources/route_remote_data_source.dart`: `POST /routes/plan`.
- Create `lib/features/route_result/data/repositories/route_repository_impl.dart`: domain-facing repository.
- Create `lib/features/route_result/domain/services/route_speech_service.dart`: testable speech interface and narration builder.
- Create `lib/features/route_result/data/services/flutter_route_speech_service.dart`: `flutter_tts` adapter.
- Create `lib/features/route_result/presentation/controllers/route_controller.dart`: loading, retry, preference, and speech state.
- Modify `lib/features/route_result/presentation/pages/route_result_page.dart`: remove runtime dummy routing and render controller state.
- Modify `lib/features/search_station/presentation/pages/search_station_page.dart`: preserve station slug in navigation.
- Modify `lib/features/home/presentation/pages/home_page.dart`: carry origin/destination slugs into `/rute` when available.
- Add focused tests under `test/route_*_test.dart`.

---

### Task 1: Lock the backend route-preference contract

**Files:**
- Modify: `tests/routeService.test.ts`
- Create: `tests/routeController.test.ts`
- Modify: `src/presentation/controllers/routeController.ts`

- [ ] **Step 1: Write failing service assertions for response metadata**

Extend the current route test with:

```ts
const fastest = await RouteService.planRoute('Bogor', 'Tangerang', 1, 'FASTEST');
assert.equal(fastest.preference, 'FASTEST');
assert.equal(fastest.transferCount, fastest.steps.filter(({ isTransit }) => isTransit).length);

const minimumTransfers = await RouteService.planRoute(
  'Bogor',
  'Tangerang',
  1,
  'MIN_TRANSFERS',
);
assert.equal(minimumTransfers.preference, 'MIN_TRANSFERS');
assert.ok(minimumTransfers.transferCount <= fastest.transferCount);
```

- [ ] **Step 2: Write a failing controller validation test**

Export `planRouteSchema` and test it without starting Express:

```ts
import assert from 'node:assert/strict';
import test from 'node:test';
import { planRouteSchema } from '../src/presentation/controllers/routeController';

test('route preference defaults to FASTEST and rejects unknown modes', () => {
  assert.equal(
    planRouteSchema.parse({ from: 'bogor', to: 'tangerang' }).preference,
    'FASTEST',
  );
  assert.equal(
    planRouteSchema.safeParse({ from: 'bogor', to: 'tangerang', preference: 'CHEAPEST' })
      .success,
    false,
  );
});
```

- [ ] **Step 3: Run the focused backend tests and confirm red state**

Run:

```powershell
rtk proxy node --import tsx --test tests/routeService.test.ts tests/routeController.test.ts
```

Expected: compilation or assertions fail because preference metadata and schema support do not exist.

- [ ] **Step 4: Add the validated preference to the controller**

Implement:

```ts
export const planRouteSchema = z.object({
  from: z.string().trim().min(1),
  to: z.string().trim().min(1),
  passengerCount: z.coerce.number().int().min(1).max(6).default(1),
  preference: z.enum(['FASTEST', 'MIN_TRANSFERS']).default('FASTEST'),
});
```

Destructure `preference` and call:

```ts
const routePlan = await RouteService.planRoute(
  from,
  to,
  passengerCount,
  preference,
);
```

- [ ] **Step 5: Run the controller test**

Run the command from Step 3. The schema test must pass; the service metadata test remains red until Task 2.

---

### Task 2: Implement fastest and minimum-transfer Dijkstra costs

**Files:**
- Modify: `src/domain/services/routeService.ts`
- Modify: `src/presentation/routes/routeRoutes.ts`
- Test: `tests/routeService.test.ts`

- [ ] **Step 1: Define preference and a lexicographic queue cost**

Add:

```ts
export type RoutePreference = 'FASTEST' | 'MIN_TRANSFERS';

type RouteCost = { minutes: number; transfers: number };
type QueueItem = { id: string; cost: RouteCost };

const compareCost = (a: RouteCost, b: RouteCost, preference: RoutePreference) =>
  preference === 'MIN_TRANSFERS'
    ? a.transfers - b.transfers || a.minutes - b.minutes
    : a.minutes - b.minutes || a.transfers - b.transfers;
```

Update heap insertion/removal to call `compareCost` rather than comparing one numeric distance.

- [ ] **Step 2: Update the route service signature and result**

Use:

```ts
static async planRoute(
  fromIdentifier: string,
  toIdentifier: string,
  passengerCount = 1,
  preference: RoutePreference = 'FASTEST',
): Promise<RoutePlanResult>
```

Add to `RoutePlanResult`:

```ts
preference: RoutePreference;
transferCount: number;
```

For every candidate edge calculate:

```ts
const nextCost = {
  minutes: current.cost.minutes + connection.travelTime,
  transfers: current.cost.transfers + Number(connection.isTransfer),
};
```

Replace a stored cost only when `compareCost(nextCost, knownCost, preference) < 0`. Return `preference` and `transferConnections.length`.

- [ ] **Step 3: Strengthen the route tests**

Assert both modes return the same endpoints and valid topology:

```ts
for (const route of [fastest, minimumTransfers]) {
  assert.equal(route.stationSequence[0].name, 'Bogor');
  assert.equal(route.stationSequence.at(-1)?.name, 'Tangerang');
  assert.ok(route.travelTime > 0);
  assert.equal(route.transferCount, route.steps.filter(({ isTransit }) => isTransit).length);
}
assert.ok(minimumTransfers.transferCount <= fastest.transferCount);
if (minimumTransfers.transferCount === fastest.transferCount) {
  assert.ok(minimumTransfers.travelTime >= fastest.travelTime);
}
```

- [ ] **Step 4: Document the preference field in Swagger JSDoc**

Add a request property:

```yaml
preference:
  type: string
  enum: [FASTEST, MIN_TRANSFERS]
  default: FASTEST
```

- [ ] **Step 5: Verify backend routing**

Run:

```powershell
rtk proxy node --import tsx --test tests/routeService.test.ts tests/routeController.test.ts
rtk npm run build
```

Expected: focused tests pass and TypeScript exits with code 0.

---

### Task 3: Add Flutter route domain and JSON mapping

**Files:**
- Create: `lib/features/route_result/domain/entities/route_plan.dart`
- Create: `lib/features/route_result/data/models/route_plan_model.dart`
- Create: `test/route_plan_model_test.dart`

- [ ] **Step 1: Write a failing JSON contract test**

Use a backend-shaped fixture and assert:

```dart
final route = RoutePlanModel.fromJson(fixture);
expect(route.from, 'Bogor');
expect(route.to, 'Tangerang');
expect(route.preference, RoutePreference.fastest);
expect(route.transferCount, 1);
expect(route.steps.singleWhere((step) => step.isTransit).text, contains('Transit'));
expect(route.stationSequence.first.line.slug, 'bogor');
```

- [ ] **Step 2: Run the model test and confirm it fails**

```powershell
rtk proxy C:\src\flutter\bin\flutter.bat test test\route_plan_model_test.dart
```

Expected: imports/classes do not exist.

- [ ] **Step 3: Create immutable domain types**

Define `RoutePreference { fastest, minimumTransfers, accessible }`, `RoutePlan`, `RouteStep`, `RouteStation`, and `RouteLine`. Keep backend preference conversion on the enum:

```dart
enum RoutePreference {
  fastest('FASTEST'),
  minimumTransfers('MIN_TRANSFERS'),
  accessible('FASTEST');

  const RoutePreference(this.apiValue);
  final String apiValue;
}
```

`RoutePlan` includes `from`, `to`, `travelTime`, `fare`, `unitFare`, `currency`, `passengerCount`, `stops`, `serviceInfo`, `hasTransit`, `transferCount`, backend `preference`, `steps`, `stationSequence`, `exitGateA`, and `exitGateB`.

- [ ] **Step 4: Implement strict but nullable-safe JSON mapping**

Map backend icon strings to domain strings and validate required collections:

```dart
factory RoutePlanModel.fromJson(Map<String, dynamic> json) => RoutePlanModel(
  from: json['from'] as String,
  to: json['to'] as String,
  travelTime: json['travelTime'] as int,
  fare: json['fare'] as int,
  unitFare: json['unitFare'] as int,
  currency: json['currency'] as String,
  passengerCount: json['passengerCount'] as int,
  stops: json['stops'] as int,
  serviceInfo: json['serviceInfo'] as String,
  hasTransit: json['hasTransit'] as bool,
  transferCount: json['transferCount'] as int? ?? 0,
  backendPreference: json['preference'] as String? ?? 'FASTEST',
  steps: (json['steps'] as List<dynamic>)
      .map((value) => RouteStepModel.fromJson(value as Map<String, dynamic>))
      .toList(growable: false),
  stationSequence: (json['stationSequence'] as List<dynamic>)
      .map((value) => RouteStationModel.fromJson(value as Map<String, dynamic>))
      .toList(growable: false),
  exitGateA: json['exitGateA'] as String? ?? '',
  exitGateB: json['exitGateB'] as String? ?? '',
);
```

- [ ] **Step 5: Run and pass the model test**

Run the command from Step 2. Expected: all assertions pass.

---

### Task 4: Add route HTTP data source and repository

**Files:**
- Create: `lib/features/route_result/domain/repositories/route_repository.dart`
- Create: `lib/features/route_result/data/datasources/route_remote_data_source.dart`
- Create: `lib/features/route_result/data/repositories/route_repository_impl.dart`
- Create: `test/route_remote_data_source_test.dart`

- [ ] **Step 1: Write failing HTTP payload and response tests**

Use `MockClient` to capture the request and return the Task 3 fixture. Assert:

```dart
expect(request.method, 'POST');
expect(request.url.toString(), '${ApiConfig.baseUrl}/routes/plan');
expect(jsonDecode(request.body), {
  'from': 'bogor',
  'to': 'tangerang',
  'passengerCount': 1,
  'preference': 'MIN_TRANSFERS',
});
```

Also return status 503 and assert that the data source throws `RouteRequestException`.

- [ ] **Step 2: Run the data-source test and confirm red state**

```powershell
rtk proxy C:\src\flutter\bin\flutter.bat test test\route_remote_data_source_test.dart
```

- [ ] **Step 3: Define the repository interface**

```dart
abstract interface class RouteRepository {
  Future<RoutePlan> plan({
    required String from,
    required String to,
    required RoutePreference preference,
    int passengerCount = 1,
  });
}
```

- [ ] **Step 4: Implement the remote request**

Post JSON to `${ApiConfig.baseUrl}/routes/plan`, apply a 10-second timeout, accept only HTTP 200 with `success == true`, and parse `body['data']` with `RoutePlanModel.fromJson`. Convert timeout, socket, format, and non-200 failures into one `RouteRequestException` type; do not synthesize a route.

- [ ] **Step 5: Implement the repository adapter**

```dart
class RouteRepositoryImpl implements RouteRepository {
  RouteRepositoryImpl(this._remote);
  final RouteRemoteDataSource _remote;

  @override
  Future<RoutePlan> plan({
    required String from,
    required String to,
    required RoutePreference preference,
    int passengerCount = 1,
  }) => _remote.plan(
        from: from,
        to: to,
        preference: preference,
        passengerCount: passengerCount,
      );
}
```

- [ ] **Step 6: Run and pass the data-source test**

Run the command from Step 2. Expected: success and failure cases pass.

---

### Task 5: Add native TTS abstraction and route controller

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/features/route_result/domain/services/route_speech_service.dart`
- Create: `lib/features/route_result/data/services/flutter_route_speech_service.dart`
- Create: `lib/features/route_result/presentation/controllers/route_controller.dart`
- Create: `test/route_controller_test.dart`
- Create: `test/route_speech_service_test.dart`

- [ ] **Step 1: Add the native TTS dependency**

Run from the mobile project:

```powershell
rtk proxy C:\src\flutter\bin\flutter.bat pub add flutter_tts
```

Expected: `flutter_tts` appears in `pubspec.yaml` and dependency resolution succeeds.

- [ ] **Step 2: Write failing narration tests**

For an Indonesian route with a transfer, assert the narration contains origin, destination, duration, fare, departure line, transit instruction, and arrival. For English locale, assert the opening sentence is English. The builder signature is:

```dart
String buildRouteNarration(RoutePlan route, String languageCode)
```

- [ ] **Step 3: Write failing controller state tests**

With fake repository and fake speech service, assert:

```dart
await controller.load(from: 'bogor', to: 'tangerang');
expect(controller.state, RouteViewState.success);
expect(controller.route?.from, 'Bogor');

repository.fail = true;
await controller.retry();
expect(controller.state, RouteViewState.error);
expect(controller.errorMessage,
    'Tidak dapat memuat rute. Periksa koneksi dan coba lagi.');
```

Assert selecting `minimumTransfers` reloads with `MIN_TRANSFERS`; selecting `accessible` reloads fastest only when necessary and exposes speech controls.

- [ ] **Step 4: Define speech interface and narration builder**

```dart
abstract interface class RouteSpeechService {
  Future<void> speak(String text, String languageCode);
  Future<void> pause();
  Future<void> stop();
}
```

Construct narration from actual `RoutePlan.steps`; never introduce station or platform data not present in the response.

- [ ] **Step 5: Implement the Flutter TTS adapter**

Wrap `FlutterTts`, configure `id-ID` for Indonesian and `en-US` for English, set speech rate to `0.45`, await speak completion, and delegate pause/stop. The adapter contains no UI state.

- [ ] **Step 6: Implement `RouteController`**

Use:

```dart
enum RouteViewState { initial, loading, success, error }

class RouteController extends ChangeNotifier {
  static const connectionError =
      'Tidak dapat memuat rute. Periksa koneksi dan coba lagi.';
  // injected repository and speech service
  // immutable public getters for route, preference, state, isSpeaking
}
```

Store the last `from`/`to` for retry. `dispose()` must call `speech.stop()` before `super.dispose()`. `accessible` maps to API `FASTEST` and only changes narration/UI behavior.

- [ ] **Step 7: Run focused controller and narration tests**

```powershell
rtk proxy C:\src\flutter\bin\flutter.bat test test\route_controller_test.dart test\route_speech_service_test.dart
```

Expected: loading, success, exact error message, retry, preference, narration, and stop behavior pass.

---

### Task 6: Integrate controller state into the existing route-result UI

**Files:**
- Modify: `lib/features/route_result/presentation/pages/route_result_page.dart`
- Modify: `lib/features/search_station/presentation/pages/search_station_page.dart`
- Modify: `lib/features/home/presentation/pages/home_page.dart`
- Create: `test/route_result_page_test.dart`

- [ ] **Step 1: Write failing page-state widget tests**

Inject a `RouteController` through an optional page constructor. Assert:

- loading shows `CircularProgressIndicator`;
- failure shows exactly `Tidak dapat memuat rute. Periksa koneksi dan coba lagi.` and `Coba Lagi`;
- success shows backend origin, destination, minutes, formatted fare, and transfer step;
- accessible mode shows speak, repeat, and stop controls;
- no offline `_calculateRoute` result appears during error.

- [ ] **Step 2: Run the widget test and confirm red state**

```powershell
rtk proxy C:\src\flutter\bin\flutter.bat test test\route_result_page_test.dart
```

- [ ] **Step 3: Replace inline routing with controller lifecycle**

In `initState`, construct the production dependencies when no controller is injected:

```dart
RouteController(
  RouteRepositoryImpl(RouteRemoteDataSource()),
  FlutterRouteSpeechService(),
)
```

Read `from` and `to` once in `didChangeDependencies`, call `load`, render via `ListenableBuilder`, and dispose only an internally owned controller. Delete the runtime `_calculateRoute` function and local route classes after domain imports replace them.

- [ ] **Step 4: Preserve the existing success layout**

Keep the summary, timeline, exit-gate section, and ticket button. Map backend icon keys with one presentation helper:

```dart
IconData routeIcon(String value) => switch (value) {
  'directions_walk' => Icons.directions_walk_rounded,
  'place' => Icons.place_rounded,
  _ => Icons.train_rounded,
};
```

Remove the current fake `Live ETA` card because route planning does not provide realtime departure information. Do not replace it with generated text.

- [ ] **Step 5: Add accessible controls**

When selected, render semantic buttons for `Bacakan Rute`, `Ulangi`, `Jeda`, and `Hentikan`. Use `Localizations.localeOf(context).languageCode` for narration. Add `Semantics` labels to route steps and summary values.

- [ ] **Step 6: Carry stable station slugs through navigation**

When a catalog station is selected, preserve both display name and slug. Add `selectedId`/`fromId` local state in Home. Build the route URI with `Uri`:

```dart
context.go(Uri(path: '/rute', queryParameters: {
  'from': _fromStationId ?? _fromStation!,
  'to': currentStationId ?? currentStation,
}).toString());
```

Map-click selections may still use names because the backend resolver supports exact names. Never concatenate unescaped station names into URLs.

- [ ] **Step 7: Run and pass page/navigation tests**

Run the command from Step 2 plus existing station tests. Expected: route page states and station selection contract pass.

---

### Task 7: Full verification and runtime smoke test

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Document route preferences, mobile base URL, and TTS behavior**

Document request examples for `FASTEST` and `MIN_TRANSFERS`, Android emulator `10.0.2.2`, physical-device LAN configuration through `--dart-define=API_BASE_URL=...`, exact retry behavior, and that accessible mode narrates backend route data rather than changing topology.

- [ ] **Step 2: Run full backend verification**

```powershell
rtk npm test
rtk npm run build
rtk npx prisma validate
rtk npx prisma migrate status
```

Expected: all tests pass, TypeScript exits 0, schema is valid, and migrations are current.

- [ ] **Step 3: Run focused Flutter verification**

```powershell
rtk proxy C:\src\flutter\bin\flutter.bat test test\route_plan_model_test.dart test\route_remote_data_source_test.dart test\route_controller_test.dart test\route_speech_service_test.dart test\route_result_page_test.dart test\station_model_test.dart test\station_controller_test.dart test\station_remote_data_source_test.dart test\station_map_contract_test.dart
rtk proxy C:\src\flutter\bin\flutter.bat analyze
```

Expected: focused tests pass. Analyzer reports no new findings; the three pre-existing schematic painter findings are recorded separately if still present.

- [ ] **Step 4: Smoke-test the live backend contract**

With the backend running, POST both preferences for `bogor` to `tangerang`. Assert HTTP 200, correct preference metadata, non-empty steps/station sequence, and minimum-transfer count no greater than fastest.

- [ ] **Step 5: Manually verify the mobile journey**

On Android emulator: choose an origin and destination, open route results, confirm the visible route matches the backend response, switch to minimum transfers, activate accessible mode, listen to Indonesian narration, stop narration, leave the page, then temporarily point `API_BASE_URL` to an unavailable port and confirm only the exact retry message and `Coba Lagi` appear.
