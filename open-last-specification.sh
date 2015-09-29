#!/bin/bash
# Author: Irina.Ivanova@nortal.com, 28.09.2015
# v0.1

path="/Users/irina/Desktop/specs"

file=$( find $path -iname *$1* | sort -n | tail -1 )

open "$file"
