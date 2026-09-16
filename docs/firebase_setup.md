# ApnaCare integration setup

The app is intentionally offline-first. A clean checkout runs with demo hospitals,
doctors, bookings and a safe local Care Companion. Firebase and Google Places are
opt-in, so no credentials belong in this repository.

## 1. Create the Firebase project

1. Create a Firebase project and register the Android, iOS and (if needed) web apps
   with the exact application IDs from this repository.
2. Enable **Authentication → Sign-in method → Email/Password**. Enable **Google** only
   after adding the Android SHA-1/SHA-256 fingerprints; phone/SMS authentication is not
   used by this app and does not need billing.
3. Create Firestore in production mode, then apply rules that require an authenticated
   user. Do not ship open test-mode rules.
4. Enable Storage, Cloud Functions and App Check before a public pilot.

The Android app is already registered in this workspace. The Android config and
`lib/firebase_options.dart` are enough for this demo, so FlutterFire CLI is not
required. If you register another platform later, use its generated Firebase config.
Do not put server keys or Gemini keys in the Flutter binary.

## 2. Initial Firestore contract

The starter security rules are in [`firestore.rules`](../firestore.rules). Paste them
into **Firestore Database → Rules → Publish** after creating the database. They are
deliberately restrictive: patient documents are owner-scoped, appointments require an
authenticated patient, and organization documents require membership.

The frontend is already shaped around these collections:

| Collection | Purpose |
| --- | --- |
| `users/{uid}` | patient profile, emergency contacts, consent flags |
| `organizations/{orgId}` | hospital/clinic provider profile and subscription tier |
| `organizations/{orgId}/members/{uid}` | organization membership, custom role and permissions |
| `providers/{providerId}` | doctor, clinic, hospital or ambulance listing |
| `appointments/{appointmentId}` | patient, provider, slot, status and audit timestamps |
| `care_tasks/{taskId}` | Care Circle reminders and document tasks |
| `emergency_incidents/{incidentId}` | SOS request, location, dispatch and status timeline |
| `billing_events/{eventId}` | invoice/payment event (never store raw card details) |

Use server timestamps, immutable audit events and organization scoping in every
provider/admin query. The first production rules should make a user read/write only
their own profile and appointments, while organization members can read data only for
their assigned organization and permission set.

## 3. Email verification and password reset

After enabling Email/Password, open **Authentication → Templates** and keep the
email-address verification and password-reset templates enabled. Account creation
sends a verification email and signs the user out; sign-in is blocked until the link is
opened. The phone number in the registration form is only a contact field and never
triggers an SMS.

## 4. Gemini / Care Companion

Keep the Gemini key on a server, never in the Flutter binary. Deploy a callable
Cloud Function named `aiChat` that accepts:

```json
{ "message": "Find a cardiologist tomorrow" }
```

and returns:

```json
{ "answer": "...", "action": "find_doctor", "requiresEmergencyEscalation": false }
```

The Flutter `AiGateway` calls that function when Firebase is enabled. If the function
is unavailable, it automatically uses the deterministic safety-first demo responses.
The assistant must always escalate severe symptoms to **112**, avoid diagnosis, and
write an audit event when it creates a booking, reminder or emergency action.

## 5. Nearby providers

Set a restricted Google Places API key only for a local demonstration:

```bash
flutter run --dart-define=GOOGLE_PLACES_API_KEY=replace-me
```

Restrict the key by Android package/SHA-1 and iOS bundle ID, enable only Places API,
and set billing/quota alerts. `HospitalRepositoryImpl` tries Nearby Search and falls
back to the bundled data on a timeout, quota error, missing key or denied location.
That fallback is deliberate: the patient flow must still be demonstrable offline.

## 6. Before a public pilot

- Add App Check and move all privileged provider/admin operations behind callable
  functions.
- Move Places requests to a callable function so the mobile key is not exposed.
- Add Crashlytics, Analytics consent, notification permission and an incident audit log.
- Replace all demo IDs with authenticated user/org IDs and test Firestore rules with the
  Firebase Emulator Suite.
