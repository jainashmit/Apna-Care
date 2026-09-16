# ApnaCare

ApnaCare is a Flutter healthcare coordination prototype built around one clear problem: during an emergency, patients, caregivers, ambulance teams, hospitals, and doctors work with disconnected information. ApnaCare turns that handoff into one permission-aware care timeline and then continues into everyday appointments, documents, reminders, and billing.

## Showcase scope

- Patient Care Hub with Care Circle, appointments, health tasks, profile, and emergency readiness.
- Doctor workspace with today’s queue, patient context, availability, notes, and prescriptions.
- Hospital operations workspace for capacity, services, billing, staff, and access management.
- Platform control centre for provider verification, emergency coverage, quality, and revenue signals.
- Custom RBAC demo with organization-scoped permissions and custom roles.
- Offline-first Care Companion with safe intent routing and clickable actions for appointments, reports, reminders, and emergencies.
- Firebase-ready repositories and build-time configuration are included. The app still
  falls back to deterministic demo data when credentials, location permission, network,
  or an AI endpoint are unavailable.

## Recommended demo flow

1. Open the patient home screen and tap the SOS control.
2. Open the Emergency Care Room and show the response timeline.
3. Open Workspaces and switch to Doctor, Hospital Operations, and Platform Admin.
4. Open Organization Access and create a custom role.
5. Open Care Companion and try “Find a doctor”, “Explain my report”, and “I need emergency help”.

## Run locally

```bash
flutter pub get
flutter run
```

The default showcase build does not require Firebase or an LLM key. To connect them,
follow [`docs/firebase_setup.md`](docs/firebase_setup.md). Email/password and Google
sign-in, Firestore appointment writes, Google Places nearby hospitals, and the `aiChat`
callable function are guarded behind configuration, with offline fallbacks kept in place
for reliable demos. Phone/SMS authentication is intentionally not used.

## Architecture highlights

The Flutter code is organised by feature with Riverpod providers, domain models, mock repositories, reusable design tokens, and named routes. The access model is:

```text
Person → Organization membership → Role → Permission → Scope
```

## Resume positioning

Describe it as an **emergency-to-everyday healthcare coordination platform**, not as a generic doctor-booking app. The strongest proof is the cross-role flow: patient SOS → ambulance assignment → hospital readiness → doctor handoff → patient timeline.
