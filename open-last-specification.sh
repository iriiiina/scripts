#!/bin/bash
# Author: Irina.Ivanova@nortal.com, 28.09.2015
# Finds file in specific directory by name and opens last modified version
# v1.0

path="/Users/irina/Desktop/specs"

text=$*

NONE='\e[0m'
RED='\e[31m'
CYAN='\e[36m'
YELLOW='\e[33m'

function printError() {
  printf "${RED}$1${NONE}\n"
}

function printInfo() {
  printf "${CYAN}$1${NONE}\n"
}

function printWarning() {
  printf "${YELLOW}$1${NONE}\n"
}

function notificate() {
  printf '\a'
}

function verifyArguments() {
  if [ $1 -lt 1 ]; then
    printError "Usage: $0 ARGUMENT_1 ARGUMENT_2 ...";
    notificate;
    exit
  fi
}

function findFile() {
  file=$( find $path -iname "*$text*" | sort -n | tail -1 )
}

function checkIsFileIsDoc() {
  if [[ $file == *'.doc' ]]; then
    doc=1
  else
    doc=0
  fi
}

function openFile() {
  printInfo "Opening $file...";
  open "$file"
}

verifyArguments $#;
findFile;
checkIsFileIsDoc;

if [[ $doc == 1 ]]; then
  openFile;
else
  printWarning "WARNING: Found file $file is not .DOC. Do you still want to open it? y/n";
  read open

  if [[ $open == 'y' || $open == 'Y' || $open == 'yes' || $open == 'YES' ]]; then
    openFile;
  fi
fi
