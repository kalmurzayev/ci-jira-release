#!/bin/bash -       
#description	:CI/CD скрипт для Нахождения самого последнего коммита, с которым был произведен deployment в тестовую среду
#author		 	:Azamat Kalmurzayev
#usage		 	:bash ci_latest_deploy_commit.sh
#===================================================================


latestTag=$(git describe --abbrev=0 --tags) 
if [ -z $latestTag ] 
then
	echo '\033[0;31mNo latest tag found in latest 150 commits'
	exit 1
fi

# ----------- Start script actions -------------------
gitMessages=$(git log -n 150 --oneline $(echo $latestTag)..HEAD)
gitLogMatch=$(echo "$gitMessages" | grep -Eo -m 1 "(.+) ci\(deploy\):" | uniq )
commitHash=$(echo "$gitLogMatch" | grep -Eo -m 1 "[0-9a-f]{8}" | uniq )
echo $commitHash