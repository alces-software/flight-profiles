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

if [ "$1" == "--dryrun" ]; then
    echo "Unrecognised option --dryrun. Perhaps you meant '--dry-run'?"
    exit 1
fi

assert_unchanged() {
    if [ $(git status --porcelain | wc -l) -gt 0 ]; then
        echo "Local changes found. Refusing to sync.  Maybe 'git stash'?"
        git status --porcelain
        exit 1
    fi
}

branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$1" == "" ]; then
    if [ "$branch" == "master" ]; then
        echo "Supply feature set name (e.g. '2017.1' etc.) or '--legacy' to update profiles for legacy (pre-2017) releases."
        exit 1
    else
        assert_unchanged
        prefix="$branch/"
        prefix_name="$branch"
    fi
elif [ "$1" == "--legacy" ]; then
    if [ "$branch" == "master" ]; then
        assert_unchanged
        if [ -z "$dry_run" ] ; then
            # we always tag master when pushed
            tag=2016.4.$(date +%Y%m%d%H%M%S)
            git tag $tag && git push origin master && git push --tags
            if [ $? -gt 0 ]; then
                exit 1
            fi
        fi
        prefix=""
        prefix_name="<legacy>"
    else
        echo "Can't push to legacy from a non-master branch."
        exit 1
    fi
else
    if [ "$branch" == "master" ]; then
        assert_unchanged
        if [ -z "$dry_run" ] ; then
            tag_prefix="$1"
            # we always tag master when pushed
            tag=$tag_prefix.$(date +%Y%m%d%H%M%S)
            git tag $tag && git push origin master && git push --tags
            if [ $? -gt 0 ]; then
                exit 1
            fi
        fi
    fi
    prefix="$1/"
    prefix_name="($1)"
fi

regions="${REGIONS:-$(aws ec2 --output json describe-regions | grep RegionName | awk '{print $2}' | tr -d '",' | sort)}"

cd $(dirname "$0")
for r in $regions; do
    echo ""
    echo "== Syncing: ${r} ${prefix_name} =="
    s3cmd sync ${dry_run} --delete-removed -F -P ./machines/aws/ s3://alces-flight-profiles-${r}/${prefix}machines/
    s3cmd sync ${dry_run} --delete-removed -F -P ./features/ s3://alces-flight-profiles-${r}/${prefix}features/
    s3cmd sync ${dry_run} --delete-removed -F -P s3://alces-flight-profiles-eu-west-1/share/ s3://alces-flight-profiles-${r}/share/
    echo "==================="
done
