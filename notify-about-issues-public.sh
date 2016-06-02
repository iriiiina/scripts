#!/bin/bash
# Author: iriiiina@gmail.com, 02.06.2016
# Send e-mail when JIRA JQL query returns some result
# v0.1

# JIRA part
jiraUrl="https://jira.example.com"
restParameter="/rest/api/latest/search?jql="
issueParameter="/browse"
filterParameter="/issues/?jql="
# Use URL decoder for escaping special characters, for example, http://meyerweb.com/eric/tools/dencoder
### For the following JQL query: project in ("Project1", "Project2") AND status = Open
### you should put into $filter variable something like this: "project%20in%20(%22Project1%22%2C%20%22Project2%22)%20AND%20status%20%3D%20Open"
filter=""
user="" # JIRA username
password="" # JIRA password for Basic authentication (you can ask it from the user)

# Email
to="" # Where email should be sent
from="" # From whom email should be sent (it can be the same as $to value)
subject="Your JQL query gives a new issue" # Subject of the email

now=$(date +"%d.%m.%Y %H:%M:%S")

function getAllIssues() {
  printf "\n$now INFO: Getting all issues...\n"
  issues=$( curl -D- -u $user:$password -H "Content-Type: application/json" "$jiraUrl$restParameter$filter" )

  http200=$( echo $issues | grep "HTTP\/1\.1 200 OK" )
  if [[ $http200 = "" ]]; then
    printf "$now ERROR: HTTP status is not 200 OK"
    error="ERROR: REST query response status is not 200 OK"
  else
    printf "$now OK: Got all issues\n"
  fi
}

function getNewIssues() {
  printf "\n$now INFO: Getting new issues...\n"
  if [[ $error = "" ]]; then
    newIssues+=$( echo $issues | grep -o --regexp="\"key\":\"[A-Z]*-[0-9]*\"," | grep -o --regexp="[A-Z]*\-[0-9]*" )
  fi
  printf "$now OK: Got new issues: $newIssues\n"
}

function setEmailContent() {
  printf "\n$now INFO: Generating content of the email...\n"

  if [[ $error = "" ]]; then
    content="You JQL quert returns following issues:"
    for item in ${newIssues[*]}; do
      content+=$( printf "\n\t$item: $jiraUrl$issueParameter/$item\n" )
    done
    content+=$( printf "\n\nSee search result in the JIRA: ")
    content+=$( echo "$jiraUrl$filterParameter$filter" )
  else
    content="$error"
  fi
  printf "$now OK: Content of the email is generated: \n"
  echo "$content"
}

function sendEmail() {
  printf "\n$now INFO: Sending e-mail...\n"
  if [[ $newIssues != "" ]]; then
/usr/sbin/sendmail -t $to <<EOF
subject:$subject
from:$from
to:$to
$content
EOF
    printf "$now OK: E-mail is sent to $to with the subject $subject\n"
  else
    printf "$now INFO: E-mail is not sent\n"
  fi
}

printf "\n\n******Checking for new support issues******\n\n"

getAllIssues;
getNewIssues;
setEmailContent;
sendEmail;
