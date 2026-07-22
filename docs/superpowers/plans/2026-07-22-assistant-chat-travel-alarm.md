# Assistant Chat and Travel Alarm Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a unified text-and-voice Assistant timeline plus simulated departure and destination alarms shared with the ticket purchase flow.

**Architecture:** A router-level `TravelAlarmController` owns one in-memory alarm state observed by Tickets and Assistant through `TravelAlarmScope`. A separate `AssistantConversationController` owns deterministic local chat messages and invokes the alarm controller for supported commands. Focused widgets render the setup sheet, floating alarm control, timeline, status cards, and composer.

**Tech Stack:** Flutter, Dart, Material widgets, `ChangeNotifier`, `InheritedNotifier`, GoRouter, `flutter_test`.

---

## File Map

### New Alarm Files

- `lib/features/travel_alarm/domain/entities/travel_alarm_state.dart`: immutable active-trip and alarm state values.
- `lib/features/travel_alarm/presentation/controllers/travel_alarm_controller.dart`: ticket and alarm state transitions.
- `lib/features/travel_alarm/presentation/widgets/travel_alarm_scope.dart`: router-level inherited state access.
- `lib/features/travel_alarm/presentation/widgets/travel_alarm_setup_sheet.dart`: post-payment alarm choices.
- `lib/features/travel_alarm/presentation/widgets/travel_alarm_button.dart`: floating active/inactive alarm control.
- `lib/features/travel_alarm/presentation/widgets/travel_alarm_disable_dialog.dart`: destructive-action confirmation.
- `lib/features/travel_alarm/presentation/widgets/travel_alarm_status_card.dart`: shared alarm summary for chat.

### New Assistant Files

- `lib/features/assistant/domain/entities/assistant_conversation_item.dart`: typed timeline item model.
- `lib/features/assistant/presentation/controllers/assistant_conversation_controller.dart`: local command handling and timeline state.
- `lib/features/assistant/presentation/widgets/assistant_conversation_timeline.dart`: conversation item renderer.
- `lib/features/assistant/presentation/widgets/assistant_composer.dart`: text, send, and microphone controls.

### Modified Files

- `lib/main.dart`: own and dispose the application alarm controller.
- `lib/core/routing/router.dart`: inject shared alarm state into Tickets and Assistant.
- `lib/features/tickets/presentation/pages/tickets_page.dart`: open alarm setup after payment and show the alarm button.
- `lib/features/assistant/presentation/pages/assistant_page.dart`: compose voice, chat, alarm state, and fixed composer.
- `lib/features/assistant/presentation/controllers/assistant_controller.dart`: expose completed voice exchanges without duplicating timeline items.
- `test/widget_test.dart`: route-level integration, semantics, keyboard, and text-scale coverage.

### New Tests

- `test/travel_alarm_controller_test.dart`
- `test/assistant_conversation_controller_test.dart`
- `test/travel_alarm_widgets_test.dart`

---

### Task 1: Travel Alarm State and Controller

**Files:**
- Create: `lib/features/travel_alarm/domain/entities/travel_alarm_state.dart`
- Create: `lib/features/travel_alarm/presentation/controllers/travel_alarm_controller.dart`
- Create: `test/travel_alarm_controller_test.dart`

- [ ] **Step 1: Write failing state-transition tests**

Create `test/travel_alarm_controller_test.dart` with these behaviors:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/travel_alarm/presentation/controllers/travel_alarm_controller.dart';

void main() {
  test('new purchase starts with both alarms unconfirmed', () {
    final controller = TravelAlarmController();

    controller.completePurchase(from: 'Setiabudi', to: 'Manggarai');

    expect(controller.state.hasActiveTicket, isTrue);
    expect(controller.state.departureAlarmEnabled, isFalse);
    expect(controller.state.destinationAlarmEnabled, isFalse);
    expect(controller.state.minutesUntilTrain, 5);
    expect(controller.state.stationsUntilDestination, 1);
  });

  test('selected alarm categories can be activated independently', () {
    final controller = TravelAlarmController()
      ..completePurchase(from: 'Setiabudi', to: 'Manggarai');

    controller.configureAlarms(departure: true, destination: false);

    expect(controller.state.departureAlarmEnabled, isTrue);
    expect(controller.state.destinationAlarmEnabled, isFalse);
    expect(controller.state.hasAnyAlarm, isTrue);
  });

  test('destination and all alarms can be disabled safely', () {
    final controller = TravelAlarmController()
      ..completePurchase(from: 'Setiabudi', to: 'Manggarai')
      ..configureAlarms(departure: true, destination: true);

    controller.disableDestinationAlarm();
    expect(controller.state.departureAlarmEnabled, isTrue);
    expect(controller.state.destinationAlarmEnabled, isFalse);

    controller.cancelAllAlarms();
    expect(controller.state.hasAnyAlarm, isFalse);
  });

  test('next alarm describes departure then destination state', () {
    final controller = TravelAlarmController()
      ..completePurchase(from: 'Setiabudi', to: 'Manggarai')
      ..configureAlarms(departure: true, destination: true);

    expect(controller.nextAlarmDescription, 'Kereta datang 5 menit lagi');

    controller.advanceDepartureDemo();
    expect(controller.nextAlarmDescription, 'Kereta datang 1 menit lagi');

    controller.advanceDestinationDemo();
    expect(
      controller.destinationDescription,
      'Turun di Manggarai, 1 stasiun lagi',
    );
  });
}
```

- [ ] **Step 2: Run the tests and verify RED**

Run:

```powershell
rtk flutter test test/travel_alarm_controller_test.dart
```

Expected: compilation fails because `TravelAlarmController` does not exist.

- [ ] **Step 3: Add the immutable alarm state**

Create `travel_alarm_state.dart`:

```dart
class ActiveTrip {
  const ActiveTrip({required this.from, required this.to});

  final String from;
  final String to;
}

class TravelAlarmState {
  const TravelAlarmState({
    this.activeTrip,
    this.departureAlarmEnabled = false,
    this.destinationAlarmEnabled = false,
    this.minutesUntilTrain = 5,
    this.stationsUntilDestination = 1,
  });

  final ActiveTrip? activeTrip;
  final bool departureAlarmEnabled;
  final bool destinationAlarmEnabled;
  final int minutesUntilTrain;
  final int stationsUntilDestination;

  bool get hasActiveTicket => activeTrip != null;
  bool get hasAnyAlarm =>
      departureAlarmEnabled || destinationAlarmEnabled;

  TravelAlarmState copyWith({
    ActiveTrip? activeTrip,
    bool? departureAlarmEnabled,
    bool? destinationAlarmEnabled,
    int? minutesUntilTrain,
    int? stationsUntilDestination,
  }) {
    return TravelAlarmState(
      activeTrip: activeTrip ?? this.activeTrip,
      departureAlarmEnabled:
          departureAlarmEnabled ?? this.departureAlarmEnabled,
      destinationAlarmEnabled:
          destinationAlarmEnabled ?? this.destinationAlarmEnabled,
      minutesUntilTrain: minutesUntilTrain ?? this.minutesUntilTrain,
      stationsUntilDestination:
          stationsUntilDestination ?? this.stationsUntilDestination,
    );
  }
}
```

- [ ] **Step 4: Implement minimal controller transitions**

Create `travel_alarm_controller.dart`:

```dart
import 'package:flutter/foundation.dart';

import '../../domain/entities/travel_alarm_state.dart';

class TravelAlarmController extends ChangeNotifier {
  TravelAlarmState state = const TravelAlarmState();

  String get nextAlarmDescription {
    if (state.departureAlarmEnabled) {
      return 'Kereta datang ${state.minutesUntilTrain} menit lagi';
    }
    if (state.destinationAlarmEnabled && state.activeTrip != null) {
      return destinationDescription;
    }
    return 'Tidak ada alarm aktif';
  }

  String get destinationDescription {
    final destination = state.activeTrip?.to ?? 'tujuan';
    return 'Turun di $destination, ${state.stationsUntilDestination} stasiun lagi';
  }

  void completePurchase({required String from, required String to}) {
    state = TravelAlarmState(activeTrip: ActiveTrip(from: from, to: to));
    notifyListeners();
  }

  void configureAlarms({
    required bool departure,
    required bool destination,
  }) {
    if (!state.hasActiveTicket) return;
    state = state.copyWith(
      departureAlarmEnabled: departure,
      destinationAlarmEnabled: destination,
    );
    notifyListeners();
  }

  void disableDestinationAlarm() {
    if (!state.destinationAlarmEnabled) return;
    state = state.copyWith(destinationAlarmEnabled: false);
    notifyListeners();
  }

  void cancelAllAlarms() {
    if (!state.hasAnyAlarm) return;
    state = state.copyWith(
      departureAlarmEnabled: false,
      destinationAlarmEnabled: false,
    );
    notifyListeners();
  }

  void advanceDepartureDemo() {
    state = state.copyWith(minutesUntilTrain: 1);
    notifyListeners();
  }

  void advanceDestinationDemo() {
    state = state.copyWith(stationsUntilDestination: 1);
    notifyListeners();
  }
}
```

- [ ] **Step 5: Run the controller tests and verify GREEN**

Run `rtk flutter test test/travel_alarm_controller_test.dart`.

Expected: all four tests pass.

- [ ] **Step 6: Commit the state layer**

```powershell
rtk git add lib/features/travel_alarm test/travel_alarm_controller_test.dart
rtk git commit -m "feat: add simulated travel alarm state"
```

---

### Task 2: Application-Level Alarm Scope

**Files:**
- Create: `lib/features/travel_alarm/presentation/widgets/travel_alarm_scope.dart`
- Modify: `lib/main.dart`
- Modify: `lib/core/routing/router.dart`
- Modify: `lib/features/tickets/presentation/pages/tickets_page.dart`
- Modify: `lib/features/assistant/presentation/pages/assistant_page.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Write a failing shared-state route test**

Add a widget test that opens `MyApp`, retrieves `TravelAlarmScope` from a descendant context, and verifies the same controller instance remains available after navigation from `/tiket` to `/asisten`:

```dart
testWidgets('Tickets and Assistant share one travel alarm controller', (
  tester,
) async {
  appRouter.go('/tiket');
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();

  final ticketContext = tester.element(find.byType(TicketsPage));
  final ticketController = TravelAlarmScope.of(ticketContext);

  appRouter.go('/asisten');
  await tester.pumpAndSettle();
  final assistantContext = tester.element(find.byType(AssistantPage));

  expect(TravelAlarmScope.of(assistantContext), same(ticketController));
});
```

- [ ] **Step 2: Verify the route test fails**

Run:

```powershell
rtk flutter test test/widget_test.dart --plain-name "share one travel alarm"
```

Expected: compilation fails because `TravelAlarmScope` does not exist.

- [ ] **Step 3: Add `TravelAlarmScope`**

```dart
import 'package:flutter/widgets.dart';

import '../controllers/travel_alarm_controller.dart';

class TravelAlarmScope extends InheritedNotifier<TravelAlarmController> {
  const TravelAlarmScope({
    super.key,
    required TravelAlarmController controller,
    required super.child,
  }) : super(notifier: controller);

  static TravelAlarmController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TravelAlarmScope>();
    assert(scope != null, 'TravelAlarmScope is missing above this context.');
    return scope!.notifier!;
  }
}
```

- [ ] **Step 4: Make `MyApp` own the shared controller**

Convert `MyApp` to a `StatefulWidget`. Create one `TravelAlarmController` in `initState`, dispose it in `dispose`, and wrap `MaterialApp.router` with `TravelAlarmScope`.

```dart
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final TravelAlarmController _travelAlarmController;

  @override
  void initState() {
    super.initState();
    _travelAlarmController = TravelAlarmController();
  }

  @override
  void dispose() {
    _travelAlarmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TravelAlarmScope(
      controller: _travelAlarmController,
      child: MaterialApp.router(
        title: 'KAI Access Prototype',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
```

- [ ] **Step 5: Inject the controller through routes and page constructors**

Add `TravelAlarmController? alarmController` to `TicketsPage` and `AssistantPage`. In each route builder, pass `TravelAlarmScope.of(context)`. Direct widget tests may continue to inject isolated controllers.

```dart
child: TicketsPage(
  alarmController: TravelAlarmScope.of(context),
  from: from,
  to: to,
  fare: fare,
  duration: duration,
  transit: transit,
),
```

```dart
child: AssistantPage(
  alarmController: TravelAlarmScope.of(context),
),
```

- [ ] **Step 6: Run focused and existing tests**

Run:

```powershell
rtk flutter test test/widget_test.dart --plain-name "share one travel alarm"
rtk flutter test
```

Expected: the focused test and existing suite pass.

- [ ] **Step 7: Commit the shared scope**

```powershell
rtk git add lib/main.dart lib/core/routing/router.dart lib/features/tickets/presentation/pages/tickets_page.dart lib/features/assistant/presentation/pages/assistant_page.dart lib/features/travel_alarm/presentation/widgets/travel_alarm_scope.dart test/widget_test.dart
rtk git commit -m "feat: share travel alarms across app routes"
```

---

### Task 3: Alarm Setup and Toggle Widgets

**Files:**
- Create: `lib/features/travel_alarm/presentation/widgets/travel_alarm_setup_sheet.dart`
- Create: `lib/features/travel_alarm/presentation/widgets/travel_alarm_button.dart`
- Create: `lib/features/travel_alarm/presentation/widgets/travel_alarm_disable_dialog.dart`
- Create: `test/travel_alarm_widgets_test.dart`

- [ ] **Step 1: Write failing setup-sheet tests**

Test that the title appears, both toggles start enabled, confirming returns both values, and `Lewati` returns no configuration.

```dart
testWidgets('alarm setup enables both categories by default', (tester) async {
  TravelAlarmSelection? result;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: Builder(builder: (context) {
        return TextButton(
          onPressed: () async {
            result = await showTravelAlarmSetupSheet(
              context,
              from: 'Setiabudi',
              to: 'Manggarai',
            );
          },
          child: const Text('Open'),
        );
      }),
    ),
  ));

  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();

  expect(find.text('Aktifkan pengingat perjalanan?'), findsOneWidget);
  expect(tester.widget<Switch>(find.byKey(const Key('departure-alarm-toggle'))).value, isTrue);
  expect(tester.widget<Switch>(find.byKey(const Key('destination-alarm-toggle'))).value, isTrue);

  await tester.tap(find.text('Aktifkan alarm'));
  await tester.pumpAndSettle();
  expect(result, const TravelAlarmSelection(departure: true, destination: true));
});
```

- [ ] **Step 2: Write failing button and dialog tests**

Verify neutral and active semantics labels and that the dialog contains `Kembali` and `Matikan alarm`.

```dart
expect(find.bySemanticsLabel('Aktifkan alarm perjalanan'), findsOneWidget);
expect(
  find.bySemanticsLabel(
    'Alarm perjalanan aktif, ketuk untuk menonaktifkan',
  ),
  findsOneWidget,
);
```

- [ ] **Step 3: Run widget tests and verify RED**

Run `rtk flutter test test/travel_alarm_widgets_test.dart`.

Expected: compilation fails because the alarm widgets do not exist.

- [ ] **Step 4: Implement the selection value and setup sheet**

Define:

```dart
class TravelAlarmSelection {
  const TravelAlarmSelection({
    required this.departure,
    required this.destination,
  });

  final bool departure;
  final bool destination;

  @override
  bool operator ==(Object other) =>
      other is TravelAlarmSelection &&
      other.departure == departure &&
      other.destination == destination;

  @override
  int get hashCode => Object.hash(departure, destination);
}
```

`showTravelAlarmSetupSheet` must use `showModalBottomSheet<TravelAlarmSelection>`, local state for the two default-true switches, entire-row semantics actions, a primary confirmation button, and `Navigator.pop(context)` for `Lewati`.

- [ ] **Step 5: Implement the alarm button and disable dialog**

`TravelAlarmButton` accepts `bool isActive` and `VoidCallback onPressed`. Use `Icons.alarm_rounded`, `AppColors.statusRed` when active, a neutral surface when inactive, a 56 logical-pixel circle, and the exact dynamic semantics labels from the test.

`showTravelAlarmDisableDialog` returns `Future<bool>` and maps `Kembali` to `false` and `Matikan alarm` to `true`.

- [ ] **Step 6: Run alarm widget tests**

Run `rtk flutter test test/travel_alarm_widgets_test.dart`.

Expected: all setup, button, and dialog tests pass.

- [ ] **Step 7: Commit the widgets**

```powershell
rtk git add lib/features/travel_alarm/presentation/widgets test/travel_alarm_widgets_test.dart
rtk git commit -m "feat: add accessible travel alarm controls"
```

---

### Task 4: Integrate Alarms with Ticket Payment

**Files:**
- Modify: `lib/features/tickets/presentation/pages/tickets_page.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Write a failing post-payment test**

Pump `TicketsPage` with an injected `TravelAlarmController`. Open the pending ticket, pay, and assert the setup sheet appears with both defaults enabled.

```dart
testWidgets('payment opens travel alarm setup before showing active ticket', (
  tester,
) async {
  final alarms = TravelAlarmController();
  await tester.pumpWidget(MaterialApp(
    home: TicketsPage(alarmController: alarms),
  ));

  await tester.tap(find.text('Bayar sekarang'));
  await tester.pump();
  await tester.tap(find.text('Bayar Rp7.800'));
  await tester.pumpAndSettle();

  expect(find.text('Aktifkan pengingat perjalanan?'), findsOneWidget);
  expect(alarms.state.hasActiveTicket, isTrue);
  expect(alarms.state.hasAnyAlarm, isFalse);
});
```

- [ ] **Step 2: Verify the post-payment test fails**

Run `rtk flutter test test/widget_test.dart --plain-name "payment opens travel alarm"`.

Expected: no setup sheet is found.

- [ ] **Step 3: Open the setup sheet after payment**

Replace the payment button callback with an async `_completePayment` method:

```dart
Future<void> _completePayment({
  required String from,
  required String to,
}) async {
  _alarmController.completePurchase(from: from, to: to);
  setState(() => _viewMode = _TicketViewMode.active);

  final selection = await showTravelAlarmSetupSheet(
    context,
    from: from,
    to: to,
  );
  if (selection == null || !mounted) return;

  _alarmController.configureAlarms(
    departure: selection.departure,
    destination: selection.destination,
  );
  _showAlarmMessage('Alarm perjalanan diaktifkan');
}
```

The page must subscribe to the injected or locally owned alarm controller and dispose only controllers it creates.

- [ ] **Step 4: Write a failing active-button test**

Activate both alarms, verify the red floating button, tap it, confirm the dialog, and assert all alarms are disabled plus the snackbar appears.

- [ ] **Step 5: Add the floating alarm control to the active view**

Wrap the active ticket content in a `Stack`. Position `TravelAlarmButton` at the lower-right of the expanded content, above the custom bottom navigation. On inactive tap, reopen the setup sheet. On active tap, call `showTravelAlarmDisableDialog`; when confirmed, call `cancelAllAlarms()` and show `Alarm perjalanan dinonaktifkan`.

- [ ] **Step 6: Run focused and ticket regression tests**

Run:

```powershell
rtk flutter test test/widget_test.dart --plain-name "payment opens travel alarm"
rtk flutter test test/widget_test.dart --plain-name "Ticket tab"
```

Expected: alarm and existing ticket tests pass.

- [ ] **Step 7: Commit ticket integration**

```powershell
rtk git add lib/features/tickets/presentation/pages/tickets_page.dart test/widget_test.dart
rtk git commit -m "feat: configure travel alarms after payment"
```

---

### Task 5: Conversation Model and Local Command Controller

**Files:**
- Create: `lib/features/assistant/domain/entities/assistant_conversation_item.dart`
- Create: `lib/features/assistant/presentation/controllers/assistant_conversation_controller.dart`
- Create: `test/assistant_conversation_controller_test.dart`

- [ ] **Step 1: Write failing command tests**

Cover empty input, all five supported intents, unknown input, and no-active-ticket behavior.

```dart
test('typed command activates every alarm and appends ordered messages', () {
  final alarms = TravelAlarmController()
    ..completePurchase(from: 'Setiabudi', to: 'Manggarai');
  final chat = AssistantConversationController(alarmController: alarms);

  chat.submitText('Aktifkan semua alarm tiket saya');

  expect(chat.items.first.author, AssistantMessageAuthor.user);
  expect(chat.items.first.text, 'Aktifkan semua alarm tiket saya');
  expect(chat.items.last.kind, AssistantConversationItemKind.alarmStatus);
  expect(alarms.state.departureAlarmEnabled, isTrue);
  expect(alarms.state.destinationAlarmEnabled, isTrue);
});

test('unknown command returns examples', () {
  final chat = AssistantConversationController(
    alarmController: TravelAlarmController(),
  );

  chat.submitText('Pesan yang tidak dikenali');

  expect(chat.items.last.text, contains('Saya belum memahami perintah itu'));
  expect(chat.items.last.text, contains('Alarm berikutnya kapan?'));
});

test('alarm command without a ticket adds an empty-ticket item', () {
  final chat = AssistantConversationController(
    alarmController: TravelAlarmController(),
  );

  chat.submitText('Aktifkan semua alarm tiket saya');

  expect(chat.items.last.kind, AssistantConversationItemKind.noActiveTicket);
});
```

- [ ] **Step 2: Verify command tests fail**

Run `rtk flutter test test/assistant_conversation_controller_test.dart`.

Expected: compilation fails because the conversation types do not exist.

- [ ] **Step 3: Add the timeline item model**

```dart
enum AssistantMessageAuthor { user, assistant }

enum AssistantConversationItemKind {
  message,
  alarmStatus,
  noActiveTicket,
}

class AssistantConversationItem {
  const AssistantConversationItem({
    required this.id,
    required this.author,
    required this.kind,
    required this.text,
  });

  final int id;
  final AssistantMessageAuthor author;
  final AssistantConversationItemKind kind;
  final String text;
}
```

- [ ] **Step 4: Implement deterministic command matching**

`AssistantConversationController` extends `ChangeNotifier`, stores an unmodifiable item list, ignores trimmed empty input, and uses ordered matching so specific cancel commands take precedence over general alarm words.

```dart
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../domain/entities/assistant_conversation_item.dart';
import '../../../travel_alarm/presentation/controllers/travel_alarm_controller.dart';

class AssistantConversationController extends ChangeNotifier {
  AssistantConversationController({required this.alarmController});

  final TravelAlarmController alarmController;
  final List<AssistantConversationItem> _items = [];
  int _nextId = 0;

  UnmodifiableListView<AssistantConversationItem> get items =>
      UnmodifiableListView(_items);

  void submitText(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return;
    _append(
      author: AssistantMessageAuthor.user,
      kind: AssistantConversationItemKind.message,
      text: text,
    );

    final normalized = text.toLowerCase();
    if (_requiresTicket(normalized) &&
        !alarmController.state.hasActiveTicket) {
      _append(
        author: AssistantMessageAuthor.assistant,
        kind: AssistantConversationItemKind.noActiveTicket,
        text: 'Belum ada tiket aktif',
      );
    } else if (normalized.contains('batalkan semua alarm')) {
      alarmController.cancelAllAlarms();
      _appendAssistant('Semua alarm perjalanan dibatalkan.');
    } else if (normalized.contains('matikan alarm tujuan')) {
      alarmController.disableDestinationAlarm();
      _appendAlarmStatus('Alarm tujuan dinonaktifkan.');
    } else if (normalized.contains('aktifkan semua alarm')) {
      alarmController.configureAlarms(departure: true, destination: true);
      _appendAlarmStatus('Semua alarm perjalanan aktif.');
    } else if (normalized.contains('alarm berikutnya')) {
      _appendAlarmStatus(alarmController.nextAlarmDescription);
    } else if (normalized.contains('datang') ||
        normalized.contains('berapa menit')) {
      _appendAssistant(alarmController.nextAlarmDescription);
    } else {
      _appendAssistant(
        'Saya belum memahami perintah itu. Coba: "Alarm berikutnya kapan?" atau "Aktifkan semua alarm tiket saya".',
      );
    }
    notifyListeners();
  }

  void addVoiceExchange({
    required String transcript,
    required String response,
  }) {
    _append(
      author: AssistantMessageAuthor.user,
      kind: AssistantConversationItemKind.message,
      text: transcript,
    );
    _appendAssistant(response);
    notifyListeners();
  }

  bool _requiresTicket(String text) {
    return text.contains('alarm') ||
        text.contains('kereta') ||
        text.contains('berapa menit');
  }

  void _appendAssistant(String text) {
    _append(
      author: AssistantMessageAuthor.assistant,
      kind: AssistantConversationItemKind.message,
      text: text,
    );
  }

  void _appendAlarmStatus(String text) {
    _append(
      author: AssistantMessageAuthor.assistant,
      kind: AssistantConversationItemKind.alarmStatus,
      text: text,
    );
  }

  void _append({
    required AssistantMessageAuthor author,
    required AssistantConversationItemKind kind,
    required String text,
  }) {
    _items.add(AssistantConversationItem(
      id: _nextId++,
      author: author,
      kind: kind,
      text: text,
    ));
  }
}
```

- [ ] **Step 5: Run command tests**

Run `rtk flutter test test/assistant_conversation_controller_test.dart`.

Expected: every local command and error test passes.

- [ ] **Step 6: Commit conversation logic**

```powershell
rtk git add lib/features/assistant/domain lib/features/assistant/presentation/controllers/assistant_conversation_controller.dart test/assistant_conversation_controller_test.dart
rtk git commit -m "feat: add local assistant chat commands"
```

---

### Task 6: Timeline, Alarm Card, and Composer Widgets

**Files:**
- Create: `lib/features/assistant/presentation/widgets/assistant_conversation_timeline.dart`
- Create: `lib/features/assistant/presentation/widgets/assistant_composer.dart`
- Create: `lib/features/travel_alarm/presentation/widgets/travel_alarm_status_card.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Write failing timeline and composer tests**

Verify user and Assistant sender labels, alarm status content, no-ticket action, text submission, whitespace rejection, send semantics, and microphone semantics.

```dart
testWidgets('composer submits trimmed text and retains voice action', (
  tester,
) async {
  String? submitted;
  var microphoneTaps = 0;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: AssistantComposer(
        onSubmit: (value) => submitted = value,
        onMicrophoneTap: () => microphoneTaps++,
      ),
    ),
  ));

  await tester.enterText(
    find.bySemanticsLabel('Ketik pesan untuk Asisten'),
    '  Alarm berikutnya kapan?  ',
  );
  await tester.tap(find.bySemanticsLabel('Kirim pesan'));
  expect(submitted, 'Alarm berikutnya kapan?');

  await tester.tap(find.bySemanticsLabel('Mulai percakapan suara'));
  expect(microphoneTaps, 1);
});
```

- [ ] **Step 2: Verify widget tests fail**

Run the new focused tests and expect missing-widget compilation failures.

- [ ] **Step 3: Implement `AssistantComposer`**

Use a `TextEditingController`, `TextField` with `textInputAction: TextInputAction.send`, icon buttons for send and microphone, 48-pixel minimum targets, and the exact semantics labels. Clear the field only after a non-empty submission.

- [ ] **Step 4: Implement the timeline renderer**

Render items in order without an independently nested scroll view. Use sender labels `Anda` and `Asisten`, restrained message surfaces, and `Semantics(liveRegion: true)` only around the newest Assistant item.

Render `alarmStatus` through `TravelAlarmStatusCard`. Render `noActiveTicket` with `Belum ada tiket aktif` and a `Cari perjalanan` button callback.

- [ ] **Step 5: Implement `TravelAlarmStatusCard`**

Show route, departure status, destination status, next alarm text, and callbacks for `Lihat tiket` and `Batalkan alarm`. Use a flat card, an `Icons.alarm_rounded` status icon, text labels in addition to color, and no nested card surfaces.

- [ ] **Step 6: Run widget tests and 200 percent text-scale coverage**

Run:

```powershell
rtk flutter test test/widget_test.dart --plain-name "composer"
rtk flutter test test/widget_test.dart --plain-name "conversation timeline"
rtk flutter test test/widget_test.dart --plain-name "200 percent"
```

Expected: all focused tests pass without render exceptions.

- [ ] **Step 7: Commit presentation widgets**

```powershell
rtk git add lib/features/assistant/presentation/widgets lib/features/travel_alarm/presentation/widgets/travel_alarm_status_card.dart test/widget_test.dart
rtk git commit -m "feat: add accessible assistant chat timeline"
```

---

### Task 7: Integrate Chat and Voice on Assistant Page

**Files:**
- Modify: `lib/features/assistant/presentation/pages/assistant_page.dart`
- Modify: `lib/features/assistant/presentation/controllers/assistant_controller.dart`
- Modify: `test/assistant_controller_test.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Write a failing unified-timeline test**

Pump `AssistantPage` with short voice durations, an alarm controller with an active ticket, and an injected conversation controller. Submit typed text, trigger voice, and expect both exchanges in one timeline.

```dart
expect(find.text('Alarm berikutnya kapan?'), findsOneWidget);
expect(find.text('Kereta datang 5 menit lagi'), findsOneWidget);
expect(find.text('Saya ingin ke Manggarai dari Setiabudi.'), findsOneWidget);
```

- [ ] **Step 2: Verify the unified test fails**

Run `rtk flutter test test/widget_test.dart --plain-name "voice and text share one timeline"`.

Expected: composer and typed timeline content are absent.

- [ ] **Step 3: Expose one completed voice exchange**

Add an integer `completedExchangeId` to `AssistantController`, increment it in `_finishProcessing` after assigning transcript and response, and retain existing state transitions. Test that one conversation increments the ID once while repeat speech does not increment it.

- [ ] **Step 4: Own or inject the conversation controller**

Extend `AssistantPage` with:

```dart
final TravelAlarmController? alarmController;
final AssistantConversationController? conversationController;
```

Create owned controllers only when no instance is injected. Listen to voice and conversation controllers independently. Track the last consumed `completedExchangeId`; append each new voice exchange exactly once through `addVoiceExchange`.

- [ ] **Step 5: Restructure the page without losing voice-first layout**

Keep the existing header, wake-word switch, and large voice panel. Replace the old single response panel with `AssistantConversationTimeline`. Keep quick actions after timeline content. Place `AssistantComposer` between the expanded scrollable content and `AppBottomNavBar` so it remains visible above the keyboard and navbar.

Wire composer actions:

```dart
AssistantComposer(
  onSubmit: _conversationController.submitText,
  onMicrophoneTap: _voiceAction,
)
```

Wire status-card actions to `/tiket`, `cancelAllAlarms`, and `/cari-stasiun`.

- [ ] **Step 6: Preserve lifecycle behavior**

On page disposal, remove every listener, cancel transient voice timers, reset wake-word mode, and dispose only owned controllers. Do not cancel ticket alarms when leaving Assistant.

- [ ] **Step 7: Run Assistant regressions**

Run:

```powershell
rtk flutter test test/assistant_controller_test.dart
rtk flutter test test/assistant_conversation_controller_test.dart
rtk flutter test test/widget_test.dart --plain-name "Assistant"
```

Expected: old voice controls and new unified timeline tests pass.

- [ ] **Step 8: Commit Assistant integration**

```powershell
rtk git add lib/features/assistant test/assistant_controller_test.dart test/widget_test.dart
rtk git commit -m "feat: combine assistant voice and text conversations"
```

---

### Task 8: Accessibility, Integration, and Emulator Verification

**Files:**
- Modify: `test/widget_test.dart`
- Modify only failing implementation files identified by these tests.

- [ ] **Step 1: Add failing end-to-end alarm tests**

Cover this route flow in `MyApp`:

1. Open Tickets.
2. Pay for the pending ticket.
3. Confirm both alarms.
4. Navigate to Assistant.
5. Ask `Alarm berikutnya kapan?`.
6. Verify `Kereta datang 5 menit lagi` and active alarm status.
7. Cancel alarms from chat.
8. Return to Tickets and verify the alarm button is inactive.

- [ ] **Step 2: Add failing accessibility tests**

Assert:

- The setup toggle rows expose tap and toggled semantics.
- Alarm button labels match active state.
- New Assistant messages expose a live region.
- Send and microphone buttons expose tap actions.
- The disable dialog has explicit action labels.
- `tester.takeException()` stays null at 200 percent text scale.

- [ ] **Step 3: Add a keyboard-layout test**

Focus the composer field on a 390 by 844 logical-pixel viewport, simulate a bottom view inset, and verify the composer and newest message remain visible with no overflow.

- [ ] **Step 4: Run focused tests and fix only demonstrated failures**

Run each new test by exact `--plain-name`. For every failure, change the smallest responsible widget, rerun the focused test, then rerun related tests.

- [ ] **Step 5: Format and run full verification**

```powershell
rtk dart format lib test
rtk flutter test
rtk flutter analyze
rtk git diff --check
rtk flutter build apk --debug --no-pub
```

Expected:

- All tests pass.
- `flutter analyze` reports `No issues found!`.
- `git diff --check` prints no output.
- APK builds at `build/app/outputs/flutter-apk/app-debug.apk`.

- [ ] **Step 6: Install on Medium Phone API 36.1**

```powershell
rtk flutter devices
rtk flutter install -d emulator-5554 --use-application-binary build\app\outputs\flutter-apk\app-debug.apk
```

Open the app and manually inspect:

- Alarm setup after payment.
- Active red alarm button.
- Disable confirmation dialog.
- Activation and deactivation snackbar messages.
- Typed and voice messages in one timeline.
- Chat commands for status and cancellation.
- Keyboard behavior, scrolling, and bottom navigation.

- [ ] **Step 7: Capture final screenshots**

Capture at least the alarm setup sheet, active alarm ticket, unified Assistant timeline, and disable dialog. Inspect each image for clipping, overlap, contrast, and correct state.

- [ ] **Step 8: Commit final verification fixes**

```powershell
rtk git add lib test
rtk git commit -m "test: cover assistant chat and travel alarms"
```

Do not create an empty commit when verification requires no code or test changes.

---

## Completion Checklist

- [ ] The post-payment sheet defaults both alarm categories to active.
- [ ] `Lewati` leaves both categories inactive.
- [ ] Ticket and Assistant display one shared in-memory state.
- [ ] Active alarm controls use label, icon, color, and semantics.
- [ ] Disabling an active alarm requires confirmation.
- [ ] Typed and voice messages appear in one timeline.
- [ ] Five local alarm commands return deterministic responses.
- [ ] No-ticket and unknown-command states offer recovery actions.
- [ ] Voice timers stop when Assistant closes; travel alarms remain unchanged.
- [ ] The UI works at 200 percent text scale and with keyboard insets.
- [ ] Full tests, analysis, diff check, APK build, and emulator inspection pass.
