# Traceable Multilingual Merge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Merge Brandon's four-language implementation into `dev1-riyadh` with a real merge commit while preserving the target UI and every pre-existing working-tree change.

**Architecture:** Merge the reviewed `Brandon-Dev2` tip as the second parent, retain Brandon's ARB catalogs, locale model, controller, storage, and tests, and resolve the seven known conflicts from the target versions. Combine the target's authentication lifecycle with the incoming persistent locale controller, expose the four canonical locale tags to profile synchronization, and force the application child to remain LTR for Arabic.

**Tech Stack:** Flutter/Dart, Flutter `gen-l10n`, `shared_preferences`, Node.js/TypeScript, Express, Zod, Git.

---

## File Map

Incoming files retained from Brandon:

- `lib/core/localization/app_locale.dart`: supported locale enum and startup resolution.
- `lib/core/localization/locale_controller.dart`: active locale state and persistence orchestration.
- `lib/core/localization/locale_storage.dart`: `shared_preferences` adapter.
- `lib/features/profile/presentation/models/app_locale_presentation.dart`: localized language names and descriptions.
- `lib/l10n/app_ar.arb`, `lib/l10n/app_zh.arb`, `lib/l10n/app_zh_Hans.arb`: Arabic and Simplified Chinese catalogs.
- `test/app_locale_test.dart`, `test/locale_controller_test.dart`, `test/localization_catalog_test.dart`, `test/language_page_test.dart`: locale policy, persistence, catalog, UI, and LTR coverage.
- `test/helpers/fake_locale_storage.dart`, `test/helpers/localized_test_app.dart`: localization test support.

Conflict resolutions and integration edits:

- `lib/main.dart`: combine the target auth/travel-alarm lifecycle with Brandon's persistent locale controller and fixed LTR builder.
- `lib/core/localization/locale_provider.dart`: expose `LocaleController` instead of `ValueNotifier<Locale>`.
- `lib/features/profile/presentation/pages/language_page.dart`: keep the target page design and account update behavior while listing all four locales.
- `lib/features/profile/presentation/pages/profile_page.dart`: keep the target page design and show the active localized language name.
- `lib/features/home/presentation/pages/home_page.dart`: keep the target version so Brandon's older UI cannot replace it.
- `pubspec.yaml`: keep target dependencies and add `shared_preferences`.
- `pubspec.lock`, `macos/Flutter/GeneratedPluginRegistrant.swift`: regenerate from the resolved manifest.
- `timetable_backend/src/presentation/controllers/profileController.ts`: accept the four canonical locale tags already supported by the mobile app.
- `timetable_backend/tests/profileLanguageValidation.test.ts`: verify account profile language validation.

Other incoming non-conflicting widget edits remain only when they localize text or make translated text overflow-safe. Any visual replacement found in the final audit is reverted to the target presentation.

### Task 1: Pin Brandon's Source and Protect Local Work

**Files:**

- No source files modified.
- Git metadata: remote configuration and named stash.

- [ ] **Step 1: Confirm the target branch and capture the current state**

Run:

```powershell
rtk git branch --show-current
rtk git status --short --branch
rtk git log -1 --oneline
```

Expected: branch is `dev1-riyadh`; status shows the user's current staged, modified, and untracked work; the latest commit includes the approved merge design/plan history.

- [ ] **Step 2: Configure the traceable source remote**

Run:

```powershell
rtk git remote add brandon https://github.com/BrandonSjt/Timetable-scheduling.git
rtk git fetch brandon Brandon-Dev2
rtk git rev-parse refs/remotes/brandon/Brandon-Dev2
```

Expected: the final command prints `7d4da01edddac0e668c16b35a43a8f6c0714fc95`. If `brandon` already exists, verify `rtk git remote get-url brandon` prints the same URL instead of adding it again. If the fetched tip differs, stop and review the new commits before merging.

- [ ] **Step 3: Save all visible local work in a named safety stash**

Run:

```powershell
rtk git stash push --include-untracked -m "pre-multilingual-merge-2026-08-14"
rtk git stash list --max-count=3
rtk git stash show --include-untracked --name-status "stash@{0}"
```

Expected: the first stash is named `pre-multilingual-merge-2026-08-14`, and its file list contains every staged, modified, and untracked path reported in Step 1.

- [ ] **Step 4: Verify the merge will start from a clean tree**

Run:

```powershell
rtk git status --porcelain=v1 --untracked-files=all
```

Expected: no output. Do not begin the merge if any pre-existing source file remains outside the stash.

### Task 2: Start the True Merge and Establish Conflict Ownership

**Files:**

- Preserve target: `lib/features/home/presentation/pages/home_page.dart`
- Resolve manually: `lib/features/profile/presentation/pages/language_page.dart`
- Resolve manually: `lib/features/profile/presentation/pages/profile_page.dart`
- Resolve manually: `lib/main.dart`
- Regenerate: `macos/Flutter/GeneratedPluginRegistrant.swift`
- Resolve then regenerate: `pubspec.yaml`, `pubspec.lock`

- [ ] **Step 1: Start the non-fast-forward merge without committing**

Run:

```powershell
rtk git merge --no-ff --no-commit 7d4da01edddac0e668c16b35a43a8f6c0714fc95
```

Expected: Git pauses with conflicts in exactly these seven paths: `home_page.dart`, `language_page.dart`, `profile_page.dart`, `main.dart`, `GeneratedPluginRegistrant.swift`, `pubspec.lock`, and `pubspec.yaml`. The merge remains active.

- [ ] **Step 2: Restore the target side of all conflicted presentation and generated files**

Run:

```powershell
rtk git checkout --ours -- lib/features/home/presentation/pages/home_page.dart
rtk git checkout --ours -- lib/features/profile/presentation/pages/language_page.dart
rtk git checkout --ours -- lib/features/profile/presentation/pages/profile_page.dart
rtk git checkout --ours -- lib/main.dart
rtk git checkout --ours -- pubspec.yaml
rtk git checkout --ours -- pubspec.lock
rtk git checkout --ours -- macos/Flutter/GeneratedPluginRegistrant.swift
```

Expected: the current UI and target dependency set are restored as the baseline. `rtk git diff --name-only --diff-filter=U` still lists these paths until their resolved versions are staged later.

- [ ] **Step 3: Verify Brandon's non-conflicting localization files are present**

Run:

```powershell
rtk git status --short
rtk rg -n "enum AppLocale|simplifiedChinese|arabic" lib/core/localization
rtk rg -n '"@@locale": "(ar|zh)' lib/l10n/app_ar.arb lib/l10n/app_zh.arb lib/l10n/app_zh_Hans.arb
```

Expected: `AppLocale`, `LocaleController`, `LocaleStorage`, the Arabic/Chinese catalogs, and Brandon's localization tests appear as incoming additions.

### Task 3: Resolve the Flutter Runtime and Dependency Integration

**Files:**

- Modify: `pubspec.yaml`
- Modify: `lib/main.dart`
- Modify: `lib/core/localization/locale_provider.dart`
- Regenerate: `pubspec.lock`
- Regenerate: `macos/Flutter/GeneratedPluginRegistrant.swift`
- Regenerate: `lib/l10n/app_localizations*.dart`

- [ ] **Step 1: Demonstrate that the incoming tests cannot pass against the target runtime yet**

Run:

```powershell
rtk flutter test test/app_locale_test.dart test/locale_controller_test.dart test/language_page_test.dart
```

Expected: FAIL because the merge conflicts are unresolved and the target `MyApp`/locale provider still use `ValueNotifier<Locale>`.

- [ ] **Step 2: Add the persistence dependency without replacing target dependencies**

Add this entry under `dependencies` in `pubspec.yaml`, retaining `flutter_secure_storage` and every other target dependency:

```yaml
  shared_preferences: ^2.5.5
```

- [ ] **Step 3: Combine persistent locale startup with the existing auth and travel-alarm controllers**

Resolve `lib/main.dart` with these imports and runtime shapes while keeping the target's `AuthScope`, `AuthController`, `AuthRepositoryImpl`, and travel-alarm code:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/app_locale.dart';
import 'core/localization/locale_controller.dart';
import 'core/localization/locale_provider.dart';
import 'core/localization/locale_storage.dart';
```

Use asynchronous startup and injectable locale ownership:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = await LocaleController.load(
    storage: SharedPreferencesLocaleStorage(SharedPreferencesAsync()),
    deviceLocales: WidgetsBinding.instance.platformDispatcher.locales,
  );
  runApp(MyApp(localeController: localeController));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.localeController});

  final LocaleController? localeController;
```

Replace `_localeNotifier` with:

```dart
late final LocaleController _localeController;
late final bool _ownsLocaleController;
```

Initialize the controller before the existing auth bootstrap:

```dart
_ownsLocaleController = widget.localeController == null;
_localeController =
    widget.localeController ??
    LocaleController(initialLocale: AppLocale.indonesian);
```

Keep account-language synchronization, but resolve canonical locale tags safely:

```dart
void _handleAuthChange() {
  final appLocale = AppLocale.fromStorageTag(_authController.user?.language);
  if (appLocale != null && _localeController.value != appLocale) {
    unawaited(_localeController.select(appLocale));
  }
}
```

Dispose `_localeController` only when `MyApp` created it:

```dart
if (_ownsLocaleController) {
  _localeController.dispose();
}
```

Keep the target nesting order `LocaleScope -> AuthScope -> TravelAlarmScope`, replace the locale builder with `ValueListenableBuilder<AppLocale>`, set `locale: appLocale.locale`, and retain the incoming fixed-direction builder:

```dart
builder: (context, child) => Directionality(
  textDirection: TextDirection.ltr,
  child: child!,
),
```

- [ ] **Step 4: Confirm `LocaleScope` exposes the typed controller**

The resolved `lib/core/localization/locale_provider.dart` must contain:

```dart
class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    super.key,
    required LocaleController super.notifier,
    required super.child,
  });

  static LocaleController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleScope>()!.notifier!;
  }
}
```

- [ ] **Step 5: Regenerate package and localization artifacts**

Run:

```powershell
rtk flutter pub get
rtk flutter gen-l10n
```

Expected: `pubspec.lock`, the macOS plugin registrant, and generated localization Dart files contain `shared_preferences` and all four supported locales without conflict markers.

### Task 4: Preserve the Target UI While Connecting Four-Language Selection

**Files:**

- Modify: `lib/features/profile/presentation/pages/language_page.dart`
- Modify: `lib/features/profile/presentation/pages/profile_page.dart`
- Preserve: `lib/features/home/presentation/pages/home_page.dart`
- Test: `test/language_page_test.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Keep the target language-page shell and add only locale model imports**

Retain the target `ProfileDetailScaffold`, `_LanguageOption`, container styling, spacing, preview, and apply button. Use these imports in addition to the existing auth scope:

```dart
import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/auth_scope.dart';
import '../models/app_locale_presentation.dart';
import '../widgets/profile_detail_scaffold.dart';
```

- [ ] **Step 2: Combine local persistence with the target's authenticated profile update**

Replace `_applyLanguage` with:

```dart
Future<void> _applyLanguage(AppLocale newLocale) async {
  final saved = await LocaleScope.of(context).select(newLocale);

  final auth = AuthScope.of(context, listen: false);
  if (auth.isAuthenticated) {
    await auth.updateProfile(language: newLocale.storageTag);
  }

  await WidgetsBinding.instance.endOfFrame;
  if (!mounted) return;
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? l10n.languageAppliedSnackbar
              : l10n.languageSaveFailedSnackbar,
        ),
      ),
    );
}
```

- [ ] **Step 3: Replace only the two hard-coded options with the four-value loop**

Keep all surrounding target layout code and use:

```dart
final currentLocale = LocaleScope.of(context).value;
```

Then render:

```dart
for (final option in AppLocale.values) ...[
  _LanguageOption(
    title: option.localizedName(l10n),
    subtitle: option.localizedDescription(l10n),
    selected: currentLocale == option,
    onTap: () => _applyLanguage(option),
  ),
  if (option != AppLocale.values.last) const SizedBox(height: 12),
],
```

- [ ] **Step 4: Show the selected language in the target profile UI**

Add:

```dart
import '../models/app_locale_presentation.dart';
```

Replace the English/Indonesian boolean subtitle in `lib/features/profile/presentation/pages/profile_page.dart` with:

```dart
final currentLocale = LocaleScope.of(context).value;
```

and:

```dart
subtitle: currentLocale.localizedName(l10n),
```

Do not change the page scaffold, header, menu-card styling, spacing, or navigation.

- [ ] **Step 5: Prove the four-language UI and fixed Arabic direction work**

Run:

```powershell
rtk flutter test test/language_page_test.dart test/widget_test.dart
```

Expected: PASS; the language page offers Indonesian, English, Simplified Chinese, and Arabic; Chinese selection persists; Arabic text renders with `TextDirection.ltr`; existing account navigation tests still pass.

### Task 5: Keep Authenticated Language Synchronization Compatible

**Files:**

- Create: `timetable_backend/tests/profileLanguageValidation.test.ts`
- Modify: `timetable_backend/src/presentation/controllers/profileController.ts`

- [ ] **Step 1: Export the validation boundary and write the failing backend test**

Change only the declaration visibility first:

```typescript
export const updateProfileSchema = z.object({
```

Create `timetable_backend/tests/profileLanguageValidation.test.ts`:

```typescript
import assert from 'node:assert/strict';
import test from 'node:test';
import { updateProfileSchema } from '../src/presentation/controllers/profileController';

test('profile accepts every canonical mobile locale tag', () => {
  for (const language of ['id', 'en', 'zh-Hans', 'ar']) {
    assert.equal(
      updateProfileSchema.safeParse({ language }).success,
      true,
      `expected ${language} to be accepted`,
    );
  }
});

test('profile rejects unsupported locale tags', () => {
  for (const language of ['zh-Hant', 'fr', '']) {
    assert.equal(
      updateProfileSchema.safeParse({ language }).success,
      false,
      `expected ${language} to be rejected`,
    );
  }
});
```

- [ ] **Step 2: Run the test to verify the new locales fail**

Run:

```powershell
rtk node --import tsx --test --test-name-pattern="profile accepts every canonical mobile locale tag" tests/profileLanguageValidation.test.ts
```

Working directory: `timetable_backend`.

Expected: FAIL because `zh-Hans` and `ar` are rejected by the existing `z.enum(['id', 'en'])`.

- [ ] **Step 3: Expand the backend enum minimally**

Use:

```typescript
language: z.enum(['id', 'en', 'zh-Hans', 'ar']).optional(),
```

No Prisma migration is needed because the column is already an unrestricted `String`.

- [ ] **Step 4: Run the backend validation and build checks**

Run:

```powershell
rtk node --import tsx --test --test-name-pattern="profile (accepts|rejects)" tests/profileLanguageValidation.test.ts
rtk npm run build
```

Working directory: `timetable_backend`.

Expected: both profile language tests PASS and TypeScript exits with code 0.

### Task 6: Verify and Commit the Merge Before Restoring Local Work

**Files:**

- All merge files staged as one true merge commit.

- [ ] **Step 1: Format only localization-related Dart files**

Run:

```powershell
rtk dart format lib/main.dart lib/core/localization lib/features/profile/presentation/models/app_locale_presentation.dart lib/features/profile/presentation/pages/language_page.dart lib/features/profile/presentation/pages/profile_page.dart test/app_locale_test.dart test/locale_controller_test.dart test/localization_catalog_test.dart test/language_page_test.dart test/helpers/fake_locale_storage.dart test/helpers/localized_test_app.dart
```

Expected: formatter exits 0 without touching unrelated target UI files.

- [ ] **Step 2: Run the focused localization suite**

Run:

```powershell
rtk flutter test test/app_locale_test.dart test/locale_controller_test.dart test/localization_catalog_test.dart test/language_page_test.dart
```

Expected: all focused tests PASS.

- [ ] **Step 3: Run complete Flutter and backend verification**

Run:

```powershell
rtk flutter gen-l10n
rtk flutter analyze
rtk flutter test
rtk npm test
rtk npm run build
```

Run the final two commands from `timetable_backend`.

Expected: localization generation exits 0, Flutter analysis reports no issues, all Flutter tests pass, all backend tests pass, and TypeScript builds successfully.

- [ ] **Step 4: Audit merge resolution and stage it**

Run:

```powershell
rtk rg -n "^(<<<<<<<|=======|>>>>>>>)" lib test pubspec.yaml pubspec.lock macos timetable_backend/src timetable_backend/tests
rtk git diff --check
rtk git diff --name-only --diff-filter=U
rtk git status --short
rtk git add pubspec.yaml pubspec.lock macos/Flutter/GeneratedPluginRegistrant.swift lib test timetable_backend/src/presentation/controllers/profileController.ts timetable_backend/tests/profileLanguageValidation.test.ts
rtk git diff --cached --check
```

Expected: no conflict markers, no whitespace errors, no unmerged paths, and only intended multilingual/merge files are staged.

- [ ] **Step 5: Create the true merge commit**

Run:

```powershell
rtk git commit -m "merge: integrate Brandon multilingual support"
rtk git rev-parse HEAD^2
rtk git merge-base --is-ancestor 7d4da01edddac0e668c16b35a43a8f6c0714fc95 HEAD
```

Expected: the second parent is `7d4da01edddac0e668c16b35a43a8f6c0714fc95`, and the ancestor check exits 0.

### Task 7: Restore the User's Work and Verify the Combined Tree

**Files:**

- Restore every path recorded in Task 1.
- Resolve overlap especially in `profile_page.dart`, `tickets_page.dart`, theme files, route-result files, tests, and backend route/network files without discarding either the user's work or the locale integration.

- [ ] **Step 1: Apply the safety stash without dropping it**

Run:

```powershell
rtk git stash apply "stash@{0}"
rtk git status --short
rtk git diff --name-only --diff-filter=U
```

Expected: the original modified/untracked paths return. If conflicts occur, the last command lists them while the safety stash remains available.

- [ ] **Step 2: Resolve any stash conflicts with a combined policy**

For every conflicted visual file, retain the stashed user's styling/layout/content and reapply only the locale imports, `AppLocale`/`LocaleController` types, localized text calls, and four-language callbacks established in Tasks 3–4. For backend conflicts, retain user route/network work and keep the four-value profile language enum.

After editing with `apply_patch`, run:

```powershell
rtk rg -n "^(<<<<<<<|=======|>>>>>>>)" lib test timetable_backend
rtk git add -u
rtk git restore --staged .
rtk git diff --name-only --diff-filter=U
rtk git status --short
```

Expected: no markers and no unmerged paths; the working tree is intentionally dirty and unstaged with the user's restored work. `git add -u` marks resolved tracked paths, and `git restore --staged .` immediately returns the restored work to the working tree without changing file contents.

- [ ] **Step 3: Compare restored paths to the saved snapshot**

Run:

```powershell
rtk git stash show --include-untracked --name-status "stash@{0}"
rtk git status --short
```

Expected: every meaningful source/test path from the stash is present in the combined working tree or has become identical because the merge already contains the same content. Investigate any missing path before dropping the stash.

- [ ] **Step 4: Run fresh verification on the final combined working tree**

Run:

```powershell
rtk flutter gen-l10n
rtk flutter analyze
rtk flutter test
rtk npm test
rtk npm run build
```

Run the final two commands from `timetable_backend`.

Expected: all commands exit 0 after the user's work is restored.

- [ ] **Step 5: Perform the final traceability and UI-preservation audit**

Run:

```powershell
rtk git show --no-patch --format=fuller HEAD
rtk git rev-parse HEAD^2
rtk git merge-base --is-ancestor 7d4da01edddac0e668c16b35a43a8f6c0714fc95 HEAD
rtk git diff HEAD -- lib/core/theme lib/features/profile/presentation lib/features/home/presentation lib/features/tickets/presentation
```

Expected: HEAD is the merge commit, its second parent is Brandon's reviewed tip, the ancestor check exits 0, and the remaining UI diff consists of the user's pre-merge work plus minimal locale wiring rather than Brandon's older visual implementation.

- [ ] **Step 6: Drop the safety stash only after all comparisons and verification pass**

Run:

```powershell
rtk git stash drop "stash@{0}"
rtk git status --short --branch
```

Expected: the named safety stash is removed only after its contents are restored and verified; the branch contains the merge commit and the working tree still shows the user's intentionally uncommitted work.
