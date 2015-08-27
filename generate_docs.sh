#!/bin/bash

set -e

mkdir -p _source
git --work-tree=_source checkout master -- .

jazzy -a "Adzerk" \
      -u "http://adkzerk.com" \
      -g https://github.com/adzerk/adzerk-ios-sdk \
      -o . \
      --source-directory _source/AdzerkSDK/ \
      --readme _source/README.md
