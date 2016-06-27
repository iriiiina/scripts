#!/bin/bash

### Rename log files: module.log.31.12.2015 -> module.log.2015.12.31
### Script should be located in the same directory as log files, that need to be renamed.
### It was used to change format of the date from dd.MM.yyyy to yyyy.MM.dd to fix file sorting by name.
###
### Author: Irina Ivanova, iriiiina@gmail.com, 24.05.2016

for f in *.log.*; do
  module=$( echo "$f" | cut -d "." -f1 )
  day=$( echo "$f" | cut -d "." -f3 )
  month=$( echo "$f" | cut -d "." -f4 )
  year=$( echo "$f" | cut -d "." -f5 )

  mv -n "$f" "$module.log.$year.$month.$day"
done
