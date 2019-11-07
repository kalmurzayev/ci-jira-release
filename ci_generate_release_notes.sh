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
    c) credentialsFile="$OPTARG"
    ;;
    r) resolutionStatus="$OPTARG"
    ;;
    \?) echo "\e[31Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z $credentialsFile ]
then
    credentialsFile=".jiracredentials.txt"
fi

if [ -z $resolutionStatus ]
then
    resolutionStatus="all"
fi

# reading contents of user specified .jiracredentials.txt
if [ ! -f $credentialsFile ] 
then
	echo '\033[0;31mNo .jiracredentials.txt file not passed or found'
	exit 1
fi
credentialsFileContents=$(<$credentialsFile)
IFS=$' ' read -ra credentials <<< "$credentialsFileContents"
jiraServerHost=${credentials[0]}
jiraUsername=${credentials[1]}
jiraPassword=${credentials[2]}
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
generatedChangelog=$(python -W ignore $pythonScript $jiraServerHost $jiraUsername $jiraPassword $resolutionStatus $(echo $matchesString))

if [ -z $output ]
then
    echo "$generatedChangelog"
else
    versionText="Version ${newVersion}"
    if [ -z $newVersion ]
    then
        versionText="Next version candidate"
    fi
    echo "Writing release-notes to output file..."
    echo -e "${versionText}\n----------------\n\n${generatedChangelog}" > $output
    echo "\033[0;32mDONE. Checkout $output"
fi
