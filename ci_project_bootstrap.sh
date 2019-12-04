#!/bin/bash -       
#description	:CI/CD workflow скрипт развертки среды сборки и запуска iOS проекта на Mac
#author		 	:Azamat Kalmurzayev
#usage		 	:bash ci_project_bootstrap.sh
#===================================================================

# Проверить наличие данных Runtimes/приложений на локальной машине:
# 1) ruby
# 2) Ruby Gem
# 3) Node.js and npm (for Firebase CLI tools) https://nodejs.org/en/
# 3) Xcode 11.0 for Mojave: install from AppStore
# 4) Если возникнет "error with active developer directory", нужно изменить активную директорию для xcode CLI:
#    https://github.com/nodejs/node-gyp/issues/569#issuecomment-104284148

# Административные требования:
# 1) Наличие учетной записи в удаленном репозитории для CI/CD
# 2) Наличие учетной записи и пароля в Developer Portal и AppStoreConnect для CI/CD
# 3) Наличие FIREBASE_TOKEN env var на машине для загрузки билдов в Firebase App Distribution
# 3) Файл `.jiracredentials.txt`. Заполнить!

projectBootstrapArtText="$(base64 -D <<< "ICAgX19fICAgICBfX18gICAgX19fX18gICBfICAgXyAgICAgX19fICAKICAvIF9ffCAgIHwgX198ICB8XyAgIF98IHwgfCB8IHwgICB8IF8gXCAKICBcX18gXCAgIHwgX3wgICAgIHwgfCAgIHwgfF98IHwgICB8ICBfLyAKICB8X19fLyAgIHxfX198ICAgX3xffF8gICBcX19fLyAgIF98X3xfICAKX3wiIiIiInxffCIiIiIifF98IiIiIiJ8X3wiIiIiInxffCAiIiIgfCAKImAtMC0wLSciYC0wLTAtJyJgLTAtMC0nImAtMC0wLSciYC0wLTAtJyA=")"
echo "$projectBootstrapArtText"
echo ""
echo "Bootstrapping your iOS project."
read -p "Have you met all env requirements from script description? (y/n): "  answer

if [ $answer == "n" ] || [ $answer == "N" ]
then
    echo "Go back and complete all necessary env requirements"
    exit 1
fi
# latest setup scripts are usually on development branch
git checkout development

# -------------------- Native libraries -----------------------
# making sure Homebrew package manager is installed
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install carthage
brew install swiftlint
brew tap blender/tap https://github.com/blender/homebrew-tap.git
brew install blender/homebrew-tap/rome

# -------------- Install platform dependencies --------------------

sudo gem install bundler
sudo bundle install
sudo easy_install pip
pip install -r requirements.txt
sudo npm install -g firebase-tools
if [ -z $FIREBASE_TOKEN ]
then
	echo "WARNING: set FIREBASE_TOKEN env var to your machine, ask your DevOps for variable value"
fi


# --------------------- Project initialization -----------------------

# updating Carthage libraries
carthage update --platform iOS --verbose --new-resolver

# ----------------- Required environment variables ---------------------
if [ ! -f $CI_JIRA_USERNAME ] 
then
	echo "WARNING: Make sure to set CI_JIRA_USERNAME environment variable"
fi
if [ ! -f $CI_JIRA_PASSWORD ] 
then
	echo "WARNING: Make sure to set CI_JIRA_PASSWORD environment variable"
fi


