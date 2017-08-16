#!/bin/bash
# W3C validator API: http://validator.w3.org/docs/api.html
api="https://validator.w3.org/nu/";
doc="https%3A%2F%2Firina-ivanova.gitlab.io";
out="json";
url="$api?doc=$doc&out=$out";
status=$(curl --silent -I $url | grep "HTTP/1.1" | grep -o -e "\s[0-9]*\s" | grep -o -e "[0-9][0-9]*");
if [[ $status -ne "200" ]]; then
  echo "ERROR: response status code is $status";
  exit 1;
fi
response=$(curl --silent -H "Accept: application/json" $url);
errors=$( echo $response | grep "\"type\":\"error\"" );
if [[ $errors != "" ]]; then
  echo "ERROR: there are some errors in HTML:";
  echo $errors;
  exit 1;
else
  echo "OK: there are no errors in HTML";
  exit 0;
fi
