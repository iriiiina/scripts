#!/bin/bash
# Author: Irina Ivanova, Irina.Ivanova@protonmail.com, 02.10.2015
# Copy file from local computer to server
# v1.0

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
    printError "Example: $0 test logfile.log";
    notify;
    exit
  fi
}

# Set your own servers and their shortnames here
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

function uploadFile() {
  scp $file $host:~/
}

verifyArguments $#;
setHost;
uploadFile;

notify;
