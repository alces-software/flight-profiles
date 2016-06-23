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
fi

regions="eu-west-1 eu-central-1 ap-northeast-1 ap-northeast-2 ap-southeast-1 ap-southeast-2 sa-east-1 us-east-1 us-west-1 us-west-2"

cd $(dirname "$0")
for r in $regions; do
    echo ""
    echo "== Syncing: ${r} =="
    s3cmd sync ${dry_run} --delete-removed -F -P ./machines/aws/ s3://alces-flight-profiles-${r}/machines/
    s3cmd sync ${dry_run} --delete-removed -F -P ./features/ s3://alces-flight-profiles-${r}/features/
    s3cmd sync ${dry_run} --delete-removed -F -P s3://alces-flight-profiles-eu-west-1/share/ s3://alces-flight-profiles-${r}/share/
    echo "==================="
done
