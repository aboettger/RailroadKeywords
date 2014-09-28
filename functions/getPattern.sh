#!/bin/bash

pattern_case="$1"
#   echo "$pattern_case"
retValue=$(sed '/^#/d' "$pattern_case" | grep 'pattern=' | gawk  -F 'pattern=' '{print $2}')

# retValue
echo "$retValue"

exit 0
