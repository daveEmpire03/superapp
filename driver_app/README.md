# Bokku Driver App

This is a separate Flutter application source tree for approved Bokku Mart drivers and couriers. It authenticates against the existing Bokku Mart API and uses the shared rider account role.

## Generate Android/iOS platform scaffolding

From this directory, run:

```powershell
flutter create --project-name bokku_driver_app --platforms android,ios .
flutter pub get
```

Then add the following Android permissions to `android/app/src/main/AndroidManifest.xml` above `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

For iOS, add `NSLocationWhenInUseUsageDescription` to `ios/Runner/Info.plist`.

## Run

```powershell
flutter run --dart-define=API_BASE_URL=https://YOUR_API_HOST/api/v1/
```

Use the deployed HTTPS API URL in release builds. Do not ship a localhost URL. Drivers must be created as `RIDER` accounts, complete their vehicle profile, and be approved by an operations administrator before they can go online.

The app supports profile setup, fresh location updates, availability, nearby ride/parcel requests, accepting work, and status transitions. Production launch still requires device testing, background-location policy decisions, app signing, privacy disclosures, and provider configuration.
