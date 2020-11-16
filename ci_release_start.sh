#!/bin/bash -       
#description	:CI/CD workflow скрипт для запуска процедуры релиза
#author		 	:Azamat Kalmurzayev
#usage		 	:bash ci_release_start.sh -v [NEW_APP_VERSION]
#===================================================================

# extracting shell script arguments
while getopts ":v:" opt; do
  case $opt in
    v) newVersion="$OPTARG"
    ;;
    \?) echo "\e[31Invalid option -$OPTARG" >&2
    ;;
  esac
done
if [ -z $newVersion ] 
then
	echo '\033[0;31mNo release version passed in -v argument'
	exit 1
fi

releaseArtTextEncoded="$(base64 -D <<< "ICAgX19fICAgICAgICAgICAgICBfICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgfCBfIFwgICAgX19fICAgICB8IHwgICAgIF9fXyAgICBfXyBfICAgICBfX18gICAgIF9fXyAgIAogIHwgICAvICAgLyAtXykgICAgfCB8ICAgIC8gLV8pICAvIF9gIHwgICAoXy08ICAgIC8gLV8pICAKICB8X3xfXCAgIFxfX198ICAgX3xffF8gICBcX19ffCAgXF9fLF98ICAgL19fL18gICBcX19ffCAgCl98IiIiIiJ8X3wiIiIiInxffCIiIiIifF98IiIiIiJ8X3wiIiIiInxffCIiIiIifF98IiIiIiJ8IAoiYC0wLTAtJyJgLTAtMC0nImAtMC0wLSciYC0wLTAtJyJgLTAtMC0nImAtMC0wLSciYC0wLTAtJyA=")"
echo "$releaseArtTextEncoded"
echo ""
echo "RELEASE-START"
echo "-------------"
echo "New version: \033[0;32m $newVersion\033[0m"

# checkout latest development code
# git checkout .
git checkout development
# not sure if this should be called: git pull origin development

# generate release notes since latest "branchcut" tag on development
outputPath="fastlane/release_notes.txt"
export LATEST_DEPLOY_COMMIT_MATCH="testflight"
./ci_generate_release_notes.sh -v $newVersion -o $outputPath
git add $outputPath

# create branchcut tag on development and push
git tag "branchcut-$newVersion" --message "Срез ветки development для процедуры релиза версии $newVersion"
git push origin --tags

# checking out new release branch, bump app version and push
git checkout -B release/$newVersion
fastlane run increment_version_number version_number:"$newVersion"
cp fastlane/release_notes.txt fastlane/metadata/ru/
git add .
git commit -m "ci: release-start step, app version $newVersion"
git push origin release/$newVersion

fastlane start_appstore_new_version || { echo "\033[0;31mCould not initiate new App Version on AppStore Connect. Release manager has to do it manually." }
fastlane start_appstore_new_version
