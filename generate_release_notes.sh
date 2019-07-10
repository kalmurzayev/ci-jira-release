
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
jiraQaTransitionId="81"

# --------------- Start script actions -------------------
releaseArtTextEncoded="$(base64 -D <<< "ICAgX19fICAgICAgICAgICAgICBfICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgfCBfIFwgICAgX19fICAgICB8IHwgICAgIF9fXyAgICBfXyBfICAgICBfX18gICAgIF9fXyAgIAogIHwgICAvICAgLyAtXykgICAgfCB8ICAgIC8gLV8pICAvIF9gIHwgICAoXy08ICAgIC8gLV8pICAKICB8X3xfXCAgIFxfX198ICAgX3xffF8gICBcX19ffCAgXF9fLF98ICAgL19fL18gICBcX19ffCAgCl98IiIiIiJ8X3wiIiIiInxffCIiIiIifF98IiIiIiJ8X3wiIiIiInxffCIiIiIifF98IiIiIiJ8IAoiYC0wLTAtJyJgLTAtMC0nImAtMC0wLSciYC0wLTAtJyJgLTAtMC0nImAtMC0wLSciYC0wLTAtJyA=")"
echo "$releaseArtTextEncoded"
echo "\n\nGenerate release-notes for version\033[0;32m $newVersion\033[0m"
jiraTaskIds=$(./ci_extract_jira_tasks_git.sh )
matchesString=$( IFS=$' '; echo "${jiraTaskIds[*]}" )
echo "\nSending Jira REST API requests. Hold your breath..."
generatedChangelog=$(python -W ignore request_jira_tasks.py $jiraServerHost $jiraUsername $jiraPassword $(echo $jiraTaskIds))

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