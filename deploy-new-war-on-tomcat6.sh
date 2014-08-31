#!/bin/bash
# Script downloads war file, undeploys old version of module and deploys downloaded version on Tomcat6
# author: Irina Ivanova, iriiiina@gmail.com, 31.08.2014

# NB! You need to make changes on further rows:
# 50: username, password, URL and port of your Tomcat manager
# 64: username, password, URL and port of your Tomcat manager
# 96: path to your webapps directory
# 97: URL to your war file

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
CYAN='\033[01;36m'

function removeExistingFile() {
  if test -e "$newWar"; then
    echo -e "\n\t${YELLOW}$newWar file already exists${NONE}"
    echo -e "\tRemoving existing $newWar file..."

    rm $newWar

    if ! test -e "$newWar"; then
      echo -e "\t${GREEN}OK: existing file is removed${NONE}"
    else
      echo -e "\t${RED}ERROR: can't remove existing file${NONE}"
      exit
    fi
  fi
}

function downloadFile() {
  echo -e "\n\tDownloading file $newWar..."
  wget $location
  exitCode=$?
  if [ $exitCode -ne 0 ]
  then
    echo -e "\t${RED}ERROR: can't download file from $location${NONE}"
    exit 1
  fi

  if test -e "$newWar"; then
    echo -e "\t${GREEN}OK: file $newWar is downloaded${NONE}"
  fi
}

function undeployOldVersion() {
  echo -e "\n\tUndeploying old version of $module"
  undeploy=$(curl "http://username:password@URL:port/manager/undeploy?path=/$module") # username, password, URL and port of your Tomcat manager

  if echo "$undeploy" | grep -q "OK - Undeployed application at context path"; then
    echo -e "\t${GREEN}OK: old version of $module is undeployed${NONE}"
    isUndeployed=1
  else
    echo $undeploy
    echo -e "\t${RED}ERROR: can't undeploy old version of $module${NONE}"
    isUndeployed=0
  fi
}

function deployNewVersion() {
  echo -e "\n\tDeploying new version $newWar ..."
  deploy=$(curl --upload-file "$newWar" "http://username:password@URL:port/manager/deploy?path=/$module&update=true") # username, password, URL and port of your Tomcat manager

  if echo "$deploy" | grep -q "OK - Deployed application at context path"; then
    echo -e "\t${GREEN}OK: $newWar is deployed${NONE}"

    removeDownloadedFile;
  else
    echo $deploy
    echo -e "\t${RED}ERROR: can't deploy $newWar. See logs for details${NONE}"
  fi
}

function removeDownloadedFile() {
  echo -e "\n\tRemoving downloaded file..."
  rm $newWar

  if ! test -e "$newWar"; then
    echo -e "\t${GREEN}OK: downloaded file is removed${NONE}"
  else
    echo -e "\t${RED}ERROR: can't remove file $newWar${NONE}"
  fi
}

# Verify arguments: first argument $1 is module name, second $2 is version number
if [ $# -ne 2 ]
then
  echo -e "\n\t${RED}Usage: $0 MODULE_NAME MODULE_VERSION${NONE}"
  echo -e "\tExample: $0 admin 1.1.1.1\n"
  exit 0
fi

# Set variables
webapps="tomcat/webapps" # path to your webapps directory
location="URL/$1-$2.war" # URL to your war file
newWar="$1-$2.war"
module=$1

echo -e "\n\t${CYAN}**********$module**********${NONE}"

removeExistingFile;

downloadFile;

if ! test -d "$webapps/$module" && ! test -e "$webapps/$module.war"; then
  echo -e "\n\t${YELLOW}WARNING: can't find previous deployed version of $module${NONE}"
  deployNewVersion;
  exit
else
  undeployOldVersion;
fi

if [[ $isUndeployed -eq 1 ]]
then
  deployNewVersion;
fi
