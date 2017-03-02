#!/usr/bin/env bash
: ${TAG1:?"Need to set TAG1 environment variable"}
: ${TAG2:?"Need to set TAG2 environment variable"}

git log --pretty=format:"* %s%b" $TAG1..$TAG2

