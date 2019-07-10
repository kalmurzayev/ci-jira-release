#extracting latest tag on current branch
latestTag=$(git describe --abbrev=0 --tags) 
if [ -z $latestTag ] 
then
	echo '\033[0;31mNo latest tag found in latest 150 commits'
	exit 1
fi

# ----------- Start script actions -------------------
GIT_MESSAGES=$(git log -n 150 --oneline $(echo $latestTag)..HEAD)

matches=$(echo $GIT_MESSAGES | grep -Eo "[A-Z]{2,7}\-[0-9]+" | sort | uniq )
echo $matches