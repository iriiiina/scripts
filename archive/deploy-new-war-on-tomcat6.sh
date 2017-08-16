#!/bin/bash

# author: Irina Ivanova, Irina.Ivanova@protonmail.com, 8.10.2014
# Script works with Tomcat 6
# Script downloads war file, undeploys old version of module and deploys downloaded version

# NB! You need to make changes on further rows:
# 26: path to your webapps directory
# 27: username, password, URL and port of your Tomcat manager
# 28: URL to your war file

. functions-for-deploying-on-tomcat6.sh

lock="SOMEBODY_IS_UPDATING_$1-$2.loc"

if test -e "SOMEBODY_IS_UPDATING"*; then
  printError "\n\tERROR: Somebody is updating, see .loc file for details"
  printError "\n\n"
  exit 0
else
  verifyArguments $#
  touch $lock
fi

# Set variables
webapps="tomcat/webapps" # TODO: path to your webapps directory
tomcatManager="http://username:password@URL:port/manager" # TODO: username, password, URL and port of your Tomcat manager
location="URL/$1-$2.war" # TODO: URL to your war file
newWar="$1-$2.war" # should be the same as downloaded file
module=$1

printInfo "\n\t**********$module**********"

removeExistingFile;

downloadFile;

if ! test -e "$newWar"; then
  rm $lock
  exit
fi

if ! test -d "$webapps/$module" && ! test -e "$webapps/$module.war"; then
  printWarning "\n\tWARNING: can't find previous deployed version of $module"
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

if test -e "$lock"; then
  rm $lock
fi
