#!/bin/bash

# author: Irina Ivanova, Irina.Ivanova@protonmail.com, 8.10.2014
# Script works with Tomcat 6
# File contains functions for scripts deploy-new-war-on-tomcat6 and deploy-many-wars-from-file-on-tomcat6

# NB! You need to make changes on further rows:
# 124: path to the directory with logs

NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
CYAN='\033[01;36m'
GRAY='\e[100m'

function printError() {
  echo -e "${RED}$1${NONE}"
}

function printWarning() {
  echo -e "${YELLOW}$1${NONE}"
}

function printOk() {
  echo -e "${GREEN}$1${NONE}"
}

function printInfo() {
  echo -e "${CYAN}$1${NONE}"
}

function printGray() {
  echo -e "${GRAY}$1${NONE}"
}

function verifyArguments() {
  if [ $1 -ne 2 ]
  then
    printError "\n\tUsage: $0 MODULE_NAME MODULE_VERSION"
    printError "\tExample: $0 admin 1.1.1.1\n"
    exit
  fi
}

function bunchVerifyArguments() {
  if [ $1 -ne 1 ]
  then
    printError "\n\tUsage: $0 FILE_NAME"
    printError "\tExample: $0 modules.txt\n"
    exit 0
  fi
}

function removeExistingFile() {
  if test -e "$newWar"; then
    printError "\n\t$newWar file already exists"
    printInfo "\tRemoving existing $newWar file..."

    rm $newWar

    if ! test -e "$newWar"; then
      printOk "\tOK: existing file is removed"
    else
      printError "\tERROR: can't remove existing file"
      exit
    fi
  fi
}

function downloadFile() {
  printInfo "\n\tDownloading file $newWar..."
  wget $location
  exitCode=$?
  if [ $exitCode -ne 0 ]
  then
    printError "\tERROR: can't download file from $location"
  fi

  if test -e "$newWar"; then
    printOk "\tOK: file $newWar is downloaded"
  fi
}

function undeployOldVersion() {
  printInfo "\n\tUndeploying old version of $module..."
  undeploy=$(curl "$tomcatManager/undeploy?path=/$module")

  if echo "$undeploy" | grep -q "OK - Undeployed application at context path"; then
    printOk "\tOK: old version of $module is undeployed"
    isUndeployed=1
  else
    printError $undeploy
    printError "\tERROR: can't undeploy old version of $module"
    isUndeployed=0
  fi
}

function deployNewVersion() {
  printInfo "\n\tDeploying new version $newWar..."
  deploy=$(curl --upload-file "$newWar" "$tomcatManager/deploy?path=/$module&update=true")

  if echo "$deploy" | grep -q "OK - Deployed application at context path"; then
    printOk "\tOK: $newWar is deployed"

    removeDownloadedFile;
  else
    printError $deploy
    printError "\tERROR: can't deploy $newWar. See logs for details"
	deployErrors+=($line)
  fi
}

function checkIsRunning() {
  printInfo "\n\tChecking is $newWar running..."

  isRunning=$(curl "$tomcatManager/list")

  if echo "$isRunning" | grep -q "$module:running"; then
    printOk "\tOK: $newWar is running"
	successModules+=($line)
  else
    printError "\tERROR: $newWar can't run"
	printError "\tSee logs: tomcat/logs/" # TODO: path to the directory with logs
	runningErrors+=($line)
  fi
}

function removeDownloadedFile() {
  printInfo "\n\tRemoving downloaded file..."
  rm $newWar

  if ! test -e "$newWar"; then
    printOk "\tOK: downloaded file is removed"
  else
    printError "\tERROR: can't remove file $newWar"
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
  printGray "\n\n\t\t********************STATISTICS********************"

  printDownloadErrors;
  printDeployErrors;
  printRunningErrors;
  printDeployedModules;

  echo -e "\n\t\tSee logs for details: apache-tomcat-6.0.39/logs/"
  printGray "\t\t**************************************************"
  echo -e "\n\n"
}
