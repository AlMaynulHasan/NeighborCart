# NeighborCart

Flutter + Firebase group-buying app (customer side + wholesaler side).

## First-time setup (after cloning / extracting)

1. Generate the native platform folders (they are not stored in this repo):
   `flutter create . --org com.neighborcart --platforms=web,android`
2. Connect Firebase (needs `firebase login` once):
   `flutterfire configure --project=neighborcart-3a0db`
   Select android + web. This creates `lib/firebase_options.dart`.
3. `flutter pub get`
4. `flutter run -d chrome`  (or a connected Android device/emulator)

If the Android build complains about minSdk, set `minSdk = 23` in
`android/app/build.gradle(.kts)`.

See `FIRESTORE_SCHEMA.md` for the data model and `firestore.rules` for the demo rules.
