#!/bin/bash

# author: Irina Ivanova, iriiiina@gmail.com, 8.10.2014
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
# 41: path to webapps directory
# 43: username, password, URL and port of your Tomcat manager
# 44: URL to your war file

. functions-for-deploying-on-tomcat6.sh

lock="SOMEBODY_IS_UPDATING_BUNCH_OF_MODULES.loc"

if test -e "SOMEBODY_IS_UPDATING"*; then
  printError "\n\tERROR: Somebody is updating, see .loc file for details"
  printError "\n\n"
  exit 0
else
  bunchVerifyArguments $#
  touch $lock
fi

printGray "\n\t\t*********************************************"
printGray "\t\t********************START********************"
printGray "\t\t*********************************************"

file=$1
while read -r line; do

  # Set variables
  webapps="apache-tomcat/webapps" # TODO: path to webapps directory
  module=$( echo "$line" |cut -d "-" -f1 ) # One line example "module-1.1.1.1" where first word before "-" is module name
  tomcatManager="http://user:password@URL:port/manager" # TODO: username, password, URL and port of your Tomcat manager
  location="URL/$line.war" # TODO: URL to your war file
  newWar=$line.war # should be the same as downloaded file

  printInfo "\n********************Updating $line********************"

  removeExistingFile;

  # Download file
  printInfo "\n\tDownloading $line file"
  wget $location

  if test -e $newWar; then
    printOk "\tOK: file $newWar is downloaded"

    if ! test -d "$webapps/$module" && ! test -e "$webapps/$module.war"; then
      printWarning "\n\tWARNING: can't find previous deployed version of $module"

      deployNewVersion;
	  checkIsRunning;

      printInfo "********************Update of $line is completed********************"

    else
      undeployOldVersion;
    fi

    if [[ $isUndeployed -eq 1 ]]
    then
      deployNewVersion;
	  checkIsRunning;

      printInfo "********************Update of $line is completed********************"
    fi
  else
    printError "\tERROR: can't download the $line.war file from $location"
    downloadErrors+=($line)
    printInfo "********************Update of $line is completed********************"
  fi

done < $file

printStatistics;

if test -e "$lock"; then
  rm $lock
fi