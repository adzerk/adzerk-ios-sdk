#!/bin/bash

set -e

command -v jazzy >/dev/null 2>&1 || { 
  echo >&2 "jazzy is not installed. Install it with rubygems:"
  echo >&2 ""
  echo >&2 "gem install jazzy"
  echo >&2 ""
  exit 1
}


mkdir -p _source
git --work-tree=_source checkout master -- .

jazzy -a "Adzerk" \
      -u "https://kevel.co" \
      -g https://github.com/adzerk/adzerk-ios-sdk \
      -o . \
      --source-directory _source/ \
      --readme _source/README.md
