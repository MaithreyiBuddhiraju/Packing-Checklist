# Packing Checklist

Personal packing checklist, customizable per trip: items by category, quantities, packed check-off, drag-to-reorder, and a save/reset template baseline.

Two apps live in this repo:

| Directory | What it is |
|---|---|
| `packing-app/` | Original PWA (single HTML file), hosted on Netlify. Kept as reference. |
| `packing_checklist/` | Native Android app (Flutter + sqflite). The replacement — all data stored on-device, no cloud, no account. |

## Android app — build & install

```bash
cd packing_checklist
flutter pub get
flutter build apk --release
```

APK lands at `packing_checklist/build/app/outputs/flutter-apk/app-release.apk`.

Install via ADB (`adb install app-release.apk`) or copy the APK to the phone and open it (enable "Install unknown apps" for your file manager).

## Tech stack

- Flutter (Android target only), Material 3
- sqflite for local persistence
- provider for state management
