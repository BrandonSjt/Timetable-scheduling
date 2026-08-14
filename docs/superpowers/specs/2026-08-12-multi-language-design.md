# Multi-Language Expansion Design

## Goal

Add Simplified Chinese and Modern Standard Arabic to the existing Indonesian and English Flutter localization system. The feature must work offline, preserve the user's language choice across launches, follow the device locale on first launch, and fall back to English when the device language is unsupported.

## Scope

The implementation will:

- add complete Simplified Chinese (`zh_Hans`) and Arabic (`ar`) catalogs for every existing application message;
- preserve identical message keys, metadata, and placeholders across all four ARB catalogs;
- add Indonesian, English, Simplified Chinese, and Arabic options to the language page;
- save the selected locale on the device with `shared_preferences`;
- restore the saved locale before rendering the application;
- resolve a supported device locale on first launch and otherwise use English;
- support right-to-left layout for Arabic and correct only directional layout code that breaks RTL;
- add focused unit and widget tests for locale resolution, persistence, language switching, catalog consistency, and RTL; and
- regenerate Flutter localization output instead of editing generated files by hand.

The implementation will not add an API, backend, remote configuration service, account synchronization, or Traditional Chinese. It will not refactor unrelated application features.

## Locale Policy

The application selects its startup locale in this order:

1. A valid locale saved by the user.
2. A supported device locale.
3. English (`en`).

The resolver recognizes these locales:

| Input locale | Application locale |
| --- | --- |
| `id` and Indonesian regional variants | `id` |
| `en` and English regional variants | `en` |
| `zh_Hans`, `zh_CN`, and `zh_SG` | Simplified Chinese (`zh_Hans`) |
| `ar` and Arabic regional variants | `ar` |
| Any other locale, including `zh_Hant`, `zh_TW`, and `zh_HK` | English (`en`) |

An unknown or malformed saved locale is invalid. The resolver ignores it and continues with device-locale matching, then English.

## Architecture

The application will retain Flutter's current ARB and `gen-l10n` workflow. `AppLocalizations` remains the source of localized UI strings, and `MaterialApp.router` remains the single place that applies the active locale and localization delegates.

A small localization component under `lib/core/localization` will separate three responsibilities:

- `LocaleStorage` reads and writes the locale tag through `shared_preferences`.
- `LocaleController` owns the active locale, resolves the startup locale, changes it, and notifies the widget tree.
- `LocaleScope` exposes the controller to the existing profile and language pages without introducing an unrelated state-management framework.

The controller will accept storage and device locales as dependencies. This boundary keeps startup resolution and persistence testable without starting the complete application.

## Localization Catalogs

The ARB catalogs will remain in `lib/l10n`. The existing Indonesian template will continue to define the message interface.

The feature will add catalogs for Simplified Chinese and Arabic. Each catalog must contain every message key in the template and preserve all placeholder names and types. Language-page labels and persistence-error copy will be added to all four catalogs.

Translations will use natural, standard UI language. Official station names, transport-line names, service names, brand names, codes, train numbers, and user-provided values will remain unchanged. Native-speaker review remains a release-quality follow-up, but the implementation must not ship blank values or silent English copies in the new catalogs.

Generated Dart localization files are build artifacts. The implementation will update ARB sources and run Flutter's generator; it will never hand-edit generated localization classes.

## Startup and Language-Change Flow

Before `runApp`, startup code initializes Flutter bindings, opens shared preferences, and asks the controller to resolve the initial locale. The first rendered frame therefore uses the correct language and avoids briefly showing another locale.

When the user selects a language, the controller validates the locale, updates the current session immediately, and saves the canonical locale tag. The language page rebuilds in the selected language, shows a localized confirmation, and the profile page displays the selected language name. The existing apply button retains its navigation role.

If a preference write fails, the chosen locale remains active for the current session. The language page shows a localized message that the preference could not be saved. On the next launch, the resolver uses the last successfully saved value or the normal device-locale fallback.

## Arabic and RTL

Flutter localization delegates will provide RTL `Directionality` for Arabic. The implementation will audit touched screens and replace absolute directional properties, such as left/right alignment or padding, only when they prevent correct mirroring. It will prefer `AlignmentDirectional`, `EdgeInsetsDirectional`, and start/end positioning where appropriate.

The implementation will not mirror brand artwork, transport diagrams, station maps, numbers, codes, or other content whose physical orientation must stay fixed. Mixed Arabic and Latin content must remain readable.

## Error Handling

Locale validation accepts only the four application locales and the documented device-locale aliases. Unsupported selections cannot reach `MaterialApp`.

Storage read errors, malformed stored tags, and removed locale values do not block startup. The controller continues to device-locale resolution and then English. Storage write failures preserve the in-memory selection and surface a localized, non-blocking message.

The generated localization delegate remains the final guard against unsupported locales. Catalog-generation failures must stop implementation verification rather than produce partial language support.

## Testing

Unit tests will cover:

- saved-locale priority over device locales;
- matching for Indonesian and English regional variants;
- Simplified Chinese matching for `zh_Hans`, `zh_CN`, and `zh_SG`;
- Arabic regional matching;
- English fallback for unsupported locales, including Traditional Chinese;
- recovery from unknown or malformed saved values;
- successful preference reads and writes; and
- storage read and write failures.

Widget tests will cover:

- all four options appearing on the language page;
- immediate switching to Indonesian, English, Simplified Chinese, and Arabic;
- the profile page showing the active language;
- localized success and persistence-error messages; and
- Arabic `Directionality.rtl` without overflow on the language page and a representative main screen.

A catalog-consistency test or equivalent verification script will compare all message keys, metadata entries, placeholder names, and placeholder types. It will also reject empty translations and unintended wholesale English fallback in the Chinese or Arabic catalogs.

Final verification will run Flutter localization generation, formatting, `flutter analyze`, and the complete `flutter test` suite.

## Completion Criteria

The feature is complete when:

- the application offers and renders all four languages;
- every existing localized message has Chinese and Arabic text with matching placeholders;
- a valid saved locale survives application restarts;
- first launch follows a supported device locale and otherwise starts in English;
- Arabic uses RTL without tested layout failures;
- persistence failures remain non-blocking and visible to the user;
- no backend or unrelated refactor is introduced; and
- localization generation, static analysis, and all tests pass.
