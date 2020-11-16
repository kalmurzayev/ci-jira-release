# gen-jira-release-notes
Scripts for generating JIRA project release notes based on git log history

### Prerequisites

* Git commit format including JIRA tasks in commit messages or branch names
* GitFlow-like development  (maintaining stable branches)
* python 2.7+
* 

### Format

`./ci_generate_release_notes.sh -v NEW_RELEASE_VERSION -o OUTPUT_FILE` 

Generates release notes text for a new app version  and writes to specified file. It retrieves JIRA user credentials from `.jiracredentials.txt`. 

If called with no parameters, it collects Jira issues starting from latest deployment commit matched by regex (see script for details)

### Required Environment variables

Make sure to set environment variables during script runs:

- `CI_JIRA_SERVER_HOST` 

- `CI_JIRA_USERNAME`

- `CI_JIRA_PASSWORD`

Optional variables:

- `LATEST_DEPLOY_COMMIT_MATCH` 

Keyword used in `ci_latest_deploy_commit.sh`, used in pattern-matching for finding latest deployment commit (examples: `"testflight"`, `"crashlytics"`).
Keywords correspond to deployment ecosystem target, to where test/prod application in archived+deployed.
This implies a convention, where app deployments are marked with special commits.

Example:

`ci(deploy): app build version 777 [crashlytics] [ci skip]`


### Usage

Usage example `./ci_generate_release_notes.sh -v 2.5.0 -o fastlane/release_notes.txt -r unresolved`

Example notes:

```
Version 2.4.5
----------------

What's new:

ABC-1004: Create release notes automation script for dev teams
ABC-1035: Implement another thing requested by product manager
DEF-1036: Create new module for payment calculation

Fixes:

DEF-1047: Fix visual bug found in login page by Vladimir
XYZ-234: Fix Regression bug eliminated in release 2.1.1

Tech-maintenance tasks:

ABC-1001: remove all legacy request methods
```

### Release scripts

`./ci_release_start.sh 1.2` - starts new app version 1.2

- performs branch cut, sets+pushes proper tags
- creates+pushes corresponding release/[VERSION] branch
- for iOS: initiates new app version in AppStoreConnect

### Fastlane examples

You can check `fastlane` folder for our fastlane workflow examples. Note that there are some dummy data and ENV_VAR references, so make sure to fill them out before copying and running these scripts.