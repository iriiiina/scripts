#!/bin/bash

# Irina Ivanova, Irina.Ivanova@protonmail.com
# Open all applications needed for work
# v0.1, 29.01.2016

path="/Applications"

apps=("Calendar" "Fleep" "Mail" "Notes" "Reminders" "Safari" "Skype" "OneDrive" "Docker")

for item in ${apps[*]}; do
  open "$path/$item.app"
done
