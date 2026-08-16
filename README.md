# HabotConnect

HabotConnect — Flutter app implementing an LSA onboarding compliance flow.

This repository contains a small Flutter application demonstrating a GetX
MVC-style structure with a focused `lsa_verification` module that enforces
fail-closed compliance rules and logs UI friction events.

## Overview

- Architecture: Flutter + GetX (navigation, bindings, controllers)
- Main entry: `lib/main.dart` → `lib/app.dart` (`GetMaterialApp`)
- Routes: `lib/app/routes/` (centralized route names and page registrations)
- LSA module: `lib/app/modules/lsa_verification/` with `view/`, `controller/`, and `binding/`

Key behaviours implemented:
- Fail-closed lineage checks (blocks requests if `predecessor_id` missing)
- Client-side validation for `parent_consent_code` (format `PCC-YYYY-NNNN`)
- Friction logging when a focused input is idle > 5s (debug log)
- Mocked compliance POST (request URL/payload and response logged)
- Quarantine handling for null/timeout/500 responses (purge volatile data,
	lock form, show a failure dialog)
- Professional success and validation dialogs; Continue/Try Again reset flow

## Project layout

- lib/
	- main.dart — app entry (minimal)
	- app.dart — GetMaterialApp bootstrap and initial route
	- app/routes/
		- app_routes.dart — route name constants
		- app_pages.dart — GetPage list
	- app/modules/
		- login/ — (existing login module)
		- lsa_verification/
			- view/lsa_verification_screen.dart — UI (stateless GetView)
			- controller/lsa_verification_controller.dart — GetxController (validation, friction logging, mock request)
			- binding/lsa_verification_binding.dart — binding registration

## Setup

1. Ensure Flutter SDK (compatible with `sdk: ^3.10.7`) is installed.
2. From the project root, get packages:

```bash
flutter pub get
```

## Run

```bash
flutter run
```

## Tests & Analysis

Run static analysis and tests:

```bash
flutter analyze
flutter test
```

Both commands were validated during development and reported no issues.

## How the LSA verification works (high level)

1. User opens the app; initial route shows the LSA Onboarding Gate screen.
2. The `parent_consent_code` field is required and must match `PCC-YYYY-NNNN`.
3. When the field is focused and idle for >5s, a friction log is emitted to
	 the debug console in the form:

	 ```
	 [UI_FRICTION_LOG] Timestamp: <ISO-UTC> | Field: parent_consent_code | Hesitation Duration: <s>s
	 ```

4. On `Verify & Submit`:
	 - client-side validation runs (fields present and format validated)
	 - lineage presence is checked (fail-closed if missing)
	 - *network call is currently mocked/commented* — request URL, payload and
		 simulated response are logged for debugging
	 - success shows a professional confirmation dialog; Continue resets form
	 - failures (null/500/timeout) purge volatile data, lock the form, and show a quarantine dialog

## Where to change behavior

- Adjust routes: `lib/app/routes/app_routes.dart` and `lib/app/routes/app_pages.dart`
- Modify validation and compliance logic: `lib/app/modules/lsa_verification/controller/lsa_verification_controller.dart`
- Tweak UI: `lib/app/modules/lsa_verification/view/lsa_verification_screen.dart`

## Security notes

- The app currently logs request payloads and simulated responses for
	debugging. Remove verbose logging and never hardcode sensitive secrets
	or validation tokens in production code.
- In production, signature validation and sensitive logic must be enforced
	server-side. Client-side checks are convenience and UX protections only.

## Mocked API (how to enable the real endpoint)

By default the compliance POST call in the controller is mocked / commented
out so the app can be used locally without calling a live endpoint. The
mock lives in:

- `lib/app/modules/lsa_verification/controller/lsa_verification_controller.dart`

To enable the real HTTP call:

1. Open the controller file above and locate the block marked `Mock / commented API call`.
2. Uncomment the `http.post(...)` call and the subsequent response handling.
3. Remove or adapt the `simulatedResponse` and its use so the code reads the
	actual `response.statusCode` and `response.body` instead.
4. Replace hard-coded headers (`x-trace-id`, `x-logic-hash`) with values
	provided securely at runtime (e.g., from environment, secure storage,
	or a signed token from your backend). Do NOT keep permanent secrets in
	the client source.
5. Remove verbose `debugPrint` logging of full request payloads before
	shipping to production.
6. Test the integration behind a staging endpoint first and confirm the
	three fail-closed cases (valid, missing lineage, null/500) behave as
	expected.

Quick checklist to enable safely:

```text
• Update `_endpointUrl` if using an alternate host
• Inject trace/hash values at runtime (don't hardcode)
• Uncomment network call and remove the simulatedResponse branch
• Run `flutter analyze` and `flutter test`
• Validate behaviour against staging endpoint
```

If you want I can add an environment toggle or an injectable HTTP client
so switching between mocked and real endpoints is safer and easier.

## Developer tips

- Use `GetX` bindings to manage dependencies and keep controllers lightweight.
- Keep UI stateless where possible and push business logic into controllers.
- For E2E testing of the compliance flow, consider adding an integration
	test that exercises the `lsa_verification_controller` behaviors with a
	mocked HTTP client.

## Contact / Next steps

If you'd like, I can:
- Add integration tests that simulate all three fail-closed cases.
- Replace the mocked API with a configurable HTTP client or environment
	toggle to test live endpoints safely.

---
Small, focused code changes were made to implement the onboarding gate. See
the module files in `lib/app/modules/lsa_verification/` for implementation details.
