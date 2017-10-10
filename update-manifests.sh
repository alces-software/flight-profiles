#!/bin/bash
cd $(dirname "$0")
for a in machines/*/* features/*; do
  if [[ -d "$a" ]]; then
    pushd "$a"
    find -H */* -type f -print | sort > manifest.txt
    popd
  fi
done

./generate-repo-index.rb features/
