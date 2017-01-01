#!/bin/bash
# Author: Irina.Ivanova@protonmail.com, 16.11.2016
# Open connection to some Oracle DB
# v1.0

db=$1

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
  if [ $1 -ne 1 ]; then
    printError "Usage: $0 [DB]";
    printError "Example: $0 test";
    notify;
    exit
  fi
}

function printDBs() {
  if [[ $1 == "help" ]]; then
    printInfo "\nUsage: $0 [DB]";
    printInfo "Example: $0 test\n"
    printInfo "\nAll possible databases:";
    printInfo "\ttest";
    printInfo "\tdemo";
    printInfo "\tlive\n";
    exit
  fi
}

### Change data here to your credentials
function setDB() {
  case $db in
    "test")     user="test username"
                password="test password"
                host="DB name"
              ;;
    "demo")     user="demo username"
                password="demo password"
                host="DB name"
              ;;
    "live")     user="live username"
                password="live password"
                host="DB name"
              ;;
    *)          user=""
                password=""
                host=""
  esac

  if [[ $user == "" || $password == "" || $host == "" ]]; then
    printError "ERROR: can't find credentials for DB $db";
    notify;
    exit
  fi
}

### Change PATH_TO_SQLPLUS here to the path to your sqlplus
function createConnection() {
  PATH_TO_SQLPLUS $user/$password@$host
}

printDBs $1;
verifyArguments $#;
setDB;
createConnection;

notify;
