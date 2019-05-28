# gen-jira-release-notes
Scripts for generating JIRA project release notes based on git logs


`./generate_release_notes.sh -p JIRA_PROJECT_NAME -v NEW_RELEASE_VERSION -o OUTPUT_FILE` 

Generates release notes text for a new app version  and writes to specified file. It retrieves JIRA user credentials from `.jiracredentials.txt`. 

#### Credentials file

Release notes generation relies on contents of your `.jiracredentials.txt` file. Fill it in according to provided example:

`JIRA_HOST JIRA_USERNAME JIRA_PASSWORD`

*Make sure to include your `.jiracredentials.txt` file to `.gitignore`*

#### Usage

Usage example `./generate_release_notes.sh -p ABC -v 2.5.0 -o fastlane/release_notes.txt`