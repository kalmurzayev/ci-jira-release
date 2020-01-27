#!/bin/bash -       
#description	:CI/CD скрипт для аггрегации идентификаторов Jira задач из логов с последнего тэга 
#author		 	:Azamat Kalmurzayev
#usage		 	:bash ci_extract_jira_tasks_git.sh [-c abc123]
#===================================================================

# extracting shell script arguments
while getopts ":c:" opt; do
  case $opt in
    c) commitFrom="$OPTARG"
    ;;
    \?) echo "\e[31Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [ -z $commitFrom ] 
then
	#extracting latest tag on current branch
	latestTag=$(git describe --abbrev=0 --tags) 
	if [ -z $latestTag ] 
	then
		echo '\033[0;31mNo latest tag found in latest 150 commits'
		exit 1
	fi
	commitFrom=$latestTag
fi

# ----------- Start script actions -------------------
GIT_MESSAGES=$(git log -n 150 --oneline $(echo $commitFrom)...HEAD)

matches=$(echo $GIT_MESSAGES | grep -Eo "[A-Za-z]{2,7}\-[0-9]+" | sort | uniq )
echo $matches