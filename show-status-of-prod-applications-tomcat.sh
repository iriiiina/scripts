#!/bin/bash

########################################################################################################################
### This is script for listing deployed applications on multiple-server and multiple-cluster environment (Tomcat 8)  ###
### You may want to add some changes here, all possible modifications are mentioned in the comments                  ###
###                                                                                                                  ###
### Author: Irina Ivanova, iriiiina@gmail.com                                                                        ###
### Last modified: 5.09.2016, v2.0                                                                                   ###
########################################################################################################################

# Colors
GRAY='\e[100m'
NONE='\e[0m'

# Global variable that defines all clusters on one Tomcat web-server; you can rename it, but don't forget to use new name in calling
declare -A firstTomcatManagers
firstTomcatManagers["@prdapp01:8080"]="http://username:password@prdapp01:8080/manager/text"
firstTomcatManagers["@prdapp02:8080"]="http://username:password@prdapp02:8080/manager/text"

# Global variable that defines all clusters on the other Tomcat web-server; you can rename it, but don't forget to use new name in calling
declare -A secondTomcatManagers
secondTomcatManagers["@prdapp01:8090"]="http://username:password@prdapp01:8090/manager/text"
secondTomcatManagers["@prdapp02:8090"]="http://username:password@prdapp02:8090/manager/text"

####
# You can add more Tomcat servers here
####

function notify() {
  printf '\a' # notification or "bell" in terminal
}

# You can change color of formatting of the title here
function printTitle() {
  echo -e "${GRAY}$1${NONE}"
}

for index in ${!firstTomcatManagers[@]}
do
  echo -e "\n\n"
  printTitle "*********FIRST $index*********";

  # You can modify regular expressions here according to your needs
  # Example of current regexp that shows deployments in the following pattern:
  #    /admin:running:0:admin##1.2.3.4
  # Colors:
  #    \033[31m - RED
  #    \033[32m - GREEN
  #    \033[33m - YELLOW
  #    \033[34m - BLUE
  #    \033[36m - CYAN
  curl -silent ${firstTomcatManagers[$index]}/list | sort | grep ^/ | awk '{ gsub("running", "\033[32m&\033[0m");
                                                                             gsub("stopped", "\033[31m&\033[0m");
                                                                             gsub("\\:[0-9]+", "\033[34m&\033[0m");
                                                                             gsub("^/.+:", "\033[36m&\033[0m");
                                                                             gsub("[0-9]+.[0-9]+.[0-9]+.[0-9]+$", "\033[33m&\033[0m");
                                                                             print }'
done

for index in ${!secondTomcatManagers[@]}
do
  echo -e "\n\n"
  printTitle "*********SECOND $index*********";

  curl -silent ${secondTomcatManagers[$index]}/list | sort | grep ^/ | awk '{ gsub("running", "\033[32m&\033[0m");
                                                                              gsub("stopped", "\033[31m&\033[0m");
                                                                              gsub("\\:[0-9]+", "\033[34m&\033[0m");
                                                                              gsub("^/.+:", "\033[36m&\033[0m");
                                                                              gsub("[0-9]+.[0-9]+.[0-9]+.[0-9]+$", "\033[33m&\033[0m");
                                                                              print }'
done

####
# If you have more than two Tomcat servers, add other for-loops here according to the number of your Tomcat servers
####

notify;
