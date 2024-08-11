#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

# Add the [ to the beginning of the file to create the JSON array
# Create an object that looks like: { "code": "ABC123" }, { "description": "Testing, one" },
# Second to last object should omit the comma to avoid the JSON syntax error
# Add the ] to the end of the file to close the JSON array

awk -F, \
'BEGIN { print "[" }

{ if (NF > 1) { while (getline == 1) { print "{ \"code\": \"" $1 "\" }, { \"description\": \"" $2 "\" }, " } print "{ \"code\": \"" $1  "\" }, { \"description\": \"" $2 "\" }" }}

END { print "]" }' $1
