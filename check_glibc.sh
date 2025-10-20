#!/bin/bash

# Script to check GLIBC version requirements for binaries and libraries
# Usage: ./check_glibc.sh <directory>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory>"
    echo "Example: $0 ./x86_64"
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist"
    exit 1
fi

echo "Scanning binaries and libraries in: $TARGET_DIR"
echo "================================================"

# Find all ELF binaries and shared objects
find "$TARGET_DIR" -type f \( -name "*.so*" -o -executable \) | while read -r file; do
    # Check if it's an ELF file
    if file "$file" | grep -q "ELF"; then
        echo ""
        echo "File: $file"

        # Extract GLIBC version requirements
        objdump -T "$file" 2>/dev/null | grep -oP "GLIBC_\K[0-9.]+" | sort -V | uniq | while read -r version; do
            if [ -n "$version" ]; then
                echo "  Requires GLIBC_$version"
            fi
        done

        # Get the maximum GLIBC version
        max_version=$(objdump -T "$file" 2>/dev/null | grep -oP "GLIBC_\K[0-9.]+" | sort -V | tail -1)
        if [ -n "$max_version" ]; then
            echo "  Max GLIBC version: $max_version"
        fi
    fi
done

echo ""
echo "================================================"
echo "Summary - Finding maximum GLIBC version across all files:"

# Find global maximum GLIBC version
max_global=$(find "$TARGET_DIR" -type f \( -name "*.so*" -o -executable \) -exec sh -c '
    for file; do
        if file "$file" | grep -q "ELF"; then
            objdump -T "$file" 2>/dev/null | grep -oP "GLIBC_\K[0-9.]+"
        fi
    done
' sh {} + | sort -V | tail -1)

if [ -n "$max_global" ]; then
    echo "Maximum GLIBC version required: $max_global"
    echo ""
    echo "This means these binaries will run on systems with GLIBC >= $max_global"
    echo "Ubuntu 18.04 has GLIBC 2.27"
    echo "Ubuntu 20.04 has GLIBC 2.31"
    echo "Ubuntu 22.04 has GLIBC 2.35"
else
    echo "No GLIBC dependencies found (static binaries or no dependencies)"
fi
