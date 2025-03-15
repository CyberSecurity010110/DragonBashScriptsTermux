#!/bin/bash

# Function to list and count directory contents
list_and_count_directory() {
    local directory=$1
    local output_file=$2
    local file_count=0
    local folder_count=0

    # Create or clear the output file
    > "$output_file"

    # Iterate through the directory
    while IFS= read -r -d '' folder; do
        folder_size=$(du -sb "$folder" | cut -f1)
        echo "Folder: $folder, Size: ${folder_size} bytes" >> "$output_file"
        folder_count=$((folder_count + 1))
    done < <(find "$directory" -type d -print0)

    while IFS= read -r -d '' file; do
        file_size=$(stat -c%s "$file")
        echo "File: $file, Size: ${file_size} bytes" >> "$output_file"
        file_count=$((file_count + 1))
    done < <(find "$directory" -type f -print0)

    # Write summary
    echo -e "\nTotal Folders: $folder_count" >> "$output_file"
    echo "Total Files: $file_count" >> "$output_file"
}

# Main script execution
read -p "Enter the directory path to scan: " directory
output_file="directory_contents.txt"

if [ -d "$directory" ]; then
    list_and_count_directory "$directory" "$output_file"
    echo "Directory contents have been written to '$output_file'."
else
    echo "The specified directory does not exist."
fi