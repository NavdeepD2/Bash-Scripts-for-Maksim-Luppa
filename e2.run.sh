#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"

if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' not found."
    exit 1
fi

calculate_statistics() {
    local text="$1"
    local word_count=0
    declare -A word_frequency

    words=$(echo "$text" | tr -sc '[:alpha:]' '[\n*]' | tr '[:upper:]' '[:lower:]')

    for word in $words; do
        ((word_count++))
        word=${word%%[[:punct:]]*}
        if [[ $word == *-* ]]; then
            ((word_frequency[$word]++))
        else
            IFS='-' read -ra parts <<< "$word"
            for part in "${parts[@]}"; do
                ((word_frequency[$part]++))
            done
        fi
    done

    echo "Total words: $word_count"
    echo "Word statistics:"
    for word in "${!word_frequency[@]}"; do
        echo "$word: ${word_frequency[$word]}"
    done
}

while IFS= read -r line; do
    text_buffer+="$line "
    if [[ $line =~ [\.!\?]$ ]]; then
        calculate_statistics "$text_buffer"
        text_buffer=""
    fi
done < "$input_file"

if [ -n "$text_buffer" ]; then
    calculate_statistics "$text_buffer"
fi

exit 0

