#!/bin/bash -       
#description  :CI/CD workflow скрипт для генерации release-notes из текста коммитов 
#author       :Azamat Kalmurzayev
#usage        :bash ci_generate_release_notes.sh -v [APP_VERSION] -o [RELEASE_NOTES_OUTPUT_FILE] -r (all/unresolved/resolved)
#===================================================================

# extracting shell script arguments
while getopts ":v:o:c:r:" opt; do
  case $opt in
    v) newVersion="$OPTARG"
    ;;
    o) output="$OPTARG"
    ;;
    r) resolutionStatus="$OPTARG"
    ;;
    \?) echo "\e[31Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z $CI_JIRA_SERVER_HOST ] || [ -z $CI_JIRA_USERNAME ] || [ -z $CI_JIRA_PASSWORD ]
then
    echo "ERROR: Please set CI_JIRA_SERVER_HOST, CI_JIRA_USERNAME and CI_JIRA_PASSWORD and environment variable (in .bash_profile or .zshrc)"
    exit 0
fi

if [ -z $resolutionStatus ]
then
    resolutionStatus="all"
fi

pythonScript=ci_request_jira_tasks.py

# ----------- Start script actions -------------------
echo "\n\nGenerate release-notes for version\033[0;32m $newVersion\033[0m"


jiraTaskIds=""
# If NEW_VERSION arg is passed, then we are in release cycle.
# Hence we collect jira tasks starting from latest `branchcut` tag
# Otherwise we collect Jira tasks from latest Dev Deployment commit
if [ -z $newVersion ]
    then
        latestDeployCommit=$(./ci_latest_deploy_commit.sh)
        jiraTaskIds=$(./ci_extract_jira_tasks_git.sh -c $latestDeployCommit)
    else
        jiraTaskIds=$(./ci_extract_jira_tasks_git.sh )
    fi

matchesString=$( IFS=$' '; echo "${jiraTaskIds[*]}" )
echo "Sending $jiraTaskIds Jira REST API requests. Hold your breath..."
generatedChangelog=$(python -W ignore $pythonScript $CI_JIRA_SERVER_HOST $CI_JIRA_USERNAME $CI_JIRA_PASSWORD $resolutionStatus $(echo $matchesString))

if [ -z $output ]
then
    echo "$generatedChangelog"
else
    versionText="Version ${newVersion}\n----------------\n\n"
    if [ -z $newVersion ]
    then
        versionText=""
    fi
    echo "Writing release-notes to output file..."
    echo -e "${versionText}${generatedChangelog}" > $output
    echo "\033[0;32mDONE. Checkout $output"
fi
