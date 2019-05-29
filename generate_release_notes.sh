
# extracting shell script arguments
while getopts ":v:o:" opt; do
  case $opt in
    v) newVersion="$OPTARG"
    ;;
    o) output="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

#extracting latest tag on current branch
latestTag=$(git describe --abbrev=0 --tags) 
if [ -z $latestTag ] 
then
	echo 'No latest tag found in latest 150 commits'
	exit 1
fi

# reading contents of user specified .jiracredentials.txt
if [ ! -f .jiracredentials.txt ] 
then
	echo 'No .jiracredentials.txt file found'
	exit 1
fi
credentialsFileContents=$(<.jiracredentials.txt)
IFS=$' ' read -ra credentials <<< "$credentialsFileContents"
jiraServerHost=${credentials[0]}
jiraUsername=${credentials[1]}
jiraPassword=${credentials[2]}

echo "Generate release-notes for version $newVersion"
echo "Latest tag on current branch: $latestTag"
GIT_MESSAGES=$(git log -n 150 --oneline $(echo $latestTag)..HEAD)

matches=$(echo $GIT_MESSAGES | grep -Eo "[A-Z]{2,5}\-[0-9]+" | sort | uniq )

echo "\nExtracted JIRA tasks:"
echo $matches

matchesString=$( IFS=$' '; echo "${matches[*]}" )
echo "Passing to python script..."
generatedChangelog=$(python -W ignore request_jira_tasks.py $jiraServerHost $jiraUsername $jiraPassword $(echo $matchesString))
echo "Writing release-notes to file $output"
echo "Version ${newVersion}\n----------------\n\n${generatedChangelog}" > $output

echo $changelog