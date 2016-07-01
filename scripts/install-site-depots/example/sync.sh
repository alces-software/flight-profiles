#!/bin/bash
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "$0: must set AWS_ACCESS_KEY_ID"
    exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "$0: must set AWS_SECRET_ACCESS_KEY"
    exit 1
fi

if [ "$1" == "--dry-run" ]; then
    dry_run="--dry-run"
    shift
fi

if [ "$1" ]; then
    cd $(dirname "$0")
    s3cmd sync ${dry_run} --delete-removed -F -P ./site-depots/ ${1}/site-depots/
else
    echo "Usage: $0 [--dry-run] <customization bucket>"
fi
