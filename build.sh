#!/bin/bash

set -e

WORKSPACE=AdzerkSDK.xcworkspace
SCHEME=AdzerkSDK

echo "[Building]"
xctool -workspace $WORKSPACE -scheme $SCHEME -sdk iphoneos

echo "[Testing]"
# xctool -workspace $WORKSPACE -scheme $SCHEME -sdk iphonesimulator test
# xctool currently shows an error when running tests, possibly due to this being a framework
# we'll use xcodebuild instead and deal with less-than-readable output.
xcodebuild -workspace $WORKSPACE -scheme $SCHEME test


