# Domexa Flutter (v2) - rebuilt against `backend_final`

MVVM: **Model** = `data/` (models + ApiService/FirebaseService) - **ViewModel** = `presentation/viewmodels` - **View** = `presentation/views` + `widgets`.

## Install
1. Keep your existing `android/`, `ios/` and `lib/firebase_options.dart` (FlutterFire output).
2. Replace your `lib/` folder and `pubspec.yaml` with these, then `flutter pub get`.
3. Start the backend: `uvicorn main:app --host 0.0.0.0 --port 8000`
4. Emulator works out of the box (`http://10.0.2.2:8000`). On a real phone open
   **Profile > Server address**, enter `http://<PC-Wi-Fi-IP>:8000`, tap *Save and test*.
5. Android cleartext HTTP: add `android:usesCleartextTraffic="true"` to `<application>` in
   `AndroidManifest.xml` and `<uses-permission android:name="android.permission.INTERNET"/>`.
6. Firestore path used: `users/{uid}/projects/{id}` (change in `firebase_service.dart` if yours differs).

## Backend contract (all verified against the Python code)
| Screen | Endpoint | Notes |
|---|---|---|
| Layout | POST /api/generate-layout | floors[].svg shown in a WebView (SVG has `<text>` labels) |
| Materials | POST /api/recommend-materials | 12 line items, brands, live_rates |
| Cost | POST /api/estimate-cost | 3 calls fill the Economy/Standard/Premium cards |
| Interior | POST /api/interior-design | HTTP 200 + `success:false` on failure is handled |
| Chat | POST /api/chatbot | history = previous messages only (backend appends the new one) |
| PDF | POST /api/export-pdf | base64 -> file -> share sheet |
| Prices / status | GET /api/prices, GET /health | Home card, Profile connection test |

## HCI heuristics (Nielsen) - where they live
1. **Visibility of status** - `LoadingPanel` (rotating steps, seconds counter), live-price source/time on Materials/Cost, connection test showing Gemini/image status.
2. **Match with real world** - Marla/Kanal presets, PKR Lac/Crore (`Fmt.pkr`), Pakistani cities, plain language.
3. **User control** - Cancel on every long request, Undo for Reset and project delete, guest mode, back always works.
4. **Consistency** - one theme, shared widgets, same budget/city selectors everywhere.
5. **Error prevention** - limits copied from the backend Pydantic models, steppers can't exceed ranges, duplicate taps ignored, soft warnings for unrealistic room counts.
6. **Recognition over recall** - `ProjectSummaryBar` on every result screen; inputs entered once.
7. **Flexibility** - presets *and* exact sqft; fast text-only interior mode; "Interior ideas" from any room of the floor plan.
8. **Minimalist design** - one task per screen, sections with clear headings.
9. **Error recovery** - `ApiException` turns timeouts/offline/server errors into plain messages with *Try again*.
10. **Help** - hints under fields, suggested chatbot questions, tips with readable contrast.
    Accessibility: AA-contrast colours, 48dp targets, check marks on selected chips (not colour alone), semantic labels.

## Differences from the old app (found while reading the backend)
- Old Cost/Materials screens used hard-coded numbers (PKR 2800/4500/8000 per sqft, "March 2025", 15% contingency). The backend computes from **live prices** and uses **10%** contingency; the new screens show the backend's values.
- Old Materials screen showed 7 quantities; backend returns 12 items with brand, unit price, total.

## Backend issues noticed (not changed)
- `requirements.txt` lacks **`svgwrite`**, which `floor_plan_renderer.py` imports -> layout fails on a clean install. Add `svgwrite`.
- `app/agents/chatbot_agent.py` imports `google.generativeai` (not in requirements) but nothing imports that file.
- The PDF only contains cost/summary data; it has no floor-plan drawing (the request model has no field for it).
- `/api/interior-design` and others have no auth; fine for development.

> Not compiled here (no Flutter SDK in my environment): run `flutter analyze` once and send me any messages.