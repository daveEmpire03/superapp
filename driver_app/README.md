# Bokku Driver App

This is a separate Flutter application source tree for approved Bokku Mart drivers and couriers. It authenticates against the existing Bokku Mart API and uses the shared rider account role.

## Generate Android/iOS platform scaffolding

The repository keeps the driver app as an independent Flutter project. Generate its native platform folders without overwriting the existing Dart source.

**Windows PowerShell:**

```powershell
.\bootstrap_platforms.ps1
flutter pub get
```

**macOS/Linux:**

```bash
bash ./bootstrap_platforms.sh
flutter pub get
```

The scripts generate Android/iOS scaffolding in a temporary Flutter project, copy only the native platform folders, and add network/location permissions plus the iOS location-purpose string. They do not replace the app's `lib/` source or `pubspec.yaml`.

## Run

```powershell
flutter run --dart-define=API_BASE_URL=https://YOUR_API_HOST/api/v1/
```

Use the deployed HTTPS API URL in release builds. Do not ship a localhost URL. Drivers must be created as `RIDER` accounts, complete their vehicle profile, and be approved by an operations administrator before they can go online.

The app supports profile setup, fresh location updates, availability, nearby ride/parcel requests, accepting work, and status transitions. Production launch still requires device testing, background-location policy decisions, app signing, privacy disclosures, and provider configuration.
