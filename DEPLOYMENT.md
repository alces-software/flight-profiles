# Deployment

Use the `sync.sh` script to deploy the feature profiles to S3 buckets.

## Prerequisites

 * `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` set with
   credentials that allow access to the target S3 buckets.

* For `master` branch (release quality profiles), you must:
   * Have no outstanding changes.
   * Provide a parameter to denote the specific prefix for the release
     (e.g. `2017.1`) or `--legacy` for releases that predate `2017.1`.
   * The current HEAD of master will be tagged with the prefix and timestamp and pushed to the repo.

* For other branches, e.g. `develop`:
   * No tag is generated for non-master branches.
   * If you are using the default set name for the branch (no parameter) then you must have no outstanding changes.
   * You may specify a custom set name (as parameter) in which case you may have outstanding local changes (i.e. you're testing things).

## How to activate different feature sets

1. Generate CFN templates with Flight Hangar and provide `--value FeatureSet=<set name>`.
2. Launch your templates
3. ???
4. Profit

The default profile set for a release will be named after the Flight
Compute release, e.g. `2017.1`. During development the default profile
set will be `develop`.
