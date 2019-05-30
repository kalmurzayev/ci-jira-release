
# extracting shell script arguments
while getopts ":v:o:" opt; do
  case $opt in
    v) newVersion="$OPTARG"
    ;;
    o) output="$OPTARG"
    ;;
    \?) echo "\e[31Invalid option -$OPTARG" >&2
    ;;
  esac
done

#extracting latest tag on current branch
latestTag=$(git describe --abbrev=0 --tags) 
if [ -z $latestTag ] 
then
	echo '\033[0;31mNo latest tag found in latest 150 commits'
	exit 1
fi

# reading contents of user specified .jiracredentials.txt
if [ ! -f .jiracredentials.txt ] 
then
	echo '\033[0;31mNo .jiracredentials.txt file found'
	exit 1
fi
credentialsFileContents=$(<.jiracredentials.txt)
IFS=$' ' read -ra credentials <<< "$credentialsFileContents"
jiraServerHost=${credentials[0]}
jiraUsername=${credentials[1]}
jiraPassword=${credentials[2]}

# ----------- Start script actions -------------------
releaseArtTextEncoded="$(base64 -D <<< "ICAgX19fICAgICAgICAgICAgICBfICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgfCBfIFwgICAgX19fICAgICB8IHwgICAgIF9fXyAgICBfXyBfICAgICBfX18gICAgIF9fXyAgIAogIHwgICAvICAgLyAtXykgICAgfCB8ICAgIC8gLV8pICAvIF9gIHwgICAoXy08ICAgIC8gLV8pICAKICB8X3xfXCAgIFxfX198ICAgX3xffF8gICBcX19ffCAgXF9fLF98ICAgL19fL18gICBcX19ffCAgCl98IiIiIiJ8X3wiIiIiInxffCIiIiIifF98IiIiIiJ8X3wiIiIiInxffCIiIiIifF98IiIiIiJ8IAoiYC0wLTAtJyJgLTAtMC0nImAtMC0wLSciYC0wLTAtJyJgLTAtMC0nImAtMC0wLSciYC0wLTAtJyA=")"
echo "$releaseArtTextEncoded"
echo "\n\nGenerate release-notes for version\033[0;32m $newVersion\033[0m"
echo "Latest tag on current branch: $latestTag"
GIT_MESSAGES=$(git log -n 150 --oneline $(echo $latestTag)..HEAD)

matches=$(echo $GIT_MESSAGES | grep -Eo "[A-Z]{2,5}\-[0-9]+" | sort | uniq )
echo "\nThis Jira task were extracted from git logs:"
echo $matches
matchesString=$( IFS=$' '; echo "${matches[*]}" )
echo "\nSending $matchesCount Jira REST API requests. Hold your breath..."
generatedChangelog=$(python -W ignore request_jira_tasks.py $jiraServerHost $jiraUsername $jiraPassword $(echo $matchesString))
echo "Writing release-notes to output file..."
echo "Version ${newVersion}\n----------------\n\n${generatedChangelog}" > $output
echo "\033[0;32mDONE. Checkout $output"