#!/bin/bash
# Author: Irina Ivanova, iriiiina@gmail.com, 26.01.2016
# Copy file from server to local computer
# v1.1

server=$1
file=$2

NONE="\e[0m"
RED="\e[31m"
CYAN="\e[36m"

function printError() {
  printf "$RED$1$NONE\n"
}

function printInfo() {
  printf "$CYAN$1$NONE\n"
}

function notify() {
  printf "\a"
}

function verifyArguments() {
  if [ $1 -ne 2 ]; then
    printError "Usage: $0 [SERVER] [FILE]";
    printError "Example: $0 test logs/logfile.log";
    notify;
    exit
  fi
}

function setHost() {
  case $server in
    "short-name")  host="username@host"
              ;;
    "second-short-name") host="username@host"
              ;;
    *)         host=""
  esac

  if [[ $host == "" ]]; then
    printError "ERROR: can't find host for server $server";
    notify;
    exit
  fi
}

function downloadFile() {
  scp $host:~/$file .
}

verifyArguments $#;
setHost;
downloadFile;

notify;
