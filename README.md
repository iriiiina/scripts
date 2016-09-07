# Collection of Bash Scripts for Mac OS

All scripts work on Mac OS El Capitan 10.11.5 (and most likely in UNIX terminals).

## bug.sh
    ./bug.sh
Prints picture of a bug. See blog post about it: [Bash Scripts for Working With Documentation](http://ivanova-irina.blogspot.com.ee/2015/09/bash-scripts-for-working-with.html)

## copy-file-from-server.sh
    ./copy-file-from-server.sh
Copy file from server to local computer. Servers can be mapped with short titles, so there is no need to remember host path. See blog post about it: [Bash Scripts for Transfering Files Between Server and Local Computer](http://ivanova-irina.blogspot.com.ee/2016/06/bash-scripts-for-transfering-files.html)

## copy-file-to-server.sh
    ./copy-file-to-server.sh
Copy file from local computer to server. Servers can be mapped with short titles, so there is no need to remember host path. See blog post about it: [Bash Scripts for Transfering Files Between Server and Local Computer](http://ivanova-irina.blogspot.com.ee/2016/06/bash-scripts-for-transfering-files.html)

## find-specification-by-name.sh
    ./find-specification-by-name.sh [text_in_file_title]
Finds file in specific directory by name. See blog post about it: [Bash Scripts for Working With Documentation](http://ivanova-irina.blogspot.com.ee/2015/09/bash-scripts-for-working-with.html)

## find-text-in-specification.sh
    ./find-text-in-specification.sh [text_in_the_file_content]
Finds files where given text is present. See blog post about it: [Bash Scripts for Working With Documentation](http://ivanova-irina.blogspot.com.ee/2015/09/bash-scripts-for-working-with.html)

## get-errors-to-file.sh
    ./get-errors-to-file.sh [path_to_log_file]
Reads given log file and prints errors (or whatever is given to regular expression) to separate file.

## nortal-logo.sh
    ./nortal-logo.sh
Prints picture of Nortal logo. See blog post about it: [Bash Scripts for Working With Documentation](http://ivanova-irina.blogspot.com.ee/2015/09/bash-scripts-for-working-with.html)

## notify-about-issues.sh
    ./notify-about-issues.sh
Sends e-mail when JIRA JQL query returns some result. See blog post about it: [Script for Sending E-mails About Certain JIRA Issues](http://ivanova-irina.blogspot.com.ee/2016/06/script-for-sending-e-mails-about.html)

## open-apps-for-work.sh
    ./open-apps-for-work.sh
Opens all applications that are required for my daily work. As I don't use computer only for work, I don't want to open them on every startup.

## open-last-specification.sh
    ./open-last-specification.sh [text_in_file_title]
Finds file in specific directory by name and opens last modified version. See blog post about it: [Bash Scripts for Working With Documentation](http://ivanova-irina.blogspot.com.ee/2015/09/bash-scripts-for-working-with.html)

## rename-log-files.sh
    ./rename-log-files.sh
Rename log files: module.log.31.12.2015 -> module.log.2015.12.31. It was used to change format of the date from dd.MM.yyyy to yyyy.MM.dd to fix file sorting by name.

## show-status-of-applications-tomcat.sh
    ./show-status-of-applications-tomcat.sh
List deployed applications on Tomcat 8 web-server. See blog post about it: [Checking Deployments on Tomcat Server Without Web Manager](http://ivanova-irina.blogspot.com.ee/2016/09/checking-deployments-on-tomcat-server.html)

## show-status-of-prod-applications-tomcat.sh
    ./show-status-of-prod-applications-tomcat.sh
List deployed applications on multiple-server and multiple-cluster environment (Tomcat 8). See blog post about it: [Checking Deployments on Tomcat Server Without Web Manager](http://ivanova-irina.blogspot.com.ee/2016/09/checking-deployments-on-tomcat-server.html)

## Scripts for Updates on Tomcat 6
    ./deploy-many-wars-from-file-on-tomcat6.sh
    ./deploy-new-war-on-tomcat6.sh
    functions-for-deploying-on-tomcat6.sh.sh

Blog post about these scripts: [Scripting For Automated Update (Tomcat 6) [DEPRECATED]](http://ivanova-irina.blogspot.com.ee/2014/09/scripting-for-automated-update-tomcat-6.html)
