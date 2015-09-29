#!/bin/bash
# Author: Irina.Ivanova@nortal.com, 28.09.2015
# v0.1

path="/Users/irina/Desktop/specs"

find $path -iname '*.doc' -exec grep $1 {} +
