#!/bin/bash -       
#description	:CI/CD скрипт для аггрегации Jira задач из логов, проставления ссылки на скачивание билда и передвижение по скрам доске 
#author		 	:Azamat Kalmurzayev
#usage		 	:bash ci_comment_transition_jira.sh
#===================================================================


# ------------ Building Jira comment body ------------------
# extracting shell script arguments
while getopts ":m:t:" opt; do
  case $opt in
    m) jiraCommentText="$OPTARG"
    ;;
    t) jiraQaTransitionId="$OPTARG"
    ;;
    \?) echo "\e[31Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z $jiraCommentText ]
then
	echo "No comment text was specified"
    exit 0
fi
if [ -z $jiraQaTransitionId ]
then
	echo "No Jira transition ID was specified"
    exit 0
fi


# ------------- Reading JIRA credentials ------------------
credentialsFile=".jiracredentials.txt"
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

# --------------- Start script actions -------------------
jiraTaskIds=$(./ci_extract_jira_tasks_git.sh )
matchesString=$( IFS=$' '; echo "${jiraTaskIds[*]}" )
echo "Jira comment text: $jiraCommentText"
python -W ignore ci_post_task_comments.py $jiraServerHost $jiraUsername $jiraPassword "$(echo $jiraCommentText)" $(echo $matchesString)
echo ""
echo "Transitioning Jira tasks to QA test..."
python -W ignore ci_trigger_jira_transitions.py $jiraServerHost $jiraUsername $jiraPassword $jiraQaTransitionId $(echo $matchesString)
git clean -f