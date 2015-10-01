#!/bin/bash
# Author: Irina.Ivanova@nortal.com, 28.09.2015
# Finds files where given text is present
# v1.0

path="/Users/irina/Desktop/specs"

text=$*
lower=$(echo $text | tr "[:upper:]" "[:lower:]")
upper=$(echo $text | tr "[:lower:]" "[:upper:]")

NONE="\e[0m"
RED="\e[31m"

function printError() {
  printf "$RED$1$NONE\n"
}

function notificate() {
  printf "\a"
}

function verifyArguments() {
  if [ $1 -lt 1 ]; then
    printError "Usage: $0 ARGUMENT_1 ARGUMENT_2 ...";
    notificate;
    exit
  fi
}

function findFiles() {
  find $path -iname "*.doc" -exec grep -E "($text|$lower|$upper)" {} + | awk '{ gsub("Arhiiv", "\033[31m&\033[0m"); gsub(".[^/]*\.doc", "\033[36m&\033[0m"); print }'
}

verifyArguments $#;
findFiles;

notificate;
