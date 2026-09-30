#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if command -v plutil >/dev/null 2>&1; then
  plutil -lint iOS/CookingImprovementApp.xcodeproj/project.pbxproj
else
  echo "plutil unavailable: defer Xcode project plist lint to macOS build gate"
fi

python3 - <<'PY'
from pathlib import Path
import re, xml.etree.ElementTree as ET
root=Path('.')
models=(root/'iOS/CookingImprovementApp/Persistence/SwiftDataModels.swift').read_text()
classes=re.findall(r'@Model\s+final class\s+(\w+)', models)
assert len(classes)==24, f"expected 24 @Model types, got {len(classes)}"
assert not re.search(r'@Attribute\([^\n]*transformable', models, re.I)
assert not re.search(r'\bvar\s+\w+\s*:\s*Data\b', models)
assert 'migrationPlan: nil' in models
pbx=(root/'iOS/CookingImprovementApp.xcodeproj/project.pbxproj').read_text()
assert 'CookingImprovementAppTests.xctest' in pbx
assert 'SwiftDataSmokeTests.swift in Sources' in pbx
ET.parse(root/'iOS/CookingImprovementApp.xcodeproj/xcshareddata/xcschemes/CookingImprovementApp.xcscheme')
workflow=(root/'.github/workflows/ios-build.yml').read_text()
for token in ['xcodebuild test','-sdk iphoneos','CookingImprovementApp-unsigned-device','TestResults.xcresult']:
    assert token in workflow, token
assert workflow.index('-sdk iphonesimulator') < workflow.index('xcodebuild test') < workflow.index('-sdk iphoneos'), 'Apple gate order must be Simulator Build -> SwiftData Smoke Test -> unsigned Device Build'
smoke=(root/'iOS/CookingImprovementAppTests/SwiftDataSmokeTests.swift').read_text()
for token in ['RecipeContentModel(', 'MeasurementModel(', 'FetchDescriptor<RecipeContentModel>', 'FetchDescriptor<MeasurementModel>']:
    assert token in smoke, f'missing SwiftData child smoke coverage: {token}'
print('static contracts: PASS')
PY

for f in iOS/CookingImprovementApp/**/*.swift iOS/CookingImprovementApp/*.swift iOS/CookingImprovementAppTests/*.swift; do
  swiftc -parse "$f"
done

swift test -c debug
swift test -c release
