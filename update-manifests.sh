#!/bin/bash
cd $(dirname "$0")
for a in machines/*/* features/*; do
    pushd "$a"
    find -H */* -type f -print > manifest.txt
    popd
done
