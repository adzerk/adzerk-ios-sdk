#!/bin/bash

set -e

output_command=xcpretty

# Make sure xcpretty is installed
command -v xcpretty >/dev/null 2>&1 || {
  echo "Please install xcpretty to get prettier test/build output."
  echo
  echo "$ gem install xcpretty"
  echo
  output_command=cat
}

WORKSPACE=AdzerkSDK.xcworkspace
SCHEME=AdzerkSDK

echo "[Building]"
xcodebuild -workspace $WORKSPACE -scheme $SCHEME -sdk iphonesimulator

echo "[Testing]"
xcodebuild -workspace $WORKSPACE -scheme $SCHEME \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=iPhone XS,OS=12.0" \
  test | $output_command
