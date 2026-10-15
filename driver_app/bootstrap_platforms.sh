#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEMP_ROOT"' EXIT

flutter create --empty --project-name bokku_driver_app --platforms android,ios "$TEMP_ROOT/app"
cp -R "$TEMP_ROOT/app/android" "$ROOT/"
cp -R "$TEMP_ROOT/app/ios" "$ROOT/"

python3 - "$ROOT" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
manifest = root / "android/app/src/main/AndroidManifest.xml"
xml = manifest.read_text(encoding="utf-8")
permissions = [
    "android.permission.INTERNET",
    "android.permission.ACCESS_COARSE_LOCATION",
    "android.permission.ACCESS_FINE_LOCATION",
]
missing = [p for p in permissions if p not in xml]
if missing:
    block = "".join(f'    <uses-permission android:name="{p}" />\n' for p in missing)
    xml = xml.replace("<application", block + "    <application", 1)
    manifest.write_text(xml, encoding="utf-8")

plist = root / "ios/Runner/Info.plist"
text = plist.read_text(encoding="utf-8")
if "NSLocationWhenInUseUsageDescription" not in text:
    entry = (
        "    <key>NSLocationWhenInUseUsageDescription</key>\n"
        "    <string>Bokku Driver uses your location to find nearby jobs and share your location during active deliveries.</string>\n"
    )
    text = text.replace("</dict>", entry + "</dict>", 1)
    plist.write_text(text, encoding="utf-8")
PY

echo "Generated Android/iOS scaffolding in $ROOT"
echo "Next run: cd \"$ROOT\" && flutter pub get"
