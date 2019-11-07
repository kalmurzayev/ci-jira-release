# gen-jira-release-notes
Scripts for generating JIRA project release notes based on git log history

### Prerequisites

* Git commit format including JIRA tasks in commit messages or branch names
* GitFlow-like development  (maintaining stable branches)
* python 2.7+

### Format

`./ci_generate_release_notes.sh -v NEW_RELEASE_VERSION -o OUTPUT_FILE` 

Generates release notes text for a new app version  and writes to specified file. It retrieves JIRA user credentials from `.jiracredentials.txt`. 

If called with no parameters, it collects Jira issues starting from latest deployment commit matched by regex (see script for details)

### Credentials file

Release notes generation relies on contents of your `.jiracredentials.txt` file. Fill it in according to provided example:

`JIRA_HOST JIRA_USERNAME JIRA_PASSWORD`

*Make sure to include your `.jiracredentials.txt` file to `.gitignore`*

### Usage

Usage example `./ci_generate_release_notes.sh -v 2.5.0 -o fastlane/release_notes.txt`

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
```