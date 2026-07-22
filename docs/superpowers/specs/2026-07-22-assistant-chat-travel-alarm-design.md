# Assistant Chat and Travel Alarm Design

## Summary

Extend the existing voice-first Assistant with a unified voice and text conversation timeline. Add simulated travel alarms that users can activate after buying a ticket, control from an active ticket, and manage through Assistant commands.

This release is a UI prototype. It does not schedule Android notifications, run background tasks, persist alarm state after the app closes, or fetch live train data.

## Goals

- Let users type and speak within one Assistant conversation.
- Keep the existing voice-first interaction prominent.
- Offer alarm setup immediately after a successful ticket purchase.
- Support departure alarms and destination or transfer alarms.
- Let users inspect, activate, and cancel alarms through chat.
- Make every alarm interaction understandable through TalkBack without relying on color.
- Support 200 percent text scaling without clipped content or hidden controls.

## Non-Goals

- Android notification channels, exact alarms, sound, or vibration.
- Background countdowns when the app is closed.
- Live train positions or backend integration.
- Natural-language understanding beyond the defined local demo commands.
- Permanent alarm or conversation storage.

## Demo Journey

The prototype uses an active ticket from Setiabudi to Manggarai. The train initially arrives in five minutes. The UI can advance to one minute before arrival. The destination alarm can advance to one station before Manggarai.

### After Payment

1. A successful payment opens the `Aktifkan pengingat perjalanan?` bottom sheet.
2. The sheet enables both alarm categories by default:
   - `Kereta datang`: reminders at five minutes and one minute before the train reaches Setiabudi.
   - `Turun atau transit`: a reminder one station before a transfer and one station before Manggarai.
3. The user may disable either category before confirming.
4. `Aktifkan alarm` closes the sheet, marks the ticket active, and shows an accessible success message.
5. `Lewati` closes the sheet without enabling an alarm.

### Active Ticket and Route

The active ticket or journey detail displays a floating alarm button inspired by the supplied references. The inactive state uses a neutral surface. The active state uses red, an active label, and updated semantics.

Tapping an inactive button activates the selected alarm categories and announces the change. Tapping an active button opens a confirmation dialog. The dialog identifies the alarm being disabled and offers `Kembali` and `Matikan alarm`.

### Assistant Conversation

Voice transcripts, typed messages, Assistant replies, and alarm status cards appear in one chronological timeline. A composer remains above the bottom navigation and contains a text field, send button, and microphone button.

The local command handler recognizes these intents:

- Activate every alarm for the active ticket.
- Report when the train arrives.
- Report the next alarm.
- Disable the destination alarm.
- Cancel every alarm.

Example inputs include:

- `Aktifkan semua alarm tiket saya`
- `Kereta saya datang berapa menit lagi?`
- `Alarm berikutnya kapan?`
- `Matikan alarm tujuan`
- `Batalkan semua alarm`

Unknown messages produce `Saya belum memahami perintah itu` and show concise command examples. Alarm commands without an active ticket produce a `Belum ada tiket aktif` card with a `Cari perjalanan` action.

## Interface Structure

### Assistant Page

The page retains its header, wake-word setting, and large voice control. The conversation timeline appears after the voice panel. Quick actions remain available after the conversation content. The composer stays above the application bottom navigation and respects keyboard and safe-area insets.

When the timeline grows, the page scrolls to the newest message without moving focus unexpectedly. Opening the keyboard must not cover the composer or the newest message.

### Conversation Items

The timeline supports four item types:

- User text or voice transcript.
- Assistant text response.
- Travel alarm status card.
- Recoverable error or empty-ticket card.

Message bubbles use restrained surfaces and clear sender labels. Alarm cards show the route, active alarm categories, next trigger, and available actions. Cards do not nest inside other cards.

### Alarm Setup Sheet

The setup sheet contains the active ticket summary, two checkbox or switch rows, a primary `Aktifkan alarm` action, and a secondary `Lewati` action. It explains that this prototype simulates reminders only while the app is open.

### Floating Alarm Button

The button uses the alarm icon from Material Icons. It has a stable touch target of at least 48 by 48 logical pixels. The active state changes color, label, icon treatment, and semantics. Color alone never communicates state.

## Architecture

### AssistantConversationController

This controller owns the ordered conversation items, composer submission state, local command matching, and simulated Assistant replies. It converts existing voice results into the same conversation item model used by typed messages.

### TravelAlarmController

This controller is the single in-memory source of truth for:

- Whether an active ticket exists.
- Whether departure reminders are active.
- Whether destination or transfer reminders are active.
- Minutes until the train arrives.
- Stations until transfer or destination.
- The next simulated alarm description.

It exposes explicit activate, disable, cancel-all, and demo-advance operations. It notifies the Assistant and ticket UI when state changes.

### Shared State Lifetime

The router-level application scope owns one `TravelAlarmController` so the ticket flow and Assistant observe the same state. The state resets when the application process restarts. The conversation controller remains owned by the Assistant page unless routing requirements demand a longer lifetime during implementation.

### Presentation Components

- `AssistantConversationTimeline`: renders ordered conversation items.
- `AssistantComposer`: accepts text and starts the existing voice interaction.
- `TravelAlarmStatusCard`: presents current alarm state and actions.
- `TravelAlarmSetupSheet`: configures alarms after payment.
- `TravelAlarmButton`: toggles alarms from an active ticket or journey.
- `TravelAlarmDisableDialog`: confirms destructive alarm changes.

## Data Flow

### Typed Command

1. The composer trims and submits non-empty text.
2. The conversation controller appends a user message.
3. The local command matcher selects a supported intent.
4. Alarm intents call the travel alarm controller.
5. The conversation controller appends an Assistant response or alarm status card.
6. The timeline announces and reveals the new content.

### Voice Command

1. The existing microphone interaction produces a transcript.
2. The Assistant converts the transcript to a user conversation item.
3. The same local command and response path handles the message.

### Ticket Alarm Setup

1. Payment success opens the alarm setup sheet.
2. The user confirms the selected categories.
3. The sheet activates them through the travel alarm controller.
4. The active ticket and Assistant reflect the same updated state.

## State and Feedback

The alarm state contains separate booleans for departure and destination alarms. The overall alarm button is active when either category is active.

The prototype supports these visible countdown states:

- Departure: `Kereta datang 5 menit lagi`.
- Departure urgent: `Kereta datang 1 menit lagi`.
- Destination: `Turun di Manggarai, 1 stasiun lagi`.
- Transfer: `Transit, 1 stasiun lagi` when the selected route includes a transfer.

State changes produce both visible feedback and a semantics announcement. Snackbars use short messages such as `Alarm perjalanan diaktifkan` and `Alarm perjalanan dinonaktifkan`.

## Accessibility

- The composer text field uses `Ketik pesan untuk Asisten` as its TalkBack label.
- Send and microphone controls expose clear action labels.
- New Assistant messages and alarm changes use focused live regions; the application must not reread the entire timeline.
- The alarm button exposes `Aktifkan alarm perjalanan` when inactive.
- The active button exposes `Alarm perjalanan aktif, ketuk untuk menonaktifkan`.
- Toggle rows expose their selected state and entire-row tap actions.
- The disable dialog places initial focus on its title and uses explicit button labels.
- Every control remains reachable in a logical traversal order.
- The interface supports 200 percent text scaling without overflow.
- Active and urgent states meet contrast requirements and use text or icons in addition to color.

## Error and Empty States

- Empty or whitespace-only messages do not enter the timeline.
- Unknown commands return an explanation and command examples.
- Alarm commands without an active ticket show a recoverable empty-ticket card.
- Repeated activation is idempotent and reports the existing alarm state.
- Repeated cancellation reports that no alarm is active.
- Closing the setup sheet preserves no unconfirmed changes.
- Leaving the Assistant cancels transient voice timers without mutating ticket alarm state.

## Testing

Controller tests cover command matching, conversation ordering, alarm activation, idempotent operations, cancellation, empty-ticket behavior, and simulated countdown transitions.

Widget tests cover:

- The post-payment alarm setup sheet and its default selections.
- Selective alarm activation and the `Lewati` path.
- Active and inactive floating alarm button states.
- The disable confirmation dialog.
- Typed and voice messages in one timeline.
- Supported chat commands and unknown-command feedback.
- Alarm status shared between ticket and Assistant screens.
- TalkBack actions, labels, selected states, and live regions.
- Keyboard-safe composer layout and 200 percent text scaling.

Manual emulator verification uses Medium Phone API 36.1 and checks payment, ticket, Assistant, dialog, snackbar, keyboard, and scrolling states.

## Acceptance Criteria

- Users can activate both alarm categories after payment with one confirmation.
- Users can disable either category before activation.
- An active ticket shows a clear alarm control with active and inactive states.
- Users must confirm before disabling an active alarm from the floating button.
- Typed and spoken messages share one timeline.
- The five defined chat intents return deterministic simulated responses.
- Ticket and Assistant surfaces display the same in-memory alarm state.
- The interface remains usable with TalkBack semantics and 200 percent text scaling.
- The feature requires no backend, notification permission, or Android background scheduling.
