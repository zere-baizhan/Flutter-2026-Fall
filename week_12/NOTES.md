## Level 1: Package verdicts

- **shared_preferences** — verified publisher flutter.dev, 2.5.6 released October 2026, all six platforms, 160 points, ~16 open issues with commits this month in flutter/packages, depends only on its own platform implementations, BSD-3-Clause.
- **flutter_secure_storage** — verified publisher steenbakker.dev (a community maintainer, not Google), 11.2.0 released September 2026, all six platforms, 160 points, ~12 open issues with commits this month, depends on its own platform implementations + meta, BSD-3-Clause.
- **path_provider** — verified publisher flutter.dev, 2.1.6 released June 2026, five platforms (no Web — there is no file system there), 160 points, ~22 open issues in an active repo, depends only on its own platform implementations, BSD-3-Clause.
- **image_picker** — verified publisher flutter.dev, 1.2.4 released October 2026, all six platforms, 160 points, ~87 open issues but an active repo, depends only on its own platform implementations, Apache-2.0 + BSD-3-Clause.
- **permission_handler** — verified publisher baseflow.com (a company, not Google), 13.0.2 released September 2026, four platforms (Android, iOS, Web, Windows — no Linux/macOS), 160 points, ~130 open issues but commits this month, depends on its own platform implementations + meta, MIT.
- **url_launcher** — verified publisher flutter.dev, 6.3.3 released October 2026, all six platforms, 160 points, ~34 open issues in an active repo, depends only on its own platform implementations, BSD-3-Clause.

## Versions

- `flutter pub add` wrote carets: `shared_preferences: ^2.5.6`, `flutter_secure_storage: ^11.2.0`, `path_provider: ^2.1.6`, `image_picker: ^1.2.4`, `permission_handler: ^13.0.2`, `url_launcher: ^6.3.3`.
- http resolved in pubspec.lock: **1.6.0** (pubspec.yaml says `^1.6.0`).
- `^1.2.0` means `>=1.2.0 <2.0.0`. It **accepts** 1.2.0, 1.2.5, 1.6.0, 1.99.0. It **refuses** 1.1.9 (too old) and 2.0.0 or later (a new major version is allowed to break the API, so pub never jumps to it on its own).
- Why pubspec.lock is committed for an app: pubspec.yaml only gives ranges, the lock file records the exact versions that were tested. With it in git, my teammate, CI and I a month from now all build with exactly the same code. (A library package does not commit it — the app that uses the library decides the versions.)
- `flutter pub outdated`: **cupertino_icons** is at 1.0.9 but 2.0.0 exists. It was not upgraded because my constraint `^1.0.8` stops before 2.0.0 — a major version may break things, so I have to opt in by editing pubspec.yaml (or `flutter pub upgrade --major-versions`).
- Break-it experiment: I changed `http: ^1.6.0` to `http: 1.2.0` (no caret = exactly that version). `flutter pub get` **failed**: permission_handler 13 needs `web >=0.5.1`, but http 1.2.0 needs `web <0.5.0`, so no set of versions satisfies both. Exact pins stop pub from finding versions that work with my other packages. I put the caret back; the lock is at 1.6.0 again.

## Level 2: Settings

- `darkMode` and `cityFilter` live in shared_preferences and are read in `main()` **before** `runApp`, so the first frame already has the right theme. If the read happened inside `SettingsModel` with a default of `false`, the first frame would be light and then flash to dark when the disk answered.
- `setDark` calls `notifyListeners()` first and writes to disk second: the switch moves instantly, the disk write (a few ms, sometimes more) does not block the UI.
- Every read is nullable (`bool?`, `String?`) — null means "never saved". Defaults come from `??`, never `!` or `late`.

## Level 3: Storage

- **Where `prefs.setString('token', …)` would have put the token:** in a plain, unencrypted file inside the app folder — on Android an XML file `shared_prefs/FlutterSharedPreferences.xml`, on iOS a `.plist` in `Library/Preferences`. Anyone who gets a copy of the app folder can read it: a device/cloud **backup**, a **rooted/jailbroken** phone, or a computer connected with a **cable** (adb backup / iTunes backup).
- **flutter_secure_storage** instead puts it in the iOS **Keychain** / encrypted with a key from the Android **Keystore** (hardware-backed where available). The key never leaves the secure hardware, so a copied file is useless.
- **iOS surprise:** Keychain items are **not deleted when the app is uninstalled**. After reinstalling, the old token can still be there → the app thinks you are signed in. (Fix: on first launch, check a flag in shared_preferences — which *is* deleted on uninstall — and clear the secure store if the flag is missing.)
- **Android surprise:** if the user **removes the screen lock** (or changes biometrics), the Keystore key can be invalidated and the stored data becomes unreadable — `read` throws or returns null. The app must treat that as "signed out", not crash.
- The token is never printed: the debug-only "Copy token to clipboard" button (behind `kDebugMode`) proves it exists without putting it in logs. DevTools → Network shows `Authorization: Bearer tok_…` on requests.

## Level 4: Offline

- `UsersCache` writes `users.json` to `getApplicationDocumentsDirectory()`. `getTemporaryDirectory()` is the OS's cache folder — "Clear cache" in Android settings (or iOS under storage pressure) empties it, and the saved list silently disappears. Documents is only removed on uninstall.
- `getAll()`: network → save → `fromCache: false`. `NoConnectionException` → load file → `fromCache: true`; if the file does not exist → `rethrow` → the honest Offline screen instead of an empty list.

## Level 5: Permissions

- **Android sequence:** tap 1 → system dialog → Don't allow → `denied` (SnackBar). Tap 2 → system dialog again → Don't allow → `permanentlyDenied`. Tap 3 → **no system dialog**, our own AlertDialog at once → "Open settings" → `openAppSettings()` opens the app's permission page.
- **iOS sequence:** iOS asks **only once**. The first "Don't Allow" already means `permanentlyDenied` — the system dialog never appears again; only Settings can change it.
- **The fourth Photos state on iOS** (besides not determined / denied / authorized) is **Limited** — "Select Photos…": the user shares only some photos (`PermissionStatus.limited`).
- iOS also has **restricted** (parental controls / MDM — the user cannot change it). All statuses are handled in the `switch` in `profile_screen.dart`.
- `launchUrl(Uri.parse('kbtu.edu.kz'))` without a scheme returns **false** — Android/iOS do not know which app opens "kbtu.edu.kz". With `https://` the browser opens.
- Every device API answers with a "No": `pickImage` → null on Cancel, `launchUrl` → false, `request()` → denied/permanentlyDenied. No `!` after any of these awaits — the feature keeps working without the photo.
