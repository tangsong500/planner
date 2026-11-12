#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "IPA compilation requires macOS and Xcode. Use the Build iOS IPA GitHub Actions workflow from Windows." >&2
  exit 1
fi

cd "$(dirname "$0")/.."
project_root="$PWD"
output_dir="$project_root/artifacts/ios"
build_dir="$(mktemp -d "${TMPDIR:-/tmp}/planner-ios.XXXXXX")"
app_version="$(node -p "require('./package.json').version")"
ipa_path="$output_dir/planner-$app_version-unsigned.ipa"

mkdir -p "$output_dir"
xcodebuild -version
xcodebuild \
  -project ios/App/App.xcodeproj \
  -scheme App \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$build_dir/DerivedData" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY= \
  build > "$output_dir/xcodebuild.log" 2>&1 || {
    tail -n 150 "$output_dir/xcodebuild.log"
    exit 1
  }

app_path="$build_dir/DerivedData/Build/Products/Release-iphoneos/App.app"
test -d "$app_path"
app_name_pattern='^[A-Za-z0-9][A-Za-z0-9 ._-]*$'
for name_key in CFBundleName CFBundleDisplayName; do
  app_name="$(/usr/libexec/PlistBuddy -c "Print :$name_key" "$app_path/Info.plist")"
  if [[ ! "$app_name" =~ $app_name_pattern ]]; then
    echo "$name_key must use an ASCII name for iloader provisioning. Put translated names in InfoPlist.strings." >&2
    exit 1
  fi
done
mkdir -p "$build_dir/Payload"
ditto "$app_path" "$build_dir/Payload/App.app"
ditto -c -k --keepParent "$build_dir/Payload" "$ipa_path"
unzip -t "$ipa_path"
(
  cd "$output_dir"
  shasum -a 256 "$(basename "$ipa_path")" > "$(basename "$ipa_path").sha256"
)
echo "Unsigned IPA for iloader: $ipa_path"
