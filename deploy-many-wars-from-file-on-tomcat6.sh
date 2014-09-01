#!/bin/bash

# author: Irina Ivanova, iriiiina@gmail.com, 31.08.2014
# Script works with Tomcat 6
# Script takes module and version number from a file, downloads the war file, undeploys old version, deploys new version and continue with next module and version in the file.
# Example of rows in the file:
#     moduleOne-1.1.1.1
#     moduleTwo-2.2.2.2
#     moduleThree-3.3.3.3
#
# If one module can't be downloaded script continues work with next module
#
# At the end script prints statistics: download errors, deploy errors and succesfully deployed modules.

# NB! You need to make changes on further rows:
# 157: path to the directory with logs
# 178: path to webapps directory
# 180: username, password, URL and port of your Tomcat manager
# 181: URL to your war file
# 182: should be the same as downloaded file

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
CYAN='\033[01;36m'
GRAY='\e[100m'

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

function undeployOldVersion() {
  echo -e "\n\tUndeploying old version of $module"
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
  echo -e "\n\tDeploying new version $newWar ..."
  deploy=$(curl --upload-file "$newWar" "$tomcatManager/deploy?path=/$module&update=true")

  if echo "$deploy" | grep -q "OK - Deployed application at context path"; then
    echo -e "\t${GREEN}OK: $newWar is deployed${NONE}"
    removeDownloadedFile;
  else
    echo $deploy
    echo -e "\t${RED}ERROR: can't deploy $newWar. See logs for details${NONE}"
    deployErrors+=($line)
  fi
}

function checkIsRunning() {
  echo -e "\n\tChecking is $newWar running..."
  isRunning=$(curl "$tomcatManager/list")

  if echo "$isRunning" | grep -q "$moduleName:running"; then
    echo -e "\t${GREEN}OK: $newWar is running${NONE}"
    successModules+=($line)
  else
    echo -e "\t${RED}ERROR: $newWar is not running${NONE}"
    runningErrors+=($line)
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

function printDownloadErrors() {
  if [ ${#downloadErrors[*]} -gt 0 ]
  then
    echo -e "\t\tDOWNLOAD ERRORS: ${RED}${#downloadErrors[*]}${NONE}"
    for item in ${downloadErrors[*]}
    do
      echo -e "\t\t\t${RED}$item${NONE}"
    done
  else
    echo -e "\t\tDOWNLOAD ERRORS: ${#downloadErrors[*]}"
  fi
}

function printDeployErrors() {
  if [ ${#deployErrors[*]} -gt 0 ]
  then
    echo -e "\t\tDEPLOY ERRORS: ${RED}${#deployErrors[*]}${NONE}"
    for item in ${deployErrors[*]}
    do
      echo -e "\t\t\t${RED}$item${NONE}"
    done
  else
    echo -e "\t\tDEPLOY ERRORS: ${#deployErrors[*]}"
  fi
}

function printRunningErrors() {
  if [ ${#runningErrors[*]} -gt 0 ]
  then
    echo -e "\t\tRUNNING ERRORS: ${RED}${#runningErrors[*]}${NONE}"
    for item in ${runningErrors[*]}
    do
      echo -e "\t\t\t${RED}$item${NONE}"
    done
  else
    echo -e "\t\tRUNNING ERRORS: ${#runningErrors[*]}"
  fi
}

function printDeployedModules() {
  if [ ${#successModules[*]} -gt 0 ]
  then
    echo -e "\n\t\tDEPLOYED MODULES: ${GREEN}${#successModules[*]}${NONE}"
    for item in ${successModules[*]}
    do
      echo -e "\t\t\t${GREEN}$item${NONE}"
    done
  else
    echo -e "\n\t\tDEPLOYED MODULES: ${#successModules[*]}"
  fi
}

function printStatistics() {
  echo -e "\n\n\t\t${GRAY}********************STATISTICS********************${NONE}"

  printDownloadErrors;
  printDeployErrors;
  printRunningErrors;
  printDeployedModules;

  echo -e "\n\t\tSee logs for details: tomcat/logs/" # TODO: path to the directory with logs
  echo -e "\t\t${GRAY}**************************************************${NONE}"
  echo -e "\n\n"
}

# Verify arguments: $1 = file with modules and versions. File should contain one module and version per line: module-1.1.1.1 
if [ $# -ne 1 ]
then
  echo -e "\n\t ${RED}Usage: $0 FILE_NAME${NONE}"
  echo -e "\t Example: $0 modules.txt\n"
  exit 0
fi

echo -e "\n\t\t${GRAY}*********************************************${NONE}"
echo -e "\t\t${GRAY}********************START********************${NONE}"
echo -e "\t\t${GRAY}*********************************************${NONE}"

file=$1
while read -r line; do

  # Set variables
  webapps="apache-tomcat/webapps" # TODO: path to webapps directory
  module=$( echo "$line" |cut -d "-" -f1 ) # One line example "module-1.1.1.1" where first word before "-" is module name
  tomcatManager="http://user:password@URL:port/manager" # TODO: username, password, URL and port of your Tomcat manager
  location="URL/$line.war" # TODO: URL to your war file
  newWar=$line.war # TOOD: should be the same as downloaded file

  echo -e "\n${CYAN}********************Updating $line********************${NONE}"

  removeExistingFile;

  # Download file
  echo -e "\n\tDownloading $line file"
  wget $location

  if test -e $newWar; then
    echo -e "\t${GREEN}OK: file $newWar is downloaded${NONE}"

    if ! test -d "$webapps/$module" && ! test -e "$webapps/$module.war"; then
      echo -e "\n\t${YELLOW}WARNING: can't find previous deployed version of $module${NONE}"

      deployNewVersion;
	  checkIsRunning;

      echo -e "${CYAN}********************Update of $line is completed********************${NONE}"

    else
      undeployOldVersion;
    fi

    if [[ $isUndeployed -eq 1 ]]
    then
      deployNewVersion;
	  checkIsRunning;

      echo -e "${CYAN}********************Update of $line is completed********************${NONE}"
    fi
  else
    echo -e "\t ${RED}ERROR: can't download the $line.war file from $location${NONE}"
    downloadErrors+=($line)
    echo -e "${CYAN}********************Update of $line is completed********************${NONE}"
  fi

done < $file

printStatistics;