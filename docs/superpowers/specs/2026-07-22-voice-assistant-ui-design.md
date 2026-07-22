# Voice Assistant UI Design

## Goal

Replace the Promo tab with an accessible, voice-first travel assistant prototype. The prototype helps blind and low-vision users plan trips, inspect the next train, open tickets, and reach help without requiring an AI backend or microphone integration.

## Scope

The first release implements an interactive Flutter UI with deterministic local responses. It does not request microphone permission, record audio, perform speech recognition, synthesize speech, call an AI API, or listen for a real wake word.

The UI simulates two entry methods:

- Tap the main microphone button once to start a conversation.
- Enable the optional `Halo Asisten` mode while the Assistant page remains open.

Leaving the page disables wake-word mode.

## Navigation

- Replace the `Promo` bottom-navigation label with `Asisten`.
- Replace the promo icon with a headset microphone icon.
- Add `/asisten` as the main Assistant route.
- Keep `/promo` as a redirect to `/asisten` for compatibility.
- Connect quick actions to existing routes:
  - `Rencanakan perjalanan` opens `/cari-stasiun`.
  - `Kereta berikutnya` opens `/timetable`.
  - `Tiket saya` opens `/tiket`.
  - `Bantuan petugas` opens `/pusat-bantuan`.

## Page Structure

The page uses a quiet, task-focused layout rather than a traditional chat screen.

1. Header with `Asisten Perjalanan` and the current availability state.
2. Wake-word setting with a switch, clear active state, and page-only scope.
3. Large central microphone control with an icon and explicit state label.
4. Latest user transcript and assistant response in one compact conversation area.
5. Contextual response actions such as `Pakai rute ini`, `Pilihan lain`, `Ulangi`, and `Batalkan`.
6. Four quick actions for trip planning, timetable, tickets, and staff help.
7. Existing bottom navigation with the Assistant tab selected.

## Interaction States

The prototype uses a small state machine:

- `ready`: waiting for a tap or simulated wake word.
- `listening`: displays a listening indicator and stop action.
- `processing`: disables duplicate input and shows progress.
- `speaking`: displays the simulated route response.
- `confirmation`: waits for the user before opening another page.
- `error`: offers retry and quick actions.

A demo conversation follows this path:

1. The user starts listening.
2. The UI shows a local transcript: `Saya ingin ke Manggarai dari Setiabudi.`
3. The UI processes the request.
4. The assistant responds: `Rute tercepat membutuhkan 7 menit. Kereta tiba 5 menit lagi.`
5. The assistant requests confirmation before navigation.

Timers drive state transitions and must be cancelled when the page is disposed.

## Accessibility

- Give every interactive control a concise semantic label and state value.
- Keep touch targets at least 48 by 48 logical pixels.
- Use a predictable TalkBack traversal order from page status to voice control, response, actions, and bottom navigation.
- Announce state changes through semantic live regions where Flutter supports them.
- Pair color with text and icons; color alone never communicates state.
- Keep visible text concise because TalkBack reads the same content.
- Prevent decorative child widgets from producing duplicate TalkBack labels.
- Preserve high contrast between text, controls, focus states, and surfaces.

## Visual Direction

Use the app's existing blue, green, orange, white, and dark-neutral palette. The microphone control is the strongest visual element, but it must not push quick actions below the first usable viewport. Cards use restrained borders and small corner radii. The page avoids decorative gradients, oversized marketing text, and long chat-bubble histories.

## Error Handling

The local prototype exposes a recoverable error state for testing. It says `Saya belum memahami tujuanmu` and provides `Coba lagi` plus the four quick actions. Navigation never occurs automatically after a simulated response.

## Architecture

- Place the feature under `lib/features/assistant/`.
- Keep interaction state and timers in a small controller independent of widgets.
- Keep the page responsible for layout and routing callbacks.
- Build focused widgets for wake-word mode, voice interaction, assistant response, and quick actions.
- Avoid adding state-management or speech packages for this UI-only phase.

This boundary allows a later speech or AI adapter to replace local simulation without redesigning the page.

## Testing

Widget tests cover:

- The bottom navigation displays `Asisten` instead of `Promo`.
- `/promo` redirects to the Assistant page.
- The wake-word switch changes state and resets when the page closes.
- A microphone tap advances through listening, processing, and response states.
- Retry, repeat, cancel, and confirmation actions behave predictably.
- Each quick action opens its existing destination.
- Important controls expose semantic labels.

Verification includes `flutter analyze`, `flutter test`, an Android debug build, installation on `Medium Phone API 36.1`, and visual inspection at the emulator viewport.
