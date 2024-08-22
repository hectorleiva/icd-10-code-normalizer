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

LINE_BREAKING_MATCHES=""

while IFS= read -r line; do
    MATCH=$(echo $line | grep -o '"[^"]\+"')
    
    if [[ $LINE_BREAKING_MATCHES ]]; then # there was a line break prior
        MATCHING_LINE=$(echo $line | sed 's/"/\\"/g')
        echo "line_breaking_matches before: $LINE_BREAKING_MATCHES"
        echo "MATCHING_LINE=$MATCHING_LINE"
        LINE_BREAKING_MATCHES="$LINE_BREAKING_MATCHES $MATCHING_LINE"
        echo "line_breaking_matches after: $LINE_BREAKING_MATCHES"
    else
        NO_DOUBLE_QUOTE_MATCH=$(echo $line | grep -o '^"[^"]*$')

        if [[ $NO_DOUBLE_QUOTE_MATCH ]]; then
            echo "no double quote match found: $NO_DOUBLE_QUOTE_MATCH"
            LINE_BREAKING_MATCHES=$(echo $line | sed 's/"/\\"/g')
            continue;
        fi
    fi

    if [[ -z $MATCH && -z $LINE_BREAKING_MATCHES ]]; then # no match found
        echo $line >> $OUTPUT_FILE
    elif [[ $LINE_BREAKING_MATCHES ]]; then # Line breaking match was found
        UPDATED=$LINE_BREAKING_MATCHES

        while read -r line_breaking_match; do
            echo "in the while loop: $line_breaking_match"
            echo "----------------"
            NORMALIZED=$(echo $line_breaking_match | sed 's|\/|\\/|g' | sed 's|\[|\\[|g' | sed 's|\]|\\]|g')
            echo "normalized: $NORMALIZED"
            echo "----------------"
            PATTERN_TARGET=$(echo $NORMALIZED | sed 's/"//g' | sed 's/,/ -/g' | sed 's/&/and/g' | tr "[]" "()")

            echo "pattern_target: $PATTERN_TARGET"
            echo "----------------"

            UPDATED=$(echo $UPDATED | sed "s/$NORMALIZED/$PATTERN_TARGET/")

            echo "updated: $UPDATED"
            echo "----------------"
        done < <(echo $LINE_BREAKING_MATCHES | grep -o '"[^"]\+"')

        LINE_BREAKING_MATCHES=""

        echo $UPDATED >> $OUTPUT_FILE
    else
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
