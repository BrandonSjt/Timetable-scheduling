# Voice Assistant UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Promo tab with an accessible, voice-first Assistant prototype that simulates listening and route guidance without a backend.

**Architecture:** A dependency-free `AssistantController` owns the deterministic interaction state and cancellable timers. `AssistantPage` renders focused widgets from controller state and delegates navigation to GoRouter. The router exposes `/asisten`, redirects `/promo`, and the bottom navigation points to the new route.

**Tech Stack:** Flutter, Dart, Material, GoRouter, flutter_test

---

### Task 1: Local assistant interaction state

**Files:**
- Create: `lib/features/assistant/presentation/controllers/assistant_controller.dart`
- Create: `test/assistant_controller_test.dart`

- [ ] **Step 1: Write failing controller tests**

Create tests that verify the initial `ready` state, wake-word toggle, deterministic state progression, cancellation, and timer cleanup.

```dart
final controller = AssistantController(
  listeningDuration: Duration.zero,
  processingDuration: Duration.zero,
);
expect(controller.state, AssistantInteractionState.ready);
controller.toggleWakeWord(true);
expect(controller.wakeWordEnabled, isTrue);
controller.startConversation();
await Future<void>.delayed(Duration.zero);
await Future<void>.delayed(Duration.zero);
expect(controller.state, AssistantInteractionState.confirmation);
expect(controller.userTranscript, contains('Manggarai'));
controller.cancelConversation();
expect(controller.state, AssistantInteractionState.ready);
```

- [ ] **Step 2: Run the controller tests and confirm failure**

Run: `rtk flutter test test/assistant_controller_test.dart`

Expected: FAIL because `AssistantController` does not exist.

- [ ] **Step 3: Implement the minimal controller**

Define:

```dart
enum AssistantInteractionState {
  ready,
  listening,
  processing,
  speaking,
  confirmation,
  error,
}

class AssistantController extends ChangeNotifier {
  AssistantController({
    this.listeningDuration = const Duration(milliseconds: 850),
    this.processingDuration = const Duration(milliseconds: 700),
    this.speakingDuration = const Duration(milliseconds: 650),
  });

  AssistantInteractionState state = AssistantInteractionState.ready;
  bool wakeWordEnabled = false;
  String? userTranscript;
  String? assistantResponse;

  void toggleWakeWord(bool value);
  void startConversation();
  void repeatResponse();
  void cancelConversation();
  void showError();
  void dispose();
}
```

Use one cancellable `Timer` at a time. The normal flow sets the demo transcript, then the route response, then waits in `confirmation`.

- [ ] **Step 4: Run the controller tests**

Run: `rtk flutter test test/assistant_controller_test.dart`

Expected: all controller tests pass.

### Task 2: Accessible Assistant page

**Files:**
- Create: `lib/features/assistant/presentation/pages/assistant_page.dart`
- Create: `lib/features/assistant/presentation/widgets/assistant_voice_panel.dart`
- Create: `lib/features/assistant/presentation/widgets/assistant_response_panel.dart`
- Create: `lib/features/assistant/presentation/widgets/assistant_quick_actions.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Write failing Assistant page tests**

Add widget tests that open `/asisten` and verify:

```dart
expect(find.text('Asisten Perjalanan'), findsOneWidget);
expect(find.text('Dengarkan "Halo Asisten"'), findsOneWidget);
expect(find.byKey(const Key('assistant-microphone-button')), findsOneWidget);
expect(find.text('Rencanakan perjalanan'), findsOneWidget);
expect(find.text('Bantuan petugas'), findsOneWidget);
```

Tap the wake-word switch and assert `Kata pemicu aktif`. Tap the microphone, pump through the configured durations, and assert the transcript, route response, `Pakai rute ini`, `Ulangi`, and `Batalkan`.

- [ ] **Step 2: Run the Assistant widget tests and confirm failure**

Run: `rtk flutter test test/widget_test.dart --plain-name "Assistant"`

Expected: FAIL because the page and route do not exist.

- [ ] **Step 3: Implement the Assistant page and focused widgets**

Build a `StatefulWidget` that owns and listens to `AssistantController`. Use:

```dart
Scaffold(
  backgroundColor: AppColors.background,
  body: SafeArea(
    child: Column(
      children: [
        Expanded(child: SingleChildScrollView(child: assistantContent)),
        const AppBottomNavBar(currentIndex: 3),
      ],
    ),
  ),
)
```

The page must:

- Show a compact header and status badge.
- Expose the wake-word setting through `SwitchListTile` with a semantic label.
- Render an 88-pixel microphone button with a stable key and state-dependent icon, text, and color.
- Show only the latest transcript and response.
- Require `Pakai rute ini` before routing to `/rute`.
- Offer `Ulangi` and `Batalkan` during confirmation.
- Route quick actions to `/cari-stasiun`, `/timetable`, `/tiket`, and `/pusat-bantuan`.
- Keep all touch targets at least 48 logical pixels.

- [ ] **Step 4: Run focused widget tests**

Run: `rtk flutter test test/widget_test.dart --plain-name "Assistant"`

Expected: all Assistant tests pass.

### Task 3: Router and bottom navigation integration

**Files:**
- Modify: `lib/core/routing/router.dart`
- Modify: `lib/shared/widgets/bottom_nav_bar.dart`
- Delete: `lib/features/promo/presentation/pages/promo_page.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Write failing navigation tests**

Add tests that verify the navbar shows `Asisten` and no `Promo`, tapping it opens the Assistant page, and navigating to `/promo` redirects to `/asisten`.

```dart
expect(find.text('Asisten'), findsOneWidget);
expect(find.text('Promo'), findsNothing);
appRouter.go('/promo');
await tester.pumpAndSettle();
expect(find.text('Asisten Perjalanan'), findsOneWidget);
```

- [ ] **Step 2: Run navigation tests and confirm failure**

Run: `rtk flutter test test/widget_test.dart --plain-name "Assistant navigation"`

Expected: FAIL because the navbar still points to Promo.

- [ ] **Step 3: Update routing and navigation**

- Import `AssistantPage` in the router.
- Add a no-transition `/asisten` route.
- Replace the old Promo page route with `GoRoute(path: '/promo', redirect: (_, __) => '/asisten')`.
- Change navbar index 3 route to `/asisten`.
- Change its icons to `Icons.headset_mic_outlined` and `Icons.headset_mic_rounded`.
- Change its label to `Asisten`.
- Remove the unused Promo page.

- [ ] **Step 4: Run navigation and full test suites**

Run: `rtk flutter test test/widget_test.dart --plain-name "Assistant navigation"`

Expected: navigation tests pass.

Run: `rtk flutter test`

Expected: all project tests pass.

### Task 4: Verification on Android emulator

**Files:**
- Modify only if verification exposes a defect.

- [ ] **Step 1: Run static analysis**

Run: `rtk flutter analyze`

Expected: `No issues found!`

- [ ] **Step 2: Build Android debug APK**

Run: `rtk flutter build apk --debug --no-pub`

Expected: `build/app/outputs/flutter-apk/app-debug.apk` is produced.

- [ ] **Step 3: Start or select Medium Phone API 36.1**

Use the configured Android/Flutter device list. Start the existing cold-boot emulator only if it is offline, then wait for `adb devices` to report it as `device`.

- [ ] **Step 4: Install and launch the app**

Run the app on the emulator, open the Assistant tab, toggle wake-word mode, run the microphone simulation, and inspect the confirmation and quick-action states.

- [ ] **Step 5: Capture and inspect a screenshot**

Verify that text fits at the emulator viewport, the bottom navigation remains visible, controls do not overlap, and the primary microphone control and quick actions appear without excessive scrolling.
