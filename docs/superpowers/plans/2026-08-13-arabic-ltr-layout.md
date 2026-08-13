# Arabic LTR Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep application geometry LTR while Arabic translations continue to render Arabic character runs from right to left.

**Architecture:** Override the inherited `Directionality` once through `MaterialApp.router.builder`. Keep `locale` set to Arabic so localization lookup and Unicode bidirectional shaping remain active, while every routed screen receives stable LTR widget geometry.

**Tech Stack:** Flutter, generated `AppLocalizations`, `flutter_test`

## Global Constraints

- Arabic remains a supported, persisted locale.
- Buttons, navigation bars, icons, component order, and directional spacing remain in their existing LTR positions.
- Translation catalogs, routing, data models, and backend behavior do not change.
- Indonesian, English, and Simplified Chinese behavior does not change.

---

### Task 1: Fix application direction without changing Arabic localization

**Files:**
- Modify: `lib/main.dart:83-98`
- Modify: `test/language_page_test.dart:107-117`
- Test: `test/language_page_test.dart`

**Interfaces:**
- Consumes: `AppLocale.arabic`, `MaterialApp.router.builder`, generated Arabic `AppLocalizations`
- Produces: an LTR `Directionality` inherited by every routed application screen

- [ ] **Step 1: Change the Arabic regression assertions first**

Change both Arabic page assertions to `TextDirection.ltr`. Replace the expected right chevron with the left chevron, and retain the exact Arabic localized feedback assertion.

- [ ] **Step 2: Run the focused test and verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/language_page_test.dart`

Expected: FAIL because Arabic currently supplies `TextDirection.rtl` and the right chevron.

- [ ] **Step 3: Add the application boundary override**

Add this property to `MaterialApp.router`:

```dart
builder: (context, child) => Directionality(
  textDirection: TextDirection.ltr,
  child: child!,
),
```

Do not modify `locale`, localization delegates, supported locales, translation catalogs, or individual pages.

- [ ] **Step 4: Run focused and complete verification**

Run:

```powershell
& 'C:\src\flutter\bin\flutter.bat' test test/language_page_test.dart
& 'C:\src\flutter\bin\flutter.bat' test
& 'C:\src\flutter\bin\flutter.bat' analyze
```

Expected: locale tests and the full test suite pass. Static analysis introduces no new diagnostics; the three pre-existing `schematic_map_painter.dart` diagnostics may remain.

- [ ] **Step 5: Verify on Pixel 9**

Install with:

```powershell
& 'C:\src\flutter\bin\flutter.bat' run -d emulator-5554 --no-resident
```

Select Arabic and inspect the language page and bottom navigation. Confirm Arabic labels remain visible, navbar order stays fixed, and back icons remain left-facing.

- [ ] **Step 6: Commit the implementation separately**

```powershell
git add -- lib/main.dart test/language_page_test.dart
git commit -m "fix(localization): keep Arabic application layout LTR"
```
