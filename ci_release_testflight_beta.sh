#!/bin/bash -       
#description	:CI/CD workflow скрипт для сборки/загрузка IPA в TestFlight
#author		 	:Azamat Kalmurzayev
#usage		 	:bash ci_release_testflight_beta.sh
#===================================================================
export LATEST_DEPLOY_COMMIT_MATCH="testflight"
fastlane build_for_appstore
