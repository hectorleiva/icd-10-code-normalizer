#!/bin/bash

INPUT_FILE=$1
OUTPUT_FILE=$2

# Test cases:
#
# The line has a comma separated value within double-quotes that needs to be caught and replaced
#
# ABC123, "Testing, one", "Testing, two",
#
# The line has a comma separated value within double-quotes that needs to be caught and replaced AND has "[]" characters that will mess up the sed command
#
# DEFG456, "[EXCLUDE] Testing, three", "[EXCLUDE] Testing, four",
#
# The line that has an early end $ character break that will cause issues (this can be observed using: "cat -vE"):
#
# HIJK789$
# , "Testing, five", "Testing, six",^M$

if [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_FILE" ]; then
  echo "Usage: $0 <input_file> <output_file>"
  exit 1
fi

while IFS= read -r line; do
    MATCH=$(echo $line | grep -o '"[^"]\+"')

    if [[ -z $MATCH ]]; then # no match found
        echo $line >> $OUTPUT_FILE
    else # match was found
        UPDATED=$line

        while read -r match; do
            NORMALIZED=$(echo $match | sed 's|\/|\\/|g' | sed 's|\[|\\[|g' | sed 's|\]|\\]|g')
            PATTERN_TARGET=$(echo $NORMALIZED | sed 's/"//g' | sed 's/,/ -/g' | sed 's/&/and/g' | tr "[]" "()")

            UPDATED=$(echo $UPDATED | sed "s/$NORMALIZED/$PATTERN_TARGET/")
        done < <(echo $line | grep -o '"[^"]\+"')

        echo $UPDATED >> $OUTPUT_FILE
    fi
done < $INPUT_FILE

echo "Normalization complete: $OUTPUT_FILE"
