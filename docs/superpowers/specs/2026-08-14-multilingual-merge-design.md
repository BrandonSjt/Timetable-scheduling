# Multilingual Merge Design

## Goal

Merge Brandon's `Brandon-Dev2` branch into `dev1-riyadh` with a real Git merge so Brandon's commits and ancestry remain traceable, while preserving the current branch's visual design and all uncommitted local work.

The resulting application supports Indonesian, English, Simplified Chinese, and Arabic. Arabic text uses a fixed left-to-right application layout so switching languages does not rearrange the established interface.

## Source and Traceability

- Source repository: `https://github.com/BrandonSjt/Timetable-scheduling.git`
- Source branch: `Brandon-Dev2`
- Source tip reviewed for this merge: `7d4da01edddac0e668c16b35a43a8f6c0714fc95`
- Target branch: `dev1-riyadh`

The source repository will be configured as the `brandon` Git remote. The integration will use a non-fast-forward merge commit whose second parent is the reviewed Brandon branch tip. This preserves authorship, ancestry, and future merge tracking.

## Safety Strategy

The target working tree contains staged, modified, and untracked user work. Before merging, all of it will be captured in a named stash that includes untracked files. The merge will run against the clean target branch, and the stash will be restored after the merge commit exists.

The safety stash will not be dropped until restoration and verification succeed. If restoration conflicts, the merge commit stays intact while conflicts are resolved in favor of the user's pre-merge work for visual code and with both sides combined where localization wiring is required.

## Merge and Conflict Policy

The merge takes Brandon's localization capability, including:

- the four-locale policy and device-locale fallback;
- locale selection and persistence through `shared_preferences`;
- Chinese and Arabic ARB catalogs and generated localization output;
- localized language names, feedback, and service information; and
- focused localization tests and test helpers.

The current branch remains the source of truth for:

- widget composition and page structure;
- colors, typography, spacing, shapes, and animation;
- navigation and existing feature behavior;
- maps, diagrams, brand artwork, and other directional visuals; and
- all user changes that were present before the merge.

Conflicted UI files will not be accepted wholesale from either branch. Their current target-branch presentation will be retained, while the minimum imports, localized strings, locale state reads, and selection callbacks required by the multilingual feature will be integrated manually.

## Runtime Design

`AppLocale` defines the four supported locales and startup resolution policy. `LocaleStorage` persists the canonical locale tag, while `LocaleController` owns the active locale and exposes selection results. `LocaleScope` makes that controller available to the existing widget tree without adding a new application-wide state-management framework.

Startup loads the saved locale before the first rendered frame. A valid saved choice wins; otherwise the first supported device locale is selected, followed by English as the fallback. A failed preference read falls through to device resolution. A failed write keeps the selected language active for the session and displays localized, non-blocking feedback.

`MaterialApp.router` receives the selected Flutter locale. Its application child is wrapped in `Directionality(textDirection: TextDirection.ltr)` for every language, including Arabic, to preserve the current visual arrangement.

## UI Integration

The existing language page retains its local scaffold, cards, spacing, colors, and apply/navigation behavior. Its two hard-coded language choices are replaced by the four `AppLocale` values, using localized names and descriptions. The profile page reads the selected language name from the same locale model.

Other pages retain their current layouts. Only user-facing strings and small overflow-safe text behavior needed for longer translations may change. No unrelated visual redesign or refactor is included.

## Verification

Verification will confirm:

- the merge commit has Brandon's reviewed branch tip as an ancestor and parent;
- the pre-merge staged, modified, and untracked work is restored;
- all four ARB catalogs expose matching message interfaces;
- locale resolution, persistence, switching, and failure handling tests pass;
- Arabic renders translated text while application direction remains LTR;
- existing Flutter tests still pass;
- Flutter localization generation and static analysis succeed; and
- the final diff does not introduce unintended visual replacements from Brandon's branch.

## Completion Criteria

The work is complete when the true merge is present in Git history, all four languages are selectable and persistent, Arabic keeps the application LTR, the current UI is preserved, the user's pre-existing work remains available, and the verification suite passes.
