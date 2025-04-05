#!/usr/bin/env bash
#!/bin/bash

# Usage: ./link_files_recursive.sh /path/to/source /path/to/destination

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source_folder> <destination_folder>"
  exit 1
fi

SOURCE=$(realpath "$1")
DEST=$(realpath "$2")

# Check if source exists
if [ ! -d "$SOURCE" ]; then
  echo "Source folder '$SOURCE' does not exist."
  exit 1
fi

# Create destination directory if it doesn't exist
mkdir -p "$DEST"

# Find all files under the source directory
find "$SOURCE" -type f | while read -r file; do
  # Get the relative path from source root
  rel_path="${file#$SOURCE/}"
  dest_path="$DEST/$rel_path"

  # Create the destination directory if needed
  mkdir -p "$(dirname "$dest_path")"

  # Create the hard link
  ln "$file" "$dest_path"
  echo "Linked: $file -> $dest_path"
done

echo "Done creating recursive hard links."
