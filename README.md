# NeighborCart

Flutter + Firebase group-buying app. Neighbors join a local pool, combine grocery
orders, unlock wholesale price tiers, split the cost and pick up together.
Two sides in one app: **Customer** and **Wholesaler**.

## Run it
```
flutter pub get
flutter run -d chrome        # or a connected Android device / emulator
```
Firebase project: `neighborcart-3a0db`. `lib/firebase_options.dart`, `android/` and `web/`
are already in this repo — no extra setup needed.

## Try it with demo data
1. Sign up as **Wholesaler** (toggle on the login screen) -> Profile -> *Load demo products & tiers*.
2. Log out, sign up as **Customer** -> Profile -> *Load demo pools*.
3. Pools tab -> open a pool -> *Join Pool & Start Shopping* -> add items -> *Proceed to Split details* -> *Pay Now*.
4. Log in as the wholesaler again to see demand, MOQ status and alerts update.

## Where things are
- `lib/screens/` customer screens + `lib/screens/wholesaler/` wholesaler screens
- `lib/services/` all Firebase/Firestore calls (screens never call Firebase directly)
- `lib/core/utils/price_break.dart` price-tier logic (thresholds come from Firestore `config/pricing`)
- `FIRESTORE_SCHEMA.md` data model, `firestore.rules` demo rules (fully open — not for production)
- `Figma Design/` UI reference, `NeighborCartProposal.docx` project proposal

## Known gaps
Pool creation UI, Google sign-in, product images (needs paid Firebase plan), phone-number login,
weekly cart reset, coordinator rotation, reliability score, real security rules.
