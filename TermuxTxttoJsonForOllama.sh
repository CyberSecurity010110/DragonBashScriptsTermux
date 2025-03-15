#!/bin/bash

# Default output file
outputFile="output.json"

# Function to prompt for input file with browsing capability
get_input_file() {
    if [ $# -eq 1 ] && [ -f "$1" ]; then
        echo "$1"
    else
        echo "No valid input file provided via command line."
        echo "Please select a .txt file..."

        # Try to use file picker
        file=$(termux-dialog file -f "text/plain" | jq -r '.text')
        if [ -n "$file" ] && [ -f "$file" ]; then
            echo "$file"
        else
            # Fall back to text prompt if dialog is canceled or unavailable
            read -p "Enter the path to the .txt file (or type 'exit' to quit): " file
            if [ "$file" == "exit" ]; then
                exit 0
            fi
            if [ -f "$file" ]; then
                echo "$file"
            else
                echo "Error: '$file' is not a valid file."
                exit 1
            fi
        fi
    fi
}

# Get the input file
inputFile=$(get_input_file "$@")

# Validate input file (redundant but kept for safety)
if [ ! -f "$inputFile" ]; then
    echo "Error: Input file '$inputFile' not found."
    exit 1
fi

# Read the consolidated text file
lines=$(cat "$inputFile")

# Initialize data structure
declare -A data
currentPath=()

# Function to create nested associative arrays
create_nested_array() {
    local -n ref=$1
    shift
    for key in "$@"; do
        if [ -z "${ref[$key]}" ]; then
            declare -A new_array
            ref[$key]=$(declare -p new_array)
        fi
        ref=$(declare -p ref[$key])
    done
}

# Process each line
while IFS= read -r line; do
    # Skip empty lines
    if [ -z "$line" ]; then
        continue
    fi

    # Count indentation level (2 spaces per level)
    indentLevel=$(echo "$line" | sed -e 's/[^ ].*//')
    level=$(( ${#indentLevel} / 2 ))

    # Adjust currentPath to match the current level
    while [ ${#currentPath[@]} -gt $level ]; do
        unset 'currentPath[${#currentPath[@]}-1]'
    done

    # Parse folder
    if [[ "$line" =~ \[Folder:\ (.+)\] ]]; then
        folderName="${BASH_REMATCH[1]}"
        currentPath+=("$folderName")
        create_nested_array data "${currentPath[@]}"
    elif [[ "$line" =~ \[File:\ (.+)\] ]]; then
        fileName="${BASH_REMATCH[1]}"
        currentPath+=("$fileName")
        create_nested_array data "${currentPath[@]}"
        currentPath=("${currentPath[@]::${#currentPath[@]}-1}")
    elif [[ ! "$line" =~ Contents: ]]; then
        # Append content to the last file
        create_nested_array data "${currentPath[@]}"
        data["${currentPath[*]}"]+="${line#"${line%%[![:space:]]*}"}"$'\n'
    fi
done <<< "$lines"

# Convert to JSON and write to file
{
    echo "{"
    for key in "${!data[@]}"; do
        echo "\"$key\": \"${data[$key]}\","
    done
    echo "}"
} > "$outputFile"

echo "JSON file '$outputFile' created successfully!"