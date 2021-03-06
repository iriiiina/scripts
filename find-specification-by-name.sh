#!/bin/bash
# Author: Irina.Ivanova@protonmail.com, 28.09.2015
# Finds file in specific directory by given name
# v1.1.

path="/Users/irina/Desktop/specs"
text=$*
lower=$(echo $text | tr "[:upper:]" "[:lower:]")
upper=$(echo $text | tr "[:lower:]" "[:upper:]")

NONE="\e[0m"
RED="\e[31m"

function printError() {
  printf "$RED$1$NONE\n"
}

function notify() {
  printf "\a"
}

function verifyArguments() {
  if [ $1 -lt 1 ]; then
    printError "Usage: $0 ARGUMENT_1 ARGUMENT_2 ...";
    notify;
    exit
  fi
}

function findFile() {
  find $path -iname "*$text*" | awk -v text="$text" -v lower="$lower" -v upper="$upper" '{ gsub(text, "\033[36m&\033[0m"); gsub(lower, "\033[36m&\033[0m"); gsub(upper, "\033[36m&\033[0m"); gsub("Arhiiv", "\033[31m&\033[0m"); gsub("Archive", "\033[31m&\033[0m"); print }'
}

verifyArguments $#;
findFile;

notify;
