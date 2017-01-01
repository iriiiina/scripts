#!/usr/bin/env python

import requests
import json
import operator # Sort dictionary
import sys # Stop script

### COLORS for the output
RED="\033[1;31m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
NONE="\033[1;m"

### GET input parameters from user
user=str(raw_input(CYAN + "\nJIRA username of inspected person: " + NONE))

days=raw_input(CYAN + "Number of last days you want to collect statistics about: " + NONE)
try:
    days=int(days)
    if days <= 0:
        print(RED + "ERROR: Number of days should be a positive integer" + NONE)
        sys.exit()
except ValueError:
    print(RED + "ERROR: Number of days should be a positive integer" + NONE)
    sys.exit()

top=raw_input(CYAN + "Max number of colleagues in ratings: " + NONE)
try:
    top=int(top)
    if top <= 0:
        print(RED + "ERROR: Max number of colleagues should be a positive integer" + NONE)
        sys.exit()
except ValueError:
    print(RED + "ERROR: Max number of colleagues should be a positive integer" + NONE)
    sys.exit()

### GLOBAL variables
jira="" # put your JIRA API URL here, like https://jira.example.com/rest/api/2
issuesAPI=jira + "/search?jql=createdDate%20%3E%20startOfDay(-" + str(days) + "d)%20and%20assignee%20was%20" + user + "&startAt="
testerAPI=jira + "/search?jql=createdDate%20%3E%20startOfDay(-" + str(days) + "d)%20and%20Tester%3D" + user + "&startAt="
userAPI=jira + "/user?username=" + user
jiraUser="" # put your JIRA username here
jiraPass="" # put your JIRA password here

issuesByAssignee=[]
testersByAssignee={}
creatorsByAssignee={}
commentatorsByAssignee={}

issuesByTester=[]
creatorsByTester={}
commentatorsByTester={}

testersIssues=[]
creatorsIssues=[]
commentatorsIssues=[]

### FUNCTIONS
def getIssuesByAssignee(startAtValue):
    "Get all issues from JIRA where user was an assignee. NB! Recursive function!"

    url=issuesAPI + str(startAtValue)
    print("Getting all issues where user " + user + " was an assignee: " + url)
    try:
        response=requests.get(url, auth=(jiraUser, jiraPass)).json()

        if "errorMessages" in response:
            print(RED + "ERROR: can't get any result about " + user + NONE)
            sys.exit()

        for i in response["issues"]:
            issuesByAssignee.append(i["id"])
        if response["total"] > response["startAt"] + response["maxResults"]:
            getIssuesByAssignee(startAtValue + response["maxResults"])
    except requests.ConnectionError:
        print(RED + "ERROR: Failed to connect to " + url + NONE)

def getIssuesByTester(startAtValue):
    "Get all issues from JIRA where user was a tester. NB! Recursive function!"

    url=testerAPI + str(startAtValue)
    print("Getting all issues where user " + user + " was a tester: " + url)
    try:
        response=requests.get(url, auth=(jiraUser, jiraPass)).json()

        if "errorMessages" in response:
            print(RED + "ERROR: can't get any result about " + user + NONE)

        for i in response["issues"]:
            issuesByTester.append(i["id"])
        if response["total"] > response["startAt"] + response["maxResults"]:
            getIssuesByTester(startAtValue + response["maxResults"])
    except request.ConnectionError:
        print(RED + "ERROR: Failed to connect to " + url + NONE)

def getUserName():
    "Get display name of the inspected user"

    try:
        userName = requests.get(userAPI, auth=(jiraUser, jiraPass)).json()["displayName"]
    except:
        print(RED + "ERROR: Can't connect to " + userAPI + NONE)

    return userName

def getRolesFromAssignee():
    "Get all colleagues in different roles from issues by assignee"

    print("Getting people that were involved in previous issues...")
    for i in issuesByAssignee:
        try:
            url=jira + "/issue/" + i
            issue=requests.get(url, auth=(jiraUser, jiraPass)).json()
            # Testers. NB! This is custom field and its key may differ
            if "customfield_14302" in issue["fields"] and not(issue["fields"]["customfield_14302"] is None):
                testersIssues.append(i)

                if issue["fields"]["customfield_14302"]["displayName"] in testersByAssignee and issue["fields"]["customfield_14302"]["displayName"] != userName:
                    testersByAssignee[issue["fields"]["customfield_14302"]["displayName"]] += 1
                elif not(issue["fields"]["customfield_14302"]["displayName"] in testersByAssignee) and issue["fields"]["customfield_14302"]["displayName"] != userName:
                    testersByAssignee[issue["fields"]["customfield_14302"]["displayName"]] = 1
            # Creators
            if issue["fields"]["creator"]["displayName"] in creatorsByAssignee and issue["fields"]["creator"]["displayName"] != userName:
                creatorsIssues.append(i)
                creatorsByAssignee[issue["fields"]["creator"]["displayName"]] += 1
            elif not(issue["fields"]["creator"]["displayName"] in creatorsByAssignee) and issue["fields"]["creator"]["displayName"] != userName:
                creatorsIssues.append(i)
                creatorsByAssignee[issue["fields"]["creator"]["displayName"]] = 1
            # Commentators
            if "comment" in issue["fields"]:
                commentatorsIssues.append(i)
                for c in issue["fields"]["comment"]["comments"]:
                    if c["author"]["displayName"] in commentatorsByAssignee and c["author"]["displayName"] != userName:
                        commentatorsByAssignee[c["author"]["displayName"]] += 1
                    elif not(c["author"]["displayName"] in commentatorsByAssignee) and c["author"]["displayName"] != userName:
                        commentatorsByAssignee[c["author"]["displayName"]] = 1

        except requests.ConnectionError:
            print(RED + "ERROR: Failed to connect to " + url + NONE)

def getRolesFromTester():
    "Get all colleagues in different roles from issues by tester"

    print("Getting people that were involved in previous issues...")
    for i in issuesByTester:
        try:
            url=jira + "/issue/" + i
            issue=requests.get(url, auth=(jiraUser, jiraPass)).json()
            # Creators
            if issue["fields"]["creator"]["displayName"] in creatorsByTester and issue["fields"]["creator"]["displayName"] != userName:
                creatorsIssues.append(i)
                creatorsByTester[issue["fields"]["creator"]["displayName"]] += 1
            elif not(issue["fields"]["creator"]["displayName"] in creatorsByTester) and issue["fields"]["creator"]["displayName"] != userName:
                creatorsIssues.append(i)
                creatorsByTester[issue["fields"]["creator"]["displayName"]] = 1
            # Commentators
            if "comment" in issue["fields"]:
                commentatorsIssues.append(i)
                for c in issue["fields"]["comment"]["comments"]:
                    if c["author"]["displayName"] in commentatorsByTester and c["author"]["displayName"] != userName:
                        commentatorsByTester[c["author"]["displayName"]] += 1
                    elif not(c["author"]["displayName"] in commentatorsByTester) and c["author"]["displayName"] != userName:
                        commentatorsByTester[c["author"]["displayName"]] = 1

        except requests.ConnectionError:
            print(RED + "ERROR: Failed to connect to " + url + NONE)

def getDevelopers(issues):
    "Get developers that made commits in issues"

    print("Getting developers that made commits in previous issues...")

    developers={}

    for i in issues:
        try:
            # Put your URL here
            url="https://jira.example.com/rest/dev-status/1.0/issue/detail?issueId=" + str(i) + "&applicationType=fecru&dataType=repository"
            commit=requests.get(url, auth=(jiraUser, jiraPass)).json()

            if "detail" in commit:
                for d in commit["detail"]:
                    for r in d["repositories"]:
                        for c in r["commits"]:
                            if c["author"]["name"] in developers and c["author"]["name"] != userName:
                                developers[c["author"]["name"]] += 1
                            elif not(c["author"]["name"] in developers) and c["author"]["name"] != userName:
                                developers[c["author"]["name"]] = 1

        except requests.ConnectionError:
            print(RED + "ERROR: Failed to connect to " + url + NONE)

    return developers

def printStatistics(list, name):
    "Print statistics about top collegues"

    print(GREEN + "\nTop " + str(top) + name + NONE)

    if len(list) > top:
        max=top
    else:
        max=len(list)

    sortedList=sorted(list.items(), key=operator.itemgetter(1), reverse=True)

    for i in range(0, max):
        print(GREEN + "\t" + sortedList[i][0].encode("utf-8") + ": " + str(sortedList[i][1]) + NONE)

def generateJqlQuery(list):
    "Create JQL query of all issues of specific role"

    jql="issuekey%20in%20("
    first=True
    for i in list:
        if first:
            first=False
            jql+=i
        else:
            jql+="%2C%20" + i
    jql += ")"

    return jql

def saveHTML(issueKeys, filename):
    "Save HTML file with redirect to specified JQL search in JIRA"

    file=open(filename + ".html", "w+")
    file.write("")
    file.write("<!DOCTYPE html><html><head><meta http-equiv='refresh' content='0; url="
        + "https://jira.example.com/issues/?jql=" + issueKeys
        + "' /></head><body></body></html>")
    file.close()

    print(YELLOW + "See file " + filename + ".html for detailed information" + NONE)

### START the script
print "\nStarting to collect data about " + user + " in JIRA..."
getIssuesByAssignee(0)
userName=getUserName()
getRolesFromAssignee()
getIssuesByTester(0)
getRolesFromTester()

developersByAssignee=getDevelopers(issuesByAssignee)
developersByTester=getDevelopers(issuesByTester)

print("\n\tSTATISTICS")
printStatistics(testersByAssignee, " Testers in issues, where user was an assignee: ")
printStatistics(creatorsByAssignee, " Creators of issues, where user was an assignee: ")
printStatistics(commentatorsByAssignee, " Commentators in issues, where user was an assignee: ")
printStatistics(developersByAssignee, " Developers in issues, where user was an assignee: ")

printStatistics(creatorsByTester, " Creators of issues, where user is a tester: ")
printStatistics(commentatorsByTester, " Commentators in issues, where user is a tester: ")
printStatistics(developersByTester, " Developers in issues, where user is a tester: ")

# print("\n")
# saveHTML(generateJqlQuery(testersIssues), "issues-of-testers")
# saveHTML(generateJqlQuery(creatorsIssues), "issues-of-creators")
# saveHTML(generateJqlQuery(commentatorsIssues), "issues-of-commentators")
print("\n")

sys.stdout.write('\a') # Terminal Bell
