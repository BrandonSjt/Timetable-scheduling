# Native MethodChannel TTS Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `flutter_tts` with project-owned Android TextToSpeech while restoring Gradle 9.1.0, AGP 9.0.1, and Kotlin 2.3.20.

**Architecture:** Dart keeps the existing `RouteSpeechService` interface and route narration builder. A focused `NativeRouteSpeechService` calls `kai_access/native_tts`; Android `MainActivity` owns TextToSpeech initialization, utterance callbacks, stop, and shutdown.

**Tech Stack:** Flutter 3.44, Dart MethodChannel, Android TextToSpeech, Kotlin 2.3.20, AGP 9.0.1, Gradle 9.1.0.

---

### Task 1: MethodChannel adapter

**Files:**
- Create: `lib/features/route_result/data/services/native_route_speech_service.dart`
- Create: `test/native_route_speech_service_test.dart`
- Modify: `lib/features/route_result/presentation/pages/route_result_page.dart`

- [ ] Write a failing channel-mock test for `speak`, `pause`, and `stop` payloads.
- [ ] Implement the adapter with channel `kai_access/native_tts`.
- [ ] Inject the adapter into `RouteResultPage` and run focused Flutter tests.

### Task 2: Android TextToSpeech bridge

**Files:**
- Modify: `android/app/src/main/kotlin/com/example/timetable/MainActivity.kt`

- [ ] Configure a MethodChannel in `configureFlutterEngine`.
- [ ] Initialize one TextToSpeech engine, queue one pre-init request, and map locale/rate.
- [ ] Complete pending `speak` results from `UtteranceProgressListener`.
- [ ] Implement pause as stop, implement stop, and shutdown on destroy.

### Task 3: Restore modern Android toolchain

**Files:**
- Modify: `android/gradle/wrapper/gradle-wrapper.properties`
- Modify: `android/settings.gradle.kts`
- Modify: `android/app/build.gradle.kts`
- Modify: `android/gradle.properties`
- Modify: `pubspec.yaml`
- Regenerate: `pubspec.lock` and platform plugin registrants

- [ ] Remove `flutter_tts` from pubspec and regenerate dependencies.
- [ ] Restore Gradle 9.1.0, AGP 9.0.1, and Kotlin 2.3.20.
- [ ] Use AGP 9 built-in Kotlin in the application module.

### Task 4: Verification

- [ ] Run Flutter analyze and route/TTS tests.
- [ ] Build the debug APK with the emulator API URL.
- [ ] Install on `emulator-5554`, exercise Bogor to Jakarta Kota, and inspect TTS logs.
- [ ] Confirm backend health and clean diff whitespace.
