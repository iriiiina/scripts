#!/bin/bash
# Author: Irina.Ivanova@nortal.com, 24.09.2015
# v0.1

outputFile="log-errors.txt"

regexps="(.*ERROR.*|.*WARN.*)"

inputFile=$1

NONE='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
CYAN='\e[36m'
GREEN='\e[32m'

function printError() {
  printf "${RED}$1${NONE}\n"
}

function printWarning() {
  printf "${YELLOW}$1${NONE}\n"
}

function printInfo() {
  printf "${CYAN}$1${NONE}\n"
}

function printOk() {
  printf "${GREEN}$1${NONE}\n"
}

function notificate() {
  printf '\a'
}

function verifyArguments() {
  if [[ $1 -ne 1 ]]; then
    printError "\n\tUsage: $0 LOG_FILE";
    printError "\tExample: $0 catalina.out\n";
    notificate;
    exit
  fi
}

function clearFile() {
  printInfo "Removing old content of $outputFile...";
  > $outputFile
  printOk "OK: old content of $outputFile is being removed";
}

function getContent() {
  printInfo "Getting errors from $inputFile to $outputFile...";
  cat $inputFile | grep -A 1 -E "$regexps" >> $outputFile
  printOk "OK: errors are being copied for $inputFile to $outputFile";
}

verifyArguments $#;
clearFile;
getContent;

notificate;
