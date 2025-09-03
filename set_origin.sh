#!/bin/bash

set -e

LIB_DIR="$1"

# Check if the provided directory exists
if [ ! -d "$LIB_DIR" ]; then
    echo "Error: Directory not found at '$LIB_DIR'"
    exit 1
fi

echo "Scanning for .so files in: $LIB_DIR"

find "$LIB_DIR" -maxdepth 1 -name "*.so*" -type f -print0 | while IFS= read -r -d $'\0' lib_file; do
    echo "Processing: $(basename "$lib_file")"
    
    # Set the RPATH to '$ORIGIN'. The single quotes are crucial
    # to prevent the shell from expanding $ORIGIN as a variable.
    patchelf --set-rpath '$ORIGIN' "$lib_file"
    
    echo "  -> RPATH set to '\$ORIGIN'"
done
