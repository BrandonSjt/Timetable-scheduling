# Sistem-by-Access-KAI

## Backend route configuration

The route result page uses the backend graph endpoint and does not fall back to
dummy routes. Start the app with the API URL for the target device:

```powershell
# Android Emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1

# Physical device on the same trusted LAN
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000/api/v1
```

Station selections from the backend catalog are sent as stable slugs. Map-only
selections retain station names as a compatibility fallback. The available route
modes are fastest, minimum transfers, and accessible. Accessible mode uses the
fastest backend route and native Indonesian/English text-to-speech controls for
speak, repeat, pause, and stop.

Android speech is implemented by the app through a Flutter MethodChannel backed
by Android `TextToSpeech`; it does not depend on a third-party TTS plugin. The
project keeps Gradle 9.1.0, Android Gradle Plugin 9.0.1, and Kotlin 2.3.20.

## Run from Android Studio

1. Open this Flutter project root, not only the `android` subfolder.
2. Start PostgreSQL and the backend at `http://localhost:3000`.
3. Select an Android Emulator and press **Run** on `lib/main.dart`.

The debug build defaults to `http://10.0.2.2:3000/api/v1`, which is the Android
Emulator address for the host computer. No extra environment variable is needed
for Android Studio. For a physical phone, add this to the Flutter run
configuration's additional arguments:

```text
--dart-define=API_BASE_URL=http://<IP-LAN-PC>:3000/api/v1
```

Keep HTTP limited to local debug testing. Production builds should use an HTTPS
API URL.

## Demo release APK

1. Deploy the backend with Neon using `timetable_backend/docs/DEPLOYMENT.md`.
2. Confirm `GET https://<host>/health` returns OK.
3. Build a release APK that points at the public HTTPS API:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://<host>/api/v1
```

4. Install `build/app/outputs/flutter-apk/app-release.apk` on a physical Android
   device. Free-tier cold starts may take ~15–30s; the app shows retry instead of
   treating timeouts as empty data.

# Optional accounts

The app opens in guest mode. Registration and login are optional; guest users
can still search routes, view schedules, buy tickets, complete Xendit checkout,
and open local ticket QR codes.

For Android Studio testing:

1. Start PostgreSQL and the backend on port `3000`.
2. Open this Flutter directory in Android Studio.
3. Start an Android emulator and run the app. The default API URL is
   `http://10.0.2.2:3000/api/v1`.
4. Open **Akun**, then **Masuk atau Buat Akun**.

The refresh token and cached public profile use Android Keystore-backed secure
storage. Passwords and access tokens are never persisted. The current Android
toolchain stays on Gradle `9.1.0`, Android Gradle Plugin `9.0.1`, and Kotlin
`2.3.20`.
