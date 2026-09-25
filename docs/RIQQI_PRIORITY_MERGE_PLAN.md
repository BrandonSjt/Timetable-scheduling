# Riqqi-priority merge implementation plan

> Execute inline in this checkout. The local branch already contains `mjohan24/MJohan-Dev3`; do not push or deploy.

**Goal:** Make `riqqi15/dev1-riyadh` an ancestor of `Brandon-Dev2` while retaining compatible MJohan backend performance work.

**Architecture:** Use Riqqi's assistant voice and timetable interfaces when Git reports overlapping edits. Preserve the MJohan benchmark and observability modules. Repair integration at the smallest affected interface, then verify both mobile and backend code.

**Tech stack:** Git, Flutter/Dart, Node.js/TypeScript, Prisma.

## Global constraints

- Leave `timetable_backend/scripts/benchmark.mjs` and opt-in `Server-Timing` instrumentation available.
- Do not modify database content, `.env`, or credentials.
- Treat database-dependent test failures separately from source-code failures.
- Do not push, deploy, or claim Render performance from local tests.

### Task 1: Merge histories

**Files:** Git index and overlapping assistant, timetable, and backend files.

**Interfaces:** Input: `HEAD` and `riqqi15/dev1-riyadh`. Output: a merge commit containing both parents.

- [x] Run `git status --porcelain` and confirm the checkout is clean.
- [x] Run `git merge --no-ff --no-commit -X theirs riqqi15/dev1-riyadh`.
- [x] Inspect `git diff --check`, unresolved paths, and changes to the benchmark/observability files.
- [x] Resolve remaining conflicts with Riqqi's voice behavior and compatible backend timing in mind.
- [x] Commit the merge only after validation tasks pass.

### Task 2: Validate backend integration

**Files:** `timetable_backend/src/domain/services/routeService.ts`, `timetable_backend/src/presentation/controllers/scheduleController.ts`, and their tests.

**Interfaces:** Keep public API responses, benchmark timing phases, and station/timetable queries valid.

- [x] Run `npm run build` in `timetable_backend`; record compiler failures.
- [x] Run backend unit tests without changing database configuration.
- [x] Repair source-code failures with focused tests; rerun build and tests.
- [x] Confirm `scripts/benchmark.mjs`, timing middleware, and package script still exist.

### Task 3: Validate Flutter integration and close merge

**Files:** Assistant controllers, pages, localization, `pubspec.lock`, and corresponding tests.

**Interfaces:** Riqqi's speech recognizer/controller contract must match page and test callers.

- [x] Run dependency resolution and `flutter analyze` if Flutter is installed; otherwise record the tool limitation.
- [x] Run focused assistant and timetable tests when the Flutter toolchain is available.
- [x] Inspect merged Dart files for stale wake-word calls or duplicate voice handling.
- [x] Confirm `git merge-base --is-ancestor` succeeds for both source branch tips.
- [x] Confirm a clean worktree and report tests that require a configured dataset database.

Backend tests: 89/98 passed; nine database-backed tests require `DATABASE_URL`. Flutter tests: 271/271 passed. Flutter package download succeeded, though Windows symlink setup returned a warning; analysis and tests passed with `--no-pub`.
