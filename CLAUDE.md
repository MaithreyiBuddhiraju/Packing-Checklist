# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Personal packing checklist. Two apps:
- `packing_checklist/` — the active project: Flutter Android app, sqflite persistence, Material 3, provider state management. Local-only: no network calls, no accounts, no cloud sync.
- `packing-app/` — legacy PWA (reference only; do not modify unless asked). Its `index.html` is the source of the seed data and visual style.

## Commands

- Run: `cd packing_checklist && flutter run` (needs an Android device/emulator)
- Analyze: `flutter analyze`
- Release APK: `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`

## Architecture (packing_checklist/lib/)

- `models/` — plain Dart data classes (Category, Item)
- `db/` — sqflite helper: schema, seed data, template save/reset (all writes transactional; `PRAGMA foreign_keys = ON` is set per-connection, don't remove it — cascade deletes depend on it)
- `state/` — one ChangeNotifier (AppState) holding the in-memory list; every mutation writes to DB first, then updates memory
- `screens/`, `widgets/` — UI

## Constraints

- V1 scope is deliberately narrow: single active checklist + one unnamed template. No multiple trips, no sync, no iOS, no export, no notifications.
- Item `tag` is freeform user-editable text (seeded with SF/LA/Both from the legacy app) — display + edit only, no filtering in V1.
- "Template" stores structure (categories, items, quantities, tags) but never packed state.
