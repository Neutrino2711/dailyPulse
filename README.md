# DailyPulse

DailyPulse is a simple Flutter app to track daily moods. Users can sign up / sign in with Firebase Authentication, add mood entries (emoji + note), view a chronological list of moods, and see lightweight analytics (counts by emoji and a positive-mood count). The app stores data remotely in Firestore and caches/syncs a local copy using Hive for offline support.

![Screenshot1](https://github.com/user-attachments/assets/d8871b8b-7955-47a2-bd08-ab5628efeaca)


## Features

- Firebase Email/Password authentication (signup, login, logout)
- Add mood entries (emoji + short note + timestamp)
- Persist moods to Firestore under `users/{email}/moods`
- Local caching with Hive (box name: `moods`) for offline access
- Simple analytics: total entries, counts by emoji, positive-moods count
- Basic offline-first behavior: reads prefer Firestore when online, fallback to Hive when offline (configurable)

## Project structure (high level)

- `lib/main.dart` — app entry, Firebase & Hive initialization, Bloc providers
- `lib/blocs/bloc/` — BLoC classes for auth and mood flows
  - `auth_bloc.dart` — authentication events/states
  - `moodbloc_bloc.dart` — save/load mood events and analytics
- `lib/models/` — data models
  - `mood_model.dart` (+ generated `mood_model.g.dart`) — Hive-annotated MoodEntry
  - `mood_analytics.dart` — small analytics DTO
- `lib/presentation/` — UI screens and widgets
- `lib/repositories/` — (planned) local repository wrapper for Hive (not yet implemented)

## Dependencies

Main packages used:

- Flutter SDK (see `pubspec.yaml` sdk constraint)
- firebase_core, firebase_auth, cloud_firestore — Firebase backend
- hive, hive_flutter — local object persistence
- hive_generator, build_runner — code generation for Hive adapters (dev)
- flutter_bloc, bloc, equatable — state management
- connectivity_plus — (planned) network connectivity checks

See `pubspec.yaml` for exact versions.

## Setup & Getting started

1. Install Flutter and platform tools (Android/iOS) as usual. See https://flutter.dev/docs/get-started/install

2. Clone the repo and open it:

```powershell
cd D:\projects\
git clone <your-repo-url>
cd daily_pulse
```

3. Add Firebase configuration

- Android: place your `google-services.json` into `android/app/`
- iOS: add the `GoogleService-Info.plist` to the Runner target in Xcode
- Configure Firebase Authentication (enable Email/Password) and Firestore rules as needed

4. Install Dart & Flutter dependencies

```powershell
flutter pub get
```

5. Generate Hive TypeAdapters (only if you modify models)

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

6. Run the app (for Windows/Android emulator or device):

```powershell
flutter run
```

Notes:
- The app initializes Hive in `main.dart` and registers `MoodEntryAdapter()`.
- The Hive box name used in code is `moods`. If you change it, update references in `main.dart` and any code calling `Hive.box<MoodEntry>('moods')`.

## How data flows

- Save flow:
  1. User taps Save in `AddMoodScreen`.
  2. UI dispatches `SaveMood` event to `MoodblocBloc`.
  3. Bloc persists entry to local Hive box and then attempts to write to Firestore (best-effort).
  4. Bloc emits `MoodLoaded` with the updated list and triggers analytics computation.

- Load flow:
  1. `LoadMoods` event triggers a Firestore read when online; if Firestore fails, it falls back to read from Hive.
  2. The fetched list is stored/updated in Hive and emitted as `MoodLoaded`.
  3. The bloc computes analytics and emits `MoodAnalyticsLoaded` (or includes analytics in `MoodLoaded` depending on current code).

## Analytics

Analytics are currently derived from the loaded entries and include:

- `total` — total number of entries
- `countsByEmoji` — map of emoji to occurrence count
- `positiveCount` — count of entries whose emoji is in the configured `positiveEmojis` set (in `lib/constants/consts.dart`)

The UI displays analytics above the entries list. If analytics are not yet available from the bloc you can derive them locally from `state.entries` as a safe fallback.

## Troubleshooting

- "Null check operator used on a null value" when opening the list screen
  - This typically means the UI expected `state.analytics` to be non-null. Use a safe fallback (derive analytics from `state.entries`) or modify the bloc to include analytics in the `MoodLoaded` state.

- `mood_model.g.dart` not generated
  - Ensure your `mood_model.dart` contains `part 'mood_model.g.dart';` and Hive annotations, then run the build_runner command above.

- `Navigator` assertion `history.isNotEmpty`
  - Happens when calling `Navigator.pop(context)` when there is no route to pop. Only pop when the current screen initiated the save, or check `Navigator.canPop(context)` before popping.

## Testing

- Unit tests are not included yet. Suggested tests:
  - Repository: save/load/delete using Hive in a temp directory
  - Bloc: handle SaveMood / LoadMoods and check emitted states and analytics

## TODO / Next steps

- Implement a `MoodLocalRepository` to encapsulate Hive access
- Improve sync strategy (mark entries as `synced` and add background retry when network returns)
- Add more robust analytics (trends, charts, date-range filters)
- Add unit tests and CI

![Screenshot1](https://github.com/user-attachments/assets/ca2d0b0b-64b5-4a63-9ecb-63cb622f7969)![Screenshot2](https://github.com/user-attachments/assets/7ddb5656-b876-4494-bbfe-7e7f36e69b13)


