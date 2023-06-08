#!/bin/bash
# Lab data with labels and Titles
# Needs to be run in root, be sure to check
if [ "$(id -u)" != "0" ]; then
	echo "Root is required for this script to work"
	echo "Consider using sudo"
	exit 1
fi
# need to gether several data items
mydate=$(date)
computermodel="$(lshw -class system| grep description: | sed 's/ *description: *//')"
cpumodel="$(lscpu | grep 'Model name:' | sed 's/ *Model name: *//')"

source /etc/os-release

#print out the gathered data nicely with labels and titles

cat <<EOF
System Report produced by $USER on $mydate
 
System Description
------------------
Computer Model: $computermodel

CPU Info
--------
Model: $cpumodel

Operating System
----------------
OS: $PRETTY_NAME

EOF
