#!/bin/bash -       
#description	:CI/CD скрипт для аггрегации Jira задач из логов, проставления ссылки на скачивание билда и передвижение по скрам доске 
#author		 	:Azamat Kalmurzayev
#usage		 	:bash ci_comment_transition_jira.sh
#===================================================================

if [ -z $CI_JIRA_SERVER_HOST ] || [ -z $CI_JIRA_USERNAME ] || [ -z $CI_JIRA_PASSWORD ]
then
    echo "ERROR: Please set CI_JIRA_SERVER_HOST, CI_JIRA_USERNAME and CI_JIRA_PASSWORD and environment variable (in .bash_profile or .zshrc)"
    exit 0
fi

# ------------ Building Jira comment body ------------------
tempFile="build_number.txt"
fastlane write_build_version_file filename:$tempFile
currentBuildNumber=$(<fastlane/$tempFile)
if [ -z $currentBuildNumber ]
then
	echo "EMPTY"
    exit 0
fi
jiraCommentText="Application build #$currentBuildNumber"
jiraQaTransitionId="81"

# --------------- Start script actions -------------------
jiraTaskIds=$(./ci_extract_jira_tasks_git.sh )
matchesString=$( IFS=$' '; echo "${jiraTaskIds[*]}" )
echo "Jira comment text: $jiraCommentText"
python -W ignore ci_post_task_comments.py $CI_JIRA_SERVER_HOST $CI_JIRA_USERNAME $CI_JIRA_PASSWORD "$(echo $jiraCommentText)" $(echo $matchesString)
echo ""
echo "Transitioning Jira tasks to QA test..."
python -W ignore ci_trigger_jira_transitions.py $CI_JIRA_SERVER_HOST $CI_JIRA_USERNAME $CI_JIRA_PASSWORD $jiraQaTransitionId $(echo $matchesString)
git clean -f