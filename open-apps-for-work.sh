#!/bin/bash

# Irina Ivanova, Irina.Ivanova@protonmail.com
# Open all applications needed for work
# v0.3, 19.11.2019

apps=("/System/Applications/Calendar" "/System/Applications/Notes" "/System/Applications/Reminders" "/System/Applications/Mail" "/Applications/Safari" "/Applications/Skype" "/Applications/Docker" "/Applications/Microsoft/Teams" "/Applications/Telegram" "/Applications/Rocket.Chat")

for item in ${apps[*]}; do
  open "$item.app"
done
