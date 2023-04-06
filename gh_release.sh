#!/bin/bash

GEMSPEC=$(ls -1 *.gemspec | head -1)
# RELEASE_VERSION must be an exact version number; if not set, defaults to next patch release
RELEASE_VERSION=$1
if [ -z "$RELEASE_VERSION" ]; then
  RELEASE_VERSION=$(ruby -e "print (Gem::Specification.load '$GEMSPEC').version")
fi

# release!
(
  set -e
  ruby release-notes.rb $RELEASE_VERSION
  gh release create v$RELEASE_VERSION --verify-tag --title v$RELEASE_VERSION --notes-file pkg/release-notes.md --draft
)
exit_code=$?

exit $exit_code