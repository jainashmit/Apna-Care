# ApnaCare

ApnaCare is a Flutter healthcare coordination prototype built around one clear problem: during an emergency, patients, caregivers, ambulance teams, hospitals, and doctors work with disconnected information. ApnaCare turns that handoff into one permission-aware care timeline and then continues into everyday appointments, documents, reminders, and billing.

## Showcase scope

- Patient Care Hub with Care Circle, appointments, health tasks, profile, and emergency readiness.
- Doctor workspace with today’s queue, patient context, availability, notes, and prescriptions.
- Hospital operations workspace for capacity, services, billing, staff, and access management.
- Platform control centre for provider verification, emergency coverage, quality, and revenue signals.
- Custom RBAC demo with organization-scoped permissions and custom roles.
- Offline-first Care Companion with safe intent routing and clickable actions for appointments, reports, reminders, and emergencies.
- Dummy repositories and models are used intentionally so Firebase can be added later without redesigning the UI contracts.

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

This version does not require Firebase or an LLM API key. The assistant is intentionally offline and safe; a server-side LLM adapter can be added later without exposing provider keys in Flutter.

## Architecture highlights

The Flutter code is organised by feature with Riverpod providers, domain models, mock repositories, reusable design tokens, and named routes. The access model is:

```text
Person → Organization membership → Role → Permission → Scope
```

## Resume positioning

Describe it as an **emergency-to-everyday healthcare coordination platform**, not as a generic doctor-booking app. The strongest proof is the cross-role flow: patient SOS → ambulance assignment → hospital readiness → doctor handoff → patient timeline.
