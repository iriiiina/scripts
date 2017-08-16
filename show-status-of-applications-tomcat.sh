#!/bin/bash

############################################################################
### This is script for listing deployed applications on Tomcat 8 server  ###
### It doesn't require modifications and can be used out-of-the-box      ###
###                                                                      ###
### Author: Irina Ivanova, Irina.Ivanova@protonmail.com                  ###
### Last modified: 5.09.2016, v2.0                                       ###
############################################################################

function notify() {
  printf '\a' # notification or "bell" in terminal
}

tomcatManager="" # required global variable; Tomcat manager URL with user and password, like "http://tomcat:tomcat@app.example.com:8080/manager/text"

# You can modify regular expressions here according to your needs
# Example of current regexp that shows deployments in the following pattern:
#    /admin:running:0:admin##1.2.3.4
# Colors:
#    \033[31m - RED
#    \033[32m - GREEN
#    \033[33m - YELLOW
#    \033[34m - BLUE
#    \033[36m - CYAN
curl -silent $tomcatManager/list | sort | grep ^/ | awk '{ gsub("running", "\033[32m&\033[0m");
                                                           gsub("stopped", "\033[31m&\033[0m");
                                                           gsub("\\:[0-9]+", "\033[34m&\033[0m");
                                                           gsub("^/.+:", "\033[36m&\033[0m");
                                                           gsub("[0-9]+.[0-9]+.[0-9]+.[0-9]+$", "\033[33m&\033[0m");
                                                           print }'

notify;
