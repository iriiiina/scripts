#!/bin/bash

# Irina Ivanova, Irina.Ivanova@protonmail.com
# Quit all applications needed for work
# v0.1, 16.08.2017

apps=("Calendar" "Mail" "Notes" "Reminders" "Skype" "OneDrive" "Docker")

for item in ${apps[*]}; do
  osascript -e 'quit app "'$item'"'
done
