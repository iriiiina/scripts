#!/bin/bash

# author: Irina Ivanova, iriiiina@gmail.com, 31.08.2014
# Script works with Tomcat 6
# Script downloads war file, undeploys old version of module and deploys downloaded version

# NB! You need to make changes on further rows:
# 87: path to the directory with logs
# 111: path to your webapps directory
# 112: username, password, URL and port of your Tomcat manager
# 113: URL to your war file

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
CYAN='\033[01;36m'

function removeExistingFile() {
  if test -e "$newWar"; then
    echo -e "\n\t${YELLOW}$newWar file already exists${NONE}"
    echo -e "\t${CYAN}Removing existing $newWar file...${NONE}"

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
  echo -e "\n\t${CYAN}Downloading file $newWar...${NONE}"
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
  echo -e "\n\t${CYAN}Undeploying old version of $module...${NONE}"
  undeploy=$(curl "$tomcatManager/undeploy?path=/$module")

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
  echo -e "\n\t${CYAN}Deploying new version $newWar...${NONE}"
  deploy=$(curl --upload-file "$newWar" "$tomcatManager/deploy?path=/$module&update=true")

  if echo "$deploy" | grep -q "OK - Deployed application at context path"; then
    echo -e "\t${GREEN}OK: $newWar is deployed${NONE}"

    removeDownloadedFile;
  else
    echo $deploy
    echo -e "\t${RED}ERROR: can't deploy $newWar. See logs for details${NONE}"
  fi
}

function checkIsRunning() {
  echo -e "\n\t${CYAN}Checking is $newWar running...${NONE}"

  isRunning=$(curl "$tomcatManager/list")

  if echo "$isRunning" | grep -q "$module:running"; then
    echo -e "\t${GREEN}OK: $newWar is running${NONE}"
  else
    echo -e "\t${RED}ERROR: $newWar can't run${NONE}"
	echo -e "\t${RED}See logs: tomcat/logs/${NONE}" # path to the directory with logs
  fi
}

function removeDownloadedFile() {
  echo -e "\n\t${CYAN}Removing downloaded file...${NONE}"
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
tomcatManager="http://username:password@URL:port/manager" # username, password, URL and port of your Tomcat manager
location="URL/$1-$2.war" # URL to your war file
newWar="$1-$2.war" # should be the same as downloaded file
module=$1

echo -e "\n\t${CYAN}**********$module**********${NONE}"

removeExistingFile;

downloadFile;

if ! test -d "$webapps/$module" && ! test -e "$webapps/$module.war"; then
  echo -e "\n\t${YELLOW}WARNING: can't find previous deployed version of $module${NONE}"
  deployNewVersion;
  checkIsRunning;
  exit
else
  undeployOldVersion;
fi

if [[ $isUndeployed -eq 1 ]]
then
  deployNewVersion;
  checkIsRunning;
fi
